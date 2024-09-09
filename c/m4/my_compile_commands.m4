AC_DEFUN([COMPILE_COMMANDS], [
    AC_MSG_CHECKING([for required software to generate compile_commands.json])
    # Añadir la opción --enable-compile-commands
    AC_ARG_ENABLE([compile-commands],
        [AS_HELP_STRING([--enable-compile-commands], [Generate compile_commands.json using Bear])],
        [enable_compile_commands=$enableval], [enable_compile_commands=yes])

    if test "$enable_compile_commands" = "yes"; then
      AC_PATH_PROG([BEAR], [bear], [no])
      if test "$BEAR" = "no"; then
        AC_MSG_ERROR([Bear is required to generate compile_commands.json, but it was not found.])
      fi
      AM_CONDITIONAL([ENABLE_COMPILE_COMMANDS], [true])
    else
      AM_CONDITIONAL([ENABLE_COMPILE_COMMANDS], [false])
    fi

])

