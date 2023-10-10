%{


#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#ifndef YYSTYPE
// 后缀表达式是一个字符串， YYSTYPE声明为 char*
#define YYSTYPE char* 
#endif

char idStr[50];
char numStr[50];
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}



%token NUMBER
%token ID
%token ADD
%token MINUS
%token MUL
%token DIV
%token LEFT_PAR
%token RIGHT_PAR

%left ADD MINUS
%left MUL DIV
%right UMINUS 

// 规则段：进行语法分析
%%

lines :    lines expr ';' { printf("%s\n", $2); } 
      |    lines ';'
      |
      ;

expr  :    expr ADD expr  { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"+"); }
      |    expr MINUS expr  { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"-"); }
      |    expr MUL expr  { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"*"); }
      |    expr DIV expr  { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"/"); }
      |    LEFT_PAR expr RIGHT_PAR   { $$ = $2; }
      |    MINUS  expr %prec UMINUS  { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,"-"); strcat($$,$2); }
      |    NUMBER         { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); }
      |    ID             { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); }  
      ;

%%


int yylex()
{
    int t;
    while(1){
        t=getchar();
        if(t==' ' || t=='\t'||t=='\n')
            ;
        
       
        else if ((t>='0' && t<= '9')){
            int n=0;
            while((t>='0'&&t<='9')){
                numStr[n]=t;
                t=getchar();
                n++;
            }
            //添加结束符\0
            numStr[n]='\0';
            // 赋给yylval
            yylval=numStr;
            ungetc(t,stdin);
            return NUMBER;
        }
        
        
        else if ((t>='a'&& t<='z')||(t>='A'&&t<='Z')||(t=='_')){
            int n=0;
            while((t>='a'&& t<='z')||(t>='A'&&t<='Z')||(t=='_')||(t>='0'&&t<='9')){
                idStr[n]=t;
                n++;
                t=getchar();
            }
            idStr[n]='\0';
            yylval=idStr;
            ungetc(t,stdin);
            return ID;
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
