package vct.col.ast.temporaryimplpackage.expr.model

import vct.col.ast.{ModelNew, TModel, Type}

trait ModelNewImpl[G] { this: ModelNew[G] =>
  override def t: Type[G] = TModel(ref)
}