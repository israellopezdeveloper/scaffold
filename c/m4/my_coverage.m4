dnl Macro to configure coverage
AC_DEFUN([CONFIGURE_COVERAGE], [
    AC_MSG_CHECKING([Configure coverage limits])
    AC_ARG_ENABLE([line-coverage],
        [AS_HELP_STRING([--line-coverage=LIMIT], [Set line coverage limit. Default value: 80])],
        [line_coverage=$enableval],
        [line_coverage=80])
    LINE_COVERAGE=$line_coverage
    AC_SUBST([LINE_COVERAGE])
    AC_ARG_ENABLE([function-coverage],
        [AS_HELP_STRING([--function-coverage=LIMIT], [Set function coverage limit. Default value: 80])],
        [function_coverage=$enableval],
        [function_coverage=80])
    FUNCTION_COVERAGE=$function_coverage
    AC_SUBST([FUNCTION_COVERAGE])
    AC_ARG_ENABLE([branch-coverage],
        [AS_HELP_STRING([--branch-coverage=LIMIT], [Set branch coverage limit. Default value: 60])],
        [branch_coverage=$enableval],
        [branch_coverage=60])
    BRANCH_COVERAGE=$branch_coverage
    AC_SUBST([BRANCH_COVERAGE])
])

