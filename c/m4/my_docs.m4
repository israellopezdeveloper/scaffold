dnl Macro para habilitar la generación de documentación con Doxygen y PDF
AC_DEFUN([CONFIGURE_DOXYGEN], [
    dnl Añadir opción para habilitar/deshabilitar la generación de documentación
    AC_ARG_ENABLE([doxygen-doc],
        [AS_HELP_STRING([--enable-doxygen-doc], [Enable Doxygen documentation generation])],
        [build_doxygen_docs=$enableval],
        [build_doxygen_docs=no]
    )

    if test "$build_doxygen_docs" = "yes"; then
        dnl Verificar si Doxygen está instalado solo si se habilita la generación de documentación
        AC_MSG_CHECKING([for Doxygen])
        AC_PATH_PROG([DOXYGEN], [doxygen], [no])
        if test "$DOXYGEN" = "no"; then
            AC_MSG_WARN([Doxygen not found - documentation will not be generated])
            AM_CONDITIONAL([ENABLE_DOXYGEN_DOC], [false])
        else
            dnl Crear la carpeta docs si no existe
            AC_CONFIG_COMMANDS([mkdir_docs], [
                if test ! -d docs; then
                    mkdir docs
                fi
            ])

            AC_MSG_NOTICE([Generating Doxygen documentation])

            dnl Verificar si LaTeX está disponible para la generación de PDFs
            AC_PATH_PROG([LATEX], [pdflatex], [no])
            if test "$LATEX" = "no"; then
                AC_MSG_WARN([pdflatex not found - PDF generation will not be available])
            else
                AC_MSG_NOTICE([pdflatex found - PDF generation enabled])
            fi

            dnl Procesar el archivo Doxyfile.in para generar Doxyfile con los valores correctos
            AC_CONFIG_FILES([Doxyfile])

            AM_CONDITIONAL([ENABLE_DOXYGEN_DOC], [true])
        fi
    else
        AM_CONDITIONAL([ENABLE_DOXYGEN_DOC], [false])
    fi
])
