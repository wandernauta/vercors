#lang clotho

(require xsmith xsmith/app xsmith/canned-components racr racket/string)

(define-basic-spec-component mini)
(add-basic-statements mini #:ProgramWithBlock #t #:ExpressionStatement #t #:AssignmentStatement #t #:IfElseStatement #t)
(add-basic-expressions mini #:Booleans #t #:Numbers #t #:VariableReference #t #:IfExpression #t #:Strings #t)

(define object-type (base-type 'object))
;(define frac-type (base-type 'frac))

(define resource-type (base-type 'resource))
(define label-type (base-type 'label))
(define seq-type (base-type 'seq))
(define set-type (base-type 'set))
(define bag-type (base-type 'bag))
(define option-type (base-type 'option))

(define no-child-types (λ (n t) (hash)))
(define numeric-bin-op-subtype
  (λ (n t)
    (hash 'l t 'r t)))
(define (render-children sym n)
  (map (λ (cn) (att-value 'xsmith_render-node cn))
       (ast-children (ast-child sym n))))
(define (render-child sym n)
  (att-value 'xsmith_render-node (ast-child sym n)))

(add-to-grammar
 mini
 [Program ProgramWithBlock (Contract)]
 [Contract #f ([clauses : ContractClause * = (add1 (random 5))])]
 [ContractClause #f () #:prop may-be-generated #f]
 [SpecExpression #f () #:prop may-be-generated #f]
 [Null Expression ()]
 [Assert Statement (SpecExpression)]
 [Assume Statement (SpecExpression)]
 [Refute Statement (SpecExpression)]
 [SpecNormalExpression SpecExpression (Expression) #:prop wont-over-deepen #t]
 ;[OldExpression SpecExpression (Expression)]
 [Requires ContractClause (SpecExpression)]
 ;[SepAnd Expression ([l : Expression] [r : Expression])]
 [Modulo Expression ([l : Expression] [r : Expression])]
 ;[Frac Expression ([l : Expression] [r : Expression])]
 [Implies Expression ([l : Expression] [r : Expression])] ; TODO
 ;[Power Expression ([l : Expression] [r : Expression])]
 [Ensures ContractClause (SpecExpression)]
 [Context ContractClause (SpecExpression)]
 [Lock Statement (Expression)]
 [Unlock Statement (Expression)]
 [SeqLiteral Expression ()]
 [SetLiteral Expression ()]
 [BagLiteral Expression ()]
 [SeqLength Expression (Expression)]
 [SetLength Expression (Expression)]
 [BagLength Expression (Expression)]
 [SeqCompare Expression ([l : Expression] [r : Expression])]
 [SetCompare Expression ([l : Expression] [r : Expression])]
 [BagCompare Expression ([l : Expression] [r : Expression])]
 [None Expression ()]
 [Some Expression (Expression) #:prop wont-over-deepen #t]
 [OptionCompare Expression ([l : Expression] [r : Expression])]
 [ContextEverywhere ContractClause (SpecExpression)]
 [WhileStatement Statement (Expression Block) #:prop block-user? #t]
 ;[Goto Statement (VariableReference)]
 )

(add-property
 mini
 type-info
 [Program [(fresh-type-variable)
                      (λ (n t)
                        (hash 'definitions (λ (c) (fresh-type-variable))
                              'Contract void-type
                              'Block (λ (c) no-return-type)))]]
 [Requires [void-type (lambda (n t) (hash 'SpecExpression bool-type))]]
 [Ensures [void-type (lambda (n t) (hash 'SpecExpression bool-type))]]
 [Context [void-type (lambda (n t) (hash 'SpecExpression bool-type))]]
 [ContextEverywhere [void-type (lambda (n t) (hash 'SpecExpression bool-type))]]
 [Modulo [number-type numeric-bin-op-subtype]]
 [Assert [void-type (lambda (n t) (hash 'SpecExpression bool-type))]]
 [Assume [void-type (lambda (n t) (hash 'SpecExpression bool-type))]]
 [Refute [void-type (lambda (n t) (hash 'SpecExpression bool-type))]]
 [Lock [void-type (lambda (n t) (hash 'Expression t))]]
 [Unlock [void-type (lambda (n t) (hash 'Expression t))]]
 [SeqLiteral [seq-type no-child-types]]
 [SetLiteral [set-type no-child-types]]
 [BagLiteral [bag-type no-child-types]]
 [None [option-type no-child-types]]
 [Some [option-type (lambda (n t) (hash 'Expression int-type))]]
 [OptionCompare [bool-type (lambda (n t) (hash 'l option-type 'r option-type))]]
 [SeqCompare [bool-type (lambda (n t) (hash 'l seq-type 'r seq-type))]]
 [SetCompare [bool-type (lambda (n t) (hash 'l set-type 'r set-type))]]
 [BagCompare [bool-type (lambda (n t) (hash 'l bag-type 'r bag-type))]]
 [SeqLength [int-type (lambda (n t) (hash 'Expression seq-type))]]
 [SetLength [int-type (lambda (n t) (hash 'Expression set-type))]]
 [BagLength [int-type (lambda (n t) (hash 'Expression bag-type))]]
 ;[Frac [frac-type numeric-bin-op-subtype]]
 [Implies [bool-type (lambda (n t) (hash 'l bool-type 'r bool-type))]]
 ;[SepAnd [resource-type (lambda (n t) (hash 'l resource-type 'r resource-type))]]
 [Null [object-type no-child-types]]
 ;[Power [number-type numeric-bin-op-subtype]]
 [SpecNormalExpression [(fresh-type-variable) (lambda (n t) (hash 'Expression t))]]
 ;[OldExpression [(fresh-type-variable) (lambda (n t) (hash 'Expression t))]]
 [Contract [void-type (lambda (n t) (hash 'clauses t))]]
 [WhileStatement [(fresh-maybe-return-type) (lambda (n t) (hash 'Expression bool-type 'Block t))]] ; TODO contract
 ;[GotoStatement [(fresh-maybe-return-type) (lambda (n t) (hash 'VariableReference label-type))]]
 )

(define (base-type->string t)
      (pvl-type-name
       (base-type-name t)))
(define (type->string t*)
  (define t (concretize-type t*))
  (cond [(base-type? t) (base-type->string t)]
        [(nominal-record-type? t)
         (format "struct ~a" (nominal-record-type-name t))]
        [else (error 'type->string "not yet implemented for type ~a" t)]))

 (define (pvl-type-name t)
   (cond
     [(eq? t 'bool) "bool"]
     [(eq? t 'resource) "resource"]
     [(eq? t 'number) "int"] ; TODO
     [(eq? t 'int) "int"]
     [(eq? t 'seq) "seq<int>"]
     [(eq? t 'set) "set<int>"]
     [(eq? t 'bag) "bag<int>"]
     [(eq? t 'option) "option<int>"]
     [(eq? t 'string) "string"]
     ;[(eq? t 'frac) "frac"]
     [(eq? t 'object) "Example"] ; TODO
     ;[(eq? t 'label) "label"]
     [else (error "Don't know how to render" t)]))

(define (perms xs)
  (string-join (map (lambda (x) (format "context Perm(~a, write);" (ast-child 'name x))) xs) " "))

(define (inits xs)
  (string-join (map (lambda (x) (format "~a = ~a;" (ast-child 'name x) (render-child 'Expression x))) xs) " "))

(add-property
  mini
  render-node-info
  [Program (lambda (n) (format "class Example { ~a ~a ~a void example() { ~a ~a } }" (string-join (render-children 'definitions n) " ") (perms (ast-children (ast-child 'definitions n))) (render-child 'Contract n) (inits (ast-children (ast-child 'definitions n))) (render-child 'Block n)))]
  [Block (lambda (n) (format "{ ~a ~a }" (string-join (render-children 'definitions n) " ") (string-join (render-children 'statements n) " ")))]
  [Contract (lambda (n) (format "~a" (string-join (render-children 'clauses n) " ")))]
  [ExpressionStatement (lambda (n) (format "~a;" (render-child 'Expression n)))]
  [Or (lambda (n) (format "(~a || ~a)" (render-child 'l n) (render-child 'r n)))]
  [And (lambda (n) (format "(~a && ~a)" (render-child 'l n) (render-child 'r n)))]
  ;[SepAnd (lambda (n) (format "(~a ** ~a)" (render-child 'l n) (render-child 'r n)))]
  [Not (lambda (n) (format "!(~a)" (render-child 'Expression n)))]
  [Definition (lambda (n) (format "~a ~a;" (type->string (ast-child 'type n)) (ast-child 'name n)))] ; TODO
  [BoolLiteral (lambda (n) (if (ast-child 'v n) "true" "false"))]
  [Null (lambda (n) "(null)")]
  [None (lambda (n) "(None)")]
  [Some (lambda (n) (format "(Some(~a))" (render-child 'Expression n)))]
  [OptionCompare (lambda (n) (format "(~a == ~a)" (render-child 'l n) (render-child 'r n)))]
  [SeqCompare (lambda (n) (format "(~a == ~a)" (render-child 'l n) (render-child 'r n)))]
  [SetCompare (lambda (n) (format "(~a == ~a)" (render-child 'l n) (render-child 'r n)))]
  [BagCompare (lambda (n) (format "(~a == ~a)" (render-child 'l n) (render-child 'r n)))]
  [SpecExpression (lambda (n) (render-child 'Expression n))]
  [Requires (lambda (n) (format "requires ~a;" (render-child 'SpecExpression n)))]
  [Ensures (lambda (n) (format "ensures ~a;" (render-child 'SpecExpression n)))]
  ;[Goto (lambda (n) (format "goto ~a;" (render-child 'VariableReference n)))]
  [Context (lambda (n) (format "context ~a;" (render-child 'SpecExpression n)))]
  [ContextEverywhere (lambda (n) (format "context_everywhere ~a;" (render-child 'SpecExpression n)))]
  [GreaterThan (lambda (n) (format "(~a > ~a)" (render-child 'l n) (render-child 'r n)))]
  [LessThan (lambda (n) (format "(~a < ~a)" (render-child 'l n) (render-child 'r n)))]
  [Plus (lambda (n) (format "(~a + ~a)" (render-child 'l n) (render-child 'r n)))]
  [Minus (lambda (n) (format "(~a - ~a)" (render-child 'l n) (render-child 'r n)))]
  [Times (lambda (n) (format "(~a * ~a)" (render-child 'l n) (render-child 'r n)))]
  [Modulo (lambda (n) (format "(~a % ~a)" (render-child 'l n) (render-child 'r n)))]
  [Assert (lambda (n) (format "assert ~a;" (render-child 'SpecExpression n)))]
  [Assume (lambda (n) (format "assume ~a;" (render-child 'SpecExpression n)))]
  [Refute (lambda (n) (format "refute ~a;" (render-child 'SpecExpression n)))]
  [Lock (lambda (n) (format "lock ~a;" (render-child 'Expression n)))]
  [Unlock (lambda (n) (format "unlock ~a;" (render-child 'Expression n)))]
  ;[Frac (lambda (n) (format "(~a \\ ~a)" (render-child 'l n) (render-child 'r n)))]
  [Implies (lambda (n) (format "(~a ==> ~a)" (render-child 'l n) (render-child 'r n)))]
  ;[Power (lambda (n) (format "(~a ^^ ~a)" (render-child 'l n) (render-child 'r n)))]
  ;[OldExpression (lambda (n) (format "\\old(~a)" (render-child 'Expression n)))]
  [SafeDivide (lambda (n) (format "(~a / ~a)" (render-child 'l n) (render-child 'r n)))]
  [IfElseStatement (lambda (n) (format "if (~a) ~a else ~a" (render-child 'test n) (render-child 'then n) (render-child 'else n)))]
  [WhileStatement (lambda (n) (format "while (~a) ~a" (render-child 'Expression n) (render-child 'Block n)))]
  [IntLiteral (lambda (n) (number->string (ast-child 'v n)))]
  [StringLiteral (lambda (n) (format "~s" (ast-child 'v n)))]
  [StringAppend (lambda (n) (format "(~a + ~a)" (render-child 'l n) (render-child 'r n)))]
  [StringLength (lambda (n) "0")] ; TODO
  [SeqLiteral (lambda (n) "([t: int])")] ; TODO
  [SetLiteral (lambda (n) "({t: int})")] ; TODO
  [BagLiteral (lambda (n) "(b{t: int})")] ; TODO
  [SeqLength (lambda (n) (format "(|~a|)" (render-child 'Expression n)))]
  [SetLength (lambda (n) (format "(|~a|)" (render-child 'Expression n)))]
  [BagLength (lambda (n) (format "(|~a|)" (render-child 'Expression n)))]
  [AssignmentStatement (lambda (n) (format "~a = ~a;" (ast-child 'name n) (render-child 'Expression n)))]
  [VariableReference (lambda (n) (format "~a" (ast-child 'name n)))]
  [IfExpression (lambda (n) (format "(~a ? ~a : ~a)" (render-child 'test n) (render-child 'then n) (render-child 'else n)))]
  )

(add-property
 mini
 feature
 [WhileStatement while])

(define-xsmith-interface-functions
  [mini]
  #:program-node Program
  #:type-thunks (list (lambda () bool-type) (lambda () int-type) (lambda () seq-type))
  #:features [[while #t]]
  #:comment-wrap (lambda (lines) (format "/* ~a */\n" lines)))
 
(module+ main (mini-command-line))
