package vct.col.rewrite

import hre.util.ScopedStack
import vct.col.ast._
import vct.col.rewrite.CheckContractSatisfiability.{AssertPassedNontrivialUnsatisfiable, CheckSatOrigin, NotWellFormedIgnoreCheckSat}
import vct.col.rewrite.util.Extract
import vct.col.origin.{Blame, Context, ExpectedError, ExpectedErrorFailure, ExpectedErrorNotTripped, ExpectedErrorTrippedTwice, FilterExpectedErrorBlame, InlineContext, NontrivialUnsatisfiable, Origin, PanicBlame, PreferredName, ShortPosition, UnsafeDontCare, VerificationFailure}
import vct.col.rewrite.{Generation, Rewriter, RewriterBuilder, RewriterBuilderArg}
import vct.col.util.AstBuildHelpers.{ff, foldStar, procedure, unfoldStar}

import scala.collection.mutable.ArrayBuffer

case object CheckContractSatisfiability extends RewriterBuilderArg[Boolean] {
  override def key: String = "checkSat"
  override def desc: String =
    "Prove that contracts are not internally contradictory (i.e. unsatisfiable) for methods and other contract bearers, " +
      "except for the contract `false`."

  private def CheckSatOrigin(inner: Origin, n: Option[String]): Origin = Origin(
    Seq(
      PreferredName("check_sat_" + n.getOrElse(inner.getPreferredName.get.preferredName)),
      Context(inner.getContext.get.context),
      InlineContext(inner.getInlineContext.get.inlineContext),
      ShortPosition(inner.getShortPosition.get.shortPosition),
    )
  )
  case class AssertPassedNontrivialUnsatisfiable(contract: ApplicableContract[_]) extends Blame[ExpectedErrorFailure] {
    override def blame(error: ExpectedErrorFailure): Unit = error match {
      case _: ExpectedErrorTrippedTwice =>
        // Ignore: Carbon may report the assert failed, even when the contract is not well-formed.
      case ExpectedErrorNotTripped(_) =>
        contract.blame.blame(NontrivialUnsatisfiable(contract))
    }
  }

  case class NotWellFormedIgnoreCheckSat(err: ExpectedError) extends Blame[VerificationFailure] {
    override def blame(error: VerificationFailure): Unit =
      err.trip(error)
  }
}

case class CheckContractSatisfiability[Pre <: Generation](doCheck: Boolean = true) extends Rewriter[Pre] {
  val expectedErrors: ScopedStack[ArrayBuffer[ExpectedError]] = ScopedStack[ArrayBuffer[ExpectedError]]()
  val wellFormednessBlame: ScopedStack[Blame[VerificationFailure]] = ScopedStack()

  override def dispatch[T <: VerificationFailure](blame: Blame[T]): Blame[T] =
    wellFormednessBlame.topOption.getOrElse(blame)

  def splitAccountedPredicate(pred: AccountedPredicate[Pre]): Seq[Expr[Pre]] = pred match {
    case UnitAccountedPredicate(pred) => unfoldStar(pred)
    case SplitAccountedPredicate(left, right) => splitAccountedPredicate(left) ++ splitAccountedPredicate(right)
  }

  def checkSatisfiability(contract: ApplicableContract[Pre], n: Option[String]): Unit = {
    implicit val origin: Origin = CheckSatOrigin(contract.o, n)
    foldStar(splitAccountedPredicate(contract.requires)) match {
      case BooleanValue(false) =>
        // Assume the contract is not intended to be satisfiable
      case pred =>
        val err = ExpectedError("assertFailed:false", origin, AssertPassedNontrivialUnsatisfiable(contract))
        val onlyAssertBlame = FilterExpectedErrorBlame(PanicBlame("A boolean assert can only report assertFailed:false"), err)
        expectedErrors.top += err
        val extractObj = Extract[Pre]()
        val result = extractObj.extract(pred)
        val extractObj.Data(ts, in, _, _, _) = extractObj.finish()
        variables.scope {
          globalDeclarations.declare(procedure(
            blame = PanicBlame("The postcondition of a method checking satisfiability is empty"),
            contractBlame = UnsafeDontCare.Satisfiability("the precondition of a check-sat method is only there to check it."),
            requires = UnitAccountedPredicate(
              wellFormednessBlame.having(NotWellFormedIgnoreCheckSat(err)) {
                dispatch(result)
              }
            )(result.o),
            typeArgs = variables.dispatch(ts.keys),
            args = variables.dispatch(in.keys),
            body = Some(Scope[Post](Nil, Assert(ff)(onlyAssertBlame)))
          ))
        }
    }
  }

  override def dispatch(verification: Verification[Pre]): Verification[Post] = {
    val (errs, tasks) = expectedErrors.collect {
      verification.tasks.map(dispatch)
    }
    // PB: Important: the expected errors from this pass must appear before other errors, since the absence of an assert
    // failure from this pass may in turn indicate an expected "unsatisfiable" error from an earlier pass.
    Verification(tasks, errs ++ verification.expectedErrors)(verification.o)
  }

  val name: ScopedStack[String] = ScopedStack()

  override def dispatch(decl: Declaration[Pre]): Unit =
    name.having(decl.o.getPreferredName.get.preferredName) {
      super.dispatch(decl)
    }

  override def dispatch(contract: ApplicableContract[Pre]): ApplicableContract[Post] = {
    if(doCheck) checkSatisfiability(contract, name.topOption)
    rewriteDefault(contract)
  }
}