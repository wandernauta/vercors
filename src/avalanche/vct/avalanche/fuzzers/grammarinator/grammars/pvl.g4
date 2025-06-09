grammar pvl;

program  : programDecl+ ;
Identifier  : ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;

COMMENT : '/*' .*? '*/' -> skip;
LINE_COMMENT : '//' .*? ('\n'|EOF) -> skip;

WS  :   (   ' '
        |   '\t'
        |   '\r'
        |   '\n'
        )+ -> skip ;

EmbeddedLatex
    : '#' ~[\r\n]* '#' -> skip
    ;

COMMA: ',';
POINT: '.';
COLON: ':';
SEMICOLON: ';';

QUESTION: '?';
EXCL: '!';
AND: '&&';
OR: '||';
BITOR: '|';
XOR: '^^';

GTE: '>=';
LTE: '<=';
ASSIGN: '=';
EQ: '==';
INEQ: '!=';

PLUS: '+';
MINUS: '-';
STAR: '*';
SLASH: '/';
PERCENT: '%';
INC: '++';
DEC: '--';
CONS: '::';

ENUM: 'enum';
CLASS: 'class';
SEQ_PROGRAM: 'choreography';
KERNEL: 'kernel';
BARRIER: 'barrier';
INVARIANT: 'invariant';
CONSTRUCTOR: 'constructor';
RUN: 'run';
VESUV_ENTRY: 'vesuv_entry';
THREAD: 'thread';
ENDPOINT: 'endpoint';

IF: 'if';
ELSE: 'else';
WHILE: 'while';
FOR: 'for';
GOTO: 'goto';
RETURN: 'return';
VEC: 'vec';
PAR: 'par';
PAR_AND: 'and';
PARALLEL: 'parallel';
SEQUENTIAL: 'sequential';
BLOCK: 'block';

LOCK: 'lock';
UNLOCK: 'unlock';
WAIT: 'wait';
NOTIFY: 'notify';
FORK: 'fork';
JOIN: 'join';

CHANNEL_INV: 'channel_invariant';
COMMUNICATE: 'communicate';
SENDER: '\\sender';
RECEIVER: '\\receiver';
MESSAGE: '\\msg';
BENDPOINT: '\\endpoint';
BCHOR: '\\chor';

THIS: 'this';
NULL: 'null';
TRUE: 'true';
FALSE: 'false';
CURRENT_THREAD: 'current_thread';
CURRENT_THREAD_ESC: '\\current_thread';
OWNER: '\\owner';

GLOBAL: 'global';
LOCAL: 'local';
STATIC: 'static';
FINAL: 'final';
UNFOLDING_ESC: '\\unfolding';
UNFOLDING: 'unfolding';
IN_ESC: '\\in';
IN: 'in';
NEW: 'new';
ID: 'id';

BOOL: 'boolean';
VOID: 'void';
INT: 'int';
CHAR: 'char';
FLOAT32: 'float32';
FLOAT64: 'float64';


STRING_LITERAL : '"' STRING_CHARACTER* '"';

fragment
STRING_CHARACTER
    : ~["\\]
    | ESCAPE
    ;

fragment
ESCAPE
    :   '\\' [tnr"'\\]
    | UNICODE_ESCAPE
    ;

fragment
UNICODE_ESCAPE
    :   '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
    ;

fragment
HEX_DIGIT
    :   [0-9a-fA-F]
    ;

NUMBER : ('0'..'9')+;
DECIMAL_NUMBER : ('0'..'9')+ '.' ('0'..'9')+;
DECIMAL_NUMBER_F : ('0'..'9')+ '.' ('0'..'9')+ 'f';

fragment
CHARACTER
    : '\\' '\''
    | ~['\\]
    ;


CHARACTER_LITERAL : '\'' CHARACTER '\'';

VAL_INLINE: 'inline';
VAL_ASSERT: 'assert';
VAL_PACKAGE: 'package';

PAREN_OPEN: '(';
PAREN_CLOSE: ')';
BLOCK_OPEN: '{';
BLOCK_CLOSE: '}';
ANGLE_OPEN: '<';
ANGLE_CLOSE: '>';
BRACK_OPEN: '[';
BRACK_CLOSE: ']';
ARR_RIGHT: '->';

valExpressionList
 : langExpr
 | langExpr ',' valExpressionList
 ;

TRIGGER_OPEN: '{:' ('<'* [0-9]* ':')?;
TRIGGER_CLOSE: ':}';

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
 /* | 'spec_ignore' '}' # valSpecIgnoreStart */
 /* | 'spec_ignore' '{' # valSpecIgnoreEnd */
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
 : valPrimary
 | valKeywordExpr
 //| startSpec '\\replacing' '(' langExpr ')' endSpec langExpr startSpec '\\replacing_done' endSpec
 ;

valIdentifier
 : LANG_ID_ESCAPE
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
 : (/* 'resource' | */ 'process' | 'frac' | 'zfrac' | 'rational' | 'bool' | 'ref' | 'any' | 'nothing' | 'string') # valPrimaryType
 | 'seq' '<' langType '>' # valSeqType
 | 'set' '<' langType '>' # valSetType
 | 'vector' '<' langType ',' langConstInt '>' # valVectorType
 | 'bag' '<' langType '>' # valBagType
 | 'option' '<' langType '>' # valOptionType
 | 'map' '<' langType ',' langType '>' # valMapType
 | 'tuple' '<' langType ',' langType '>' # valTupleType
 | 'pointer' '<' langType '>' # valPointerType
 /* | 'type' '<' langType '>' # valTypeType */
 | 'either' '<' langType ',' langType '>' # valEitherType
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
 //| 'ghost' langClassDecl # valInstanceGhostDecl
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
 : ('pure' | 'inline' /* | 'thread_local' */ | 'bip_annotation')
 | langStatic # valStatic
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
 // startSpec valContractClause* endSpec
 : valContractClause+
 ;

valEmbedStatementBlock
 // startSpec valStatement* endSpec
 : valStatement+
 //| startSpec 'extract' endSpec langStatement
 //| startSpec 'frame' valContractClause* '{' endSpec langStatement* startSpec '}' endSpec
 ;

valEmbedWith: valWith;
valEmbedThen: valThen;
valEmbedGiven: valGiven;
valEmbedYields: valYields;

valEmbedGlobalDeclarationBlock
 //: startSpec valGlobalDeclaration* endSpec
 : valGlobalDeclaration+
 ;

valEmbedClassDeclarationBlock
 //: startSpec valClassDeclaration* endSpec
 : valClassDeclaration+
 ;

valEmbedModifier
 //: startSpec valModifier endSpec
 : valModifier
 ;

programDecl : valGlobalDeclaration | declClass | enumDecl | method | declVeyMontSeqProg | vesuvEntry ;

enumDecl : 'enum' identifier '{' identifierList ','? '}' ;

declClass
 : contract 'class' identifier declaredTypeArgs? '{' classDecl* '}'
 ;

declVeyMontSeqProg : contract 'choreography' identifier '(' args? ')' '{' seqProgDecl* '}';

seqProgDecl
 : 'endpoint' identifier '=' classType '(' exprList? ')' ';' # pvlEndpoint
 | contract 'run' block # pvlSeqRun
 | method # seqProgMethod
 ;

applicableReference
 : identifier '.' identifier # pvlAdtFunctionRef
 | identifier                # pvlFunctionRef
 ;

classDecl : valClassDeclaration | constructor | method | field | runMethod;
finalFlag: 'final';
field : finalFlag? type identifierList ';' ;

method : contract valModifier* type identifier declaredTypeArgs? '(' args? ')' methodBody ;
methodBody : /*';' |*/ block ;

constructor : contract 'constructor' declaredTypeArgs? '(' args? ')' methodBody ;

runMethod : contract 'run' methodBody ;

vesuvEntry : 'vesuv_entry' methodBody ;

contract : valContractClause* ;

args
 : type identifier
 | type identifier ',' args
 ;

exprList
 : expr
 | expr ',' exprList
 ;

expr
 : valWith? unfoldingExpr valThen?
 ;

unfoldingExpr
 : 'unfolding' unfoldingExpr 'in' unfoldingExpr
 | iteExpr
 ;

iteExpr
 : implicationExpr '?' implicationExpr ':' iteExpr
 | implicationExpr
 ;

implicationExpr
 : orExpr valImpOp implicationExpr
 | orExpr
 ;

orExpr
 : orExpr '||' andExpr
 | andExpr
 ;

andExpr
 : andExpr '&&' eqExpr
 | andExpr valAndOp eqExpr
 | eqExpr
 ;

eqExpr
 : eqExpr '==' relExpr
 | eqExpr '!=' relExpr
 | relExpr
 ;

relExpr
 : relExpr '<' addExpr
 | relExpr '<=' addExpr
 | relExpr '>=' addExpr
 | relExpr '>' addExpr
 | relExpr valInOp addExpr
 | setExpr
 ;

setExpr
 : setExpr 'in' addExpr
 | addExpr
 ;

addExpr
 : addExpr '+' multExpr
 | addExpr '-' multExpr
 | multExpr
 ;

multExpr
 : multExpr '*' powExpr
 | multExpr '/' powExpr
 | multExpr '%' powExpr
 | multExpr valMulOp powExpr
 | powExpr
 ;

powExpr
 : powExpr '^^' seqAddExpr
 | seqAddExpr
 ;

seqAddExpr
 : unaryExpr valPrependOp seqAddExpr
 | seqAddExpr valAppendOp unaryExpr
 | seqAddExpr valAppendOp '(' expr ',' expr ')'
 | unaryExpr
 ;

unaryExpr
 : '!' unaryExpr
 | '-' unaryExpr
 | valPrefix unaryExpr
 | newExpr
 ;

newExpr
 : 'new' classType call
 | 'new' nonArrayType newDims
 | postfixExpr
 ;

postfixExpr
 : postfixExpr '.' identifier call?
 | postfixExpr '[' expr ']'
 | postfixExpr valPostfix
 | unit
 ;

unit
 : valExpr # pvlValExpr
 | 'Perm' '[' identifier ']' '(' expr ',' expr ')' # pvlChorPerm
 | '(' '\\endpoint' identifier ';' expr ')' # pvlLongEndpointExpr
 | '(' '\\' '[' identifier ']' expr ')' # pvlShortEndpointExpr
 | '(' '\\chor' expr ')' # pvlLongChorExpr
 | '(' '\\' '[' ']' expr ')' # pvlShortChorExpr
 | 'this' # pvlThis
 | 'null' # pvlNull
 | '\\sender' # pvlSender
 | '\\receiver' # pvlReceiver
 | '\\msg' # pvlMessage
 | NUMBER # pvlNumber
 | DECIMAL_NUMBER # pvlDecimal
 | DECIMAL_NUMBER_F # pvlDecimalF
 | STRING_LITERAL # pvlString
 | CHARACTER_LITERAL # pvlChar
 | '(' expr ')' # pvlParens
 | identifier call? # pvlInvocation
 | valGenericAdtInvocation # pvlValAdtInvocation
 ;

call : typeArgs? tuple valGiven? valYields?;
tuple : '(' exprList? ')';

block : '{' statement* '}' ;

statement
 : 'return' expr? ';' # pvlReturn
 | 'lock' expr ';' # pvlLock
 | 'unlock' expr ';' # pvlUnlock
 | 'wait' expr ';' # pvlWait
 | 'notify' expr ';' # pvlNotify
 | 'fork' expr ';' # pvlFork
 | 'join' expr ';' # pvlJoin
 | valStatement # pvlValStatement
 | 'if' '(' '*' ')' statement elseBlock? # pvlIndetBranch
 | 'if' '(' expr ')' statement elseBlock? # pvlIf
 | 'barrier' '(' identifier barrierTags? ')' barrierBody # pvlBarrier
 | parRegion # pvlPar
 | 'vec' '(' iter ')' block # pvlVec
 | 'invariant' identifier '(' expr ')' block # pvlInvariant
 | 'atomic' '(' identifierList ')' block # pvlAtomic
 | contract 'while' '(' expr ')' statement # pvlWhile
 | contract 'for' '(' forStatementList? ';' expr? ';' forStatementList? ')' statement # pvlFor
 | contract 'for' '(' iter ')' statement # pvlRangedFor
 | block # pvlBlock
 | 'goto' identifier ';' # pvlGoto
 /* | 'label' identifier ';' # pvlLabel */
 | allowedForStatement ';' # pvlForStatement
 /* | channelInvariant? 'communicate' access direction access ';' # pvlCommunicateStatement */
 ;

 channelInvariant
 : 'channel_invariant' expr ';'
 ;

direction
 : '<-'
 | '->'
 ;

access: participant? expr;
participant: identifier ':';

elseBlock: 'else' statement;
barrierTags: ';' identifierList;
barrierBody: '{' contract '}' | contract block;

allowedForStatement
 : type declList # pvlLocal
 | expr # pvlEval
 | identifier ('++'|'--') # pvlIncDec
 | expr '=' expr # pvlAssign
 | participant? expr ':' '=' expr # pvlSeqAssign
 ;

forStatementList
 : allowedForStatement
 | allowedForStatement ',' forStatementList
 ;

parRegion
 : 'parallel' '{' parRegion* '}' # pvlParallel
 | 'sequential' '{' /*parRegion* */ parRegion+ '}' # pvlSequential
 | 'par' identifier? parBlockIter? contract statement # pvlParBlock
 ;



declList
 : identifier declInit?
 | identifier declInit? ',' declList
 ;

declInit : '=' expr ;

parBlockIter: '(' iters ')';
iters: iter | iter ',' iters;
iter: type identifier '=' expr '..' expr;

parWaitList: ';' waitList;
waitList: waitFor | waitFor ',' waitList;
waitFor: identifier waitForArgs?;
waitForArgs: '(' idArgList ')';
idArgList: idArg | idArg ',' idArgList;
idArg: identifier | '*';

nonArrayType
 : valType
 | ('int' | 'boolean' | 'void' | 'float32' | 'float64' | 'char')
 | classType
 ;

type : nonArrayType typeDims? ;
typeList
  : type
  | type ',' typeList
  ;

typeDims
 : quantifiedDim+
 | anonDim+
 ;

newDims : quantifiedDim+ ;
quantifiedDim : '[' expr ']' ;
anonDim : '[' ']' ;
classType : identifier typeArgs?;
typeArgs : '<' typeList '>';
declaredTypeArgs: '<' identifierList '>';

identifierList
 : identifier
 | identifier ',' identifierList
 ;

identifier : Identifier | LANG_ID_ESCAPE ;




langExpr: expr;
langId: identifier;
langConstInt: NUMBER;
langType: type;
langStatement: statement;
langStatic: 'static';
// langGlobalDecl: NEVER;
// langClassDecl: NEVER;
specTrue: 'true';
specFalse: 'false';

// startSpec: NEVER;
// endSpec: NEVER;

valGlobalDeclaration
 : 'axiom' langId '{' langExpr '}' # valAxiom
 /*| valModifier* 'resource' langId '(' valArgList? ')' valPureDef # valPredicate*/
 | valContractClause* valModifier* 'pure' langType langId valTypeVars? '(' valArgList? ')' valPureDef # valFunction
//| 'model' langId '{' valModelDeclaration* '}' # valModel
//| 'ghost' langGlobalDecl # valGhostDecl
 | 'adt' langId valTypeVars? '{' valAdtDeclaration* '}' # valAdtDecl
 | 'prover_type' langId valProverInterpretations ';' # valProverType
 | 'prover_function' langType langId '(' valArgList? ')' valProverInterpretations ';' # valProverFunction
 ;









// NEVER: EOF '=';

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

// UNFOLDING: '\\unfolding';
UNFOLDING_JAVA: '\\Unfolding';
// IN: '\\in';
MEMBEROF: '\\memberof';
// CURRENT_THREAD: '\\current_thread';
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
TYPEOF: '\\typeof';
TYPEVALUE: '\\type';
MATRIX: '\\matrix';
ARRAY: '\\array';
POINTER: '\\pointer';
POINTER_INDEX: '\\pointer_index';
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
LITERAL_BAG_OPEN: 'b{';
EMPTY_SEQ_OPEN: '[t:';
EMPTY_SET_OPEN: '{t:';
EMPTY_BAG_OPEN: 'b{t:';
ARROW_LEFT: '<-';

//VAL_EXPECT_ERROR_OPEN: '/*'? '[/expect ' [a-zA-Z:]+ ']' '*/'? -> channel(EXPECTED_ERROR_CHANNEL);
//VAL_EXPECT_ERROR_CLOSE: '/*'? '[/end]' '*/'? -> channel(EXPECTED_ERROR_CHANNEL);







































































