grammar Uvlparser

entry FeatureModel:
    namespace=Namespace? includes=Includes? imports=Imports? features=Features? constraints=Constraints? EOF;

Namespace:
    'namespace' reference=Reference;

Includes:
    'include' includeLine+=IncludeLine*;

IncludeLine:
    languageLevel=LanguageLevel;

Imports:
    'imports' importLine+=ImportLine*;

ImportLine:
    ns=Reference ('as' alias=Reference)?;

Features:
    'features' feature+=Feature+;

Feature:
    featureType=FeatureType? reference=Reference featureCardinality=FeatureCardinality? attributes=Attributes? group=Group?;

FeatureType returns string:
    'String' | 'Integer' | 'Boolean' | 'Real';

FeatureCardinality:
    'cardinality' cardinality=CARDINALITY;

Attributes:
    '{' (attribute+=Attribute (',' attribute+=Attribute)*)? '}';

Attribute:
    ValueAttribute | ConstraintAttribute;

ValueAttribute:
    key=ID value=Value?;

ConstraintAttribute:
    'constraint' constraint=Constraint | 'constraints' constraintList=ConstraintList;

ConstraintList:
    '[' (constraint+=Constraint (',' constraint+=Constraint)*)? ']';

Group:
    OrGroup | AlternativeGroup | OptionalGroup | MandatoryGroup | CardinalityGroup;

OrGroup:
    'or' groupSpec=GroupSpec;

AlternativeGroup:
    'alternative' groupSpec=GroupSpec;

OptionalGroup:
    'optional' groupSpec=GroupSpec;

MandatoryGroup:
    'mandatory' groupSpec=GroupSpec;

CardinalityGroup:
    'cardinality' CARDINALITY groupSpec=GroupSpec;

GroupSpec:
    feature+=Feature+;

Constraints:
    'constraints' constraintLine+=ConstraintLine*;

ConstraintLine:
    constraint=Constraint;

Constraint:
    PrimaryConstraint (BinaryConstraintOp right=PrimaryConstraint)*;

PrimaryConstraint:
    EquationConstraint | ReferenceConstraint | ParenthesisConstraint | NotConstraint;

BinaryConstraintOp returns string:
    '&' | '|' | '=>' | '<=>';

EquationConstraint:
    equation=Equation;

ReferenceConstraint:
    reference=Reference;

ParenthesisConstraint:
    '(' constraint=Constraint ')';

NotConstraint:
    '!' constraint=Constraint;

Equation:
    left=Expression operator=EquationOperator right=Expression;

EquationOperator returns string:
    '==' | '!=' | '<' | '<=' | '>' | '>=';

Expression:
    AddSubExpression;

AddSubExpression:
    MulDivExpression ((ADD | SUB) right=MulDivExpression)*;

MulDivExpression:
    PrimaryExpression ((MUL | DIV) right=PrimaryExpression)*;

terminal ADD: '+';
terminal SUB: '-';
terminal MUL: '*';
terminal DIV: '/';

PrimaryExpression:
    FLOAT | INTEGER | STRING | BOOLEAN | Reference | '(' expression=Expression ')';

Value:
    BOOLEAN | FLOAT | INTEGER | STRING | Attributes | Vector | 'true' | 'false';

Vector:
    '[' (values+=Value (',' values+=Value)*)? ']';

Reference:
    id=ID ('.' id=ID)* | STRING;

LanguageLevel:
    majorLevel=MajorLevel ('.' minorLevel=MinorLevel)?;

MajorLevel returns string:
    'Boolean' | 'Arithmetic' | 'Type';

MinorLevel returns string:
    'group-cardinality' | 'feature-cardinality' | 'aggregate-function' | 'string-constraints';

terminal ID: /[_a-zA-Z][\w_]*/;
terminal STRING: /"[^"]*"/; 
terminal CARDINALITY: /\[\d+(\.\.\d+|\.\.\*)?\]/;
terminal FLOAT: /-?\d*\.\d+/;
terminal INTEGER: /-?\d+/;
terminal BOOLEAN: /true|false/;
terminal OPEN_PAREN: '(';
terminal CLOSE_PAREN: ')';
terminal OPEN_BRACK: '[';
terminal CLOSE_BRACK: ']';
terminal OPEN_BRACE: '{';
terminal CLOSE_BRACE: '}';

hidden terminal WS: /\s+/;
hidden terminal OPEN_COMMENT: '/*';
hidden terminal CLOSE_COMMENT: '*/';
hidden terminal COMMENT: /\/\/[^\n]*|\/\*.*?\*\//;