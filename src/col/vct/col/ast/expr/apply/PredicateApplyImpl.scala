package vct.col.ast.expr.apply

import vct.col.ast.{PredicateApply, WritePerm}
import vct.col.print.{Ctx, Doc, DocUtil, Empty, Group, Precedence, Text}
import vct.col.ast.ops.PredicateApplyOps

trait PredicateApplyImpl[G] extends PredicateApplyOps[G] {
  this: PredicateApply[G] =>
  override def precedence: Int = Precedence.PREFIX

  def layoutSilver(implicit ctx: Ctx): Doc =
    Group(
      Text("acc(") <> ctx.name(ref) <> "(" <> Doc.args(args) <> "), " <> perm <>
        ")"
    )

  def layoutSpec(implicit ctx: Ctx): Doc =
    Group(
      if (!perm.isInstanceOf[WritePerm[G]])
        Text("[") <> perm <> "]" <> ctx.name(ref) <> "(" <> Doc.args(args) <>
          ")"
      else
        Text(ctx.name(ref)) <> "(" <> Doc.args(args) <> ")"
    )

  override def layout(implicit ctx: Ctx): Doc =
    ctx.syntax match {
      case Ctx.Silver => layoutSilver
      case _ => layoutSpec
    }
}
