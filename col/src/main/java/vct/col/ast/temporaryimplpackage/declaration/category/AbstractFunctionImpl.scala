package vct.col.ast.temporaryimplpackage.declaration.category

import vct.col.ast.{AbstractFunction, Expr}
import vct.col.check.{CheckContext, CheckError}

trait AbstractFunctionImpl[G] extends ContractApplicableImpl[G] { this: AbstractFunction[G] =>
  override def body: Option[Expr[G]]
  override def check(context: CheckContext[G]): Seq[CheckError] =
    body.toSeq.flatMap(_.checkSubType(returnType))
}
