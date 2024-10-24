dnl Macro to configure the build mode
AC_DEFUN([DEFINE_MODE], [
    AC_ARG_ENABLE([build-mode],
        [AS_HELP_STRING([--enable-build-mode=MODE], [Set build mode: production, debug, memleak, thread-sanitize, coverage])],
        [build_mode=$enableval],
        [build_mode=production])
])

