%{

/*
librerias y variables
prototipos
*/
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include<ctype.h>
void yyerror(char *s);
int yylex();
int localizaSimbolo(char *lexema, int token);
char lexema[100];
typedef struct {
	char nombre[100];
	int token;
	double valor;
	int tipo;
}TipoTablaDeSimbolos;
int genTemp(); /* Se crea un generador de Temporal*/
void interpretaCodigo(); /*una función que interprete el código, iremos haciendo también el interpretador*/
void generaCodigo(int op,int a1,int a2 , int a3); /*función que genere código*/
typedef struct {
	int op;
        int a1;
        int a2;
        int a3;
}TipoTablaCod; /*generamos la estructura para la tabla de código*/
TipoTablaCod tablaCod[200]; /*se crea la tabla de código*/
int nSim=0;
int cx=-1; /*se crea un cx, cantidad de instrucciones de código*/
int nVarTemp=1;
TipoTablaDeSimbolos tablaDeSimbolos[200];
%}

%token  MIENTRAS ID IGUAL NUMENT SUMA CAMBIOLINEA  LLAVEDER LLAVEIZQ PARDER RESTA MUL DIV PARIZQ SI SINO IMPRESION
%token  ASIGNAR SUMAR MULTIPLICAR MAYORQUE SALTARF SALTAR RESTAR IMPRIMIR SALTARV MENORQUE
 /*tokens de operadores*/

%%
/*gramatica*/
programa: listInst ;

listInst: instr listInst;

listInst: ;

instr: ID {int i= localizaSimbolo(lexema,ID);$$=i;} IGUAL expr  {generaCodigo(ASIGNAR
,$2,$4,'-'); }

expr: expr SUMA term {int i= genTemp() ;generaCodigo(SUMAR,i,$1,$3);$$=i;} ;

expr: expr RESTA term {int i= genTemp() ;generaCodigo(RESTAR,i,$1,$3);$$=i;} ;

expr: term;


term: term MUL factor {int i= genTemp() ;generaCodigo(MULTIPLICAR,i,$1,$3);$$=i;} ;

term: term DIV factor;

term: factor;

factor: PARIZQ expr PARDER;

factor: NUMENT{int i= localizaSimbolo(lexema,NUMENT);$$=i;};

factor: ID {int i=localizaSimbolo(lexema,ID);$$=i;};

cond: expr '>' expr {int i=genTemp(); generaCodigo(MAYORQUE,i ,$1,$3);$$=i;};
cond: expr '<' expr {int i=genTemp(); generaCodigo(MENORQUE,i ,$1,$3);$$=i;};
instr: SI PARIZQ  cond  { generaCodigo(SALTARF,$3,'?','-'); $$=cx; }  PARDER bloqinst { generaCodigo(SALTAR,'?','-','-'); $$=cx; }   {tablaCod[$4].a2=cx+1;} bloqueSino {tablaCod[$7].a1=cx+1;};
bloqueSino: SINO bloqinst ;
bloqueSino:;
instr : IMPRESION ID {int i=localizaSimbolo(lexema,ID);$$=i;} { generaCodigo(IMPRIMIR,$3,'-','-');} ;

instr: MIENTRAS PARIZQ {$$=cx+1;} cond { generaCodigo(SALTARF,$4,'?','-'); $$=cx; }  PARDER bloqinst { generaCodigo(SALTAR,$3, '-','-');$$=cx;   }   {tablaCod[$5].a2=cx+1;}  ;

bloqinst : LLAVEIZQ listInst LLAVEDER;
%%

/*codigo C*/
/*análisis léxico*/
int localizaSimbolo(char *lexema, int token){
	for(int i=0;i<nSim;i++){
		if(!strcmp(tablaDeSimbolos[i].nombre,lexema)){
			return i;
		}
	}
	strcpy(tablaDeSimbolos[nSim].nombre,lexema);
	tablaDeSimbolos[nSim].token=token;
	tablaDeSimbolos[nSim].tipo=0;
        if (token==NUMENT){ 
                tablaDeSimbolos[nSim].valor=atof(lexema);     
        }
        else {
	        tablaDeSimbolos[nSim].valor=0.0;
        }	
        nSim++;
	return nSim-1;
        /*devuelve la posición del lexema en la tabla de símbolo, en caso no lo encientra lo agrega a la tabla de símbolo
        y devuelve su posición (que vendría a ser la última)*/
}

int genTemp(){
        int pos;
        char t[10];
        sprintf(t,"_T%d",nVarTemp++);
        pos=localizaSimbolo(t,ID);
        return pos;        
}

void interpretaCodigo(){
        int i,op,a1,a2,a3;
        for (i=0;i<=cx;i=i+1) {
                op=tablaCod[i].op;
                a1=tablaCod[i].a1 ;
                a2=tablaCod[i].a2 ;
                a3=tablaCod[i].a3 ;
              
                if(op==RESTAR){
                                tablaDeSimbolos[a1].valor=tablaDeSimbolos[a2].valor-tablaDeSimbolos[a3].valor;
                }   
                if(op==SUMAR){
                                tablaDeSimbolos[a1].valor=tablaDeSimbolos[a2].valor+tablaDeSimbolos[a3].valor;
                }   
                if(op==MULTIPLICAR){
                                tablaDeSimbolos[a1].valor=tablaDeSimbolos[a2].valor*tablaDeSimbolos[a3].valor;
                }   
                if(op==IMPRIMIR){
                                printf("%lf",tablaDeSimbolos[a1].valor );
                } 
                if(op==SALTAR){
                        i=a1-1;
                }   
                if(op==SALTARF){
                        if(tablaDeSimbolos[a1].valor==0)
                                i=a2-1;
        
                }   
                if(op==SALTARV){
                        if(tablaDeSimbolos[a1].valor==1)
                                i=a2-1;
                }   
                if(op==MAYORQUE){
                        if(tablaDeSimbolos[a2].valor>tablaDeSimbolos[a3].valor)
                                tablaDeSimbolos[a1].valor=1;
                        else
                                tablaDeSimbolos[a1].valor=0;
                }  
                if(op==MENORQUE){
                        if(tablaDeSimbolos[a2].valor>tablaDeSimbolos[a3].valor)
                                tablaDeSimbolos[a1].valor=1;
                        else
                                tablaDeSimbolos[a1].valor=0;
                }  
                if(op==ASIGNAR){
                                tablaDeSimbolos[a1].valor=tablaDeSimbolos[a2].valor;
                }      
        }

}
void generaCodigo(int op,int a1,int a2 , int a3){
        cx++;        
        tablaCod[cx].op=op;
        tablaCod[cx].a1=a1;
        tablaCod[cx].a2=a2;
        tablaCod[cx].a3=a3;
        /*agrega un código de operación (o instrucción de codigo), se recibe el:
        código de la operación y las posiciones que se usarán en la operación
        */
}

int yylex(){
        char c;int i;
	    	c=getchar();
	    	while(c==' ' || c=='\n' || c=='\t'){ c=getchar(); if(c!=' ' && c!='\n' && c!='\t') break;} 
               
                
                if(c=='#') return 0;
		if(isalpha(c)){
			i=0;
			do{
				lexema[i++]=c;
				c=getchar();
			}while(isalnum(c));
			ungetc(c,stdin);
			lexema[i++]='\0';
	                if(!strcmp(lexema,"if")) return SI; 
                        if(!strcmp(lexema,"else")) return SINO; 
                        if(!strcmp(lexema,"while")) return MIENTRAS;
                        if(!strcmp(lexema,"print")) return IMPRESION;
			//localizaSimbolo(lexema,ID);
			return ID;

		}

                if(isdigit(c)){
			i=0;
			do{
				lexema[i++]=c;
				c=getchar();
			}while(isdigit(c));
			ungetc(c,stdin);
			lexema[i++]='\0';
                         
			return NUMENT;
                } 
                 
               if(c=='='){
               		return IGUAL;
               }
               
               if(c=='+'){
               		return SUMA;
               }
               if(c=='-'){
               		return RESTA;
               }
               if(c=='*'){
               		return MUL;
               }
               if(c=='/'){
               		return DIV;
               }
               if(c=='('){
               		return PARIZQ;
               }
               if(c==')'){
               		return PARDER;
               }
               if(c=='}'){
               		return LLAVEDER;
               }
               if(c=='{'){
               		return LLAVEIZQ;
               }
		return c;
	
}
void yyerror(char *s){
	fprintf(stderr,"%s\n",s);
}

void imprimeTablaCodigo(){
        printf("Tabla de codigo\n");
        printf("op\ta1\ta2\ta3\n");
	for(int i=0;i<=cx;i++){
	if(tablaCod[i].op==SUMAR){
                printf("SUMAR ");
        }
	printf("%d\t%d\t%d\t%d\t%d\n",i,tablaCod[i].op,tablaCod[i].a1,tablaCod[i].a2,tablaCod[i].a3);
		
	}
}


void imprimeTablaSimbolo(){
        printf("Tabla de simbolo\n");
        printf("nombre\ttoken\tvalor\n");

	for(int i=0;i<nSim;i++){
		printf("%d\t%s\t%d\t%lf",i,tablaDeSimbolos[i].nombre,tablaDeSimbolos[i].token,tablaDeSimbolos[i].valor);
		printf("\n");
	}
}


int main(){
        if(!yyparse()){
	         printf("cadena válida\n");
	         imprimeTablaSimbolo();
                 imprimeTablaCodigo();
                 interpretaCodigo();    
	         imprimeTablaSimbolo();
	}
	else{
	         printf("cadena inválida\n");	
	}
        return 0;
}



