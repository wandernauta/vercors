grammar cpp;

@header {
specLevel = 0
}

program : translationUnit;

LeftParen: '(';
Alignas: 'alignas';
Alignof: 'alignof';
Asm: 'asm';
Auto: 'auto';
Bool: 'bool';
Break: 'break';
Case: 'case';
Catch: 'catch';
Char: 'char';
Char16: 'char16_t';
Char32: 'char32_t';
Class: 'class';
Const: 'const';
Constexpr: 'constexpr';
Const_cast: 'const_cast';
Continue: 'continue';
Decltype: 'decltype';
Default: 'default';
Delete: 'delete';
Do: 'do';
Double: 'double';
Dynamic_cast: 'dynamic_cast';
Else: 'else';
Enum: 'enum';
Explicit: 'explicit';
Export: 'export';
Extern: 'extern';
BoolFalse: 'false';
Final: 'final';
Float: 'float';
For: 'for';
Friend: 'friend';
Goto: 'goto';
If: 'if';
Inline: 'inline';
Int: 'int';
Long: 'long';
Mutable: 'mutable';
Namespace: 'namespace';
New: 'new';
Noexcept: 'noexcept';
Nullptr: 'nullptr';
Operator: 'operator';
Override: 'override';
Private: 'private';
Protected: 'protected';
Public: 'public';
Register: 'register';
Reinterpret_cast: 'reinterpret_cast';
Return: 'return';
Short: 'short';
Signed: 'signed';
Sizeof: 'sizeof';
Static: 'static';
Static_assert: 'static_assert';
Static_cast: 'static_cast';
Struct: 'struct';
Switch: 'switch';
Template: 'template';
This: 'this';
Thread_local: '_thread_local';
Throw: 'throw';
BoolTrue: 'true';
Try: 'try';
Typedef: 'typedef';
Typeid_: 'typeid';
Typename_: 'typename';
Union: 'union';
Unsigned: 'unsigned';
Using: 'using';
Virtual: 'virtual';
Void: 'void';
Volatile: 'volatile';
Wchar: 'wchar_t';
While: 'while';

RightParen: ')';
LeftBracket: '[';
RightBracket: ']';
LeftBrace: '{';
RightBrace: '}';
Plus: '+';
Minus: '-';
Star: '*';
Div: '/';
Mod: '%';
Caret: '^';
And: '&';
Or: '|';
Tilde: '~';
Not: '!';
NotWord: 'not';
Assign: '=';
Less: '<';
Greater: '>';
PlusAssign: '+=';
MinusAssign: '-=';
StarAssign: '*=';
DivAssign: '/=';
ModAssign: '%=';
XorAssign: '^=';
AndAssign: '&=';
OrAssign: '|=';
LeftShiftAssign: '<<=';
RightShiftAssign: '>>=';
Equal: '==';
NotEqual: '!=';
LessEqual: '<=';
GreaterEqual: '>=';
AndAnd: '&&' | 'and';
OrOr: '||' | 'or';
PlusPlus: '++';
MinusMinus: '--';
Comma: ',';
ArrowStar: '->*';
Arrow: '->';
Question: '?';
Colon: ':';
Doublecolon: '::';
Semi: ';';
Dot: '.';
DotStar: '.*';
Ellipsis: '...';


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
 | startSpec '\\replacing' '(' langExpr ')' endSpec langExpr startSpec '\\replacing_done' endSpec
 ;

valIdentifier
 : {specLevel==0}? valKeywordExpr
 | {specLevel==0}? valKeywordNonExpr
 /*| {specLevel>0}? LANG_ID_ESCAPE*/
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
 /*| LANG_ID_ESCAPE # valIdEscape*/
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
 ;

// Out spec: defined meaning: a language local
// In spec: not parseable, use LANG_ID_ESCAPE instead.
valKeywordNonExpr: (
 // Frontend keywords
   VAL_INLINE | VAL_ASSERT
 // Type keywords
 | VAL_RESOURCE | VAL_PROCESS | VAL_FRAC | VAL_ZFRAC | VAL_BOOL | VAL_REF | VAL_RATIONAL | VAL_SEQ | VAL_SET | VAL_BAG
 | VAL_POINTER | VAL_MAP | VAL_OPTION | VAL_EITHER | VAL_TUPLE | VAL_TYPE | VAL_ANY | VAL_NOTHING /* | VAL_STRING */
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
 : (/* 'resource' |*/ 'process' | 'frac' | 'zfrac' | 'rational' | 'bool' | 'ref' | 'any' | 'nothing' /*| 'string'*/) # valPrimaryType
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
 /*| 'model' langId '{' valModelDeclaration* '}' # valModel*/
 | 'ghost' langGlobalDecl # valGhostDecl
 | 'adt' langId valTypeVars? '{' valAdtDeclaration* '}' # valAdtDecl
 /*| 'prover_type' langId valProverInterpretations ';' # valProverType*/
 /*| 'prover_function' langType langId '(' valArgList? ')' valProverInterpretations ';' # valProverFunction*/
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
 | valContractClause* valModifier* 'pure' langType valOperatorName '(' valArgList? ')' valPureDef # valInstanceOperatorFunction
 | valContractClause* valModifier*  langType valOperatorName '(' valArgList? ')' valImpureDef # valInstanceOperatorMethod
 ;

valOperatorName
 : '+'
 | 'right' '+' // identifier should be 'right'
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
 : (/*'pure' | */'inline' /* | 'thread_local' */ /*| 'bip_annotation'*/)
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
 : startSpec valContractClause+ endSpec
 | {specLevel>0}? valContractClause+
 ;

valEmbedStatementBlock
 : startSpec valStatement+ endSpec
 | {specLevel>0}? valStatement+
 | startSpec 'extract' endSpec langStatement
 | startSpec 'frame' valContractClause* '{' endSpec langStatement* startSpec '}' endSpec
 ;

valEmbedWith: startSpec valWith endSpec | {specLevel>0}? valWith;
valEmbedThen: startSpec valThen endSpec | {specLevel>0}? valThen;
valEmbedGiven: startSpec valGiven endSpec | {specLevel>0}? valGiven;
valEmbedYields: startSpec valYields endSpec | {specLevel>0}? valYields;

valEmbedGlobalDeclarationBlock
 : startSpec valGlobalDeclaration+ endSpec
 | {specLevel>0}? valGlobalDeclaration+
 ;

valEmbedClassDeclarationBlock
 : startSpec valClassDeclaration+ endSpec
 | {specLevel>0}? valClassDeclaration+
 ;

valEmbedModifier
 : startSpec valModifier endSpec
 | {specLevel>0}? valModifier
 ;


// Root
translationUnit: declarationseq EOF;

// Identifiers
clangppIdentifier:
    Identifier
    /*| valIdentifier*/;

// Expressions
primaryExpression:
    valExpr
	| literal // EW: Changed to match only one literal to prevent parsing errors
	| This
	| LeftParen oneOrMoreExpressions RightParen
	| idExpression
	| lambdaExpression;

annotatedPrimaryExpression: valEmbedWith? primaryExpression valEmbedThen?;

idExpression: unqualifiedId | qualifiedId;

unqualifiedId:
	templateId
	| clangppIdentifier
	| operatorFunctionId
	| conversionFunctionId
	| literalOperatorId
	/*| Tilde (className | decltypeSpecifier)*/;

qualifiedId: nestedNameSpecifier Template? unqualifiedId;

nestedNameSpecifier:
	theTypeName Doublecolon
	| namespaceName Doublecolon
	| decltypeSpecifier Doublecolon
	| Doublecolon
	| nestedNameSpecifier clangppIdentifier Doublecolon
	| nestedNameSpecifier Template? simpleTemplateId Doublecolon;

lambdaExpression:
	valEmbedContract? lambdaIntroducer lambdaDeclarator? compoundStatement;

lambdaIntroducer: LeftBracket lambdaCapture? RightBracket;

lambdaCapture:
	captureList
	| captureDefault (Comma captureList)?;

captureDefault: And | Assign;

captureList: capture (Comma capture)* Ellipsis?;

capture: simpleCapture | initcapture;

simpleCapture: And? clangppIdentifier | This;

initcapture: And? clangppIdentifier initializer;

lambdaDeclarator:
	LeftParen parameterDeclarationClause? RightParen Mutable? exceptionSpecification?
		attributeSpecifierSeq? trailingReturnType?;

postfixExpression:
	annotatedPrimaryExpression
	| postfixExpression LeftBracket oneOrMoreExpressions RightBracket
	| postfixExpression LeftBracket bracedInitList RightBracket
	| postfixExpression LeftParen expressionList? RightParen valEmbedGiven? valEmbedYields?
	| postfixExpression Dot Template? idExpression
	| postfixExpression Dot pseudoDestructorName
	| postfixExpression Arrow Template? idExpression
	| postfixExpression Arrow pseudoDestructorName
	| postfixExpression PlusPlus
	| postfixExpression MinusMinus
	| postfixExpression specPostfix
	| simpleTypeSpecifier LeftParen expressionList? RightParen valEmbedGiven? valEmbedYields?
	| simpleTypeSpecifier bracedInitList
	| typeNameSpecifier LeftParen expressionList? RightParen valEmbedGiven? valEmbedYields?
	| typeNameSpecifier bracedInitList
	| (
		Dynamic_cast
		| Static_cast
		| Reinterpret_cast
		| Const_cast
	) Less theTypeId Greater LeftParen oneOrMoreExpressions RightParen
	| typeIdOfTheTypeId LeftParen (oneOrMoreExpressions | theTypeId) RightParen;

specPostfix: {specLevel>0}? valPostfix;

/*
 add a middle layer to eliminate duplicated function declarations
 */

typeIdOfTheTypeId: Typeid_;

expressionList: initializerList;

pseudoDestructorName:
	nestedNameSpecifier? (theTypeName Doublecolon)? Tilde theTypeName
	| nestedNameSpecifier Template simpleTemplateId Doublecolon Tilde theTypeName
	| Tilde decltypeSpecifier;

unaryExpression:
	postfixExpression
	| PlusPlus unaryExpression
	| MinusMinus unaryExpression
	| unaryOperator unaryExpression
	| Sizeof unaryExpression
	| Sizeof (
		LeftParen theTypeId RightParen
		| Ellipsis LeftParen clangppIdentifier RightParen
	)
	| Alignof LeftParen theTypeId RightParen
	| noExceptExpression
	| newExpression
	| deleteExpression
	| specPrefix unaryExpression;

specPrefix: {specLevel>0}? valPrefix;

unaryOperator: And | Star | Plus | Minus | Tilde | Not | NotWord;

newExpression:
	Doublecolon? New newPlacement? newTypePtr newInitializer? valEmbedGiven? valEmbedYields?;

newPlacement: LeftParen expressionList RightParen;

newTypePtr:
    newTypeId
	| LeftParen theTypeId RightParen;

newTypeId: typeSpecifierSeq newDeclarator?;

newDeclarator:
	pointerOperator newDeclarator?
	| noPointerNewDeclarator;

noPointerNewDeclarator:
	LeftBracket oneOrMoreExpressions RightBracket attributeSpecifierSeq?
	| noPointerNewDeclarator LeftBracket constantExpression RightBracket attributeSpecifierSeq?;

newInitializer:
	LeftParen expressionList? RightParen
	| bracedInitList;

deleteExpression:
	Doublecolon? Delete (LeftBracket RightBracket)? castExpression;

noExceptExpression: Noexcept LeftParen oneOrMoreExpressions RightParen;

castExpression:
	unaryExpression
	| LeftParen theTypeId RightParen castExpression;

pointerMemberExpression:
    prependExpression
	| pointerMemberExpression DotStar prependExpression
	| pointerMemberExpression ArrowStar prependExpression;

prependExpression:
		castExpression
    | castExpression prependOp prependExpression;

prependOp: {specLevel>0}? valPrependOp;

multiplicativeExpression:
    pointerMemberExpression
	| multiplicativeExpression multiplicativeOp pointerMemberExpression;

multiplicativeOp:
    Star
    | Div
    | Mod
    | {specLevel>0}? valMulOp;

additiveExpression:
    multiplicativeExpression
	| additiveExpression Plus multiplicativeExpression
	| additiveExpression Minus multiplicativeExpression;

shiftExpression:
	additiveExpression
	| shiftExpression Less Less additiveExpression
	| shiftExpression Greater Greater additiveExpression;

relationalExpression:
    shiftExpression
    | relationalExpression relationalOp shiftExpression;

relationalOp:
    (Less | Greater | LessEqual | GreaterEqual)
    |   {specLevel>0}? valInOp;

equalityExpression:
	relationalExpression
	| equalityExpression Equal relationalExpression
	| equalityExpression NotEqual relationalExpression;

andExpression:
    equalityExpression
    | andExpression And equalityExpression;

exclusiveOrExpression:
    andExpression
    | exclusiveOrExpression Caret andExpression;

inclusiveOrExpression:
    exclusiveOrExpression
    | inclusiveOrExpression Or exclusiveOrExpression;

logicalAndExpression:
    inclusiveOrExpression
    | logicalAndExpression logicalAndOp inclusiveOrExpression;

logicalAndOp:
    AndAnd
    | {specLevel>0}? valAndOp;

logicalOrExpression:
	logicalAndExpression
	| logicalOrExpression OrOr logicalAndExpression;

implicationExpression:
		logicalOrExpression
    | logicalOrExpression implicationOp implicationExpression;

implicationOp: {specLevel>0}? valImpOp;

conditionalExpression:
	implicationExpression
	| implicationExpression Question oneOrMoreExpressions Colon expression;

assignmentExpression:
  valEmbedWith? pointerMemberExpression assignmentOperator initializerClause valEmbedThen?;

assignmentOperator:
	Assign
	| StarAssign
	| DivAssign
	| ModAssign
	| PlusAssign
	| MinusAssign
	| RightShiftAssign
	| LeftShiftAssign
	| AndAssign
	| XorAssign
	| OrAssign;

oneOrMoreExpressions:
  expression Comma oneOrMoreExpressions
  | expression;

expression:
  valEmbedWith? conditionalExpression valEmbedThen?
  | assignmentExpression
  /*| throwExpression*/;

constantExpression: conditionalExpression;

// Statements
/*
statement:
  attributeSpecifierSeq? statementTwo
  | blockDeclaration
	| labeledStatement;
*/
statement: blockDeclaration | statementTwo;

statementTwo:
    expressionStatement
    | compoundStatement
    | selectionStatement
    | iterationStatement
    | jumpStatement
    /*| tryBlock*/
    | valEmbedStatementBlock
    | {specLevel>0}? valStatement;

labeledStatement:
	attributeSpecifierSeq? (
		clangppIdentifier
		| Case constantExpression
		| Default
	) Colon statement;

expressionStatement: oneOrMoreExpressions/*?*/ Semi;

compoundStatement: LeftBrace statementSeq RightBrace;

statementSeq: statement+;

selectionStatement:
	ifStatement
	| switchStatement;

ifStatement:
	If LeftParen condition RightParen statement Else statement
	| If LeftParen condition RightParen statement;

switchStatement: Switch LeftParen condition RightParen statement;

condition:
	oneOrMoreExpressions
	| attributeSpecifierSeq? declSpecifierSeq declarator (
		Assign initializerClause
		| bracedInitList
	);

iterationStatement:
	valEmbedContract? While LeftParen condition RightParen valEmbedContract? statement
	| Do statement While LeftParen oneOrMoreExpressions RightParen Semi
	| valEmbedContract? For LeftParen forInitStatement condition? Semi oneOrMoreExpressions? RightParen valEmbedContract? statement
	| valEmbedContract? For LeftParen forRangeDeclaration Colon forRangeInitializer RightParen valEmbedContract? statement;

forInitStatement: expressionStatement | simpleDeclaration;

forRangeDeclaration:
	attributeSpecifierSeq? declSpecifierSeq declarator;

forRangeInitializer: oneOrMoreExpressions | bracedInitList;

jumpStatement:
	/* Break Semi
	| Continue Semi */
	| Return oneOrMoreExpressions Semi
	| Return bracedInitList Semi
	| Return Semi
	| Goto clangppIdentifier Semi;

// Declarations
declarationseq:
	declaration Semi?
	| declarationseq declaration Semi?;

declaration:
	functionDefinition
	| blockDeclaration
	/*| templateDeclaration */
	/*| explicitInstantiation */
	/*| explicitSpecialization */
	/*| linkageSpecification */
	| namespaceDefinition
	/*| emptyDeclaration */
	/*| attributeDeclaration */
	| valEmbedGlobalDeclarationBlock;

blockDeclaration:
	simpleDeclaration
	/*| asmDefinition */
	/*| namespaceAliasDefinition*/
	/*| usingDeclaration */
	/*| usingDirective*/
	| staticAssertDeclaration
	/*| aliasDeclaration*/
	/*| opaqueEnumDeclaration*/;

aliasDeclaration:
	Using clangppIdentifier attributeSpecifierSeq? Assign theTypeId Semi;

simpleDeclaration:
	valEmbedContract? declSpecifierSeq initDeclaratorList/*?*/ Semi
	| valEmbedContract? attributeSpecifierSeq declSpecifierSeq initDeclaratorList Semi;

staticAssertDeclaration:
	Static_assert LeftParen constantExpression Comma StringLiteral RightParen Semi;

emptyDeclaration: Semi;

attributeDeclaration: attributeSpecifierSeq Semi;

declSpecifier:
	storageClassSpecifier
	| typeSpecifier
	| functionSpecifier
	| Friend
	/*| Typedef */
	| Constexpr
	| valEmbedModifier;

declSpecifierSeq: declSpecifier+? attributeSpecifierSeq?;

storageClassSpecifier:
	Register
	| Static
	| Thread_local
	| Extern
	| Mutable;

functionSpecifier: Inline | Virtual | Explicit;

typedefName: clangppIdentifier;

typeSpecifier:
	trailingTypeSpecifier
	/*| classSpecifier*/
	/*| enumSpecifier*/;

trailingTypeSpecifier:
	simpleTypeSpecifier
	| elaboratedTypeSpecifier
	/*| typeNameSpecifier */
	/*| cvQualifier*/;

typeSpecifierSeq: typeSpecifier+ attributeSpecifierSeq?;

trailingTypeSpecifierSeq:
	trailingTypeSpecifier+ attributeSpecifierSeq?;

simpleTypeSpecifier:
	nestedNameSpecifier? theTypeName
	| nestedNameSpecifier Template simpleTemplateId
	| Char
	/*| Char16 */
	/*| Char32 */
	/*| Wchar */
	| Bool
	/* | Short */
	| Int
	/*| Long */
	/*| Signed*/
	/*| Unsigned*/
	| Float
	| Double
	| Void
	/*| Auto */
	| {specLevel>0}? valType
	/*| decltypeSpecifier */;

theTypeName:
	simpleTemplateId
	| className
	| enumName
	| typedefName;

decltypeSpecifier:
	Decltype LeftParen (oneOrMoreExpressions | Auto) RightParen;

elaboratedTypeSpecifier:
	classKey (
		attributeSpecifierSeq? nestedNameSpecifier? clangppIdentifier
		| simpleTemplateId
		| nestedNameSpecifier Template? simpleTemplateId
	)
	| Enum nestedNameSpecifier? clangppIdentifier;

enumName: clangppIdentifier;

enumSpecifier:
	enumHead LeftBrace (enumeratorList Comma?)? RightBrace;

enumHead:
	enumkey attributeSpecifierSeq? (
		nestedNameSpecifier? clangppIdentifier
	)? enumbase?;

opaqueEnumDeclaration:
	enumkey attributeSpecifierSeq? clangppIdentifier enumbase? Semi;

enumkey: Enum (Class | Struct)?;

enumbase: Colon typeSpecifierSeq;

enumeratorList:
	enumeratorDefinition (Comma enumeratorDefinition)*;

enumeratorDefinition: enumerator (Assign constantExpression)?;

enumerator: clangppIdentifier;

namespaceName: originalNamespaceName | namespaceAlias;

originalNamespaceName: clangppIdentifier;

namespaceDefinition:
	/*Inline?*/ Namespace clangppIdentifier/*?*/ LeftBrace declarationseq RightBrace;

namespaceAlias: clangppIdentifier;

namespaceAliasDefinition:
	Namespace clangppIdentifier Assign qualifiednamespacespecifier Semi;

qualifiednamespacespecifier: nestedNameSpecifier? namespaceName;

usingDeclaration:
	Using ((Typename_? nestedNameSpecifier) | Doublecolon) unqualifiedId Semi;

usingDirective:
	attributeSpecifierSeq? Using Namespace nestedNameSpecifier? namespaceName Semi;

asmDefinition: Asm LeftParen StringLiteral RightParen Semi;

linkageSpecification:
	Extern StringLiteral (
		LeftBrace declarationseq? RightBrace
		| declaration
	);

attributeSpecifierSeq: attributeSpecifier+;

attributeSpecifier:
	LeftBracket LeftBracket attributeList RightBracket RightBracket
	| alignmentspecifier;

alignmentspecifier:
	Alignas LeftParen (theTypeId | constantExpression) Ellipsis? RightParen;

attributeList: attribute (Comma attribute)* Ellipsis?;

attribute: (attributeNamespace Doublecolon)? clangppIdentifier attributeArgumentClause?;

attributeNamespace: clangppIdentifier;

attributeArgumentClause: LeftParen balancedTokenSeq? RightParen;

balancedTokenSeq: balancedtoken+;

balancedtoken:
	LeftParen balancedTokenSeq RightParen
	| LeftBracket balancedTokenSeq RightBracket
	| LeftBrace balancedTokenSeq RightBrace
	| ~(
		LeftParen
		| RightParen
		| LeftBrace
		| RightBrace
		| LeftBracket
		| RightBracket
	)+;

// Declarators
initDeclaratorList:
    initDeclarator
    | initDeclaratorList Comma initDeclarator;

initDeclarator: declarator initializer?;

declarator:
	pointerDeclarator
	| noPointerDeclarator parametersAndQualifiers trailingReturnType;

pointerDeclarator: pointerDeclaratorPrefix* noPointerDeclarator;

pointerDeclaratorPrefix: pointerOperatorWithDoubleStar Const?;

noPointerDeclarator:
	declaratorid attributeSpecifierSeq?
	| noPointerDeclarator parametersAndQualifiers
	| noPointerDeclarator LeftBracket constantExpression? RightBracket attributeSpecifierSeq?
	| LeftParen pointerDeclarator RightParen;

parametersAndQualifiers:
	LeftParen parameterDeclarationClause? RightParen cvqualifierseq? refqualifier?
		exceptionSpecification? attributeSpecifierSeq?;

trailingReturnType:
	Arrow trailingTypeSpecifierSeq abstractDeclarator?;

pointerOperator:
	And attributeSpecifierSeq?
	| AndAnd attributeSpecifierSeq?
	| nestedNameSpecifier? Star attributeSpecifierSeq? cvqualifierseq?;

// ** is tokenized separately as separating conjunction,
// so add special case where ** can be used, which is when
// multiple pointerOperators are allowed to be repeated after each other
pointerOperatorWithDoubleStar:
    pointerOperator
    | nestedNameSpecifier? SEP_CONJ attributeSpecifierSeq? cvqualifierseq?;

cvqualifierseq: cvQualifier+;

cvQualifier: Const | Volatile;

refqualifier: And | AndAnd;

declaratorid: Ellipsis? idExpression;

theTypeId: typeSpecifierSeq abstractDeclarator?;

abstractDeclarator:
	pointerAbstractDeclarator
	| noPointerAbstractDeclarator? parametersAndQualifiers trailingReturnType
	| abstractPackDeclarator;

pointerAbstractDeclarator:
    pointerOperatorWithDoubleStar* (noPointerAbstractDeclarator | pointerOperatorWithDoubleStar);

noPointerAbstractDeclarator:
    (parametersAndQualifiers | LeftParen pointerAbstractDeclarator RightParen) (
        parametersAndQualifiers
        | LeftBracket constantExpression? RightBracket attributeSpecifierSeq?
    )*;

abstractPackDeclarator:
	pointerOperatorWithDoubleStar* noPointerAbstractPackDeclarator;

noPointerAbstractPackDeclarator:
	Ellipsis (
		parametersAndQualifiers
		| LeftBracket constantExpression? RightBracket attributeSpecifierSeq?
	)*;

parameterDeclarationClause:
	parameterDeclarationList parameterDeclarationVarargs?;

parameterDeclarationVarargs: Comma? Ellipsis;

parameterDeclarationList:
	parameterDeclaration (Comma parameterDeclaration)*;

parameterDeclaration:
  declSpecifierSeq declarator
	| attributeSpecifierSeq? declSpecifierSeq (
		(declarator | abstractDeclarator?) (
			Assign initializerClause
		)?
	);

functionDefinition:
	valEmbedContract? attributeSpecifierSeq? declSpecifierSeq? declarator virtualSpecifierSeq? functionBody;

functionBody:
	constructorInitializer? compoundStatement
	| functionTryBlock
	| Assign (Default | Delete) Semi;

initializer:
	braceOrEqualInitializer
	| LeftParen expressionList RightParen;

braceOrEqualInitializer:
	Assign initializerClause
	| bracedInitList;

// EW: Had to flip the two options to not get parsing errors
initializerClause: bracedInitList | expression;

initializerList:
	initializerClause Ellipsis?
	| initializerList Comma initializerClause Ellipsis?;

bracedInitList:
    LeftBrace RightBrace
    | LeftBrace initializerList RightBrace
    | LeftBrace initializerList Comma RightBrace;

// Classes
className: clangppIdentifier | simpleTemplateId;

classSpecifier:
	classHead LeftBrace memberSpecification? RightBrace;

classHead:
	classKey attributeSpecifierSeq? (
		classHeadName classVirtSpecifier?
	)? baseClause?
	| Union attributeSpecifierSeq? (
		classHeadName classVirtSpecifier?
	)?;

classHeadName: nestedNameSpecifier? className;

classVirtSpecifier: Final;

classKey: Class | Struct;

memberSpecification:
	(memberdeclaration | accessSpecifier Colon)+;

memberdeclaration:
	attributeSpecifierSeq? declSpecifierSeq? memberDeclaratorList? Semi
	| functionDefinition
	| usingDeclaration
	| staticAssertDeclaration
	/*| templateDeclaration*/
	| aliasDeclaration
	/*| emptyDeclaration*/;

memberDeclaratorList:
	memberDeclarator (Comma memberDeclarator)*;

memberDeclarator:
	 declarator (virtualSpecifierSeq | { this.IsPureSpecifierAllowed() }? pureSpecifier | { this.IsPureSpecifierAllowed() }? virtualSpecifierSeq pureSpecifier | braceOrEqualInitializer)
    | declarator
    | clangppIdentifier? attributeSpecifierSeq? Colon constantExpression
    ;

virtualSpecifierSeq: virtualSpecifier+;

virtualSpecifier: Override | Final;
/*
 purespecifier: Assign '0'//Conflicts with the lexer ;
 */

pureSpecifier:
    Assign IntegerLiteral;

//Derived classes
baseClause: Colon baseSpecifierList;

baseSpecifierList:
	baseSpecifier Ellipsis? (Comma baseSpecifier Ellipsis?)*;

baseSpecifier:
	attributeSpecifierSeq? (
		baseTypeSpecifier
		| Virtual accessSpecifier? baseTypeSpecifier
		| accessSpecifier Virtual? baseTypeSpecifier
	);

classOrDeclType:
	nestedNameSpecifier? className
	| decltypeSpecifier;

baseTypeSpecifier: classOrDeclType;

accessSpecifier: Private | Protected | Public;

// Special member functions
conversionFunctionId: Operator conversionTypeId;

conversionTypeId: typeSpecifierSeq conversionDeclarator?;

conversionDeclarator: pointerOperator conversionDeclarator?;

constructorInitializer: Colon memInitializerList;

memInitializerList:
	memInitializer Ellipsis? (Comma memInitializer Ellipsis?)*;

memInitializer:
	meminitializerid (
		LeftParen expressionList? RightParen
		| bracedInitList
	);

meminitializerid: classOrDeclType | clangppIdentifier;

// Overloading
operatorFunctionId: Operator theOperator;

literalOperatorId:
	Operator (
		StringLiteral clangppIdentifier
		| UserDefinedStringLiteral
	);

// Templates
templateDeclaration:
	Template Less templateparameterList Greater declaration;

templateparameterList:
	templateParameter (Comma templateParameter)*;

templateParameter: typeParameter | parameterDeclaration;

typeParameter:
	(
		(Template Less templateparameterList Greater)? Class
		| Typename_
	) ((Ellipsis? clangppIdentifier?) | (clangppIdentifier? Assign theTypeId));

simpleTemplateId:
	templateName Less templateArgument Greater
	| templateName Less templateArgumentList? Greater;

templateId:
	simpleTemplateId
	/* | (operatorFunctionId | literalOperatorId) Less templateArgumentList? Greater */;

templateName: clangppIdentifier;

templateArgumentList:
	templateArgument Ellipsis? Comma templateArgumentList
	| templateArgument Ellipsis?;

templateArgument: theTypeId | constantExpression | idExpression;

typeNameSpecifier:
	Typename_ nestedNameSpecifier (
		clangppIdentifier
		| Template? simpleTemplateId
	);

explicitInstantiation: Extern? Template declaration;

explicitSpecialization: Template Less Greater declaration;

// Exception handling
tryBlock: Try compoundStatement handlerSeq;

functionTryBlock:
	Try constructorInitializer? compoundStatement handlerSeq;

handlerSeq: handler+;

handler:
	Catch LeftParen exceptionDeclaration RightParen compoundStatement;

exceptionDeclaration:
	attributeSpecifierSeq? typeSpecifierSeq (
		declarator
		| abstractDeclarator
	)?
	| Ellipsis;

throwExpression: Throw expression?;

exceptionSpecification:
	dynamicExceptionSpecification
	| noeExceptSpecification;

dynamicExceptionSpecification:
	Throw LeftParen typeIdList? RightParen;

typeIdList: theTypeId Ellipsis? (Comma theTypeId Ellipsis?)*;

noeExceptSpecification:
	Noexcept LeftParen constantExpression RightParen
	| Noexcept;

// Preprocessing directives

// Lexer
theOperator:
	New (LeftBracket RightBracket)?
	| Delete (LeftBracket RightBracket)?
	| Plus
	| Minus
	| Star
	| Div
	| Mod
	| Caret
	| And
	| Or
	| Tilde
	| Not
	| NotWord
	| Assign
	| Greater
	| Less
	| GreaterEqual
	| PlusAssign
	| MinusAssign
	| StarAssign
	| ModAssign
	| XorAssign
	| AndAssign
	| OrAssign
	| Less Less
	| Greater Greater
	| RightShiftAssign
	| LeftShiftAssign
	| Equal
	| NotEqual
	| LessEqual
	| AndAnd
	| OrOr
	| PlusPlus
	| MinusMinus
	| Comma
	| ArrowStar
	| Arrow
	| LeftParen RightParen
	| LeftBracket RightBracket;

literal:
	IntegerLiteral
	| CharacterLiteral
	| FloatingLiteral
	| StringLiteral
	| BooleanLiteral
	| PointerLiteral
	| UserDefinedLiteral;



langExpr: expression;
langId: clangppIdentifier;
langConstInt: literal;
langType: typeSpecifier;
langStatement: statement;
langGlobalDecl: declaration;
//valArg: parameterDeclaration;

startSpec: BlockStartSpecImmediate {global specLevel
specLevel += 1};
endSpec: EndSpec {global specLevel
specLevel -= 1};

// ---

VAL_INLINE: EOF EOF;
VAL_ASSERT: 'assert';
VAL_PACKAGE: 'package';
//VAL_BOOL: EOF EOF;

IntegerLiteral:
	DecimalLiteral Integersuffix?
	| OctalLiteral Integersuffix?
	| HexadecimalLiteral Integersuffix?
	| BinaryLiteral Integersuffix?;

CharacterLiteral:
	('u' | 'U' | 'L')? '\'' Cchar+ '\'';

FloatingLiteral:
	Fractionalconstant Exponentpart? Floatingsuffix?
	| Digitsequence Exponentpart Floatingsuffix?;

StringLiteral:
	Encodingprefix?
    (Rawstring
	|'"' Schar* '"');

BooleanLiteral: BoolFalse | BoolTrue;

PointerLiteral: Nullptr;

UserDefinedLiteral:
	UserDefinedIntegerLiteral
	| UserDefinedFloatingLiteral
	| UserDefinedStringLiteral
	| UserDefinedCharacterLiteral;

MultiLineMacro:
	'#' (~[\n]*? '\\' '\r'? '\n')+ ~ [\n]+ ;

Directive: '#' ~ [\n]* ;

fragment Hexquad:
	HEXADECIMALDIGIT HEXADECIMALDIGIT HEXADECIMALDIGIT HEXADECIMALDIGIT;

fragment Identifiernondigit: NONDIGIT;

fragment NONDIGIT: [a-fA-F_]; /* WORKAROUND */

fragment DIGIT: [0-9];

DecimalLiteral: NONZERODIGIT ('\''? DIGIT)*;

OctalLiteral: '0' ('\''? OCTALDIGIT)*;

HexadecimalLiteral: ('0x' | '0X') HEXADECIMALDIGIT (
		'\''? HEXADECIMALDIGIT
	)*;

BinaryLiteral: ('0b' | '0B') BINARYDIGIT ('\''? BINARYDIGIT)*;

fragment NONZERODIGIT: [1-9];

fragment OCTALDIGIT: [0-7];

fragment HEXADECIMALDIGIT: [0-9a-fA-F];

fragment BINARYDIGIT: [01];

Integersuffix:
	Unsignedsuffix Longsuffix?
	| Unsignedsuffix Longlongsuffix?
	| Longsuffix Unsignedsuffix?
	| Longlongsuffix Unsignedsuffix?;

fragment Unsignedsuffix: [uU];

fragment Longsuffix: [lL];

fragment Longlongsuffix: 'll' | 'LL';

fragment Cchar:
	~ ['\\\r\n]
	| Escapesequence;

fragment Escapesequence:
	Simpleescapesequence
	| Octalescapesequence
	| Hexadecimalescapesequence;

fragment Simpleescapesequence:
	'\\\''
	| '\\"'
	| '\\?'
	| '\\\\'
	| '\\a'
	| '\\b'
	| '\\f'
	| '\\n'
	| '\\r'
	| ('\\' ('\r' '\n'? | '\n'))
	| '\\t'
	| '\\v';

fragment Octalescapesequence:
	'\\' OCTALDIGIT
	| '\\' OCTALDIGIT OCTALDIGIT
	| '\\' OCTALDIGIT OCTALDIGIT OCTALDIGIT;

fragment Hexadecimalescapesequence: '\\x' HEXADECIMALDIGIT+;

fragment Fractionalconstant:
	Digitsequence? '.' Digitsequence
	| Digitsequence '.';

fragment Exponentpart:
	'e' SIGN? Digitsequence
	| 'E' SIGN? Digitsequence;

fragment SIGN: [+-];

fragment Digitsequence: DIGIT ('\''? DIGIT)*;

fragment Floatingsuffix: [flFL];

fragment Encodingprefix: 'u8' | 'u' | 'U' | 'L';

fragment Schar:
	~ ["\\\r\n]
	| Escapesequence;

fragment Rawstring: 'R"' (( '\\' ["()] )|~[\r\n (])*? '(' ~[)]*? ')'  (( '\\' ["()]) | ~[\r\n "])*? '"';

UserDefinedIntegerLiteral:
	DecimalLiteral Udsuffix
	| OctalLiteral Udsuffix
	| HexadecimalLiteral Udsuffix
	| BinaryLiteral Udsuffix;

UserDefinedFloatingLiteral:
	Fractionalconstant Exponentpart? Udsuffix
	| Digitsequence Exponentpart Udsuffix;

UserDefinedStringLiteral: StringLiteral Udsuffix;

UserDefinedCharacterLiteral: CharacterLiteral Udsuffix;

fragment Udsuffix: Identifier;

BlockStartSpecImmediate: '/' '*' '@';

BlockCommentStart: '/' '*';

LineCommentStart: '/' '/';

EndSpec:
    '*/' ;

Whitespace: [ \t]+;

Newline: ('\r' '\n'? | '\n');


Identifier: Identifiernondigit Identifiernondigit (Identifiernondigit | DIGIT)*;


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
TRIGGER_OPEN: '{:' ('<'* [0-9]* ':')?;
TRIGGER_CLOSE: ':}';
LITERAL_BAG_OPEN: 'b{';
EMPTY_SEQ_OPEN: '[t:';
EMPTY_SET_OPEN: '{t:';
EMPTY_BAG_OPEN: 'b{t:';
ARROW_LEFT: '<-';

VAL_EXPECT_ERROR_OPEN: '/*'? '[/expect ' [a-zA-Z:]+ ']' '*/'? -> channel(EXPECTED_ERROR_CHANNEL);
VAL_EXPECT_ERROR_CLOSE: '/*'? '[/end]' '*/'? -> channel(EXPECTED_ERROR_CHANNEL);
