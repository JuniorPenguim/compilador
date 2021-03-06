%{
#include <stdio.h>
#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <list>
#define YYSTYPE atributos
using namespace std;
struct atributos
{
	string label;
	string traducao;
	string tipo;
	string nome_var;
};



typedef struct atributos Atributos;
typedef map<string, Atributos> MAPA;
list<MAPA*> pilhaDeMapas;

MAPA mapa_temp;
int yylex(void);
void yyerror(string);
string gerarNome(){
	static int numeroVariaveis = 0;
	numeroVariaveis++;
	ostringstream stringNumeroVariaveis;
	stringNumeroVariaveis << numeroVariaveis;
	return "temp_" + stringNumeroVariaveis.str();
}
atributos buscaMapa(string label)
{ 
	MAPA* mapa;
	atributos var;
	list<MAPA*>::reverse_iterator i;
	for(i = pilhaDeMapas.rbegin(); i != pilhaDeMapas.rend(); i++)
	{
		mapa = *i;
		if(mapa->find(label) != mapa->end())
		{
			cout << (*mapa)[label].label << endl;
			return (*mapa)[label];
		}
		
	}

	
	yyerror("Variável não declarada!");
	return var;
}
string conversaoImplicita(atributos E1, atributos E2, string operador, atributos *$$)
{
	
	
	if((E1.tipo == "bool" || E2.tipo == "bool") && operador != "&&" && operador != "||")
		{
			yyerror("Error: Operação invalida.");
		}
	else if((E1.tipo == "bool")^(E2.tipo == "bool"))
	{
		yyerror("Error: Operação invalida.");
	}
	
	if(operador == "+" || operador == "-" || operador == "*" || operador == "/")
	{	
		
		if(E1.tipo == E2.tipo)
		{
				string tempLabelResultado = gerarNome();
				$$->label = tempLabelResultado;
				mapa_temp[$$->label].label = $$->label;
				mapa_temp[$$->label].tipo = $$->tipo;
				return "\t" + tempLabelResultado + " = " + E1.label + " " + operador + " " + E2.label + ";\n";
		}else if(E1.tipo != E2.tipo)
		{
			if(E1.tipo == "int")
			{
				string tempCastVarLabel = gerarNome();
				string builder = "\t" + tempCastVarLabel + " = " + "(" + E2.tipo + ")" + E1.label + ";\n";
				E1.label = tempCastVarLabel;
				mapa_temp[tempCastVarLabel].label = E1.label;
				mapa_temp[tempCastVarLabel].tipo = E2.tipo;
				string tempLabelResultado = gerarNome();
				$$->label = tempLabelResultado;
				$$->tipo = "float";
				mapa_temp[$$->label].label = $$->label;
				mapa_temp[$$->label].tipo = $$->tipo;
				return builder + "\t" + tempLabelResultado + " = " + E1.label + " " + operador + " " + E2.label + ";\n";
			}else
			{
				string tempCastVarLabel = gerarNome();
				string builder = "\t" + tempCastVarLabel + " = " + "(" + E1.tipo + ")" + E2.label + ";\n";
				E2.label = tempCastVarLabel;
				mapa_temp[tempCastVarLabel].label = E2.label;
				mapa_temp[tempCastVarLabel].tipo = E1.tipo;
				string tempLabelResultado = gerarNome();
				$$->label = tempLabelResultado;
				$$->tipo = "float";
				mapa_temp[$$->label].label = $$->label;
				mapa_temp[$$->label].tipo = $$->tipo;
				return builder + "\t" + tempLabelResultado + " = " + E1.label + " " + operador + " " + E2.label + ";\n";
			}
		}
	}else if(operador == "<" || operador == ">" || operador == ">=" || operador == "<=" || operador == "==" || operador == "!=" || operador == "&&" || operador == "||")
	{
		$$->tipo = "bool";
		if(E1.tipo == E2.tipo)
		{
				string tempLabelResultado = gerarNome();
				$$->label = tempLabelResultado;
				mapa_temp[$$->label].label = $$->label;
				mapa_temp[$$->label].tipo = "int";
				return "\t" + tempLabelResultado + " = " + E1.label + " " + operador + " " + E2.label + ";\n";
		}else if(E1.tipo != E2.tipo){
			if(E1.tipo == "int" && E2.tipo != "bool")
			{
				string tempCastVarLabel = gerarNome();
				string builder = "\t" + tempCastVarLabel + " = " + "(" + E2.tipo + ")" + E1.label + ";\n";
				E1.label = tempCastVarLabel;
				mapa_temp[tempCastVarLabel].label = E1.label;
				mapa_temp[tempCastVarLabel].tipo = E2.tipo;
				string tempLabelResultado = gerarNome();
				$$->label = tempLabelResultado;
				mapa_temp[$$->label].label = $$->label;
				mapa_temp[$$->label].tipo = "int";
				return builder + "\t" + tempLabelResultado + " = " + E1.label + " " + operador + " " + E2.label + ";\n";
			}else if(E1.tipo == "float" && E2.tipo != "bool")
			{
				string tempCastVarLabel = gerarNome();
				string builder = "\t" + tempCastVarLabel + " = " + "(" + E1.tipo + ")" + E2.label + ";\n";
				E2.label = tempCastVarLabel;
				mapa_temp[tempCastVarLabel].label = E2.label;
				mapa_temp[tempCastVarLabel].tipo = E1.tipo;
				string tempLabelResultado = gerarNome();
				$$->label = tempLabelResultado;
				mapa_temp[$$->label].label = $$->label;
				mapa_temp[$$->label].tipo = "int";
				return builder + "\t" + tempLabelResultado + " = " + E1.label + " " + operador + " " + E2.label + ";\n";
			}
		}
	}
}
string declaracoes()
{
	string variaveis;
	MAPA::iterator i;
	stringstream s;
	
	
	for(i = mapa_temp.begin(); i != mapa_temp.end(); i++){
		if(i->second.tipo == "bool"){
			i->second.tipo = "int";
		}
			
		s << i->second.tipo << " " << i->second.label << ";\n\t";
	}
	variaveis += "\t" + s.str() + "\n";
	return variaveis;
}

string gerarRotulo(){
	static int numeroRotulos = 0;
	numeroRotulos++;
	ostringstream stringNumeroVariaveis;
	stringNumeroVariaveis << numeroRotulos;
	return "rotulo_" + stringNumeroVariaveis.str();
}


%}
%token TK_NUM
%token TK_CHAR
%token TK_MAIN TK_ID TK_TIPO
%token TK_FIM TK_ERROR
%token TK_CAST
%token TK_BOOL
%token TK_IF TK_ELSE
%token TK_WHILE TK_FOR TK_DO
%start START
%left "||" "&&"
%left "==" "!="
%left '<' '>' ">=" "<="
%left '+' '-'
%left '*' '/'
%%
START			: ESCOPO_GLOBAL MAIN
				{ 
					cout << "\n*Compilador DOIT* \n#include<string.h>\n#include<iostream>\n#include<stdio.h>\n" << endl;
					//cout << variaveis << endl;
								
					cout << $2.traducao << endl;
				}
				;
MAIN			: TK_TIPO TK_MAIN  '(' ')' BLOCO 
				{
					$$.traducao = "int main(void)\n{\n" + declaracoes() + $5.traducao + "\treturn 0;\n}\n\n"; 
				}
				;
ESCOPO_GLOBAL	:
				{
					MAPA* mapa = new MAPA();
					pilhaDeMapas.push_back(mapa);
				} 
				;
INICIO_ESCOPO	: 
				{	
					MAPA* mapa = new MAPA();
					pilhaDeMapas.push_back(mapa);
					$$.traducao = "";
				}
				;
FIM_ESCOPO		: 
				{	
					//declaracoes();				
					pilhaDeMapas.pop_back();
					$$.traducao = "";
				}
				;
BLOCO			: '{' COMANDOS '}'
				{
					$$.traducao = $2.traducao;
				}
				;
COMANDOS		: COMANDO COMANDOS
				{ 
					$$.label = $1.label + $2.label;
					$$.traducao = $1.traducao + $2.traducao;
				}
				|
				;
COMANDO 	 	: E ';'
				| DECLARACAO ';'
				| ATRIBUICAO ';'
				| IF  
				| LOOPS
				;

IF				: TK_IF '(' COMPARACAO ')' INICIO_ESCOPO BLOCO FIM_ESCOPO
				{
					string rotulo_inicio = gerarRotulo();
					string rotulo_fim = gerarRotulo();
					$$.traducao = $3.traducao + "\tif(!" + $3.label + ")\n\t\tgoto " + rotulo_fim +  ";\n" + $6.traducao + "\t" + rotulo_fim + ":\n";
				}
				|
				  TK_IF '(' COMPARACAO ')' INICIO_ESCOPO BLOCO FIM_ESCOPO TK_ELSE INICIO_ESCOPO BLOCO FIM_ESCOPO 
				{
					string rotulo_inicio = gerarRotulo();
					string rotulo_fim = gerarRotulo();
					$$.traducao = $3.traducao + "\tif(!" + $3.label + ")\n\t\tgoto " + rotulo_fim + ";\n\telse\n\t\tgoto " + rotulo_fim + ";\n" + $6.traducao + "\t" + rotulo_fim +":\n" + $10.traducao + "\n";	
				}
				;

LOOPS:			TK_WHILE '(' COMPARACAO ')' INICIO_ESCOPO BLOCO FIM_ESCOPO//mudar expressao para comparar
				{

					string rotulo_inicio = gerarRotulo();
					string rotulo_fim = gerarRotulo();
	
					$$.traducao = "\t" + rotulo_inicio + ":\n"+ $3.traducao +"\tif(!" +$3.label + ") goto " +rotulo_fim+";\n"
					+ $6.traducao + "\tgoto " + rotulo_inicio + ";\n\t"+ rotulo_fim +":\n";

				}
				|TK_DO INICIO_ESCOPO BLOCO TK_WHILE '(' COMPARACAO ')' FIM_ESCOPO ';'
				{

					string rotulo_inicio = gerarRotulo();
					string rotulo_fim = gerarRotulo();
					$$.traducao = "";
	
					$$.traducao = $6.traducao + "\t" + rotulo_inicio + ":\n"+ $3.traducao +"\tif(" +$6.label + ") goto " +rotulo_inicio+";\n"
					+ "\t"+ rotulo_fim +":\n";


				}  	

				|TK_FOR '(' ATRIBUICAO ';' COMPARACAO ';' ATRIBUICAO ')' INICIO_ESCOPO BLOCO FIM_ESCOPO
				{

					string rotulo_inicio = gerarRotulo();
					string rotulo_fim = gerarRotulo();

					$$.traducao = $3.traducao + "\t" + rotulo_inicio + ":\n"+ $5.traducao +"\tif(!" +$5.label + ") goto " +rotulo_fim+";\n"
				 	+ $10.traducao + $7.traducao + "\tgoto " + rotulo_inicio + ";\n\t"+ rotulo_fim +":\n";

				}
				|TK_FOR '('  ';' COMPARACAO ';' ATRIBUICAO ')' INICIO_ESCOPO BLOCO FIM_ESCOPO
				{

					string rotulo_inicio = gerarRotulo();
					string rotulo_fim = gerarRotulo();

					$$.traducao = "\t" + rotulo_inicio + ":\n"+ $4.traducao +"\tif(!" +$4.label + ") goto " +rotulo_fim+";\n"
				 	+ $9.traducao + $6.traducao + "\tgoto " + rotulo_inicio + ";\n\t"+ rotulo_fim +":\n";
				}

				|TK_FOR '('  ';' COMPARACAO ';' ')' INICIO_ESCOPO BLOCO FIM_ESCOPO
				{

					string rotulo_inicio = gerarRotulo();
					string rotulo_fim = gerarRotulo();

					$$.traducao = "\t" + rotulo_inicio + ":\n"+ $4.traducao +"\tif(!" +$4.label + ") goto " +rotulo_fim+";\n"
				 	+ $8.traducao  + "\tgoto " + rotulo_inicio + ";\n\t"+ rotulo_fim +":\n";
				}

				;


DECLARACAO 		: TK_TIPO TK_ID
				{
					
					$$.label = gerarNome();
					$$.tipo = $1.label;
					mapa_temp[$$.label] = $$;
					MAPA* mapa = pilhaDeMapas.back();
					(*mapa)[$2.nome_var].label = $$.label;
					(*mapa)[$2.nome_var].tipo = $$.tipo;
					(*mapa)[$2.nome_var].nome_var = $2.nome_var;
					
				} 
				;
ATRIBUICAO      :TK_ID '=' E 
				{

					atributos var = buscaMapa($1.nome_var);

					$1 = var;

					cout << $1.tipo << "tttttttt" << endl;
								
					if($1.tipo != $3.tipo)
					{
						
						string temp_cast = gerarNome();
						string temp_builder = "\t" + temp_cast + " = " + "(" + $1.tipo + ")" + $3.label + ";\n";
						mapa_temp[temp_cast].label = temp_cast;
						mapa_temp[temp_cast].tipo = $1.tipo;
						$$.traducao = $1.traducao + $3.traducao + temp_builder +"\t" + $1.label + " = " + temp_cast + ";\n" ;
					}
					
					else
					{	
									
					 	$$.traducao = $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";
					}
					
					
				}
				;
E 				: '(' E ')'
				{
					$$ = $2;
				} 
				| E '+' E
				{
					$$.traducao = $1.traducao + $3.traducao + conversaoImplicita($1, $3, "+", &$$);
				}
				| E '-' E
				{
					$$.traducao = $1.traducao + $3.traducao + conversaoImplicita($1, $3, "-", &$$);
				}
				| E '*' E
				{
					$$.traducao = $1.traducao + $3.traducao + conversaoImplicita($1, $3, "*", &$$);
				}
				| E '/' E
				{
					$$.traducao = $1.traducao + $3.traducao + conversaoImplicita($1, $3, "/", &$$);
				}
				| T
				{
					$$ = $1;
				}
				;

COMPARACAO		: E '>' E
				{
					$$.traducao = $1.traducao + $3.traducao + conversaoImplicita($1, $3, ">", &$$);
				}
				| E '<' E
				{
					$$.traducao = $1.traducao + $3.traducao + conversaoImplicita($1, $3, "<", &$$);
				}
				| E '>' '=' E
				{
					$$.traducao = $1.traducao + $4.traducao + conversaoImplicita($1, $4, ">=", &$$);
				}
				| E '<' '=' E
				{
					$$.traducao = $1.traducao + $4.traducao + conversaoImplicita($1, $4, "<=", &$$);
				}
				| E '=' '=' E
				{
					$$.traducao = $1.traducao + $4.traducao + conversaoImplicita($1, $4, "==", &$$);
				}
				| E '!' '=' E
				{
					$$.traducao = $1.traducao + $4.traducao + conversaoImplicita($1, $4, "!=", &$$);
				}
				| E '&' '&' E
				{
					$$.traducao = $1.traducao + $4.traducao + conversaoImplicita($1, $4, "&&", &$$);
				}
				| E '|' '|' E
				{
					$$.traducao = $1.traducao + $4.traducao + conversaoImplicita($1, $4, "||", &$$);
				}
				| E '%' '%' E
				{
					string tempNome = gerarNome();
					string tempNome2 = gerarNome();
					$$.traducao = $1.traducao + $4.traducao + "\t" + tempNome + " = " + $1.label + " * " + $4.label + ";\n" + "\t" + tempNome2 + " = " + tempNome + " / 100;\n";
					$$.label = tempNome2;
				}				
				;
T 				: C F
				{
					
					$$ = $2;
					$$.label = gerarNome();
					mapa_temp[$$.label].label = $$.label;
					mapa_temp[$$.label].tipo = $$.tipo;
					if($1.label == "(float)"){
						$$.traducao = "\tfloat " + $$.label + " = " + $2.label + ";\n";
						$$.tipo = "float";
					}else if($1.label == "(int)"){
						$$.traducao = "\t" + $$.label + " = " + $2.label + ";\n";
						$$.tipo = "int";
					}else{
						$$.traducao = "\t" + $$.label + " = " + $2.label + ";\n";
					}
				}
				| '-' F
				{
					$$ = $2;
					$$.label = gerarNome();
					$$.traducao = $2.traducao + "\t" + $2.tipo + " " + $$.label + " = -" + $2.label + ";\n";
					
				}
				| '+' F
				{
					$$ = $2;
					$$.label = gerarNome();
					$$.traducao = "\t" + $2.tipo + " " + $$.label + " = " + $2.label + ";\n";
				}
				;
F 		  		: TK_NUM
				{
					$$ = $1;
				}
				| TK_ID
				{

					$$ = buscaMapa($1.nome_var);
					if($$.label == "NULL")
					yyerror("Variável não declarada! ");					
				}
				| TK_CHAR
				{
					$$ = $1;
				}
				| TK_BOOL
				{
					$$ = $1;
				}
				;
C 				: TK_CAST
				{
					$$ = $1;
				}
				|
				;
%%
#include "lex.yy.c"
int yyparse();
int main( int argc, char* argv[] )
{
	yyparse();
	return 0;
}
void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}