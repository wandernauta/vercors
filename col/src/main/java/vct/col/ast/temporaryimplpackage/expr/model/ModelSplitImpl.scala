package vct.col.ast.temporaryimplpackage.expr.model

import vct.col.ast.{ModelSplit, TVoid, Type}

trait ModelSplitImpl[G] { this: ModelSplit[G] =>
  override def t: Type[G] = TVoid()
}