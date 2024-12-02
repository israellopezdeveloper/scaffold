dnl Macro to detect the compiler (GCC or Clang)
AC_DEFUN([DETECT_COMPILER], [
    AC_MSG_CHECKING([for compiler used by CC])
    AC_CHECK_TOOL([WINDRES], [windres], [no])
    if test "$WINDRES" != "no"; then
        IS_MINGW=yes
    else
        IS_MINGW=no
    fi

    # Initially assume it is unknown
    COMPILER="Unknown"

    CFLAGS=""
    CXXFLAGS=""
    LDFLAGS=""
    # Detect if it is GCC
    if $CC --version 2>/dev/null | grep -q 'gcc'; then
        COMPILER="GCC"
    # Detect if it is Clang
    elif $CC --version 2>/dev/null | grep -q 'clang'; then
        COMPILER="Clang"
        CXXFLAGS="-stdlib=libstdc++"
        LDFLAGS="-lc++ -lc++abi"
    # Detect if it is MinGW
    elif $CC --version 2>/dev/null | grep -q 'mingw'; then
        COMPILER="MingW"
    fi

    # Show the detected compiler
    AC_MSG_RESULT([$COMPILER])

    # Export the COMPILER variable for later use
    AC_SUBST([COMPILER])
])

