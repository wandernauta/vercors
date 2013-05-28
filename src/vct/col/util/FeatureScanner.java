package vct.col.util;

import vct.col.ast.ASTClass;
import vct.col.ast.ASTNode;
import vct.col.ast.ParallelBlock;
import vct.col.ast.PrimitiveType.Sort;
import vct.col.ast.RecursiveVisitor;
import vct.col.ast.Type;

public class FeatureScanner extends RecursiveVisitor<Object> {

  public FeatureScanner(){
    super(null,null);
  }
  
  private boolean has_statics=false;
  private boolean has_dynamics=false;
  private boolean has_doubles=false;
  private boolean has_longs=false;
  private boolean has_inheritance=false;
  private boolean has_kernels=false;
  
  public boolean usesDoubles(){
    return has_doubles;
  }
  
  public boolean usesLongs(){
    return has_longs;
  }
  
  public boolean hasStaticItems(){
    return has_statics;
  }

  public boolean hasDynamicItems(){
    return has_dynamics;
  }
  
  public boolean usesInheritance(){
    return has_inheritance;
  }
  
  public boolean usesKernels(){
    return has_kernels;
  }

  public void pre_visit(ASTNode node){
    super.pre_visit(node);
    Type t=node.getType();
    if (t!=null){
      if (t.isDouble()) has_doubles=true;
      if (t.isPrimitive(Sort.Long)) has_longs=true;
    }
  }

  public void visit(ASTClass c) {
    if (c.super_classes.length > 0 || c.implemented_classes.length > 0) {
      Warning("detected inheritance");
      has_inheritance=true;
    }
    int N=c.getStaticCount();
    for(int i=0;i<N;i++){
      ASTNode node=c.getStatic(i);
      if (!(node instanceof ASTClass)) {
        has_statics=true;
      }
      node.accept(this);
    }    
    N=c.getDynamicCount();
    for(int i=0;i<N;i++){
      c.getDynamic(i).accept(this);
    }
  }
  
  public void visit(ParallelBlock pb){
    has_kernels=true;
    super.visit(pb);
  }

}
