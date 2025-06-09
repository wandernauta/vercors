grammar llvm;

@header {
specLevel = 1
}

/*
@parser::members {
    public int specLevel = 1;
}
*/

unit: 'define i1 @example() ' '!VC.contract !{ ' ('!"' valContractClause '", ')+ ' !"" } { ret i1 0 } ';

langExpr: expression;
langId: Identifier;
langConstInt: IntegerConstant;
langType: type;
langStatement: EOF EOF;
langStatic: EOF EOF;
langGlobalDecl: EOF EOF;
langClassDecl: EOF EOF;
specTrue: 'true';
specFalse: 'false';

//startSpec: StartSpec {global specLevel
//specLevel += 1};
//endSpec: EndSpec {global specLevel
//specLevel -= 1};

expression
    : instruction
    | constant
    | identifier
    | valExpr
    | <assoc=right> expression valImpOp expression
    ;

instruction
    : binOpInstruction # binOpRule
    | compareInstruction # cmpOpRule
    | callInstruction # callOpRule
    | branchInstruction #brOpRule
    ;

constant
    : booleanConstant # boolConstRule
    | integerConstant # intConstRule
    ;

type
    : T_int # t_intRule
    | T_bool # t_boolRule
    ;

booleanConstant
    : constTrue # constTrue
    | constFalse # constFalse
    ;

integerConstant: IntegerConstant;

identifier: Identifier;

expressionList
    : expression
    | expression Comma expressionList
    ;

binOpInstruction: binOp Lparen expression Comma expression Rparen;

compareInstruction: compOp Lparen compPred Comma expression Comma expression Rparen;

callInstruction: CALL Identifier Lparen expressionList Rparen;

branchInstruction: BR Lparen expression Comma expression Comma expression Rparen;

binOp
    : ADD # add
    | SUB # sub
    | MUL # mul
    | UDIV # udiv
    | SDIV # sdiv
    | AND # and
    | OR # or
    | XOR # xor
    ;


compOp
    : ICMP
    ; // FCMP at some point

compPred
    : EQ_pred  # eq
    | NE_pred  # ne
    | UGT_pred # ugt
    | UGE_pred # uge
    | ULT_pred # ult
    | ULE_pred # ule
    | SGT_pred # sgt
    | SGE_pred # sge
    | SLT_pred # slt
    | SLE_pred # sle
    ;

/*
@lexer::members {
    private static boolean inBlockSpec = false;
    private static boolean inLineSpec = false;
}

channels {
  EXPECTED_ERROR_CHANNEL
}
*/

// mandatory tokens
SEMI: ';';
BLOCK_OPEN: '{';
BLOCK_CLOSE: '}';
BRACK_OPEN: '[';
BRACK_CLOSE: ']';
ANGLE_OPEN: '<';
ANGLE_CLOSE: '>';
EQ: '=';
EQUALS: '==';
EXCL: '!';
STAR: '*';
PIPE: '|';
PLUS: '+';
COLON: ':';
VAL_INLINE: 'inline';
VAL_ASSERT: 'assert';
VAL_PACKAGE: 'package';
CONS: '::';

INC: '++';
ARROW: '->';
DOT: '.';


// misc characters
Percent : '%';
AtSign : '@';
Sign    : '-';
Lparen  : '(';
Rparen  : ')';
Comma   : ',';

// useless stuff but neccesary i guess
EndSpec: '"}';
StartSpec: '!VC.contract !{"';

// identifiers

Digit: [0-9];

Identifier: NamedIdentifier | UnnamedIdentifier;

NamedIdentifier: [%@][-a-zA-Z$._][-a-zA-Z$._0-9]*;

UnnamedIdentifier: [%@]Digit+;

constTrue: 'true';
constFalse: 'false';

IntegerConstant : Sign?Digit+;

Whitespace
    :   [ \t]+
        -> skip
    ;
Newline
    :   (   '\r' '\n'?
        |   '\n'
        )
        -> skip
    ;

// operators
// operators -> binops
ADD: 'add';
SUB: 'sub';
MUL: 'mul';
UDIV: 'udiv';
SDIV: 'sdiv';
// bitwise
AND: 'and';
OR: 'or';
XOR: 'xor';

// operators -> other
ICMP: 'icmp';
CALL: 'call';

// operators -> termops
BR: 'br';

// compare predicates
EQ_pred: 'eq';
NE_pred: 'ne';
UGT_pred: 'ugt';
UGE_pred: 'uge';
ULT_pred: 'ult';
ULE_pred: 'ule';
SGT_pred: 'sgt';
SGE_pred: 'sge';
SLT_pred: 'slt';
SLE_pred: 'sle';

// typing
T_int: 'i'[2-9]Digit*;
T_bool: 'i1';

/**
 imported grammar rules
   langExpr
   langConstInt
   langId
   langType
   langModifier
   langStatement
   startSpec - the rule entering the lexer into specification mode
   endSpec - the rule exiting the lexer from specification mode
 exported grammar rules for PVL
   valContractClause        - contract clause
   valStatement             - proof guiding statement
   valWithThen              - with/then statement to use given/yields ghost arguments
   valReserved              - reserved identifiers
 exported grammar rules for other languages
   valEmbedContract         - sequence of contract clauses embedded in sequence of comments
   valEmbedContractBlock    - sequence of contract clauses embedded in one comment
   valEmbedStatementBlock   - sequence of valStatements embedded in a comment
   valEmbedWithThenBlock    - with and/or then in one comment
   valEmbedWithThen         - with and/or then in a sequence of comments
 */

valExpressionList
 : langExpr
 | langExpr ',' valExpressionList
 ;

valIdList
 : langId
 | langId ',' valIdList
 ;

valTypeList
 : langType
 | langType ',' valTypeList
 ;

valContractClause
 : 'modifies' valIdList ';'
 | 'accessible' valIdList ';'
 | 'requires' langExpr ';'
 | 'ensures' langExpr ';'
 | 'given' langType langId ';'
 | 'yields' langType langId ';'
 | 'context_everywhere' langExpr ';'
 | 'context' langExpr ';'
 | 'loop_invariant' langExpr ';'
 | 'kernel_invariant' langExpr ';'
 | 'signals' '(' langType langId ')' langExpr ';'
 | 'lock_invariant' langExpr ';'
 | 'decreases' valDecreasesMeasure? ';'
 ;

valDecreasesMeasure
 : 'assume'
 | valExpressionList
 ;

valBlock
 : '{' valStatement* '}'
 ;

valStatement
 : 'package' langExpr langStatement  # valPackage
 | 'apply' langExpr ';' # valApplyWand
 | 'fold' langExpr ';' # valFold
 | 'unfold' langExpr ';' # valUnfold
 | 'open' langExpr ';' # valOpen
 | 'close' langExpr ';' # valClose
 | 'assert' langExpr ';' # valAssert
 | 'assume' langExpr ';' # valAssume
 | 'inhale' langExpr ';' # valInhale
 | 'exhale' langExpr ';' # valExhale
 | 'label' langId ';' # valLabel
 | 'refute' langExpr ';' # valRefute
 | 'witness' langExpr ';' # valWitness
 | 'ghost' langStatement # valGhost
 | 'send' langId ',' langConstInt ':' langExpr ';' # valSend
 | 'recv' langId ';' # valRecv
 | 'transfer' langExpr ';' # valTransfer
 | 'csl_subject' langExpr ';' # valCslSubject
 | 'spec_ignore' '}' # valSpecIgnoreStart
 | 'spec_ignore' '{' # valSpecIgnoreEnd
 | 'action' '(' langExpr ',' langExpr ',' langExpr ',' langExpr ')' valActionImpl # valActionModel
 | 'atomic' '(' langId ')' langStatement # valAtomic
 | 'commit' langExpr ';' # valCommit
 | 'extract' langStatement # valExtract
 | 'frame' valContractClause* langStatement # valFrame
 ;

valActionImpl
 : ';'
 | langStatement
 ;

valImpOp: '-*' | '==>';
valAndOp: '**';
valInOp: '\\in';
valMulOp: '\\';
valPrependOp : '::';
valAppendOp : '++'; // postfix issues? maybe disable in spec - no side effects?
valPostfix
 : '[' '..' langExpr ']'
 | '[' langExpr '..' langExpr? ']'
 | '[' langExpr '->' langExpr ']' // C?
 | '?.' langId '(' valExpressionList? ')'
 ;
valPrefix
 : '[' langExpr ']' # valScale
 ;
valWith: 'with' langStatement;
valThen: 'then' langStatement;
valGiven: 'given' '{' valGivenMappings '}';
valYields: 'yields' '{' valYieldsMappings '}';

valGivenMappings
 : langId '=' langExpr
 | langId '=' langExpr ',' valGivenMappings
 ;

valYieldsMappings
 : langId '=' langId
 | langId '=' langId ',' valYieldsMappings
 ;

valPrimarySeq
 : '|' langExpr '|' # valCardinality
 | '\\values' '(' langExpr ',' langExpr ',' langExpr ')' # valArrayValues
 ;

valPrimaryOption
 : 'Some' '(' langExpr ')' # valSome
 ;

valPrimaryEither
 : 'Left' '(' langExpr ')' # valLeft
 | 'Right' '(' langExpr ')' # valRight
 ;

valSetCompSelectors
 : langType langId
 | langType langId '<-' langId
 | langType langId '<-' valPrimaryCollectionConstructor
 | langType langId ',' valSetCompSelectors
 | langType langId '<-' langId ',' valSetCompSelectors
 | langType langId '<-' valPrimaryCollectionConstructor ',' valSetCompSelectors
 ;

valMapPairs
 : langExpr '->' langExpr
 | langExpr '->' langExpr ',' valMapPairs
 ;

valPrimaryCollectionConstructor
 : 'seq' '<' langType '>' '{' valExpressionList? '}' # valTypedLiteralSeq
 | 'set' '<' langType '>' '{' valExpressionList? '}' # valTypedLiteralSet
 | 'vector' '<' langType '>' '{' valExpressionList? '}' # valTypedLiteralVector
 | 'set' '<' langType '>' '{' langExpr '|' valSetCompSelectors ';' langExpr '}' # valSetComprehension
 | 'bag' '<' langType '>' '{' valExpressionList? '}' # valTypedLiteralBag
 | 'map' '<' langType ',' langType '>' '{' valMapPairs? '}' # valTypedLiteralMap
 | 'tuple' '<' langType ',' langType '>' '{' langExpr ',' langExpr '}' # valTypedTuple
 | '[' valExpressionList ']' # valLiteralSeq
 | '{' valExpressionList '}' # valLiteralSet
 | 'b{' valExpressionList '}' # valLiteralBag
 | '[t:' langType ']' # valEmptySeq
 | '{t:' langType '}' # valEmptySet
 | 'b{t:' langType '}' # valEmptyBag
 | '{' langExpr '..' langExpr '}' # valRangeSet
 | '[' langExpr '..' langExpr ']' # valRange
 ;

valPrimaryPermission
 : 'perm' '(' langExpr ')' # valCurPerm
 | 'Perm' '(' langExpr ',' langExpr ')' # valPerm
 | 'Value' '(' langExpr ')' # valValue
 | 'AutoValue' '(' langExpr ')' # valAutoValue
 | 'PointsTo' '(' langExpr ',' langExpr ',' langExpr ')' #valPointsTo
 | 'HPerm' '(' langExpr ',' langExpr ')' # valHPerm
 | 'APerm' '(' langExpr ',' langExpr ')' # valAPerm
 | 'ArrayPerm' '(' langExpr ',' langExpr ',' langExpr ',' langExpr ',' langExpr ')' # valArrayPerm
 | '\\matrix' '(' langExpr ',' langExpr ',' langExpr ')' # valMatrix
 | '\\array'  '(' langExpr ',' langExpr ')' # valArray
 | '\\pointer' '(' langExpr ',' langExpr ',' langExpr ')' # valPointer
 | '\\pointer_index' '(' langExpr ',' langExpr ',' langExpr ')' # valPointerIndex
 | '\\pointer_block' '(' langExpr ')' # valPointerBlock
 | '\\pointer_block_length' '(' langExpr ')' # valPointerBlockLength
 | '\\pointer_block_offset' '(' langExpr ')' # valPointerBlockOffset
 | '\\pointer_length' '(' langExpr ')' # valPointerLength
 | '\\polarity_dependent' '(' langExpr ',' langExpr ')' # valPolarityDependent
 ;

valForall: '\\forall' | '\u2200';
valStarall: '\\forall*' | '\u2200*';
valExists: '\\exists' | '\u2203';

valBinderSymbol
 : valForall # valForallSymb
 | valStarall # valStarallSymb
 | valExists # valExistsSymb
 ;

valBinding
 : langType langId '=' langExpr '..' langExpr # valRangeBinding
 | valArg # valNormalBinding
 ;

valBindings
 : valBinding
 | valBinding ',' valBindings
 ;

valBinderCont: ';' langExpr;

valPrimaryBinder
 : '(' valBinderSymbol valBindings ';' langExpr valBinderCont? ')' # valQuantifier
 | '(' '\\let' langType langId '=' langExpr ';' langExpr ')' # valLet
 | '(' '\\forperm' valArgList '\\in' langExpr ';' langExpr ')' #valForPerm
 | '(' '\\forpermwithvalue' 'any' langId ';' langExpr ')' #valForPermWithValue
 ;

valPrimaryVector
 : '(' '\\sum' langType langId ';' langExpr ';' langExpr ')' # valSum
 | '\\sum' '(' langExpr ',' langExpr ')' # valVectorSum
 | '\\vcmp' '(' langExpr ',' langExpr ')' # valVectorCmp
 | '\\vrep' '(' langExpr ')' # valVectorRep
 | '\\msum' '(' langExpr ',' langExpr ')' # valMatrixSum
 | '\\mcmp' '(' langExpr ',' langExpr ')' # valMatrixCmp
 | '\\mrep' '(' langExpr ')' # valMatrixRep
 ;

valPrimaryReducible
 : 'Reducible' '(' langExpr ',' valReducibleOperator ')' # valReducible
 | 'Contribution' '(' langExpr ',' langExpr ')' # valContribution
 ;

valReducibleOperator
 : '+'
 | langId
 ;

valPrimaryThread
 : 'idle' '(' langExpr ')' # valIdle
 | 'running' '(' langExpr ')' # valRunning
 ;

valPrimaryContext
 : '\\result'
 | '\\current_thread'
 | '\\ltid'
 | '\\gtid'
 ;

valExpr
 : {specLevel>0}? valPrimary
 | {specLevel>0}? valKeywordExpr
 //| startSpec '\\replacing' '(' langExpr ')' endSpec langExpr startSpec '\\replacing_done' endSpec
 ;

valIdentifier
 : {specLevel==0}? valKeywordExpr
 | {specLevel==0}? valKeywordNonExpr
 | {specLevel>0}? LANG_ID_ESCAPE
 ;

valExprPair: ',' langExpr ',' langExpr;

valPrimary
 : valPrimarySeq
 | valPrimaryOption
 | valPrimaryEither
 | valPrimaryCollectionConstructor
 | valPrimaryPermission
 | valPrimaryBinder
 | valPrimaryVector
 | valPrimaryReducible
 | valPrimaryThread
 | valPrimaryContext
 | '*' # valAny
 | '(' langId '!' valIdList ')' # valFunctionOf
 | TRIGGER_OPEN langExpr ':}' # valInlinePattern
 | ('\\unfolding'|'\\Unfolding') langExpr '\\in' langExpr # valUnfolding
 | '\\old' '(' langExpr ')' # valOld
 | '\\old' '[' langId ']' '(' langExpr ')' #valOldLabeled
 | '\\typeof' '(' langExpr ')' # valTypeof
 | '\\type' '(' langType ')' # valTypeValue
 | 'held' '(' langExpr ')' # valHeld
 | 'committed' '(' langExpr ')' # valCommitted
 | LANG_ID_ESCAPE # valIdEscape
 | '\\shared_mem_size' '(' langExpr ')' # valSharedMemSize
 | '\\nd_index' '(' langExpr ',' langExpr valExprPair* ')' # valNdIndex
 | '\\nd_partial_index' '(' valExpressionList ';' valExpressionList ')' # valNdLIndex
 | '\\nd_length' '(' valExpressionList ')' # ValNdLength
 | '\\euclidean_div' '(' langExpr ',' langExpr ')' # valEuclideanDiv
 | '\\euclidean_mod' '(' langExpr ',' langExpr ')' # valEuclideanMod
 | '\\pow' '(' langExpr ',' langExpr ')' # valPow
 | '\\is_int' '(' langExpr ')' # valIsInt
 | '\\choose' '(' langExpr ')' # valChoose
 | '\\choose_fresh' '(' langExpr ')' # valChooseFresh
 | '(' '\\assuming' langExpr ')' # valBoolAssuming
 | '(' '\\assuming' langExpr ';' langExpr ')' # valAssuming
 | '(' '\\asserting' langExpr ')' # valBoolAsserting
 | '(' '\\asserting' langExpr ';' langExpr ')' # valAsserting
 ;

// Out spec: defined meaning: a language local
// In spec: defined meaning: the spec value
valKeywordExpr
 : 'none' # valNonePerm
 | 'write' # valWrite
 | 'read' # valRead
 | 'None' # valNoneOption
 | 'empty' # valEmpty
 | specTrue # valTrue
 | specFalse # valFalse
 ;

// Out spec: defined meaning: a language local
// In spec: not parseable, use LANG_ID_ESCAPE instead.
valKeywordNonExpr: (
 // Frontend keywords
   VAL_INLINE | VAL_ASSERT
 // Type keywords
 | VAL_RESOURCE | VAL_PROCESS | VAL_FRAC | VAL_ZFRAC | VAL_BOOL | VAL_REF | VAL_RATIONAL | VAL_SEQ | VAL_SET | VAL_BAG
 | VAL_POINTER | VAL_MAP | VAL_OPTION | VAL_EITHER | VAL_TUPLE | VAL_TYPE | VAL_ANY | VAL_NOTHING | VAL_STRING
 // Annotation keywords
 | VAL_PURE | VAL_THREAD_LOCAL | VAL_WITH | VAL_THEN | VAL_GIVEN | VAL_YIELDS | VAL_BIP_ANNOTATION
 // Declaration keywords
 | VAL_AXIOM | VAL_MODEL | VAL_ADT | VAL_PROVER_TYPE | VAL_PROVER_FUNCTION
 // Contract clause keywords
 | VAL_MODIFIES | VAL_ACCESSIBLE | VAL_REQUIRES | VAL_ENSURES | VAL_CONTEXT_EVERYWHERE | VAL_CONTEXT
 | VAL_LOOP_INVARIANT | VAL_KERNEL_INVARIANT | VAL_LOCK_INVARIANT | VAL_SIGNALS | VAL_DECREASES
 // Statement keywords
 | VAL_APPLY | VAL_FOLD | VAL_UNFOLD | VAL_OPEN | VAL_CLOSE | VAL_ASSUME | VAL_INHALE
 | VAL_EXHALE | VAL_LABEL | VAL_REFUTE | VAL_WITNESS | VAL_GHOST | VAL_SEND | VAL_WORD_TO | VAL_RECV | VAL_FROM
 | VAL_TRANSFER | VAL_CSL_SUBJECT | VAL_SPEC_IGNORE | VAL_ACTION | VAL_ATOMIC
 | VAL_EXTRACT | VAL_FRAME
 // Spec function keywords
 | VAL_REDUCIBLE | VAL_ADDS_TO | VAL_APERM | VAL_ARRAYPERM | VAL_CONTRIBUTION | VAL_HELD | VAL_HPERM | VAL_IDLE
 | VAL_PERM_VAL | VAL_PERM | VAL_POINTS_TO | VAL_RUNNING | VAL_SOME | VAL_LEFT | VAL_RIGHT | VAL_VALUE
);

valGenericAdtInvocation
 : langId '<' valTypeList '>' '.' langId '(' valExpressionList? ')'
 ;

valType
 : ('resource' | 'process' | 'frac' | 'zfrac' | 'rational' | 'bool' | 'ref' | 'any' | 'nothing' | 'string') # valPrimaryType
 | 'seq' '<' langType '>' # valSeqType
 | 'set' '<' langType '>' # valSetType
 | 'vector' '<' langType ',' langConstInt '>' # valVectorType
 | 'bag' '<' langType '>' # valBagType
 | 'option' '<' langType '>' # valOptionType
 | 'map' '<' langType ',' langType '>' # valMapType
 | 'tuple' '<' langType ',' langType '>' # valTupleType
 | 'pointer' '<' langType '>' # valPointerType
 | 'type' '<' langType '>' # valTypeType
 | 'either' '<' langType ',' langType '>' # valEitherType
 ;

valGlobalDeclaration
 : 'axiom' langId '{' langExpr '}' # valAxiom
 | valModifier* 'resource' langId '(' valArgList? ')' valPureDef # valPredicate
 | valContractClause* valModifier* 'pure' langType langId valTypeVars? '(' valArgList? ')' valPureDef # valFunction
 | 'model' langId '{' valModelDeclaration* '}' # valModel
 | 'ghost' langGlobalDecl # valGhostDecl
 | 'adt' langId valTypeVars? '{' valAdtDeclaration* '}' # valAdtDecl
 | 'prover_type' langId valProverInterpretations ';' # valProverType
 | 'prover_function' langType langId '(' valArgList? ')' valProverInterpretations ';' # valProverFunction
 ;

valProverInterpretations
 : valProverInterpretation
 | valProverInterpretation valProverInterpretations
 ;

valProverInterpretation
 : '\\smtlib' langId # valInterpSmtlib
 | '\\boogie' langId # valInterpBoogie
 ;

valClassDeclaration
 : valModifier* 'resource' langId '(' valArgList? ')' valPureDef # valInstancePredicate
 | valContractClause* valModifier* 'pure' langType langId valTypeVars? '(' valArgList? ')' valPureDef # valInstanceFunction
 | 'ghost' langClassDecl # valInstanceGhostDecl
 | valContractClause* valModifier* 'pure' langType valOperatorName '(' valArgList? ')' valPureDef # valInstanceOperatorFunction
 | valContractClause* valModifier*  langType valOperatorName '(' valArgList? ')' valImpureDef # valInstanceOperatorMethod
 ;

valOperatorName
 : '+'
 | langId '+' // identifier should be 'right'
 ;

valModelDeclaration
 : valContractClause* 'process' langId '(' valArgList? ')' '=' langExpr ';' # valModelProcess
 | valContractClause* 'action' langId '(' valArgList? ')' ';' # valModelAction
 | langType valIdList ';' # valModelField
 ;

valTypeVars
 : '<' valIdList '>'
 ;

valAdtDeclaration
 : 'axiom' langExpr ';' # valAdtAxiom
 | 'pure' langType langId '(' valArgList? ')' ';' # valAdtFunction
 ;

valPureDef
 : ';'              # valPureAbstractBody
 | '=' langExpr ';' # valPureBody
 ;

valImpureDef
 : ';'           # valImpureAbstractBody
 | langStatement # valImpureBody
 ;

valModifier
 : ('pure' | 'inline' | 'thread_local' | 'bip_annotation')
 | langStatic # valStatic
 ;

valTypeQualifier
  : 'unique' '<' langConstInt '>' # valUnique
  | 'unique_pointer_field' '<' langId ',' langConstInt '>' # valUniquePointerField
  ;

valArgList
 : valArg
 | valArg ',' valArgList
 ;

valArg
 : langType langId
 ;

valEmbedContract: valEmbedContractBlock+;

valEmbedContractBlock
 : /*startSpec valContractClause* endSpec
 | */{specLevel>0}? valContractClause+
 ;

valEmbedStatementBlock
 : /*startSpec valStatement* endSpec
 | */{specLevel>0}? valStatement+
 //| startSpec 'extract' endSpec langStatement
 //| startSpec 'frame' valContractClause* '{' endSpec langStatement* startSpec '}' endSpec
 ;

valEmbedWith: /*startSpec valWith? endSpec |*/ {specLevel>0}? valWith;
valEmbedThen: /*startSpec valThen? endSpec |*/ {specLevel>0}? valThen;
valEmbedGiven: /*startSpec valGiven? endSpec |*/ {specLevel>0}? valGiven;
valEmbedYields: /*startSpec valYields? endSpec |*/ {specLevel>0}? valYields;

valEmbedGlobalDeclarationBlock
 : /*startSpec valGlobalDeclaration* endSpec
 | */{specLevel>0}? valGlobalDeclaration+
 ;

valEmbedClassDeclarationBlock
 : /*startSpec valClassDeclaration* endSpec
 | */{specLevel>0}? valClassDeclaration+
 ;

valEmbedModifier
 : /*startSpec valModifier endSpec
 | */{specLevel>0}? valModifier
 ;

 valEmbedTypeQualifier
  : /*startSpec valTypeQualifier endSpec
  | */{specLevel>0}? valTypeQualifier
  ;

/*
These tokens overlap one of the frontends, which leads to problems in ANTLR. They must be reproduced in the lexer of a
frontend, if the lexer of the frontend does not already define the token.

COMMA: ',';
SEMI: ';';
BLOCK_OPEN: '{';
BLOCK_CLOSE: '}';
PAREN_OPEN: '(';
PAREN_CLOSE: ')';
BRACK_OPEN: '[';
BRACK_CLOSE: ']';
ANGLE_OPEN: '<';
ANGLE_CLOSE: '>';
EQ: '=';
EQUALS: '==';
EXCL: '!';
STAR: '*';
PIPE: '|';
PLUS: '+';
COLON: ':';
CONS: '::';
VAL_INLINE: 'inline';
VAL_ASSERT: 'assert';
VAL_TRUE: 'true';
VAL_FALSE: 'false';
VAL_PACKAGE: 'package';
*/

NEVER: EOF '=';

// Must be able to contain identifiers from any frontend, so it's fine to over-approximate valid identifiers a bit.
LANG_ID_ESCAPE: '`' ~[`]+ '`';

VAL_RESOURCE: 'resource';
VAL_PROCESS: 'process';
VAL_FRAC: 'frac';
VAL_ZFRAC: 'zfrac';
VAL_BOOL: 'bool';
VAL_REF: 'ref';
VAL_RATIONAL: 'rational';
VAL_SEQ: 'seq';
VAL_SET: 'set';
VAL_VECTOR: 'vector';
VAL_BAG: 'bag';
VAL_POINTER: 'pointer';
VAL_MAP: 'map';
VAL_OPTION: 'option';
VAL_EITHER: 'either';
VAL_TUPLE: 'tuple';
VAL_TYPE: 'type';
VAL_ANY: 'any';
VAL_NOTHING: 'nothing';
VAL_STRING: 'string';

VAL_PURE: 'pure';
VAL_THREAD_LOCAL: 'thread_local';
VAL_BIP_ANNOTATION: 'bip_annotation';
VAL_UNIQUE: 'unique';
VAL_UNIQUE_POINTER_FIELD: 'unique_pointer_field';

VAL_WITH: 'with';
VAL_THEN: 'then';
VAL_GIVEN: 'given';
VAL_YIELDS: 'yields';

VAL_AXIOM: 'axiom';
VAL_MODEL: 'model';
VAL_ADT: 'adt';
VAL_PROVER_TYPE: 'prover_type';
VAL_PROVER_FUNCTION: 'prover_function';

VAL_MODIFIES: 'modifies';
VAL_ACCESSIBLE: 'accessible';
VAL_REQUIRES: 'requires';
VAL_ENSURES: 'ensures';
VAL_CONTEXT_EVERYWHERE: 'context_everywhere';
VAL_CONTEXT: 'context';
VAL_LOOP_INVARIANT: 'loop_invariant';
VAL_KERNEL_INVARIANT: 'kernel_invariant';
VAL_LOCK_INVARIANT: 'lock_invariant';
VAL_SIGNALS: 'signals';
VAL_DECREASES: 'decreases';

VAL_APPLY: 'apply';
VAL_FOLD: 'fold';
VAL_UNFOLD: 'unfold';
VAL_OPEN: 'open';
VAL_CLOSE: 'close';
VAL_ASSUME: 'assume';
VAL_INHALE: 'inhale';
VAL_EXHALE: 'exhale';
VAL_LABEL: 'label';
VAL_EXTRACT: 'extract';
VAL_FRAME: 'frame';
VAL_OUTLINE: 'outline';
VAL_REFUTE: 'refute';
VAL_WITNESS: 'witness';
VAL_GHOST: 'ghost';
VAL_SEND: 'send';
VAL_WORD_TO: 'to';
VAL_RECV: 'recv';
VAL_FROM: 'from';
VAL_TRANSFER: 'transfer';
VAL_CSL_SUBJECT: 'csl_subject';
VAL_SPEC_IGNORE: 'spec_ignore';
VAL_SPEC_REPLACE_EXPR_DONE: '\\replacing_done';
VAL_SPEC_REPLACE_EXPR: '\\replacing';
VAL_ACTION: 'action';
VAL_ATOMIC: 'atomic';
VAL_COMMIT: 'commit';

VAL_REDUCIBLE: 'Reducible';
VAL_ADDS_TO: 'AddsTo';
VAL_APERM: 'APerm';
VAL_ARRAYPERM: 'ArrayPerm';
VAL_CONTRIBUTION: 'Contribution';
VAL_HELD: 'held';
VAL_COMMITTED: 'committed';
VAL_HPERM: 'HPerm';
VAL_IDLE: 'idle';
VAL_PERM_VAL: 'perm';
VAL_PERM: 'Perm';
VAL_POINTS_TO: 'PointsTo';
VAL_RUNNING: 'running';
VAL_SOME: 'Some';
VAL_LEFT: 'Left';
VAL_RIGHT: 'Right';
VAL_VALUE: 'Value';
VAL_AUTO_VALUE: 'AutoValue';

UNFOLDING: '\\unfolding';
UNFOLDING_JAVA: '\\Unfolding';
IN: '\\in';
MEMBEROF: '\\memberof';
CURRENT_THREAD: '\\current_thread';
FORALL_STAR: '\\forall*';
FORALL: '\\forall';
EXISTS: '\\exists';
FORPERM: '\\forperm';
FORPERMWITHVALUE: '\\forpermwithvalue';
FORALL_UNICODE: '\u2200';
FORALL_STAR_UNICODE: '\u2200*';
EXISTS_UNICODE: '\u2203';
LET: '\\let';
SUM: '\\sum';
CHOOSE: '\\choose';
CHOOSE_FRESH: '\\choose_fresh';
LENGTH: '\\length';
OLD: '\\old';
ASSERT_EXPR: '\\asserting';
ASSUME_EXPR: '\\assuming';
TYPEOF: '\\typeof';
TYPEVALUE: '\\type';
MATRIX: '\\matrix';
ARRAY: '\\array';
POINTER: '\\pointer';
POINTER_INDEX: '\\pointer_index';
POINTER_BLOCK: '\\pointer_block';
POINTER_BLOCK_LENGTH: '\\pointer_block_length';
POINTER_BLOCK_OFFSET: '\\pointer_block_offset';
POINTER_LENGTH: '\\pointer_length';
SHARED_MEM_SIZE: '\\shared_mem_size';
VALUES: '\\values';
VCMP: '\\vcmp';
VREP: '\\vrep';
MSUM: '\\msum';
MCMP: '\\mcmp';
MREP: '\\mrep';
RESULT: '\\result';
LTID: '\\ltid';
GTID: '\\gtid';
VAL_INDEX: '\\nd_index';
VAL_LENGTH: '\\nd_length';
VAL_PARTIAL_INDEX: '\\nd_partial_index';
POLARITY_DEPENDENT: '\\polarity_dependent';
SMT_LIB: '\\smtlib';
BOOGIE: '\\boogie';

EUCLIDIAN_DIV: '\\euclidean_div';
EUCLIDIAN_MOD: '\\euclidean_mod';
POW: '\\pow';
IS_INT: '\\is_int';

NONE: 'none';
OPTION_NONE: 'None';
WRITE: 'write';
READ: 'read';
EMPTY: 'empty';

COALESCE: '?.';
FRAC_DIV: '\\';
SEP_CONJ: '**';
IMPLIES: '==>';
WAND: '-*';
RANGE_TO: '..';
TRIGGER_OPEN: '{:' ('<'* [0-9]* ':')?;
TRIGGER_CLOSE: ':}';
LITERAL_BAG_OPEN: 'b{';
EMPTY_SEQ_OPEN: '[t:';
EMPTY_SET_OPEN: '{t:';
EMPTY_BAG_OPEN: 'b{t:';
ARROW_LEFT: '<-';

VAL_EXPECT_ERROR_OPEN: '/*'? '[/expect ' [a-zA-Z:]+ ']' '*/'? -> channel(EXPECTED_ERROR_CHANNEL);
VAL_EXPECT_ERROR_CLOSE: '/*'? '[/end]' '*/'? -> channel(EXPECTED_ERROR_CHANNEL);
