AC_DEFUN([SUMMARY], [
    AC_MSG_NOTICE([])

    # Usar m4_expand para generar el texto del resumen con las variables de m4
    m4_expand([
    summary_text="Project:[$PACKAGE_NAME]
Version:[$VERSION]
Compilation mode:[$build_mode]
Compiler:[$COMPILER]
CFLAGS:[$CFLAGS]
CXXFLAGS:[$CXXFLAGS]
LDFLAGS:[$LDFLAGS]"
    
    echo "$summary_text" | awk -v max_width="80" '
    BEGIN {
        FS = ":"; 
        dash_line = "";
        for (i = 1; i <= max_width; i++) {
            dash_line = dash_line "=";
        }
        print dash_line;
    }
    {
        field1 = [$]1;
        field2 = [$]2;

        # Elimina espacios en blanco al inicio y final
        gsub(/^[ \t]+|[ \t]+$/, "", field1);
        gsub(/^[ \t]+|[ \t]+$/, "", field2);

        # Ajustar la longitud del campo 2 si excede max_width
        if (length(field2) > max_width - 45) {
            printf("%-20s : ", field1);
            while (length(field2) > 0) {
                split_point = max_width - (20 + 5);
                if (length(field2) > split_point) {
                    while (substr(field2, split_point, 1) != " " && split_point > 0) {
                        split_point--;
                    }
                }
                printf("%s\n", substr(field2, 1, split_point));
                field2 = substr(field2, split_point + 1);
                if (length(field2) > 0) {
                    printf("%-20s   ", "");  # Espacios para la nueva línea
                }
            }
        } else {
            printf("%-20s : %s\n", field1, field2);
        }
        
        # Imprimir línea separadora simple entre campos
        dash_line_simple = "";
        for (i = 1; i <= max_width; i++) {
            dash_line_simple = dash_line_simple "-";
        }
        print dash_line_simple;
    }
    END {
        dash_line = "";
        for (i = 1; i <= max_width; i++) {
            dash_line = dash_line "=";
        }
        print dash_line;
    }'
    ])])

    AC_MSG_NOTICE([])
])

