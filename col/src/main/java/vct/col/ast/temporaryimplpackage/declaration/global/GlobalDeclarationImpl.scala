package vct.col.ast.temporaryimplpackage.declaration.global

import vct.col.ast.GlobalDeclaration
import vct.col.rewrite.ScopeContext

trait GlobalDeclarationImpl[G] { this: GlobalDeclaration[G] =>
  override def declareDefault[Pre](scope: ScopeContext[Pre, G]): Unit = scope.globalScopes.top += this
}