package vct.col.ast.expr.literal.build

import vct.col.ast.{OptNoneTyped, TOption, Type}
import vct.col.print.{Ctx, Doc, Group, Precedence, Text}
import vct.col.ast.ops.OptNoneTypedOps

trait OptNoneTypedImpl[G] extends OptNoneTypedOps[G] {
  this: OptNoneTyped[G] =>
  override def t: Type[G] = TOption(element)

  override def precedence: Int = Precedence.ATOMIC
  override def layout(implicit ctx: Ctx): Doc = Text("None")
}
