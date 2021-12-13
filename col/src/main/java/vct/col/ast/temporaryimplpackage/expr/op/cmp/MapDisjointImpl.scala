package vct.col.ast.temporaryimplpackage.expr.op.cmp

import vct.col.ast.{MapDisjoint, TBool, Type}

trait MapDisjointImpl[G] { this: MapDisjoint[G] =>
  override def t: Type[G] = TBool()
}
