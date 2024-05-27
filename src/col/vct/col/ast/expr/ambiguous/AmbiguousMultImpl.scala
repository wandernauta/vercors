package vct.col.ast.expr.ambiguous

import vct.col.ast._
import vct.col.print.{Ctx, Doc, Precedence}
import vct.col.typerules.{CoercionUtils, Types}
import vct.col.ast.ops.AmbiguousMultOps

trait AmbiguousMultImpl[G] extends AmbiguousMultOps[G] {
  this: AmbiguousMult[G] =>
  override lazy val t: Type[G] =
    if (isVectorOp)
      Types.leastCommonSuperType(left.t, right.t)
    else if (isProcessOp)
      TProcess()
    else
      getNumericType

  override def precedence: Int = Precedence.MULTIPLICATIVE
  override def layout(implicit ctx: Ctx): Doc = lassoc(left, "*", right)
}
