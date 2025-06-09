grammar c;

@header {
specLevel = 0
}

start: compilationUnit;
// start: '/* c */ ' 'int main() { ' blockItem+ ' }';

// start: C cCompilationUnit | JAVA javaCompilationUnit | PVL pvlProgram;

//JAVA : '--lang=java\n';
//PVL : '--lang=pvl\n';
//C : '--lang=c\n';

langExpr: assignmentExpression;
langId: clangIdentifier;
langConstInt: Constant;
langType: typeSpecifierWithPointerOrArray;
langStatement: blockItem;
langGlobalDecl: externalDeclaration;
specTrue: 'true';
specFalse: 'false';

BlockStartSpecImmediate: '/' '*@';
EndSpec: '*/';

startSpec: {specLevel==0}? BlockStartSpecImmediate {global specLevel
specLevel += 1};
endSpec: {specLevel==1}? EndSpec {global specLevel
specLevel -= 1};

typeSpecifierWithPointerOrArray : typeSpecifier | typeSpecifier '[' ']' | typeSpecifier '*';

primaryExpression :   valExpr
    |   clangIdentifier
    |   Constant
    |   StringLiteral+
    |   '(' expression ')'
    |   genericSelection
    |   '__extension__'? '(' compoundStatement ')' 
    |   '__builtin_va_arg' '(' unaryExpression ',' typeName ')'
    |   '__builtin_offsetof' '(' typeName ',' unaryExpression ')'
    |   'NULL'
    ;

annotatedPrimaryExpression
    : valEmbedWith? primaryExpression valEmbedThen?
    ;

genericSelection
    :   '_Generic' '(' assignmentExpression ',' genericAssocList ')'
    ;

genericAssocList
    :   genericAssociation
    |   genericAssocList ',' genericAssociation
    ;

genericAssociation
    :   typeName ':' assignmentExpression
    |   'default' ':' assignmentExpression
    ;

postfixExpression
    :   annotatedPrimaryExpression
    |   postfixExpression '[' expression ']'
    |   postfixExpression '(' argumentExpressionList? ')' valEmbedGiven? valEmbedYields?
    |   postfixExpression '.' clangIdentifier
    |   postfixExpression '->' clangIdentifier
    |   postfixExpression '++'
    |   postfixExpression '--'
    |   postfixExpression specPostfix
    |   '(' typeName ')' '{' initializerList '}'
    |   '(' typeName ')' '{' initializerList ',' '}'
    |   '__extension__' '(' typeName ')' '{' initializerList '}'
    |   '__extension__' '(' typeName ')' '{' initializerList ',' '}'
    /*|   gpgpuCudaKernelInvocation*/
    ;

specPostfix
    :   {specLevel>0}? valPostfix
    ;

argumentExpressionList
    :   assignmentExpression
    |   argumentExpressionList ',' assignmentExpression
    ;

unaryExpression
    :   '++' unaryExpression
    |   '--' unaryExpression
    |   unaryOperator castExpression
    |   'sizeof' unaryExpression
    |   'sizeof' '(' typeName ')'
    |   '_Alignof' '(' typeName ')'
    |   '&&'  clangIdentifier 
    |   postfixExpression
    |   specPrefix unaryExpression
    ;

specPrefix
    :   {specLevel>0}? valPrefix
    ;

unaryOperator
    :   ('&' | '*' | '+' | '-' | '~' | '!')
    ;

castExpression
    :   unaryExpression
    |   '(' typeName ')' castExpression
    |   '__extension__' '(' typeName ')' castExpression
    ;

prependExpression
    :   castExpression prependOp prependExpression
    |   castExpression
    ;

prependOp
    :   {specLevel>0}? valPrependOp
    ;

multiplicativeExpression
    :   prependExpression
    |   multiplicativeExpression multiplicativeOp prependExpression
    ;

multiplicativeOp
    : '*'
    | '/'
    | '%'
    | {specLevel>0}? valMulOp
    ;

additiveExpression
    :   multiplicativeExpression
    |   additiveExpression '+' multiplicativeExpression
    |   additiveExpression '-' multiplicativeExpression
    ;

shiftExpression
    :   additiveExpression
    |   shiftExpression '<<' additiveExpression
    |   shiftExpression '>>' additiveExpression
    ;

relationalExpression
    :   shiftExpression
    |   relationalExpression relationalOp shiftExpression
    ;

relationalOp
    :   ('<'|'>'|'<='|'>=')
    |   {specLevel>0}? valInOp
    ;

equalityExpression
    :   relationalExpression
    |   equalityExpression '==' relationalExpression
    |   equalityExpression '!=' relationalExpression
    ;

andExpression
    :   equalityExpression
    |   andExpression '&' equalityExpression
    ;

exclusiveOrExpression
    :   andExpression
    |   exclusiveOrExpression '^' andExpression
    ;

inclusiveOrExpression
    :   exclusiveOrExpression
    |   inclusiveOrExpression '|' exclusiveOrExpression
    ;

logicalAndExpression
    :   inclusiveOrExpression
    |   logicalAndExpression logicalAndOp inclusiveOrExpression
    ;

logicalAndOp
    : '&&'
    | {specLevel>0}? valAndOp
    ;

logicalOrExpression
    :   logicalAndExpression
    |   logicalOrExpression '||' logicalAndExpression
    ;

implicationExpression
    :   logicalOrExpression implicationOp implicationExpression
    |   logicalOrExpression
    ;

implicationOp
    :   {specLevel>0}? valImpOp
    ;

conditionalExpression
    :   implicationExpression
    |   implicationExpression '?' expression ':' conditionalExpression
    ;

assignmentExpression
    :   valEmbedWith? conditionalExpression valEmbedThen?
    |   valEmbedWith? unaryExpression assignmentOperator assignmentExpression valEmbedThen?
    ;

assignmentOperator
    :   ('=' | '*=' | '/=' | '%=' | '+=' | '-=' | '<<=' | '>>=' | '&=' | '^=' | '|=')
    ;

expression
    :   assignmentExpression
    |   expression ',' assignmentExpression
    ;

constantExpression
    :   conditionalExpression
    ;

declaration
    :   valEmbedContract? declarationSpecifiers initDeclaratorList ';'
    /* |   staticAssertDeclaration */
    ;

declarationSpecifiers
    :   declarationSpecifier+?
    ;

declarationSpecifiers2
    :   declarationSpecifier+?
    ;

declarationSpecifier
    :   storageClassSpecifier
    |   typeSpecifier
    |   typeQualifier
    |   functionSpecifier
    // |   alignmentSpecifier skipped for ??
    /*|   gpgpuKernelSpecifier*/
    |   valEmbedModifier
    ;

initDeclaratorList
    :   initDeclarator
    |   initDeclaratorList ',' initDeclarator
    ;

initDeclarator
    :   declarator
    |   declarator '=' initializer
    ;

storageClassSpecifier
    :   'typedef'
    |   'extern'
    |   'static'
    |   '_Thread_local'
    |   'auto'
    |   'register'
    /*| gpgpuLocalMemory*/
    /*| gpgpuGlobalMemory*/
    ;

typeSpecifier
    :   ('void'
    |   'char'
    |   'short'
    |   'int'
    |   'long'
    |   'float'
    |   'double'
    |   'signed'
    |   'unsigned'
    |   '_Bool'
    |   '_Complex'
    )
    |   {specLevel>0}? valType
    //|   atomicTypeSpecifier skipped for ??
    |   structOrUnionSpecifier
    |   enumSpecifier
    |   typedefName
    |   '__typeof__' '(' constantExpression ')' 
    /*|   OPENCL_VECTOR_TYPE '(' typeName ',' Constant  ')'*/
    ;

structOrUnionSpecifier
    :   structOrUnion  clangIdentifier? '{' structDeclarationList '}'
    |   structOrUnion  clangIdentifier
    ;

structOrUnion
    :   'struct'
    //|   'union' skipped for no support (#1291)
    ;

structDeclarationList
    :   structDeclaration
    |   structDeclarationList structDeclaration
    ;

structDeclaration 
    :   specifierQualifierList structDeclaratorList ';'
    |   specifierQualifierList ';'
    /* |   staticAssertDeclaration */
    ;

specifierQualifierList
    :   typeSpecifier specifierQualifierList?
    |   typeQualifier specifierQualifierList?
    ;

structDeclaratorList
    :   structDeclarator
    |   structDeclaratorList ',' structDeclarator
    ;

structDeclarator
    :   declarator
    |   declarator? ':' constantExpression
    ;

enumSpecifier
    :   'enum' clangIdentifier? '{' enumeratorList '}'
    |   'enum' clangIdentifier? '{' enumeratorList ',' '}'
    |   'enum' clangIdentifier
    ;

enumeratorList
    :   enumerator
    |   enumeratorList ',' enumerator
    ;

enumerator
    :   enumerationConstant
    |   enumerationConstant '=' constantExpression
    ;

enumerationConstant
    :   clangIdentifier
    ;

atomicTypeSpecifier
    :   '_Atomic' '(' typeName ')'
    ;

typeQualifier
    :   'const'
    |   'restrict'
    |   'volatile'
    |   '_Atomic'
    ;

functionSpecifier
    :   ('inline'
    |   '_Noreturn'
    |   '__inline__' 
    |   '__stdcall')
    |   gccAttributeSpecifier
    |   '__declspec' '(' clangIdentifier ')'
    ;

alignmentSpecifier
    :   '_Alignas' '(' typeName ')'
    |   '_Alignas' '(' constantExpression ')'
    ;

declarator
    :   pointer? directDeclarator /* gccDeclaratorExtension* */
    ;

directDeclarator
    :   clangIdentifier
    |   directDeclarator '[' typeQualifierList? assignmentExpression ']'
    |   directDeclarator '[' 'static' typeQualifierList? assignmentExpression ']'
    |   directDeclarator '[' typeQualifierList 'static' assignmentExpression ']'
    |   {specLevel>0}? directDeclarator '[' typeQualifierList? '*' ']'
    |   directDeclarator '(' parameterTypeList ')'
    |   directDeclarator '(' identifierList? ')'
    ;

gccDeclaratorExtension
    :   '__asm' '(' StringLiteral+ ')'
    |   gccAttributeSpecifier
    ;

gccAttributeSpecifier
    :   '__attribute__' '(' '(' gccAttributeList ')' ')'
    ;

gccAttributeList
    :   gccAttributeListNonEmpty
    |   
    ;

gccAttributeListNonEmpty
    :   gccAttributeListNonEmpty ',' gccAttribute
    |   gccAttribute
    ;

gccAttribute
    : clangIdentifier 
        parenthesizedArgumentExpressionList?
    |   
    ;

parenthesizedArgumentExpressionList : '(' argumentExpressionList? ')' ;

pointer
    :   '*' typeQualifierList?
    |   '*' typeQualifierList? pointer
    |   '**' typeQualifierList?
    |   '**' typeQualifierList? pointer
    /*|   '^' typeQualifierList? */
    /*|   '^' typeQualifierList? pointer  */
    ;

typeQualifierList
    :   typeQualifier
    |   typeQualifierList typeQualifier
    ;

parameterTypeList
    :   parameterList
    |   parameterList ',' '...'
    ;

parameterList
    :   parameterDeclaration
    |   parameterList ',' parameterDeclaration
    ;

parameterDeclaration
    :   declarationSpecifiers declarator
    |   declarationSpecifiers2 abstractDeclarator?
    ;

identifierList
    :   clangIdentifier
    |   identifierList ',' clangIdentifier
    ;

typeName
    :   specifierQualifierList abstractDeclarator?
    ;

abstractDeclarator
    :   pointer
    |   pointer? directAbstractDeclarator /*gccDeclaratorExtension*/
    ;

directAbstractDeclarator
    :   '(' abstractDeclarator ')' /*gccDeclaratorExtension* */
    |   '[' typeQualifierList? assignmentExpression ']'
    |   '[' 'static' typeQualifierList? assignmentExpression ']'
    |   '[' typeQualifierList 'static' assignmentExpression ']'
    |   {specLevel>0}? '[' '*' ']'
    |   '(' parameterTypeList? ')' /*gccDeclaratorExtension* */
    |   directAbstractDeclarator '[' typeQualifierList? assignmentExpression? ']'
    |   directAbstractDeclarator '[' 'static' typeQualifierList? assignmentExpression ']'
    |   directAbstractDeclarator '[' typeQualifierList 'static' assignmentExpression ']'
    |   {specLevel>0}? directAbstractDeclarator '[' '*' ']'
    |   directAbstractDeclarator '(' parameterTypeList? ')' /* gccDeclaratorExtension* */
    ;

typedefName
    :   clangIdentifier
    ;

initializer
    :   '{' initializerList '}'
    |   '{' initializerList ',' '}'
    |   assignmentExpression
    ;

initializerList
    :   designation? initializer
    |   initializerList ',' designation? initializer
    ;

designation
    :   designatorList '='
    ;

designatorList
    :   designator
    |   designatorList designator
    ;

designator
    :   '[' constantExpression ']'
    |   '.' clangIdentifier
    ;

staticAssertDeclaration
    :   '_Static_assert' '(' constantExpression ',' StringLiteral+ ')' ';'
    ;

statement
    :   labeledStatement
    |   compoundStatement
    |   expressionStatement
    |   selectionStatement
    |   iterationStatement
    |   jumpStatement
    |   ('__asm' | '__asm__') ('volatile' | '__volatile__') '(' logicalOrExpressionList? logicalOrExpressionListColonList ')' ';'
    |   valEmbedStatementBlock
    |   {specLevel>0}? valStatement
    /*|   gpgpuBarrier*/
    /*|   gpgpuAtomicBlock*/
    ;

logicalOrExpressionListColonList
    :   ':' logicalOrExpressionList? logicalOrExpressionListColonList
    |   
    ;

logicalOrExpressionList
    :   logicalOrExpression
    |   logicalOrExpressionList ',' logicalOrExpression
    ;

labeledStatement
    :   clangIdentifier ':' statement
    |   'case' constantExpression ':' statement
    |   'default' ':' statement
    ;

compoundStatement
    :   '{' blockItemList? '}'
    /*|   ompBlockPragma '{' valEmbedContract? blockItemList? '}'*/
    ;

blockItemList
    :   blockItem
    |   blockItemList blockItem
    ;

blockItem
    :   declaration
    |   statement
    ;

expressionStatement
    :   expression? ';'
    ;

selectionStatement
    :   'if' '(' expression ')' statement elseBranch?
    |   'switch' '(' expression ')' statement
    ;

elseBranch: 'else' statement;

iterationStatement
    :   valEmbedContract? 'while' '(' expression ')' valEmbedContract? statement
    |   'do' statement 'while' '(' expression ')' ';'
    |   valEmbedContract? /*ompLoopPragma?*/ 'for' '(' expression? ';' expression? ';' expression? ')' valEmbedContract? statement
    |   valEmbedContract? /*ompLoopPragma?*/ 'for' '(' declaration expression? ';' expression? ')' valEmbedContract? statement
    ;

jumpStatement
    :   'goto' clangIdentifier ';'
    //|   'continue' ';'
    //|   'break' ';'
    |   'return' expression? ';'
    |   'goto' unaryExpression ';' 
    ;

compilationUnit
    :   externalDeclaration+ EOF
    ;

externalDeclaration
    :   functionDefinition
    |   declaration
    |   valEmbedGlobalDeclarationBlock
    //|   ';' 
    ;

specificationDeclaration : Placeholder ;

functionDefinition
    :   valEmbedContract? declarationSpecifiers directDeclarator '(' identifierList? ')' declarationList? compoundStatement
    ;

declarationList
    :   declaration
    |   declarationList declaration
    ;

clangIdentifier
    :   Identifier
    |   valIdentifier
    ;

VAL_INLINE: EOF EOF;
VAL_ASSERT: 'assert';
VAL_TRUE: 'true';
VAL_FALSE: 'false';
VAL_SIZEOF: EOF EOF;
VAL_PACKAGE: 'package';
CONS: '::';

Placeholder : EOF EOF ;

Null : 'NULL';

Auto : 'auto';
Break : 'break';
Case : 'case';
Char : 'char';
Const : 'const';
Continue : 'continue';
Default : 'default';
Do : 'do';
Double : 'double';
Else : 'else';
Enum : 'enum';
Extern : 'extern';
Float : 'float';
For : 'for';
Goto : 'goto';
If : 'if';
Inline: 'inline';
Int : 'int';
Long : 'long';
Register : 'register';
Restrict : 'restrict';
Return : 'return';
Short : 'short';
Signed : 'signed';
Sizeof : 'sizeof';
Static : 'static';
Struct : 'struct';
Switch : 'switch';
Typedef : 'typedef';
Union : 'union';
Unsigned : 'unsigned';
Void : 'void';
Volatile : 'volatile';
While : 'while';

Alignas : '_Alignas';
Alignof : '_Alignof';
Atomic : '_Atomic';
Bool : '_Bool';
Complex : '_Complex';
Generic : '_Generic';
Imaginary : '_Imaginary';
Noreturn : '_Noreturn';
StaticAssert : '_Static_assert';
ThreadLocal : '_Thread_local';

LeftParen : '(';
RightParen : ')';
LeftBracket : '[';
RightBracket : ']';
LeftBrace : '{';
RightBrace : '}';

Less : '<';
LessEqual : '<=';
Greater : '>';
GreaterEqual : '>=';
LeftShift : '<<';
RightShift : '>>';

Plus : '+';
PlusPlus : '++';
Minus : '-';
MinusMinus : '--';
Star : '*';
Div : '/';
Mod : '%';

And : '&';
Or : '|';
AndAnd : '&&';
OrOr : '||';
Caret : '^';
Not : '!';
Tilde : '~';

Question : '?';
Colon : ':';
Semi : ';';
Comma : ',';

Assign : '=';
// '*=' | '/=' | '%=' | '+=' | '-=' | '<<=' | '>>=' | '&=' | '^=' | '|='
StarAssign : '*=';
DivAssign : '/=';
ModAssign : '%=';
PlusAssign : '+=';
MinusAssign : '-=';
LeftShiftAssign : '<<=';
RightShiftAssign : '>>=';
AndAssign : '&=';
XorAssign : '^=';
OrAssign : '|=';

Equal : '==';
NotEqual : '!=';

Arrow : '->';
Dot : '.';
Ellipsis : '...';

fragment
IdentifierNondigit
    :   Nondigit
    //|   UniversalCharacterName
    //|   // other implementation-defined characters...
    ;

fragment
Nondigit
    :   [a-zA-Z_]
    ;

fragment
Digit
    :   [0-9]
    ;

fragment
UniversalCharacterName
    :   '\\u' HexQuad
    |   '\\U' HexQuad HexQuad
    ;

fragment
HexQuad
    :   HexadecimalDigit HexadecimalDigit HexadecimalDigit HexadecimalDigit
    ;

Constant
    :   IntegerConstant
    |   FloatingConstant
    //|   EnumerationConstant
    |   CharacterConstant
    ;

fragment
IntegerConstant
    :   DecimalConstant IntegerSuffix?
    |   OctalConstant IntegerSuffix?
    |   HexadecimalConstant IntegerSuffix?
    ;

fragment
DecimalConstant
    :   NonzeroDigit Digit*
    ;

fragment
OctalConstant
    :   '0' OctalDigit*
    ;

fragment
HexadecimalConstant
    :   HexadecimalPrefix HexadecimalDigit+
    ;

fragment
HexadecimalPrefix
    :   '0' [xX]
    ;

fragment
NonzeroDigit
    :   [1-9]
    ;

fragment
OctalDigit
    :   [0-7]
    ;

fragment
HexadecimalDigit
    :   [0-9a-fA-F]
    ;

fragment
IntegerSuffix
    :   UnsignedSuffix LongSuffix?
    |   UnsignedSuffix LongLongSuffix
    |   LongSuffix UnsignedSuffix?
    |   LongLongSuffix UnsignedSuffix?
    ;

fragment
UnsignedSuffix
    :   [uU]
    ;

fragment
LongSuffix
    :   [lL]
    ;

fragment
LongLongSuffix
    :   'll' | 'LL'
    ;

fragment
FloatingConstant
    :   DecimalFloatingConstant
    |   HexadecimalFloatingConstant
    ;

fragment
DecimalFloatingConstant
    :   FractionalConstant ExponentPart? FloatingSuffix?
    |   DigitSequence ExponentPart FloatingSuffix?
    ;

fragment
HexadecimalFloatingConstant
    :   HexadecimalPrefix HexadecimalFractionalConstant BinaryExponentPart FloatingSuffix?
    |   HexadecimalPrefix HexadecimalDigitSequence BinaryExponentPart FloatingSuffix?
    ;

fragment
FractionalConstant
    :   DigitSequence? '.' DigitSequence
    |   DigitSequence '.'
    ;

fragment
ExponentPart
    :   'e' Sign? DigitSequence
    |   'E' Sign? DigitSequence
    ;

fragment
Sign
    :   '+' | '-'
    ;

fragment
DigitSequence
    :   Digit+
    ;

fragment
HexadecimalFractionalConstant
    :   HexadecimalDigitSequence? '.' HexadecimalDigitSequence
    |   HexadecimalDigitSequence '.'
    ;

fragment
BinaryExponentPart
    :   'p' Sign? DigitSequence
    |   'P' Sign? DigitSequence
    ;

fragment
HexadecimalDigitSequence
    :   HexadecimalDigit+
    ;

fragment
FloatingSuffix
    :   'f' | 'l' | 'F' | 'L'
    ;

fragment
CharacterConstant
    :   '\'' CCharSequence '\''
    |   'L\'' CCharSequence '\''
    |   'u\'' CCharSequence '\''
    |   'U\'' CCharSequence '\''
    ;

fragment
CCharSequence
    :   CChar+
    ;

fragment
CChar
    :   ~['\\\r\n]
    |   EscapeSequence
    ;

fragment
EscapeSequence
    :   SimpleEscapeSequence
    |   OctalEscapeSequence
    |   HexadecimalEscapeSequence
    //|   UniversalCharacterName
    ;

fragment
SimpleEscapeSequence
    :   '\\' ['"?abfnrtv\\]
    ;

fragment
OctalEscapeSequence
    :   '\\' OctalDigit
    |   '\\' OctalDigit OctalDigit
    |   '\\' OctalDigit OctalDigit OctalDigit
    ;

fragment
HexadecimalEscapeSequence
    :   '\\x' HexadecimalDigit+
    ;

StringLiteral
    :   EncodingPrefix? '"' SCharSequence? '"'
    ;

fragment
EncodingPrefix
    :   'u8'
    |   'u'
    |   'U'
    |   'L'
    ;

fragment
SCharSequence
    :   SChar+
    ;

fragment
SChar
    :   ~["\\\r\n]
    |   EscapeSequence
    ;

/*
LineDirective
    :   '#' Whitespace? DecimalConstant Whitespace? StringLiteral ~[\r\n]* -> channel(LINE_DIRECTIVE_CHANNEL)
    ;
*/

/*
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
*/

// extensions
EXTENSION__: '__extension__';
BUILTIN_VA_ARG: '__builtin_va_arg';
BUILTIN_OFFSETOF: '__builtin_offsetof';
TYPEOF__: '__typeof__';
INLINE__: '__inline__';
STDCALL: '__stdcall';
DECLSPEC: '__declspec';
ASM: '__asm';
ASM__: '__asm__';
ATTRIBUTE__: '__attribute__';
VOLATILE__: '__volatile__';

Identifier
    :  IdentifierNondigit
        (  IdentifierNondigit
        |   Digit
        )*
    ;

/*
ExtraAt
    :  ('\n'|'\r\n') [ \t\u000C]* '@' {inBlockSpec}? -> skip
    ;
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
 | 'decreases' valDecreasesMeasure ';'
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
 //| LANG_ID_ESCAPE # valIdEscape
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
 : (/*'resource' |*/ 'process' | 'frac' | 'zfrac' | 'rational' | 'bool' | 'ref' | 'any' | 'nothing' /*| 'string'*/) # valPrimaryType
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
 // | 'model' langId '{' valModelDeclaration* '}' # valModel
 | 'ghost' langGlobalDecl # valGhostDecl
 | 'adt' langId valTypeVars? '{' valAdtDeclaration* '}' # valAdtDecl
 //| 'prover_type' langId valProverInterpretations ';' # valProverType skipped for no support (#1290)
 //| 'prover_function' langType langId '(' valArgList? ')' valProverInterpretations ';' # valProverFunction skipped for no support (#1290)
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
 | 'right' '+'
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
 : ('pure' | 'inline' | /* 'thread_local' | */ 'bip_annotation')
 //| langStatic # valStatic
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
 | startSpec 'frame' valContractClause+ '{' endSpec langStatement+ startSpec '}' endSpec
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

// VAL_EXPECT_ERROR_OPEN: '/*'? '[/expect ' [a-zA-Z:]+ ']' '*/'? -> channel(EXPECTED_ERROR_CHANNEL);
// VAL_EXPECT_ERROR_CLOSE: '/*'? '[/end]' '*/'? -> channel(EXPECTED_ERROR_CHANNEL);

// 
// cCompilationUnit
//     :   cTranslationUnit+ EOF
//     ;
// 
// cTranslationUnit
//     :   cExternalDeclaration
//     |   cTranslationUnit cExternalDeclaration
//     ;
// 
// cExternalDeclaration
//     :   cFunctionDefinition
//     |   cDeclaration
//     |   cValEmbedGlobalDeclarationBlock
//     |   ';' // stray ;
//     ;
// 
// cFunctionDefinition
//     :   cValEmbedContract? cDeclarationSpecifiers cDeclarator cDeclarationList? cCompoundStatement
//     ;
// 
// cDeclarationSpecifiers: Q;
// 
// cDeclarationList
//     :   cDeclaration
//     |   cDeclarationList cDeclaration
//     ;
// 
// cDeclarator
//     :   cPointer? cDirectDeclarator cGccDeclaratorExtension*
//     ;
// 
// cDirectDeclarator
//     :   cClangIdentifier /* TODO */
//     ;
// 
// CIdentifier
//     :  [A-Za-z] [A-Za-z0-9]*
//     ;
// 
// cClangIdentifier
//     :   CIdentifier
//     |   cValIdentifier
//     ;
// 
// 
// cCompoundStatement
//     :   '{' cBlockItemList? '}'
//     |   cOmpBlockPragma '{' cValEmbedContract? cBlockItemList? '}'
//     ;
// 
// cOmpBlockPragma: Q;
// 
// cBlockItemList
//     :   cBlockItem
//     |   cBlockItemList cBlockItem
//     ;
// 
// cBlockItem
//     :   cDeclaration
//     |   cStatement
//     ;
// 
// cDeclaration
//     :   cValEmbedContract? cDeclarationSpecifiers cInitDeclaratorList? ';'
//     |   cStaticAssertDeclaration
//     ;
// 
// cInitDeclaratorList: Q;
// cStaticAssertDeclaration: Q;
// 
// cStatement
//     :   cLabeledStatement
//     |   cCompoundStatement
//     |   cExpressionStatement
//     |   cSelectionStatement
//     |   cIterationStatement
//     |   cJumpStatement
//     |   ('__asm' | '__asm__') ('volatile' | '__volatile__') '(' cLogicalOrExpressionList? cLogicalOrExpressionListColonList ')' ';'
//     |   cValEmbedStatementBlock
//     |   {specLevel>0}? cValStatement
//     |   cGpgpuBarrier
//     |   cGpgpuAtomicBlock
//     ;
// 
// cValEmbedContract: cValEmbedContractBlock+;
// 
// cValEmbedContractBlock
//  : cStartSpec cValContractClause* cEndSpec
//  | {specLevel>0}? cValContractClause+
//  ;
// 
// CBlockStartSpecImmediate: '/*@';
// CEndSpec: '*/';
// cStartSpec: CBlockStartSpecImmediate {specLevel++;};
// cEndSpec: CEndSpec {specLevel--;};
// 
// cValContractClause
//  : 'modifies' cValIdList ';'
//  | 'accessible' cValIdList ';'
//  | 'requires' cLangExpr ';'
//  | 'ensures' cLangExpr ';'
//  | 'given' cLangType cLangId ';'
//  | 'yields' cLangType cLangId ';'
//  | 'context_everywhere' cLangExpr ';'
//  | 'context' cLangExpr ';'
//  | 'loop_invariant' cLangExpr ';'
//  | 'kernel_invariant' cLangExpr ';'
//  | 'signals' '(' cLangType cLangId ')' cLangExpr ';'
//  | 'lock_invariant' cLangExpr ';'
//  | 'decreases' cValDecreasesMeasure? ';'
//  ;
// 
// cValIdList: Q;
// cLangId: Q;
// cLangType: Q;
// cValDecreasesMeasure: Q;
// 
// cLangExpr: cAssignmentExpression;
// 
// cAssignmentExpression
//     :   cValEmbedWith? cConditionalExpression cValEmbedThen?
//     |   cValEmbedWith? cUnaryExpression cAssignmentOperator cAssignmentExpression cValEmbedThen?
//     ;
// 
// cValEmbedWith: Q;
// cConditionalExpression: Q;
// cValEmbedThen: Q;
// 
// cUnaryExpression
//     :   '++' cUnaryExpression
//     |   '--' cUnaryExpression
//     |   cUnaryOperator cCastExpression
//     |   'sizeof' cUnaryExpression
//     |   'sizeof' '(' cTypeName ')'
//     |   '_Alignof' '(' cTypeName ')'
//     |   '&&'  cClangIdentifier // GCC extension address of label
//     |   cPostfixExpression
//     |   cSpecPrefix cUnaryExpression
//     ;
// 
// cUnaryOperator
//     :   ('&' | '*' | '+' | '-' | '~' | '!')
//     ;
// cCastExpression: Q;
// 
// cTypeName
//     :   cSpecifierQualifierList cAbstractDeclarator?
//     ;
// 
// cAbstractDeclarator
//     :   cPointer
//     |   cPointer? directAbstractDeclarator gccDeclaratorExtension*
//     ;
// gccDeclaratorExtension: Q;
// directAbstractDeclarator: Q;
// 
// cSpecifierQualifierList
//     :   cTypeSpecifier cSpecifierQualifierList?
//     |   cTypeQualifier cSpecifierQualifierList?
//     ;
// 
// cTypeSpecifier
//     :   ('void'
//     |   'char'
//     |   'short'
//     |   'int'
//     |   'long'
//     |   'float'
//     |   'double'
//     |   'signed'
//     |   'unsigned'
//     |   '_Bool'
//     |   '_Complex'
//     )
// /*
//     |   {specLevel>0}? valType
//     |   atomicTypeSpecifier
//     |   structOrUnionSpecifier
//     |   enumSpecifier
//     |   typedefName
//     |   '__typeof__' '(' constantExpression ')' // GCC extension
//     |   OPENCL_VECTOR_TYPE '(' typeName ',' Constant  ')'
//   */  ;
// 
// cTypeQualifier: Q;
// cPostfixExpression: Q;
// cSpecPrefix: Q;
// 
// cAssignmentOperator
//     :   ('=' | '*=' | '/=' | '%=' | '+=' | '-=' | '<<=' | '>>=' | '&=' | '^=' | '|=')
//     ;
// 
// cLabeledStatement: Q;
// cExpressionStatement: Q;
// cSelectionStatement: Q;
// cIterationStatement: Q;
// cJumpStatement: Q;
// cLogicalOrExpressionList: Q;
// cLogicalOrExpressionListColonList: Q;
// cValEmbedStatementBlock: Q;
// cValStatement: Q;
// cGpgpuBarrier: Q;
// cGpgpuAtomicBlock: Q;
// 
// cPointer: Q;
// cGccDeclaratorExtension: Q;
// cValIdentifier: Q;
// 
// cValEmbedGlobalDeclarationBlock: Q;
// 
// pvlProgram  : pvlProgramDecl+ EOF ;
// 
// pvlProgramDecl : pvlValGlobalDeclaration | pvlDeclClass | pvlEnumDecl | pvlMethod | pvlDeclVeyMontSeqProg | pvlVesuvEntry ;
// 
// pvlValGlobalDeclaration: Q;
// 
// pvlDeclClass: Q;
// 
// pvlEnumDecl : 'enum' pvlIdentifier '{' pvlIdentifierList? ','? '}' ;
// 
// pvlIdentifier: Q;
// 
// pvlIdentifierList: Q;
// 
// pvlMethod: Q;
// 
// pvlDeclVeyMontSeqProg: Q;
// 
// pvlVesuvEntry : Q;
// 
// javaCompilationUnit
//     :   /*javaPackageDeclaration?*/ /*javaImportDeclaration**/ javaTypeDeclaration+ EOF
//     ;
// 
// javaTypeDeclaration
//     :   javaClassOrInterfaceModifier* javaClassDeclaration /*
//     |   classOrInterfaceModifier* enumDeclaration
//     |   classOrInterfaceModifier* interfaceDeclaration
//     |   classOrInterfaceModifier* annotationTypeDeclaration
//     |   valEmbedGlobalDeclarationBlock
//     */|    ';'
//     ;
// 
// javaClassOrInterfaceModifier
//     : javaAnnotation       // class or interface
//     |   (   'public'     // class or interface
//         |   'protected'  // class or interface
//         |   'private'    // class or interface
//         |   'static'     // class or interface
//         |   'abstract'   // class or interface
//         |   'final'      // class only -- does not apply to interfaces
//         |   'strictfp'   // class or interface
//         )
//     |   javaValEmbedModifier
//     ;
// 
// javaClassDeclaration
//     :   javaValEmbedContract? 'class' javaIdentifier javaTypeParameters? javaExt? javaImp? javaClassBody
//     ;
// javaExt: 'extends' javaType;
// javaImp: 'implements' javaTypeList;
// 
// javaClassBody
//     :   '{' javaClassBodyDeclaration* '}'
//     ;
// 
// javaClassBodyDeclaration
//     :   ';'
//     |   'static'? javaBlock
//     |   javaValEmbedContract? javaModifier* javaMemberDeclaration
//     |   javaValEmbedClassDeclarationBlock
//     ;
// 
// javaModifier
//     :   javaClassOrInterfaceModifier
//     |   (   'native'
//         |   'synchronized'
//         |   'transient'
//         |   'volatile'
//         )
//     ;
// 
// 
// javaBlock
//     :   '{' javaBlockStatement* '}'
//     ;
// 
// javaBlockStatement
//     :   javaLocalVariableDeclarationStatement
//     |   javaStatement
//     |   javaTypeDeclaration
//     |   javaValEmbedStatementBlock
//     ;
// 
// javaLocalVariableDeclarationStatement: Q;
// javaStatement: Q;
// javaValEmbedStatementBlock: Q;
// 
// javaMemberDeclaration: Q;
// javaValEmbedClassDeclarationBlock: Q;
// javaTypeParameters: Q;
// javaType: Q;
// javaTypeList: Q;
// javaAnnotation: Q;
// javaValEmbedModifier: Q;
// 
// javaValEmbedContract: javaValEmbedContractBlock+;
// 
// javaValEmbedContractBlock
//  : javaStartSpec javaValContractClause* javaEndSpec
//  ;
// 
// javaStartSpec: Q;
// javaValContractClause: Q;
// javaValIdentifier: Q;
// javaEndSpec: Q;
// 
// JavaIdentifier
//     :   [a-zA-Z$_] [a-zA-Z0-9$_]*
//     ;
// 
// javaIdentifier
//     : JavaIdentifier
//     | javaValIdentifier
//     ;
// 
// Q : '°';
