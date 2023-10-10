%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC file
**********************************************/
// 定义段：用于添加所需头文件、函数定义、全局变量等

#include<stdio.h>
#include<stdlib.h>
#include <ctype.h>  //导入isdigit()函数

#ifndef YYSTYPE
// 确定$$的变量类型
#define YYSTYPE double 
#endif
int yylex();

// yyparse不断调用yylex函数来得到token的类型
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}


// 声明运算符的结合性和优先级
%token NUMBER
%token ADD
%token MINUS
%token MUL
%token DIV
%token LEFT_PAR
%token RIGHT_PAR

%left ADD MINUS
%left MUL DIV
%right UMINUS 

// 规则段语法分析
%%

lines :    lines expr ';' { printf("%f\n", $2); } 
      |    lines ';'
      |
      ;

expr  :    expr ADD expr  { $$ = $1 + $3; }
      |    expr MINUS expr  { $$ = $1 - $3; }
      |    expr MUL expr  { $$ = $1 * $3; }
      |    expr DIV expr  { $$ = $1 / $3; }
      |    LEFT_PAR expr RIGHT_PAR   { $$ = $2; }
      |    MINUS expr %prec UMINUS  { $$ =-$2; }  
      |    NUMBER { $$ = $1; }
      ;
%%

// programs section

int yylex()
{
    int t;
    while (1) {
        t = getchar();
        if (t==' ' || t=='\t' || t=='\n'){
            // do nothing
        }
        else if (isdigit(t)) {
            yylval = 0;
            while (isdigit(t)) {
                yylval = yylval * 10 + t - '0';
                t = getchar();
            }
            // ungetc函数将读出的多余字符再次放回去
            ungetc(t, stdin);
            return NUMBER;
        }
        else if(t=='+') {
            return ADD;  
        }
        else if(t=='-'){
            return MINUS;
        }
        else if(t=='*'){
            return MUL;
        }
        else if(t=='/'){
            return DIV;
        }
        else if(t=='('){
            return LEFT_PAR;
        }
        else if(t==')'){
            return RIGHT_PAR;
        }
        else {
            return t;
        }
    }
}

int main(void)
{
    yyin = stdin;    
    do{
        yyparse();
    } while(!feof(yyin));
    return 0;
}


void yyerror(const char* s){
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}
