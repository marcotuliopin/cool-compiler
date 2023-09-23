 /*
  *  The scanner definition for COOL.
  */

 /*
  *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
  *  output, so headers and global definitions are placed here to be visible
  * to the code in the file.  Don't remove anything that was here initially
  */
%{

#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <stdint.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

char str_const[MAX_STR_CONST];
int str_len;
bool str_contain_null_char;

%}

 /*
  * Define names for regular expressions here.
  */

%option noyywrap
%x inline_comment multiline_comment strings

DARROW			=>
ASSIGN			<-
LE				<=
DIGIT 			[0-9]
UPPER			[A-Z]
LOWER 			[a-z]
CHAR			[A-Za-z0-9_]

%%

<INITIAL,multiline_comment>\n { curr_lineno++; }
[ \t\r\v\f]+	{}
 
 /*
  *  Nested comments
  */

"--"			{ BEGIN(inline_comment); }
"(\*"			{ BEGIN(multiline_comment); }
"\*)"			{
	strcpy(cool_yylval.error_msg, "Unmatched *)");
	return (ERROR);
}

<inline_comment>\n	{
	BEGIN(INITIAL); 
	curr_lineno++; 
}
<multiline_comment>"\*)"	{ BEGIN(INITIAL); }
<multiline_comment><<EOF>>	{ 
	strcpy(cool_yylval.error_msg, "EOF in comment");
	BEGIN(INITIAL); 
	return (ERROR);
}

<inline_comment>.			|
<multiline_comment>.		{}

 /*
  *  The multiple-character operators.
  */

{ASSIGN}		{ return (ASSIGN); }
{LE}			{ return (LE); }
{DARROW} 		{ return (DARROW); }


 /*
  *  The single-character operators.
  */

"{"			{ return '{'; }
"}"			{ return '}'; }
"("			{ return '('; }
")"			{ return ')'; }
"~"			{ return '~'; }
","			{ return ','; }
";"			{ return ';'; }
":"			{ return ':'; }
"+"			{ return '+'; }
"-"			{ return '-'; }
"*"			{ return '*'; }
"/"			{ return '/'; }
"%"			{ return '%'; }
"."			{ return '.'; }
"<"			{ return '<'; }
"="			{ return '='; }
"@"			{ return '@'; }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

[Cc][Ll][Aa][Ss][Ss]				{ return (CLASS); }
[Ee][Ll][Ss][Ee] 					{ return (ELSE); }
[Ff][Ii] 							{ return (FI); }
[Ii][Ff] 							{ return (IF); }
[Ii][Nn] 							{ return (IN); }
[Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss] 	{ return (INHERITS); }
[Ll][Ee][Tt] 						{ return (LET); }
[Ll][Oo][Oo][Pp] 					{ return (LOOP); }
[Pp][Oo][Oo][Ll] 					{ return (POOL); }
[Tt][Hh][Ee][Nn] 					{ return (THEN); }
[Ww][Hh][Ii][Ll][Ee] 				{ return (WHILE); }
[Cc][Aa][Ss][Ee] 					{ return (CASE); }
[Ee][Ss][Aa][Cc] 					{ return (ESAC); }
[Oo][Ff] 							{ return (OF); }
[Nn][Ee][Ww] 						{ return (NEW); }
[Ll][Ee] 							{ return (LE); }
[Nn][Oo][Tt] 						{ return (NOT); }
[Ii][Ss][Vv][Oo][Ii][Dd] 			{ return (ISVOID); }


t[rR][uU][eE]		{ 
	cool_yylval.boolean = 1;
	return (BOOL_CONST);
}

f[aA][lL][sS][eE]	{ 
	cool_yylval.boolean = 0;
	return (BOOL_CONST);
}

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

\"	{
	memset(str_const, 0, sizeof str_const);
	str_len = 0; 
	str_contain_null_char = false;
	BEGIN(strings);
}

<strings><<EOF>>	{
	strcpy(cool_yylval.error_msg, "String constant cannot have end of file (EOF)");
	BEGIN(INITIAL); 
	return (ERROR);
}

<strings>\\.		{
	if (str_len >= MAX_STR_CONST) {
		strcpy(cool_yylval.error_msg, "String constant exceeds maximum size");
		BEGIN(INITIAL); 
		return (ERROR);
	}
	else{
		switch(yytext[1]) {
			case 'n': 
				str_const[str_len] = '\n'; 
				break;
			case 't': 
				str_const[str_len] = '\t'; 
				break;
			case 'b': 
				str_const[str_len] = '\b'; 
				break;
			case 'f': 
				str_const[str_len] = '\f'; 
				break;
			case '\"': 
				str_const[str_len] = '\"'; 
				break;
			case '\\': 
				str_const[str_len] = '\\'; 
				break;
			case '0': 
				str_const[str_len] = 0; 
				str_contain_null_char = true; 
				break;
			default: 
				str_const[str_len] = yytext[1];
		}
		str_len++;
	}
}

<strings>\\\n	{ curr_lineno++; }

<strings>\n		{
	curr_lineno++;
	strcpy(cool_yylval.error_msg, "Unterminated string constant");
	BEGIN(INITIAL); 
	return (ERROR);
}

<strings>\"		{ 
	if (str_len > 1 && str_contain_null_char) {
		strcpy(cool_yylval.error_msg, "String constant cannot contain null character");
		BEGIN(INITIAL); 
		return (ERROR);
	}
	cool_yylval.symbol = stringtable.add_string(str_const);
	BEGIN(INITIAL); 
	return (STR_CONST);
}

<strings>.		{ 
	if (str_len >= MAX_STR_CONST) {
		strcpy(cool_yylval.error_msg, "String constant exceeds maximum size");
		BEGIN(INITIAL); 
		return (ERROR);
	} 
	str_const[str_len] = yytext[0]; 
	str_len++;
}

 /*
  *  Integers and identifiers.
  */

[{DIGIT}+([{UPPER}{LOWER}]{CHAR}*)]		{
	cool_yylval.symbol = inttable.add_string(yytext); 
	REJECT;
}

{DIGIT}+				{ 
	return (INT_CONST);
}

{UPPER}{CHAR}*	{
	return (TYPEID);
}

{LOWER}{CHAR}*	{
	return (OBJECTID);
}

 /*
  *  Other errors.
  */

.	{
	strcpy(cool_yylval.error_msg, yytext); 
	return (ERROR); 
}

%%
