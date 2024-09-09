dnl Macro para detectar el compilador (GCC o Clang)
AC_DEFUN([DETECT_COMPILER], [
    AC_MSG_CHECKING([for compiler used by CC])
    AC_CHECK_TOOL([WINDRES], [windres], [no])
    if test "$WINDRES" != "no"; then
        IS_MINGW=yes
    else
        IS_MINGW=no
    fi

    # Inicialmente asumimos que es desconocido
    COMPILER="Unknown"

    # Detectar si es GCC
    if $CC --version 2>/dev/null | grep -q 'gcc'; then
        COMPILER="GCC"
    # Detectar si es Clang
    elif $CC --version 2>/dev/null | grep -q 'clang'; then
        COMPILER="Clang"
    # Detectar si es MinGW
    elif $CC --version 2>/dev/null | grep -q 'mingw'; then
        COMPILER="MingW"
    fi

    # Mostrar el compilador detectado
    AC_MSG_RESULT([$COMPILER])

    # Exportar la variable COMPILER para uso posterior
    AC_SUBST([COMPILER])
])

