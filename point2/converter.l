%{
#include "converter.tab.h"
#include <stdio.h>
#include <stdlib.h>
%}

DIGIT       [0-9]
TZ          (\+|-)[0-9][0-9]:[0-9][0-9]
DATE        {DIGIT}{DIGIT}{DIGIT}{DIGIT}-{DIGIT}{DIGIT}-{DIGIT}{DIGIT}
TIME        {DIGIT}{DIGIT}:{DIGIT}{DIGIT}:{DIGIT}{DIGIT}

%%
{DATE}T{TIME}{TZ}[^\n\r]* { return LOG_ENTRY; } // Captura el log completo (fecha, hora, zona y evento)
[\n\r]+                   { return NEWLINE; }  // Maneja líneas vacías
[ \t]+                    { /* Ignorar espacios */ }
.                         { printf("Error: carácter no reconocido '%s'\n", yytext); }
%%
