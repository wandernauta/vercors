package vct.parsers.transform

import org.antlr.v4.runtime.ParserRuleContext
import vct.col.ast._
import vct.col.origin._
import vct.col.util.{AstBuildHelpers, ExpectedError}
import vct.parsers.ParseError

import scala.annotation.nowarn
import scala.collection.mutable
import scala.reflect.ClassTag

@nowarn("msg=match may not be exhaustive&msg=Some\\(")
abstract class ToCol[G](val originProvider: OriginProvider, val blameProvider: BlameProvider, val errors: mutable.Map[(Int, Int), String]) {
  class ContractCollector[G1]() {
    val modifies: mutable.ArrayBuffer[(ParserRuleContext, String)] = mutable.ArrayBuffer()
    val accessible: mutable.ArrayBuffer[(ParserRuleContext, String)] = mutable.ArrayBuffer()
    val signals: mutable.ArrayBuffer[(ParserRuleContext, SignalsClause[G1])] = mutable.ArrayBuffer()

    val requires: mutable.ArrayBuffer[(ParserRuleContext, Expr[G1])] = mutable.ArrayBuffer()
    val ensures: mutable.ArrayBuffer[(ParserRuleContext, Expr[G1])] = mutable.ArrayBuffer()
    val context_everywhere: mutable.ArrayBuffer[(ParserRuleContext, Expr[G1])] = mutable.ArrayBuffer()
    val kernel_invariant: mutable.ArrayBuffer[(ParserRuleContext, Expr[G1])] = mutable.ArrayBuffer()
    val lock_invariant: mutable.ArrayBuffer[(ParserRuleContext, Expr[G1])] = mutable.ArrayBuffer()

    val given: mutable.ArrayBuffer[(ParserRuleContext, Variable[G1])] = mutable.ArrayBuffer()
    val yields: mutable.ArrayBuffer[(ParserRuleContext, Variable[G1])] = mutable.ArrayBuffer()

    val loop_invariant: mutable.ArrayBuffer[(ParserRuleContext, Expr[G1])] = mutable.ArrayBuffer()

    def consume[T](buffer: mutable.ArrayBuffer[(ParserRuleContext, T)]): Seq[T] = {
      val result = buffer.map(_._2)
      buffer.clear()
      result.toSeq
    }

    def consumeApplicableContract()(implicit o: Origin): ApplicableContract[G1] = {
      ApplicableContract(AstBuildHelpers.foldStar(consume(requires)), AstBuildHelpers.foldStar(consume(ensures)),
                         AstBuildHelpers.foldStar(consume(context_everywhere)),
                         consume(signals), consume(given), consume(yields))
    }

    def consumeLoopContract()(implicit o: Origin): LoopContract[G1] = {
      if(requires.nonEmpty) IterationContract(AstBuildHelpers.foldStar(consume(requires)), AstBuildHelpers.foldStar(consume(ensures)))
      else LoopInvariant(AstBuildHelpers.foldStar(consume(loop_invariant)))
    }

    def nodes: Seq[ParserRuleContext] = Seq(
      modifies, accessible, signals,
      requires, ensures, context_everywhere, kernel_invariant,
      given, yields, loop_invariant,
    ).flatMap(_.map(_._1))
  }

  class ModifierCollector() {
    val pure: mutable.ArrayBuffer[ParserRuleContext] = mutable.ArrayBuffer()
    val inline: mutable.ArrayBuffer[ParserRuleContext] = mutable.ArrayBuffer()
    val threadLocal: mutable.ArrayBuffer[ParserRuleContext] = mutable.ArrayBuffer()
    val static: mutable.ArrayBuffer[ParserRuleContext] = mutable.ArrayBuffer()

    def consume(buffer: mutable.ArrayBuffer[ParserRuleContext]): Boolean = {
      val result = buffer.nonEmpty
      buffer.clear()
      result
    }

    def nodes: Seq[ParserRuleContext] = Seq(pure, inline, threadLocal, static).flatten
  }

  implicit def origin(implicit node: ParserRuleContext): Origin = originProvider(node)

  def blame(implicit node: ParserRuleContext): Blame[VerificationFailure] =
    errors.keys.find { case (from, to) => node.start.getTokenIndex >= from && node.stop.getTokenIndex <= to } match {
      case Some(key) =>
        val code = errors.remove(key).get
        ExpectedError(code, blameProvider(node))
      case None =>
        blameProvider(node)
    }

  def convertList[Input, Append <: Input, Singleton <: Input, Element]
                 (extractSingle: Singleton => Option[Element], extractAppend: Append => Option[(Input, Element)])
                 (input: Input)
                 (implicit singleTag: ClassTag[Singleton], appendTag: ClassTag[Append]): Seq[Element] =
    input match {
      case single: Singleton => Seq(extractSingle(single).get)
      case append: Append => extractAppend(append).get match {
        case (input, element) => convertList(extractSingle, extractAppend)(input) :+ element
      }
    }

  def getOrFail[B](node: ParserRuleContext, thing: Either[String, B]): B = thing match {
    case Left(err) => fail(node, err)
    case Right(good) => good
  }

  def getOrFail[B](node: ParserRuleContext, thing: Option[B], message: String): B = thing match {
    case None => fail(node, message)
    case Some(b) => b
  }

  def failIfDefined[T <: ParserRuleContext](node: Option[T], format: String): Unit = node match {
    case Some(node) => fail(node, format)
    case None => // do nothing
  }

  def fail(tree: ParserRuleContext, message: String): Nothing = {
    throw ParseError(originProvider(tree), message)
  }

  /**
   * Print notice and exit, because a rule is unimplemented in the conversion to COL. Named after the scala
   * "unimplemented" method, [[???]]
   */
  def ??(tree: ParserRuleContext): Nothing = {
    fail(tree, f"This construct (${tree.getClass.getSimpleName}) is syntactically valid, but not supported by VerCors.")
  }
}
