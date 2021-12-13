package vct.col.ast.temporaryimplpackage.expr.literal.build

import vct.col.ast.{Range, TInt, TSeq, Type}

trait RangeImpl[G] { this: Range[G] =>
  override def t: Type[G] = TSeq(TInt())
}