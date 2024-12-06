%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void procesar_log(const char *log);
void ajustar_a_utc(int *hh, int *mm, char signo, int tz_hh, int tz_mm);
void guardar_evento(const char *fecha, const char *contenido);
void yyerror(const char *s);
extern int yylex();
extern char *yytext;

FILE *output;
%}

%token LOG_ENTRY NEWLINE

%%
logs:
      logs log NEWLINE
    | logs NEWLINE
    | /* vacío */
    ;

log:
    LOG_ENTRY { procesar_log(yytext); }
    ;

%%
void procesar_log(const char *log) {
    int yyyy, MM, dd, HH, mm, ss, tz_hh, tz_mm;
    char signo, contenido[256];

    // Parsear el log
    sscanf(log, "%4d-%2d-%2dT%2d:%2d:%2d%1c%2d:%2d %[^\n]",
           &yyyy, &MM, &dd, &HH, &mm, &ss, &signo, &tz_hh, &tz_mm, contenido);

    // Validar zona horaria
    if (tz_hh > 14 || tz_hh < -12 || tz_mm < 0 || tz_mm > 59) {
        printf("Error: Zona horaria fuera de rango\n");
        return;
    }

    // Ajustar hora a UTC
    ajustar_a_utc(&HH, &mm, signo, tz_hh, tz_mm);

    // Crear el formato final
    char fecha_utc[20];
    sprintf(fecha_utc, "%04d%02d%02dT%02d%02d%02dZ", yyyy, MM, dd, HH, mm, ss);
    guardar_evento(fecha_utc, contenido);
}

void ajustar_a_utc(int *hh, int *mm, char signo, int tz_hh, int tz_mm) {
    int offset_min = tz_hh * 60 + tz_mm;
    if (signo == '-') offset_min = -offset_min;

    int total_min = (*hh * 60) + *mm - offset_min;

    *hh = (total_min / 60) % 24;
    *mm = total_min % 60;
}

void guardar_evento(const char *fecha, const char *contenido) {
    fprintf(output, "%s: %s\n", fecha, contenido);
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

// Función principal dentro del archivo Bison
int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Uso: %s <archivo de entrada> <archivo de salida>\n", argv[0]);
        return 1;
    }

    // Abrir archivo de entrada
    FILE *input = fopen(argv[1], "r");
    if (!input) {
        perror("Error abriendo archivo de entrada");
        return 1;
    }

    // Abrir archivo de salida
    output = fopen(argv[2], "w");
    if (!output) {
        perror("Error abriendo archivo de salida");
        fclose(input);
        return 1;
    }

    // Configurar el analizador léxico para usar el archivo de entrada
    extern FILE *yyin;
    yyin = input;

    // Ejecutar el parser
    yyparse();

    fclose(input);
    fclose(output);
    return 0;
}
