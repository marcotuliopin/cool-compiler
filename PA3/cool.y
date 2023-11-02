/*
 *  cool.y
 *              Parser definition for the COOL language.
 *
 */
%{
#include "cool-io.h"		//includes iostream
#include "cool-tree.h"
#include "stringtab.h"
#include "utilities.h"

/* Locations */
#define YYLTYPE int		   /* the type of locations */
#define cool_yylloc curr_lineno	   /* use the curr_lineno from the lexer
				      for the location of tokens */
extern int node_lineno;		   /* set before constructing a tree node
				      to whatever you want the line number
				      for the tree node to be */

/* The default actions for lacations. Use the location of the first
   terminal/non-terminal and set the node_lineno to that value. */
#define YYLLOC_DEFAULT(Current, Rhs, N)		\
  Current = Rhs[1];				\
  node_lineno = Current;

#define SET_NODELOC (Current)	\
  node_lineno = Current;

extern char *curr_filename;

void yyerror(char *s);        /*  defined below; called for each parse error */
extern int yylex();           /*  the entry point to the lexer  */

/************************************************************************/
/*                DONT CHANGE ANYTHING IN THIS SECTION                  */

Program ast_root;	      /* the result of the parse  */
Classes parse_results;        /* for use in semantic analysis */
int omerrs = 0;               /* number of errors in lexing and parsing */
%}

/* A union of all the types that can be the result of parsing actions. */
%union {
  Boolean boolean;
  Symbol symbol;
  Program program;
  Class_ class_;
  Classes classes;
  Feature feature;
  Features features;
  Formal formal;
  Formals formals;
  Case case_;
  Cases cases;
  Expression expression;
  Expressions expressions;
  char *error_msg;
}

/* 
   Declare the terminals; a few have types for associated lexemes.
   The token ERROR is never used in the parser; thus, it is a parse
   error when the lexer returns it.

   The integer following token declaration is the numeric constant used
   to represent that token internally.  Typically, Bison generates these
   on its own, but we give explicit numbers to prevent version parity
   problems (bison 1.25 and earlier start at 258, later versions -- at
   257)
*/
%token CLASS 258 ELSE 259 FI 260 IF 261 IN 262 
%token INHERITS 263 LET 264 LOOP 265 POOL 266 THEN 267 WHILE 268
%token CASE 269 ESAC 270 OF 271 DARROW 272 NEW 273 ISVOID 274
%token <symbol>  STR_CONST 275 INT_CONST 276 
%token <boolean> BOOL_CONST 277
%token <symbol>  TYPEID 278 OBJECTID 279 
%token ASSIGN 280 NOT 281 LE 282 ERROR 283

/*  DON'T CHANGE ANYTHING ABOVE THIS LINE, OR YOUR PARSER WONT WORK       */
/**************************************************************************/
 
   /* Complete the nonterminal list below, giving a type for the semantic
      value of each non terminal. (See section 3.6 in the bison 
      documentation for details). */

/* Declare types for the grammar's non-terminals. */
%type <program> program
%type <classes> class_list
%type <class_> class

/* You will want to change the following line. */
/* The body of a class definition consists of a list of feature definitions. */
%type <features> feat_list;
%type <feature> feat;
/* A feature is either an attribute or a method */
%type <feature> attr; 
%type <feature> method; /* A method of a class is a procedure that may manipulate the variables and objects of the class. */
%type <formal> formal;
%type <formals> formal_list;
%type <cases> case_list;
%type <expression> expr;
%type <expressions> expr_list;
%type <expressions> expr_list_1;
%type <expression> let;
%type <expression> init;

/* Precedence declarations go here. */


%%
/* 
   Save the root of the abstract syntax tree in a global variable.
*/
program	: class_list	{ /* make sure bison computes location information */
			  @$ = @1;
			  ast_root = program($1); }
        ;

class_list
	: class			/* single class */
		{ $$ = single_Classes($1);
                  parse_results = $$; }
	| class_list class	/* several classes */
		{ $$ = append_Classes($1,single_Classes($2)); 
                  parse_results = $$; }
	;

/* If no parent is specified, the class inherits from the Object class. */
class	: CLASS TYPEID '{' feat_list '}' ';'
		{ $$ = class_($2,idtable.add_string("Object"),$4,
			      stringtable.add_string(curr_filename)); }
	| CLASS TYPEID INHERITS TYPEID '{' feat_list '}' ';'
		{ $$ = class_($2,$4,$6,stringtable.add_string(curr_filename)); }
	;

/* Feature list may be empty, but no empty features in list. */
feat_list : /* empty */ 
		{  $$ = nil_Features(); }
	  | feat
	  	{ $$ = single_Features($1); }
	  | feat_list feat
	  	{ $$ = append_Features($1, $2); }
	  ;
	  
feat : 	  attr
	| method
	;
	  
/* An attribute of class A specifies a variable that is part of the state of objects of a class. */
attr : 	  OBJECTID ':' TYPEID init ';'
		{ $$ = attr($1, $3, $4); }
	;
	
/* A method definition has the form <id>(<id> : <type>,...,<id> : <type>): <type> { <expr> }; */
method : OBJECTID '(' formal_list ')' ':' TYPEID '{' expr '}' ';'
		{ $$ = method($1, $3, $6, $8); }
	;
	
/* Formal parameters are used in method definitions. The field names are self explanatory. */
formal_list : /* empty */
			{ $$ = nil_Formals(); }
		| formal
			{ $$ = single_Formals($1); }
		| formal_list ',' formal
			{ $$ = append_Formals($1, $3); }
		;

formal : OBJECTID ':' TYPEID
		{ $$ = formal($1, $3); }
	;

	
/* Expressions are the largest syntactic category in Cool. */
expr_list : /* empty */
		{ $$ = nil_Expressions(); }
	| expr 
		{$$ = single_Expressions($1); }
	| expr_list ',' expr
		{$$ = append_Expressions($1, $3); }
	;
	
expr_list_1 : /* empty */
		{ $$ = nil_Expressions(); }
	| expr ';'
		{ $$ = single_Expressions($1); }
	| expr_list expr ';'
		{ $$ = append_Expressions($1, $2); }
	;

expr :	'(' expr ')'
		{ $$ = $2; }
	/* constant */
	/* The constants belong to the basic classes Bool, Int, and String. 
	The value of a constant is an object of the appropriate basic class. */
	| INT_CONST 
		{ $$ = int_const($1); }
	| STR_CONST
		{ $$ = string_const($1); }
	| BOOL_CONST
		{ $$ = bool_const($1); }
	/* identifier */
	| OBJECTID
		{ $$ = object($1); }
	/* assign */	
	| OBJECTID ASSIGN expr
		{ $$ = assign($1, $3); }
	/* dispatch */
	| expr '.' OBJECTID '(' expr_list ')'  /* <expr>.<id>(<expr>,...,<expr>) */
		{ $$ = dispatch($1, $3, $5); }
	| OBJECTID '(' expr_list ')'  /* <id>(<expr>,...,<expr>) */
		{ $$ = dispatch(object(idtable.add_string("self")), $1, $3); }
	| expr '@' TYPEID '.' OBJECTID '(' expr_list ')'  /* <expr>@<type>.id(<expr>,...,<expr>) */
		{ $$ = static_dispatch($1, $3, $5, $7); }
	/* conditional */
	| IF expr THEN expr ELSE expr FI
		{ $$ = conditional( $2, $4, $6); }
	/* loop */
	| WHILE expr LOOP expr POOL 
		{ $$ = loop($2, $4); }
	/* block */
	| '{' expr_list_1 '}' 
		{ $$ = block($2); }
	/* let */
	| LET let
		{ $$ = $2; }
	/* case */
	| CASE expr OF case_list ESAC
		{ $$ = typcase($2, $4); }
	/* new */
	| NEW TYPEID
		{ $$ = new_($2); }
	/* isvoid */
	| ISVOID expr
		{ $$  = isvoid($2); }
	/* plus */
	| expr '+' expr
		{ $$ = plus($1, $3); }
	/* minus */
	| expr '-' expr
		{ $$ = sub($1, $3); }
	/* multiplication */
	| expr '*' expr
		{ $$ = mul($1, $3); }
	/* division */
	| expr '/' expr
		{ $$ = divide($1, $3); }
	/* negation */
	| '~' expr 
		{ $$ = neg($2); }
	/* less than */
	| expr '<' expr
		{ $$ = lt($1, $3); }
	/* less equal */
	| expr LE expr
		{ $$ = leq($1, $3); }
	/* equal */
	| expr '=' expr 
		{ $$ = eq($1, $3); }
	/* complement */
	| NOT expr
		{ $$ = comp($2); }
		

let :	  OBJECTID ':' TYPEID init IN expr
		{ $$ = let($1, $3, no_expr(), $6); }
	| OBJECTID ':' TYPEID init ',' let
		{ $$ = let($1, $3, $4, $6); }
	| error IN expr
		/* TODO*/  
	|  error ',' let
		/* TODO*/
	;
	
case_list : /* empty */
		{ $$ = nil_Cases(); }
	| OBJECTID ':' TYPEID DARROW expr ';'
		{ $$ = single_Cases(branch($1, $3, $5); }
	| case_list OBJECTID ':' TYPEID DARROW expr ';'	
		{ $$ = append_Cases($1, branch($2, $4, $6)); }
	;

/* Optional initialization of attributes. */
init : 	  /* empty */
		{ $$ = no_expr(); }
	| ASSIGN expr
		{ $$ = $2; }
	;


/* end of grammar */
%%

/* This function is called automatically when Bison detects a parse error. */
void yyerror(char *s)
{
  extern int curr_lineno;

  cerr << "\"" << curr_filename << "\", line " << curr_lineno << ": " \
    << s << " at or near ";
  print_cool_token(yychar);
  cerr << endl;
  omerrs++;

  if(omerrs>50) {fprintf(stdout, "More than 50 errors\n"); exit(1);}
}
