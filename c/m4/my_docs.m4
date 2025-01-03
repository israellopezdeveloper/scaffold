dnl Macro to enable documentation generation with Doxygen and PDF
AC_DEFUN([CONFIGURE_DOXYGEN], [
    dnl Add option to enable/disable documentation generation
    AC_ARG_ENABLE([doxygen-doc],
        [AS_HELP_STRING([--enable-doxygen-doc], [Enable Doxygen documentation generation])],
        [build_doxygen_docs=$enableval],
        [build_doxygen_docs=no]
    )

    if test "$build_doxygen_docs" = "yes"; then
        dnl Check if Doxygen is installed only if documentation generation is enabled
        AC_MSG_CHECKING([for Doxygen])
        AC_PATH_PROG([DOXYGEN], [doxygen], [no])
        if test "$DOXYGEN" = "no"; then
            AC_MSG_WARN([Doxygen not found - documentation will not be generated])
            AM_CONDITIONAL([ENABLE_DOXYGEN_DOC], [false])
        else
            dnl Create the docs folder if it doesn't exist
            AC_CONFIG_COMMANDS([mkdir_docs], [
                if test ! -d docs; then
                    mkdir docs
                fi
            ])

            AC_MSG_NOTICE([Generating Doxygen documentation])

            dnl Check if LaTeX is available for PDF generation
            AC_PATH_PROG([LATEX], [pdflatex], [no])
            if test "$LATEX" = "no"; then
                AC_MSG_WARN([pdflatex not found - PDF generation will not be available])
            else
                AC_MSG_NOTICE([pdflatex found - PDF generation enabled])
            fi

            dnl Process the Doxyfile.in to generate Doxyfile with the correct values
            AC_CONFIG_FILES([doc/Doxyfile])

            AM_CONDITIONAL([ENABLE_DOXYGEN_DOC], [true])
        fi
    else
        AM_CONDITIONAL([ENABLE_DOXYGEN_DOC], [false])
    fi
])

