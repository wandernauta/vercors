package vct.col.newrewrite

import vct.col.ast._
import RewriteHelpers._
import vct.col.origin.Origin
import vct.col.util.AstBuildHelpers._
import vct.col.rewrite.{Generation, Rewriter, RewriterBuilder}

case object EvaluationTargetDummy extends RewriterBuilder {
  case object EvaluationOrigin extends Origin {
    override def preferredName: String = "evaluationDummy"
    override def messageInContext(message: String): String =
      s"[At variable generated for an evaluation]: $message"
  }
}

case class EvaluationTargetDummy[Pre <: Generation]() extends Rewriter[Pre] {
  import EvaluationTargetDummy._

  override def dispatch(stat: Statement[Pre]): Statement[Post] = stat match {
    case Eval(_: ProcedureInvocation[Pre] | _: MethodInvocation[Pre]) => rewriteDefault(stat)
    case Eval(other) =>
      val v = new Variable[Post](dispatch(other.t))(EvaluationOrigin)
      v.declareDefault(this)
      Assign(v.get(EvaluationOrigin), dispatch(other))(stat.o)
    case other => rewriteDefault(other)
  }
}
