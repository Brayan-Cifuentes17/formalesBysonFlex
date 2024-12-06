%{
#include <stdio.h>
#include <string.h>

FILE *output;
%}

%%

\+                     { fprintf(output, " sumar "); }
-                      { fprintf(output, " restar "); }
\*                     { fprintf(output, " multiplicar "); }
\/                     { fprintf(output, " dividir "); }

"if"                   { fprintf(output, "condicional_si "); }
"else"                 { fprintf(output, "condicional_sino "); }
"for"                  { fprintf(output, "ciclo_para "); }
"while"                { fprintf(output, "ciclo_mientras "); }

"System.out.println"   { fprintf(output, "imprimir"); }
"Scanner.nextLine"     { fprintf(output, "leer"); }

"&&"                   { fprintf(output, " y_logico "); }
"||"                   { fprintf(output, " o_logico "); }
"!"                    { fprintf(output, " no_logico "); }

"=="                   { fprintf(output, " igual_a "); }
"!="                   { fprintf(output, " diferente_a "); }
"<"                    { fprintf(output, " menor_que "); }
"<="                   { fprintf(output, " menor_o_igual_que "); }
">"                    { fprintf(output, " mayor_que "); }
">="                   { fprintf(output, " mayor_o_igual_que "); }

"int"                  { fprintf(output, " tipo_entero "); }
"float"                { fprintf(output, " tipo_decimal "); }
"double"               { fprintf(output, " tipo_decimal_grande "); }
"boolean"              { fprintf(output, " tipo_booleano "); }

"true"                 { fprintf(output, " verdadero "); }
"false"                { fprintf(output, " falso "); }

"char"                 { fprintf(output, " tipo_caracter "); }

"void"                 { fprintf(output, " tipo_vacio "); }

[\{\}\(\);]            { fprintf(output, "%s", yytext); }
\"[^\"]*\"             { fprintf(output, " %s ", yytext); }  
[0-9]+                 { fprintf(output, " %s ", yytext); }  
[0-9]*\.[0-9]+         { fprintf(output, " %s ", yytext); }
[a-zA-Z_][a-zA-Z0-9_]* { fprintf(output, " %s ", yytext); }  
"="                    { fprintf(output, " asignar "); }

[\n]                   { fprintf(output, "\n"); }
[ \t]                  { /* Ignorar espacios y tabulaciones */ }

%%

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "Uso: %s <archivo de entrada> <archivo de salida>\n", argv[0]);
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        perror("Error al abrir el archivo de entrada");
        return 1;
    }

    output = fopen(argv[2], "w");
    if (!output) {
        perror("Error al abrir el archivo de salida");
        fclose(input);
        return 1;
    }

    yyin = input;
    yylex();

    fclose(input);
    fclose(output);

    return 0;
}

int yywrap() {
    return 1;
}
