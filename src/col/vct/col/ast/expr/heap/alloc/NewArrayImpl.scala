package vct.col.ast.expr.heap.alloc

import hre.util.FuncTools
import vct.col.ast.{NewArray, TArray, Type}
import vct.col.print._
import vct.col.print.Doc.concat
import vct.col.ast.ops.NewArrayOps

trait NewArrayImpl[G] extends NewArrayOps[G] {
  this: NewArray[G] =>
  override lazy val t: Type[G] = FuncTools
    .repeat[Type[G]](TArray(_), dims.size + moreDims, element)

  override def precedence: Int = Precedence.POSTFIX
  override def layout(implicit ctx: Ctx): Doc =
    Text("new") <+> element <> concat(dims.map(Text("[") <> _ <> "]")) <>
      "[]".repeat(moreDims)
}
