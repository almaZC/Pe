%{

/*
librerias y variables
prototipos
*/
#include<stdio.h>
#include<string.h>
#include<ctype.h>
void yyerror(char *s);
int yylex();
char lexema[100];
int localizaSimbolo(char *lexema, int token);

typedef struct {
	char nombre[100];
	int token;
	double valor;
	int tipo;
}TipoTablaDeSimbolos;

int nSim=0;

TipoTablaDeSimbolos tablaDeSimbolos[200];
%}

%token  MIENTRAS ID IGUAL NUMENT SUMA PARIZQ FUEPE DOSPUNT PARDER RESTA MUL DIV ZAFA ENDL PARA HACER MANYA TRAETE VETEA GUARDARMEM IMPRIME LEE MENORQUE MAYORQUE MEVOY A IGUALQUE MAYORIGUALQUE MENORIGUALQUE LIBRERIA TINKA PALTA CRITERIO EXCLAMACION CADENA SALTATE DEFFUN CHECA COMA DEVUELVE VERDURA FEIK CONDSI SINO POSINC PUNTERO MENU ETIQUETA NOHAY FUNCION DEFINE

%%
/*gramatica*/

programa: preprocesa listInst;

listInst: instr listInst;

listInst: ;

instr: ID {localizaSimbolo(lexema,ID);} IGUAL compara ENDL;/**/

instr: ID {localizaSimbolo(lexema,ID);} PUNTERO ENDL;/**/

instr: ZAFA ENDL;

instr: SALTATE ENDL;

expr: TINKA PARIZQ PARDER;

compara: compara MENORQUE expr;

compara: compara MAYORQUE expr;

compara: compara IGUALQUE expr;

compara: expr;

expr: expr SUMA term;

expr: expr RESTA term;

instr: expr POSINC;

instr: expr POSINC ENDL;

compara: compara MAYORIGUALQUE compara; 

compara: compara MENORIGUALQUE compara;

compara: EXCLAMACION compara;

expr: term;

term: term MUL factor;

term: term DIV factor;

term: factor;

factor: PARIZQ expr PARDER;

factor: NUMENT{ localizaSimbolo(lexema,NUMENT);};

factor: ID {localizaSimbolo(lexema,ID);} ;

factor: VERDURA;

factor: FEIK;

factor: NOHAY;

instr: MIENTRAS PARIZQ compara PARDER HACER bloqinst;

instr: PARA PARIZQ auxPara COMA compara COMA instr PARDER HACER bloqinst;

auxPara: ID {localizaSimbolo(lexema,ID);} IGUAL compara; /*Para la inicializacion dentro del for*/

bloqinst : DOSPUNT listInst FUEPE;

instr: CONDSI PARIZQ compara PARDER bloqinst;
instr:  CONDSI PARIZQ compara PARDER DOSPUNT listInst bloqSino;

bloqSino: SINO bloqinst;

incluir: TRAETE LIBRERIA;

define: MANYA ID {localizaSimbolo(lexema,DEFINE);} NUMENT;

instr: MEVOY PARIZQ ID {localizaSimbolo(lexema,ID);} PARDER DOSPUNT listaSwitch FUEPE;

listaSwitch: casoSwitch listaSwitch;
listaSwitch: ;

casoSwitch: A NUMENT {localizaSimbolo(lexema,NUMENT);} DOSPUNT listInst;

instr: IMPRIME PARIZQ CADENA PARDER ENDL; 

instr: IMPRIME PARIZQ ID {localizaSimbolo(lexema,ID);}  PARDER ENDL;

instr: LEE PARIZQ ID {localizaSimbolo(lexema,ID);} PARDER ENDL;

expr: GUARDARMEM PARIZQ NUMENT  {localizaSimbolo(lexema,NUMENT);} PARDER;

instr: DEFFUN ID {localizaSimbolo(lexema,FUNCION);} PARIZQ listArg PARDER bloqinst;

instr: MENU ID {localizaSimbolo(lexema,ID);} DOSPUNT listArg ENDL; 

instr: VETEA ID {localizaSimbolo(lexema,ID);}  ENDL;

instr: DEVUELVE ENDL;

/*Update, parece mas seguro, pero igual habria que revisar*/

instr: ETIQUETA {localizaSimbolo(lexema,ETIQUETA);} listInst FUEPE;

listArg: arg listArg;

listArg: ;

arg: ID {localizaSimbolo(lexema,ID);} ;

arg: ID {localizaSimbolo(lexema,ID);} COMA;

instr: CHECA compara DOSPUNT CADENA ENDL;

instr: PALTA ENDL;

instr: CRITERIO bloqinst;


preprocesa: define preprocesa;
preprocesa: incluir preprocesa;
preprocesa: ;

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
	tablaDeSimbolos[nSim].valor=0.0;
	nSim++;
	return nSim-1;
}

int yylex(){
        char c;int i;
		char c2,c3;
		c=getchar();
		while(c==' ' || c=='\n' || c=='\t'){ c=getchar(); if(c!=' ' && c!='\n' && c!='\t') break;} 
               
                
		if(c=='#') return 0;
		if(isalpha(c)){
			i=0;
			do{
				lexema[i++]=c;
				c=getchar();
			}while(isalnum(c));
			
			if(c=='.'){
				c2 = getchar();
				if(c2=='h'){
					lexema[i++] = '.';
					lexema[i++] = c2;
					lexema[i++] = '\0';
					return LIBRERIA;
				} 
				ungetc(c2,stdin);
			}
			ungetc(c,stdin);
			lexema[i++]='\0';
	
			if(!strcmp(lexema,"mientras")) return MIENTRAS; 
			if(!strcmp(lexema,"hazte")) return HACER; 
			if(!strcmp(lexema,"traete")) return TRAETE;
			if(!strcmp(lexema,"zafa")) return ZAFA; 
			if(!strcmp(lexema,"tinka")) return TINKA;
			if(!strcmp(lexema,"lee")) return LEE;
			if(!strcmp(lexema, "micriterio")) return CRITERIO;
			if(!strcmp(lexema, "quePaltaMeVoy")) return PALTA;
			if(!strcmp(lexema, "meVoy")) return MEVOY;
			if(!strcmp(lexema, "fuepe")) return FUEPE;
			if(!strcmp(lexema, "a")) return A;
			if(!strcmp(lexema, "manya")) return MANYA;
			if(!strcmp(lexema, "guardameSitioPorfa")) return GUARDARMEM;
			if(!strcmp(lexema, "imprime")) return IMPRIME;
			if(!strcmp(lexema, "saltate")) return SALTATE;
			if(!strcmp(lexema, "para")) return PARA;
			if(!strcmp(lexema, "checa")) return CHECA;
			if(!strcmp(lexema, "funcion")) return DEFFUN;
			if(!strcmp(lexema, "vetea")) return VETEA;
			if(!strcmp(lexema, "devuelve")) return DEVUELVE;
			if(!strcmp(lexema, "verdura")) return VERDURA;
			if(!strcmp(lexema, "feik")) return FEIK;
			if(!strcmp(lexema, "Si")) return CONDSI;
			if(!strcmp(lexema, "Sino")) return SINO;
			if(!strcmp(lexema, "menu")) return MENU;
			if(!strcmp(lexema, "nohay")) return NOHAY;

			c=getchar();
			if(c==':'){
				c2 = getchar();
				while(c2==' ' || c2=='\t'){ c2=getchar(); if(c2!=' ' &&  c2!='\t') break;} 
				if(c2=='\n'){
					lexema[--i] = ':';
					lexema[++i] = '\0';
					return ETIQUETA;
				} 
				ungetc(c2,stdin);
			}
			ungetc(c, stdin); 
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
					c2 = getchar();
					if(c2 == '='){
						return IGUALQUE;
					}
					if(c2 == ')'){
						return MAYORIGUALQUE;
					}
					if(c2 == '('){
						return MENORIGUALQUE; 
					}
					
					ungetc(c2,stdin);
               		return IGUAL;

					
               }
               
               if(c=='+'){
					c=getchar();
					if(c=='+') return POSINC;
					else{
						ungetc(c,stdin);
						return SUMA;
					}

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
			   if(c==':')
			   {
					c=getchar();
					if(c=='(') return MENORQUE;
					if(c==')') return MAYORQUE;

					ungetc(c, stdin);
					return DOSPUNT;
			   }
			   if(c=='!'){
					return EXCLAMACION;
			   }
			   if(c==','){
					return COMA;
			   }

			   if(c=='"'){
					lexema[0]='"'; 
					i=0;
					do{
						lexema[i++]=c;
						c=getchar();
					}while(c!='"');
					lexema[i]='"';
					lexema[i+1]='\0';
					return CADENA;
			   }
				if(c=='\\'){
					c2 = getchar();
					if(c2 == 'p'){
						c3 = getchar();
						if(c3 == 'e'){
							return ENDL;
						}
						else{
							ungetc(c3,stdin);
						}
					}
					else{
						ungetc(c2,stdin);
					}
               		
               }
			   if(c=='<'){
					c=getchar();
					if(c=='*'){
						c=getchar();
						if(c=='>') return PUNTERO;
					}

			   }

			   
		return c;
	
}
void yyerror(char *s){
	fprintf(stderr,"%s\n",s);
}



void imprimeTablaSimbolo(){
	for(int i=0;i<nSim;i++){
		printf("%s",tablaDeSimbolos[i].nombre);
		printf("\n");
	}
}


int main(){
        if(!yyparse()){
	         printf("cadena válida\n");
	         imprimeTablaSimbolo();
	}
	else{
	         printf("cadena inválida\n");	
	}
        return 0;
}


