grammar java;

@header {
specLevel = 0
}

program : compilationUnit;

// starting point for parsing a java file
compilationUnit
    :   /* packageDeclaration? */ /* importDeclaration* */ typeDeclaration+ EOF
    ;

packageDeclaration
    :   annotation* 'package' qualifiedName ';'
    ;

importDeclaration
    :   'import' 'static'? qualifiedName importAll? ';'
    ;
importAll: '.' '*';

typeDeclaration
    :   classOrInterfaceModifier* classDeclaration
    |   classOrInterfaceModifier* enumDeclaration
    |   classOrInterfaceModifier* interfaceDeclaration
    |   classOrInterfaceModifier* annotationTypeDeclaration
    |   valEmbedGlobalDeclarationBlock
    /*|   ';' */
    ;

modifier
    :   classOrInterfaceModifier
    |   (   'native'
        |   'synchronized'
        |   'transient'
        |   'volatile'
        )
    ;

classOrInterfaceModifier
    : annotation       // class or interface
    |   (   'public'     // class or interface
        |   'protected'  // class or interface
        |   'private'    // class or interface
        |   'static'     // class or interface
        |   'abstract'   // class or interface
        |   'final'      // class only -- does not apply to interfaces
        |   'strictfp'   // class or interface
        )
    |   valEmbedModifier
    ;

variableModifier
    :   'final'
    |   annotation
    ;

classDeclaration
    :   valEmbedContract? 'class' javaIdentifier typeParameters? ext? imp? classBody
    ;
//ext: 'extends' type;
ext: 'extends' classOrInterfaceType;
imp: 'implements' typeList;

typeParameters
    :   '<' typeParameterList '>'
    ;

typeParameterList
    :   typeParameter
    |   typeParameter ',' typeParameterList
    ;

typeParameter
    :   javaIdentifier typeParameterBound?
    ;
typeParameterBound: 'extends' typeBound;

typeBound
    :   type
    |   type '&' typeBound
    ;

enumDeclaration
    :   ENUM javaIdentifier imp?
        '{' enumConstants? ','? enumBodyDeclarations? '}'
    ;

enumConstants
    :   enumConstant
    |   enumConstants ',' enumConstant
    ;

enumConstant
    :   annotation* javaIdentifier arguments? classBody?
    ;

enumBodyDeclarations
    :   ';' classBodyDeclaration*
    ;

interfaceDeclaration
    :   'interface' javaIdentifier typeParameters? intExt? interfaceBody
    ;
intExt: 'extends' typeList;

typeList
    :   /*type */ classOrInterfaceType
    |   /*type */ classOrInterfaceType ',' typeList
    ;

classBody
    :   '{' classBodyDeclaration* '}'
    ;

interfaceBody
    :   '{' interfaceBodyDeclaration* '}'
    ;

classBodyDeclaration
    :   ';'
    |   'static'? block
    |   valEmbedContract? modifier* memberDeclaration
    |   valEmbedClassDeclarationBlock
    ;

memberDeclaration
    :   methodDeclaration
    |   genericMethodDeclaration
    |   fieldDeclaration
    |   constructorDeclaration
    |   genericConstructorDeclaration
    |   interfaceDeclaration
    |   annotationTypeDeclaration
    |   classDeclaration
    |   enumDeclaration
    ;

/* We use rule this even for void methods which cannot have [] after parameters.
   This simplifies grammar and we can consider void to be a type, which
   renders the [] matching as a context-sensitive issue or a semantic check
   for invalid return type after parsing.
 */
methodDeclaration
    :   typeOrVoid javaIdentifier formalParameters dims? throwy? methodBodyOrEmpty
    ;

throwy
    :   'throws' qualifiedNameList
    ;

genericMethodDeclaration
    :   typeParameters methodDeclaration
    ;

constructorDeclaration
    :   javaIdentifier formalParameters throwy?
        constructorBody
    ;

genericConstructorDeclaration
    :   typeParameters constructorDeclaration
    ;

fieldDeclaration
    :   type variableDeclarators ';'
    ;

interfaceBodyDeclaration
    :   valEmbedContract? modifier* interfaceMemberDeclaration
    |   valEmbedClassDeclarationBlock
    |   ';'
    ;

interfaceMemberDeclaration
    :   constDeclaration
    |   interfaceMethodDeclaration
    |   genericInterfaceMethodDeclaration
    |   interfaceDeclaration
    |   annotationTypeDeclaration
    |   classDeclaration
    |   enumDeclaration
    ;

constDeclaration
    :   type constantDeclaratorList ';'
    ;

constantDeclaratorList
    :   constantDeclarator
    |   constantDeclarator ',' constantDeclaratorList
    ;

constantDeclarator
    :   javaIdentifier dims? '=' variableInitializer
    ;

// see matching of [] comment in methodDeclaratorRest
interfaceMethodDeclaration
    :   typeOrVoid javaIdentifier formalParameters dims? throwy? ';'
    ;

genericInterfaceMethodDeclaration
    :   typeParameters interfaceMethodDeclaration
    ;

variableDeclarators
    :   variableDeclarator
    |   variableDeclarator ',' variableDeclarators
    ;

variableDeclarator
    :   variableDeclaratorId variableDeclaratorInit?
    ;
variableDeclaratorInit: '=' variableInitializer;

variableDeclaratorId
    :   javaIdentifier dims?
    ;

variableInitializer
    :   arrayInitializer
    |   expression
    ;

arrayInitializer
    :   '{' '}'
    |   '{' variableInitializerList ','? '}'
    ;

variableInitializerList
    :   variableInitializer
    |   variableInitializer ',' variableInitializerList
    ;

enumConstantName
    :   javaIdentifier
    ;

type
    // The specification types must go first, to prevent something like "Class not found: resource"
    :   {specLevel>0}? valType
    |   classOrInterfaceType dims?
    |   primitiveType dims?
    ;

typeOrVoid
    : 'void'
    | type
    ;

dims: dim+;
dim: '[' ']';

classOrInterfaceType
    :   javaIdentifier typeArguments?
    |   classOrInterfaceType '.' javaIdentifier typeArguments?
    ;

primitiveType
    :(  'boolean'
    |   'char'
    |   'byte'
    |   'short'
    |   'int'
    |   'long'
    |   'float'
    |   'double'
    );

typeArguments
    :   '<' typeArgumentList '>'
    ;

typeArgumentList
    :   typeArgument
    |   typeArgument ',' typeArgumentList
    ;

typeArgument
    :   type
    |   '?' boundType?
    ;

boundType : ('extends' | 'super') type ;

qualifiedNameList
    :   qualifiedName
    |   qualifiedName ',' qualifiedNameList
    ;

formalParameters
    :   '(' formalParameterList? ')'
    ;

formalParameterList
    :   varargsFormalParameter
    |   initFormalParameterList
    |   initFormalParameterList ',' varargsFormalParameter
    ;

initFormalParameterList
    :   formalParameter
    |   formalParameter ',' initFormalParameterList
    ;

formalParameter
    :   variableModifier* type variableDeclaratorId
    ;

varargsFormalParameter
    :   variableModifier* type '...' variableDeclaratorId
    ;

methodBody
    :   block
    ;

methodBodyOrEmpty
    :   ';'
    |   methodBody
    ;

constructorBody
    :   block
    ;

qualifiedName
    :   javaIdentifier
    |   javaIdentifier '.' qualifiedName
    ;

literal
    :   IntegerLiteral
    |   FloatingPointLiteral
    |   CharacterLiteral
    |   StringLiteral
    |   (TrueLiteral|FalseLiteral)
    |   'null'
    ;

// ANNOTATIONS

annotation
    :   '@' annotationName annotationArgs?
    ;

annotationArgs :   '(' annotationArgsElems? ')' ;

annotationArgsElems
    : elementValuePairs
    | elementValue
    ;

annotationName : qualifiedName ;

elementValuePairs
    :   elementValuePair
    |   elementValuePairs ',' elementValuePair
    ;

elementValuePair
    :   javaIdentifier '=' elementValue
    ;

elementValue
    : /* elementValueArrayInitializer
    | */ expression
    | annotation
    ;

elementValueArrayInitializer
    :   '{' elementValues? ','? '}'
    ;

elementValues
    :   elementValue
    |   elementValues ',' elementValue
    ;

annotationTypeDeclaration
    :   '@' 'interface' javaIdentifier annotationTypeBody
    ;

annotationTypeBody
    :   '{' (annotationTypeElementDeclaration)* '}'
    ;

annotationTypeElementDeclaration
    :   modifier* annotationTypeElementRest
    |   ';' // this is not allowed by the grammar, but apparently allowed by the actual compiler
    ;

annotationTypeElementRest
    :   type annotationMethodOrConstantRest ';'
    /*|   classDeclaration ';'?
    |   interfaceDeclaration ';'?
    |   enumDeclaration ';'?
    |   annotationTypeDeclaration ';'? */
    ;

annotationMethodOrConstantRest
    :   annotationMethodRest
    /* |   annotationConstantRest */
    ;

annotationMethodRest
    :   javaIdentifier '(' ')' defaultValue?
    ;

annotationConstantRest
    :   variableDeclarators
    ;

defaultValue
    :   'default' elementValue
    ;

// STATEMENTS / BLOCKS

block
    :   '{' blockStatement+ '}'
    ;

blockStatement
    :   localVariableDeclarationStatement
    |   statement
    /*|   typeDeclaration*/
    |   {specLevel>0}? valEmbedStatementBlock
    ;

localVariableDeclarationStatement
    :    localVariableDeclaration ';'
    ;

localVariableDeclaration
    :   variableModifier* type variableDeclarators
    ;

loopAmalgamation
    : valEmbedContract loopAmalgamation
    | loopLabel loopAmalgamation
    | /* epsilon */
    ;

statement
    :   block
    |   ASSERT expression assertMessage? ';'
    |   'if' parExpression statement elseBlock?
    |   loopAmalgamation 'for' '(' forControl ')' valEmbedContract? statement
    |   loopAmalgamation 'while' parExpression valEmbedContract? statement
    |   'do' statement 'while' parExpression ';'
    |   'try' block catchClause+ finallyBlock?
    |   'try' block finallyBlock
    |   'try' resourceSpecification block catchClause* finallyBlock?
    |   'switch' parExpression '{' switchBlockStatementGroup* switchLabel* '}'
    |   'synchronized' parExpression block
    |   'return' expression? ';'
    |   'throw' expression ';'
    |   'break' javaIdentifier? ';'
    |   'continue' javaIdentifier? ';'
    |   ';'
    |   statementExpression ';'
    |   javaIdentifier ':' statement
    |   {specLevel>0}? valStatement
    ;

assertMessage: ':' expression;
elseBlock: 'else' statement;

loopLabel
    : javaIdentifier ':'
    ;

catchClause
    :   'catch' '(' variableModifier* catchType javaIdentifier ')' block
    ;

catchType
    :   classOrInterfaceType
    |   classOrInterfaceType '|' catchType
    ;

finallyBlock
    :   'finally' block
    ;

resourceSpecification
    :   '(' resources ';'? ')'
    ;

resources
    :   resource
    |   resource ';' resources
    ;

resource
    :   variableModifier* classOrInterfaceType variableDeclaratorId '=' expression
    ;

/** Matches cases then statements, both of which are mandatory.
 *  To handle empty cases at the end, we add switchLabel* to statement.
 */
switchBlockStatementGroup
    :   switchLabel+ blockStatement+
    ;

switchLabel
    :   'case' constantExpression ':'
    |   'case' enumConstantName ':'
    |   'default' ':'
    ;

forControl
    :   enhancedForControl
    |   forInit? ';' expression? ';' forUpdate?
    ;

forInit
    :   localVariableDeclaration
    |   expressionList
    ;

enhancedForControl
    :   variableModifier* type variableDeclaratorId ':' expression
    ;

forUpdate
    :   expressionList
    ;

// EXPRESSIONS

parExpression
    :   '(' expression ')'
    ;

expressionList
    :   expression
    |   expression ',' expressionList
    ;

statementExpression
    :   expression
    ;

constantExpression
    :   expression
    ;

expression
    : valEmbedWith? expr valEmbedThen?
    ;

vercorsBipJob
    : startSpec 'vercorsBipJob' endSpec
    ;

expr
    :   annotatedPrimary # javaPrimary
    |   expr '.' javaIdentifier # javaDeref
    |   expr '.' 'this' # javaPinnedThis
    |   expr '.' 'new' nonWildcardTypeArguments? innerCreator # javaPinnedOuterClassNew
    |   expr '.' 'super' superSuffix # javaSuper
    |   expr '.' explicitGenericInvocation # javaGenericInvocation
    |   expr '[' expr ']' # javaSubscript
    |   expr '->' javaIdentifier arguments # javaNonNullInvocation
    |   expr '.' javaIdentifier predicateEntryType? arguments valEmbedGiven? valEmbedYields? # javaInvocation
    |   expr postfixOp # javaValPostfix
    |   'new' /* vercorsBipJob? */ creator valEmbedGiven? valEmbedYields? # javaNew
    |   '(' type ')' expr # javaCast
    |   expr ('++' | '--') # javaPostfixIncDec
    |   ('+'|'-'|'++'|'--') expr # javaPrefixOp
    |   ('~'|'!') expr # javaPrefixOp2
    |   prefixOp expr # javaValPrefix
    |   <assoc=right> expr prependOp expr # javaValPrepend
    |   expr mulOp expr # javaMul
    |   expr ('+'|'-') expr # javaAdd
    |   expr shiftOp expr # javaShift
    |   expr relOp expr # javaRel
    |   expr 'instanceof' type # javaInstanceOf
    |   expr ('==' | '!=') expr # javaEquals
    |   expr '&' expr # javaBitAnd
    |   expr '^' expr # javaBitXor
    |   expr '|' expr # javaBitOr
    |   expr andOp expr # javaAnd
    |   expr '||' expr # javaOr
    |   <assoc=right> expr impOp  expr # javaValImp
    |   expr '?' expr ':' expr # javaSelect
    |   <assoc=right> expr assignOp expr # javaAssign
    ;
predicateEntryType: '@' javaIdentifier; // TODO: Find correct class type
prependOp
    : {specLevel>0}? valPrependOp
    ;
postfixOp
    : {specLevel>0}? valPostfix
    ;
prefixOp
    : {specLevel>0}? valPrefix
    ;
mulOp
    : ('*'|'/'|'%')
    | {specLevel>0}? valMulOp
    ;
shiftOp
    : '<' '<'
    | '>' '>' '>'
    | '>' '>'
    ;
andOp
    : ('&&')
    | {specLevel>0}? valAndOp
    ;
impOp
    : {specLevel>0}? valImpOp
    ;
relOp
    : ('<=' | '>=' | '>' | '<')
    | {specLevel>0}? valInOp
    ;
assignOp
    :   ('='
    |   '+='
    |   '-='
    |   '*='
    |   '/='
    |   '&='
    |   '|='
    |   '^='
    |   '>>='
    |   '>>>='
    |   '<<='
    |   '%=')
    ;

annotatedPrimary
    : valEmbedWith? primary valEmbedThen?
    ;

primary
    :   '(' expression ')'
    |   'this'
    /*|   'super'*/
    |   literal
    |   javaIdentifier
    |   javaIdentifier predicateEntryType? arguments valEmbedGiven? valEmbedYields?
    |   type '.' 'class'
    /*|   'void' '.' 'class'*/
    |   nonWildcardTypeArguments constructorCall
    |   valExpr
	  ;

constructorCall
    :   explicitGenericInvocationSuffix
    |   'this' arguments
    ;

creator
    :   nonWildcardTypeArguments createdName classCreatorRest
    |   createdName creatorRest
    ;

creatorRest: arrayCreatorRest | classCreatorRest;

createdName
    :   classTypeDiamondList
    |   primitiveType
    ;

classTypeDiamondList
    :   javaIdentifier typeArgumentsOrDiamond?
    |   javaIdentifier typeArgumentsOrDiamond? '.' classTypeDiamondList
    ;

innerCreator
    :   javaIdentifier nonWildcardTypeArgumentsOrDiamond? classCreatorRest
    ;

arrayCreatorRest
    :   dims arrayInitializer
    |   specifiedDims dims?
    ;

specifiedDims
    :   specifiedDim
    |   specifiedDim specifiedDims
    ;

specifiedDim: '[' expression ']';

classCreatorRest
    :   arguments classBody?
    ;

explicitGenericInvocation
    :   nonWildcardTypeArguments explicitGenericInvocationSuffix
    ;

nonWildcardTypeArguments
    :   '<' typeList '>'
    ;

typeArgumentsOrDiamond
    :   '<' '>'
    |   typeArguments
    ;

nonWildcardTypeArgumentsOrDiamond
    :   '<' '>'
    |   nonWildcardTypeArguments
    ;

superSuffix
    :   arguments
    |   '.' javaIdentifier arguments?
    ;

explicitGenericInvocationSuffix
    :   'super' superSuffix
    |   javaIdentifier predicateEntryType? arguments
    ;

arguments
    :   '(' expressionList? ')'
    ;

javaIdentifier
    : Identifier
    /*| valIdentifier*/
    ;

/*langExpr: expression;*/
langExpr: expr;

langId: javaIdentifier;
langConstInt: IntegerLiteral;
langType: type;
langStatement: blockStatement;
langStatic: 'static';
langClassDecl: classBodyDeclaration;
langGlobalDecl: typeDeclaration;
specTrue: NEVER;
specFalse: NEVER;

startSpec:
    {specLevel == 0}? BlockStartSpecImmediate {global specLevel
specLevel += 1}
    ;

endSpec
    : {specLevel == 1}? EndSpec {global specLevel
specLevel -= 1}
    ;

// LEXER

VAL_INLINE    : 'inline';
VAL_ASSERT    : EOF EOF;
VAL_TRUE      : EOF EOF;
VAL_FALSE     : EOF EOF;
VAL_SIZEOF    : 'sizeof';
CONS          : '::';

// §3.9 Keywords

ABSTRACT      : 'abstract';
ASSERT        : 'assert';
BOOLEAN       : 'boolean';
BREAK         : 'break';
BYTE          : 'byte';
CASE          : 'case';
CATCH         : 'catch';
CHAR          : 'char';
CLASS         : 'class';
CONST         : 'const';
CONTINUE      : 'continue';
DEFAULT       : 'default';
DO            : 'do';
DOUBLE        : 'double';
ELSE          : 'else';
ENUM          : 'enum';
EXTENDS       : 'extends';
FINAL         : 'final';
FINALLY       : 'finally';
FLOAT         : 'float';
FOR           : 'for';
IF            : 'if';
GOTO          : 'goto';
IMPLEMENTS    : 'implements';
IMPORT        : 'import';
INSTANCEOF    : 'instanceof';
INT           : 'int';
INTERFACE     : 'interface';
LONG          : 'long';
NATIVE        : 'native';
NEW           : 'new';
PACKAGE       : 'package';
PRIVATE       : 'private';
PROTECTED     : 'protected';
PUBLIC        : 'public';
RETURN        : 'return';
SHORT         : 'short';
STATIC        : 'static';
STRICTFP      : 'strictfp';
SUPER         : 'super';
SWITCH        : 'switch';
SYNCHRONIZED  : 'synchronized';
THIS          : 'this';
THROW         : 'throw';
THROWS        : 'throws';
TRANSIENT     : 'transient';
TRY           : 'try';
VOID          : 'void';
VOLATILE      : 'volatile';
WHILE         : 'while';

// §3.10.1 Integer Literals

IntegerLiteral
    :   DecimalIntegerLiteral /*
    |   HexIntegerLiteral
    |   OctalIntegerLiteral
    |   BinaryIntegerLiteral */
    ;

fragment
DecimalIntegerLiteral
    :   DecimalNumeral /* IntegerTypeSuffix? */
    ;

fragment
HexIntegerLiteral
    :   HexNumeral IntegerTypeSuffix?
    ;

fragment
OctalIntegerLiteral
    :   OctalNumeral IntegerTypeSuffix?
    ;

fragment
BinaryIntegerLiteral
    :   BinaryNumeral IntegerTypeSuffix?
    ;

fragment
IntegerTypeSuffix
    :   [lL]
    ;

fragment
DecimalNumeral
    :   '0'
    |   NonZeroDigit (Digits? | Underscores Digits)
    ;

fragment
Digits
    :   Digit (DigitOrUnderscore* Digit)?
    ;

fragment
Digit
    :   '0'
    |   NonZeroDigit
    ;

fragment
NonZeroDigit
    :   [1-9]
    ;

fragment
DigitOrUnderscore
    :   Digit
    |   '_'
    ;

fragment
Underscores
    :   '_'+
    ;

fragment
HexNumeral
    :   '0' [xX] HexDigits
    ;

fragment
HexDigits
    :   HexDigit (HexDigitOrUnderscore* HexDigit)?
    ;

fragment
HexDigit
    :   [0-9a-fA-F]
    ;

fragment
HexDigitOrUnderscore
    :   HexDigit
    |   '_'
    ;

fragment
OctalNumeral
    :   '0' Underscores? OctalDigits
    ;

fragment
OctalDigits
    :   OctalDigit (OctalDigitOrUnderscore* OctalDigit)?
    ;

fragment
OctalDigit
    :   [0-7]
    ;

fragment
OctalDigitOrUnderscore
    :   OctalDigit
    |   '_'
    ;

fragment
BinaryNumeral
    :   '0' [bB] BinaryDigits
    ;

fragment
BinaryDigits
    :   BinaryDigit (BinaryDigitOrUnderscore* BinaryDigit)?
    ;

fragment
BinaryDigit
    :   [01]
    ;

fragment
BinaryDigitOrUnderscore
    :   BinaryDigit
    |   '_'
    ;

// §3.10.2 Floating-Point Literals

FloatingPointLiteral
    :   DecimalFloatingPointLiteral
    |   HexadecimalFloatingPointLiteral
    ;

fragment
DecimalFloatingPointLiteral
    :   Digits '.' Digits? ExponentPart? FloatTypeSuffix?
    |   '.' Digits ExponentPart? FloatTypeSuffix?
    |   Digits ExponentPart FloatTypeSuffix?
    |   Digits FloatTypeSuffix
    ;

fragment
ExponentPart
    :   ExponentIndicator SignedInteger
    ;

fragment
ExponentIndicator
    :   [eE]
    ;

fragment
SignedInteger
    :   Sign? Digits
    ;

fragment
Sign
    :   [+-]
    ;

fragment
FloatTypeSuffix
    :   [fFdD]
    ;

fragment
HexadecimalFloatingPointLiteral
    :   HexSignificand BinaryExponent FloatTypeSuffix?
    ;

fragment
HexSignificand
    :   HexNumeral '.'?
    |   '0' [xX] HexDigits? '.' HexDigits
    ;

fragment
BinaryExponent
    :   BinaryExponentIndicator SignedInteger
    ;

fragment
BinaryExponentIndicator
    :   [pP]
    ;

// §3.10.3 Boolean Literals
TrueLiteral: 'true';
FalseLiteral: 'false';

// §3.10.4 Character Literals

CharacterLiteral
    :   '\'' SingleCharacter '\''
    |   '\'' EscapeSequence '\''
    ;

fragment
SingleCharacter
    :   ~['\\]
    ;

// §3.10.5 String Literals

StringLiteral
    :   '"' StringCharacters? '"'
    ;

fragment
StringCharacters
    :   StringCharacter+
    ;

fragment
StringCharacter
    :   ~["\\]
    |   EscapeSequence
    ;

// §3.10.6 Escape Sequences for Character and String Literals

fragment
EscapeSequence
    :   '\\' [btnfr"'\\]
    |   OctalEscape
    |   UnicodeEscape
    ;

fragment
OctalEscape
    :   '\\' OctalDigit
    |   '\\' OctalDigit OctalDigit
    |   '\\' ZeroToThree OctalDigit OctalDigit
    ;

fragment
UnicodeEscape
    :   '\\' 'u' HexDigit HexDigit HexDigit HexDigit
    ;

fragment
ZeroToThree
    :   [0-3]
    ;

// §3.10.7 The Null Literal

NullLiteral
    :   'null'
    ;

// §3.11 Separators

LPAREN          : '(';
RPAREN          : ')';
LBRACE          : '{';
RBRACE          : '}';
LBRACK          : '[';
RBRACK          : ']';
SEMI            : ';';
COMMA           : ',';
DOT             : '.';

// §3.12 Operators

ASSIGN          : '=';
GT              : '>';
LT              : '<';
BANG            : '!';
TILDE           : '~';
QUESTION        : '?';
COLON           : ':';
EQUAL           : '==';
LE              : '<=';
GE              : '>=';
NOTEQUAL        : '!=';
AND             : '&&';
OR              : '||';
INC             : '++';
DEC             : '--';
ADD             : '+';
SUB             : '-';
MUL             : '*';
DIV             : '/';
BITAND          : '&';
BITOR           : '|';
CARET           : '^';
MOD             : '%';

ADD_ASSIGN      : '+=';
SUB_ASSIGN      : '-=';
MUL_ASSIGN      : '*=';
DIV_ASSIGN      : '/=';
AND_ASSIGN      : '&=';
OR_ASSIGN       : '|=';
XOR_ASSIGN      : '^=';
MOD_ASSIGN      : '%=';
LSHIFT_ASSIGN   : '<<=';
RSHIFT_ASSIGN   : '>>=';
URSHIFT_ASSIGN  : '>>>=';

Arrow : '->';

// §3.8 Identifiers (must appear after all keywords in the grammar)

fragment
JavaLetter
    :   [a-zA-Z$_] // these are the "java letters" below 0x7F
/*
    |   // covers all characters above 0x7F which are not a surrogate
        ~[\u0000-\u007F\uD800-\uDBFF]
        {Character.isJavaIdentifierStart(_input.LA(-1))}?
    |   // covers UTF-16 surrogate pairs encodings for U+10000 to U+10FFFF
        [\uD800-\uDBFF] [\uDC00-\uDFFF]
        {Character.isJavaIdentifierStart(Character.toCodePoint((char)_input.LA(-2), (char)_input.LA(-1)))}?
*/
    ;

fragment
JavaLetterOrDigit
    :   [a-zA-Z0-9$_] // these are the "java letters or digits" below 0x7F
/*
    |   // covers all characters above 0x7F which are not a surrogate
        ~[\u0000-\u007F\uD800-\uDBFF]
        {Character.isJavaIdentifierPart(_input.LA(-1))}?
    |   // covers UTF-16 surrogate pairs encodings for U+10000 to U+10FFFF
        [\uD800-\uDBFF] [\uDC00-\uDFFF]
        {Character.isJavaIdentifierPart(Character.toCodePoint((char)_input.LA(-2), (char)_input.LA(-1)))}?
*/
    ;

//
// Additional symbols not defined in the lexical specification
//

AT: '@';
ELLIPSIS : '...';

//
// Whitespace and comments
//

FileName : '"' ~[\r\n"]* '"' ;

EndSpec: '*' '/';

BlockStartSpecImmediate: '/' '*' '@' ' ';

EmbeddedLatex
    : '#' ~[\r\n]* '#' -> skip
    ;

VerCorsBipJob : 'vercorsBipJob';

/* This is the mode we are already in, but it serves as a workaround for the ANTLR import order. All rules in this file
 * will have precedence over the imported rules, so any reserved keywords would never be lexed, because Identifier
 * appears first. However, tokens with an explicit mode always appear after all other rules, so by explicitly setting
 * the mode of Identifier to DEFAULT_MODE, it has lowest priority.
 */
Identifier
    :   JavaLetter JavaLetterOrDigit*
    ;

ExtraAt
    :  ('\n'|'\r\n') [ \t\u000C]* '@' {inBlockSpec}? -> skip
    ;

WS  :  [ \t\r\n\u000C] -> skip
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
 : ('pure' | 'inline thread_local' | 'bip_annotation') // TODO
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
 : startSpec valContractClause+ endSpec
 | {specLevel>0}? valContractClause+
 ;

valEmbedStatementBlock
 : startSpec valStatement+ endSpec
 | {specLevel>0}? valStatement+
 | startSpec 'extract' endSpec langStatement
 | startSpec 'frame' valContractClause* '{' endSpec langStatement* startSpec '}' endSpec
 ;

valEmbedWith: startSpec valWith? endSpec | {specLevel>0}? valWith;
valEmbedThen: startSpec valThen? endSpec | {specLevel>0}? valThen;
valEmbedGiven: startSpec valGiven? endSpec | {specLevel>0}? valGiven;
valEmbedYields: startSpec valYields? endSpec | {specLevel>0}? valYields;

valEmbedGlobalDeclarationBlock
 : startSpec valGlobalDeclaration+ endSpec
 | {specLevel>0}? valGlobalDeclaration+
 ;

valEmbedClassDeclarationBlock
 : startSpec valClassDeclaration* endSpec
 | {specLevel>0}? valClassDeclaration+
 ;

valEmbedModifier
 : startSpec valModifier endSpec
 | {specLevel>0}? valModifier
 ;
