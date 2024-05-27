package vct.col.ast.expr.heap.read

import vct.col.ast.{NdLength, TInt}
import vct.col.print._
import vct.col.ast.ops.NdLengthOps

trait NdLengthImpl[G] extends NdLengthOps[G] {
  this: NdLength[G] =>
  override def t: TInt[G] = TInt()

  override def precedence: Int = Precedence.ATOMIC
  override def layout(implicit ctx: Ctx): Doc =
    Group(Text("\\nd_length(") <> Doc.args(dimensions) <> ")")
}
