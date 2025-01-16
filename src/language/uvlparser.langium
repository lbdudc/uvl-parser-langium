grammar Uvlparser

entry FeatureModel: 
    namespace=Namespace? 
    NEWLINE? 
    includes=Includes? 
    NEWLINE? 
    imports=Imports? 
    NEWLINE? 
    features=Features? 
    NEWLINE? 
    constraints=Constraints?;

Namespace:
    'namespace' reference=Reference;

Includes:
    'include' NEWLINE 
    INDENT includeLines+=IncludeLine* DEDENT;

IncludeLine:
    languageLevel=LanguageLevel NEWLINE;

Imports:
    'imports' NEWLINE 
    INDENT importLines+=ImportLine* DEDENT;

ImportLine:
    ns=Reference ('as' alias=Reference)? NEWLINE;

Features:
    'features' NEWLINE 
    INDENT feature=Feature DEDENT;

Group:
    (ORGROUP GroupSpec)
  | (ALTERNATIVE GroupSpec)
  | (OPTIONAL GroupSpec)
  | (MANDATORY GroupSpec)
  | (CARDINALITY GroupSpec)
  ;


GroupSpec:
    NEWLINE INDENT feature+=Feature+ DEDENT;

Feature:
    FeatureType? Reference FeatureCardinality? Attributes? NEWLINE (INDENT group+=Group+ DEDENT)?;

FeatureCardinality:
    'cardinality' cardinality=CARDINALITY;

Attributes:
    OPEN_BRACE (attribute+=Attribute (COMMA attribute+=Attribute)*)? CLOSE_BRACE;

Attribute:
    ValueAttribute
  | ConstraintAttribute;

ValueAttribute:
    Key Value?;

Key:
    id = Id;

Value:
    BOOLEAN_T | FLOAT | INTEGER | STRING | Attributes | Vector;

Vector:
    OPEN_BRACK (val1+=Value (COMMA val2+=Value)*)? CLOSE_BRACK;

ConstraintAttribute:
    'constraint' Constraint
  | 'constraints' ConstraintList
  ;

ConstraintList:
    OPEN_BRACK (cons1+=Constraint (COMMA cons2+=Constraint)*)? CLOSE_BRACK;

Constraints:
    'constraints' NEWLINE INDENT constraintLine+=ConstraintLine* DEDENT;

ConstraintLine:
    Constraint NEWLINE;


Constraint:
    primCons1+=PrimaryConstraint (BinaryConstraintOperator primCons2+=PrimaryConstraint)*;

PrimaryConstraint:
    Equation
    | Reference
    | OPEN_PAREN Constraint CLOSE_PAREN
    | NOT PrimaryConstraint;

BinaryConstraintOperator returns string:
    AND | OR | IMPLICATION | EQUIVALENCE;

Equation
    : Expression EQUAL Expression
    | Expression LOWER Expression
    | Expression GREATER Expression
    | Expression LOWER_EQUALS Expression
    | Expression GREATER_EQUALS Expression
    | Expression NOT_EQUALS Expression
    ;

Expression:
    term1+=Term ((ADD | SUB) term2+=Term)*;

Term:
    f1+=Factor ((MUL | DIV) f2+=Factor)*;

Factor:
    FLOAT
    | INTEGER
    | STRING
    | AggregateFunction
    | Reference
    | OPEN_PAREN Expression CLOSE_PAREN;


AggregateFunction
    : 'sum' OPEN_PAREN (Reference COMMA)? Reference CLOSE_PAREN
    | 'avg' OPEN_PAREN (Reference COMMA)? Reference CLOSE_PAREN
    | StringAggregateFunction
    | NumericAggregateFunction
    ;

StringAggregateFunction:
    'len' OPEN_PAREN Reference CLOSE_PAREN
  ;

NumericAggregateFunction:
    'floor' OPEN_PAREN Reference CLOSE_PAREN
  | 'ceil' OPEN_PAREN Reference CLOSE_PAREN
  ;

Reference:
    (id+=Id ('.' id+=Id)*)?;

Id returns string: ID_STRICT | ID_NOT_STRICT;

FeatureType returns string:
    'String' | 'Integer' | 'BOOLEAN' | 'Real';

LanguageLevel:
    majorLevel=MajorLevel ('.' (minorLevel=MinorLevel | '*'))?;

MajorLevel returns string: 
    'BOOLEAN' | 'Arithmetic' | 'Type';

MinorLevel returns string: 
    'group-cardinality' | 'feature-cardinality' | 'aggregate-function' | 'string-constraints';

ORGROUP returns string: 'or';
ALTERNATIVE returns string: 'alternative';
OPTIONAL returns string: 'optional';
MANDATORY returns string: 'mandatory';
CARDINALITY returns string: OPEN_BRACK INTEGER ('..' (INTEGER | '*'))? CLOSE_BRACK;

NOT returns string: '!';
AND returns string: '&';
OR returns string: '|';
EQUIVALENCE returns string: '<=>';
IMPLICATION returns string: '=>';

EQUAL returns string: '==';
LOWER returns string: '<';
LOWER_EQUALS returns string: '<=';
GREATER returns string: '>';
GREATER_EQUALS returns string: '>=';
NOT_EQUALS returns string: '!=';

DIV returns string: '/';
MUL returns string: '*';
ADD returns string: '+';
SUB returns string: '-';

terminal FLOAT returns number: /\d+((\.\d+([Ee][+-]?\d+)?)|((\.\d+)?[Ee][+-]?\d+))/;
terminal INTEGER returns number: /[0-9]+/;
terminal BOOLEAN_T returns boolean: /true|false/;

terminal COMMA: /,/;

terminal DEDENT: ':synthetic-dedent:';
terminal INDENT: ':synthetic-indent::';
hidden terminal WS: /[ \t]+/;

terminal ID_NOT_STRICT: '"' /[^"\r\n]+/ '"';
terminal ID_STRICT: /[a-zA-Z]([a-zA-Z0-9_] | '#' | '§' | '%' | '?' | '\\' | '\'' | 'ä' | 'ü' | 'ö' | 'ß' | ';')*/;

terminal STRING: /"(\\.|[^"\\])*"|'(\\.|[^'\\])*'/;


terminal NEWLINE: /[\r?\n]+/;
terminal OPEN_BRACE: '{';
terminal CLOSE_BRACE: '}';
terminal OPEN_PAREN: '(';
terminal CLOSE_PAREN: ')';
terminal OPEN_BRACK: '[';
terminal CLOSE_BRACK: ']';