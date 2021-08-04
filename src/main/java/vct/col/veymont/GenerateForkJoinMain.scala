package vct.col.veymont

import hre.ast.MessageOrigin
import vct.col.ast.`type`.{ClassType, PrimitiveSort}
import vct.col.ast.expr.NameExpression
import vct.col.ast.stmt.decl.Method.Kind
import vct.col.ast.stmt.decl._
import vct.col.ast.util.{AbstractRewriter, ContractBuilder}
import vct.col.veymont.Util._
import scala.jdk.CollectionConverters._

class GenerateForkJoinMain(override val source: ProgramUnit)  extends AbstractRewriter(null, true) {


  def addStartThreadClass() : ProgramUnit = {
    val threads = source.asScala.collect {
      case c: ASTClass if isThreadClassName(c.name) => c
    }
    target.add(getStartThreadClass(threads.toSet,StructureCheck.getMainClass(source)))
    rewriteAll()
  }

  private def getStartThreadClass(threads : Set[ASTClass],mainClass : ASTClass) = {
    val mainFJClass = create.new_class(localMainClassName,null,null)
    val mainFJContract = mainClass.methods().asScala.find(_.name == Util.mainMethodName).get.getContract
    val threadsConstr = threads.map(_.methods().asScala.find(_.kind== Kind.Constructor).get)
    val chansVars = threadsConstr.flatMap(getConstrChanArgs).map(getChanVar).toArray
    val barrierVar = getBarrierVar(threads.size)
    val threadVars = threads.map(t => getThreadVar(t)).toArray
    val threadForks = threads.map(t => getThreadRunning(t.name, true)).toArray
    val threadJoins = threads.map(t => getThreadRunning(t.name, false)).toArray
    val mainFJArgs = threadsConstr.map(getConstrRoleArgs).reduce((a,b) => a ++ b) : Array[DeclarationStatement]
    val body = create.block(new MessageOrigin("Generated block of run method in Main class"),
      (barrierVar +: (chansVars ++ threadVars ++ threadForks ++ threadJoins)):_*)
    val mainMethod = create.method_decl(create.primitive_type(PrimitiveSort.Void),rewrite(mainFJContract),
      localMainMethodName,mainFJArgs,body)
    mainFJClass.add_static(mainMethod)
    mainFJClass
  }

  override def visit(c : ASTClass) = {
    if(c.name != Util.mainClassName) //remove Main class
      super.visit(c)
  }

  private def getBarrierVar(nrThreads : Int) : DeclarationStatement =
    create.field_decl(new MessageOrigin("Generated Barrier variable"),barrierFieldName,getBarrierClass,
      create.invokation(null,getBarrierClass,Method.JavaConstructor,create.constant(nrThreads)))

  private def getConstrChanArgs(constr : Method) : Array[DeclarationStatement] =
    constr.getArgs.filter(_.`type` match {
      case cl : ClassType => isChannelClass(cl.getName)
      case _ => false
    })

  private def getConstrRoleArgs(constr : Method) : Array[DeclarationStatement] =
    constr.getArgs.filter(_.`type` match {
      case cl : ClassType => !isChannelClass(cl.getName) && cl.getName != barrierClassName
      case _ => true
    })

  private def getChanVar(chanArg : DeclarationStatement) : DeclarationStatement = {
    val chanType = create.class_type(chanArg.`type`.toString)
    create.field_decl(new MessageOrigin("Generated Channel variable"),unArgName(chanArg.name),chanType,
      create.invokation(null,chanType,Method.JavaConstructor))
  }

  private def getThreadVar(thread : ASTClass) : DeclarationStatement = {
    val constr = thread.methods().asScala.find(_.kind== Kind.Constructor).get
    val chans = getConstrChanArgs(constr).map(a => unArgName(a.name)) : Array[String]
    val chanArgs = chans.map(chan => create.local_name(new MessageOrigin("Generated argument for calling constructor " + thread.name),chan))
    val barArg = create.local_name(new MessageOrigin("Generated argument for calling constructor " + thread.name), barrierFieldName) : NameExpression
    val roleArgs = getConstrRoleArgs(constr).map(a => create.local_name(new MessageOrigin("Generated argument for calling constructor " + thread.name),a.name)) : Array[NameExpression]
    val args : Array[NameExpression] = chanArgs  ++ (barArg +: roleArgs) : Array[NameExpression]
    create.field_decl(new MessageOrigin("Generated Thread variable"),getRoleName(thread.name),new ClassType(thread.name),
      create.invokation(null,new ClassType(thread.name),Method.JavaConstructor,args:_*))
  }

  private def getThreadRunning(threadClassName : String, isFork : Boolean) : ASTSpecial = {
    create.special(if(isFork) ASTSpecial.Kind.Fork else ASTSpecial.Kind.Join,
      create.local_name(new MessageOrigin("Generated argument for forking or joining"),getRoleName(threadClassName)))
  }
}
