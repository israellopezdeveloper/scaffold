dnl Macro to configure the flags
AC_DEFUN([CONFIGURE_FLAGS], [
    PKG_PROG_PKG_CONFIG
    PKG_CHECK_MODULES([NANOLOGGER], [nanologger],
                  [],
                  [AC_MSG_ERROR([Nanologger library not found. Please install the nanologger library.])])
    CFLAGS_COMMON="-pedantic -Wall -Wextra -Werror -Wreturn-local-addr -fstack-protector-strong -Wshadow -Wformat=2 -fstack-clash-protection -fPIE -mtune=native -ftree-vectorize -ffunction-sections -fdata-sections $NANOLOGGER_CFLAGS"
    LIBS="$LIBS $NANOLOGGER_LIBS"
    CFLAGS="-std=c23 $CFLAGS $CFLAGS_COMMON"
    CXXFLAGS="-std=c++23 $CXXFLAGS $CFLAGS_COMMON"
    LDFLAGS="$LDFLAGS -Wl,-z,relro -Wl,-z,now -pie $LIBS -lpthread"

    # Set include directories
    CPPFLAGS="$CPPFLAGS -I${srcdir}/include"

    case "$build_mode" in
        production)
            AC_MSG_NOTICE([Compiling in production mode])
            CFLAGS="-O3 $CFLAGS"
            CXXFLAGS="-O3 $CXXFLAGS"
            LDFLAGS="$LDFLAGS"
            AM_CONDITIONAL([ENABLE_CODE_COVERAGE], [false])
            AM_CONDITIONAL([ENABLE_MEMORY_LEAK], [false])
            AM_CONDITIONAL([ENABLE_THREAD_SANITIZER], [false])
            ;;
        debug)
            AC_MSG_NOTICE([Compiling in debug mode])
            CFLAGS="-Og -g3 $CFLAGS"
            CXXFLAGS="-Og -g3 $CXXFLAGS"
            LDFLAGS="-Og -g3 $LDFLAGS"
            AM_CONDITIONAL([ENABLE_CODE_COVERAGE], [false])
            AM_CONDITIONAL([ENABLE_MEMORY_LEAK], [false])
            AM_CONDITIONAL([ENABLE_THREAD_SANITIZER], [false])
            AC_ARG_WITH([logger-mode],
                AS_HELP_STRING([--with-logger-mode=MODE],
                              [Select the logger mode (options: disable, critical, warn, debug)]),
                [logger_mode=$withval],
                [logger_mode=debug])  # Default value
            # Assign DEBUG value based on the selected mode
            case "$logger_mode" in
                disable)
                    debug_value=0
                    ;;
                critical)
                    debug_value=1
                    ;;
                warn)
                    debug_value=2
                    ;;
                debug)
                    debug_value=3
                    ;;
                *)
                    AC_MSG_ERROR([Invalid logger mode: $logger_mode])
                    ;;
            esac

            # Define the DEBUG macro with the corresponding value
            AC_DEFINE_UNQUOTED([DEBUG], [$debug_value], [Logger debug level])
            ;;
        memleak)
            # Check if libasan is available
            AC_MSG_NOTICE([Compiling with memory leak detection (AddressSanitizer)])
            case "$COMPILER" in
                GCC)
                    AC_MSG_CHECKING([for libasan])
                    AC_CHECK_LIB([asan], [__asan_init], [has_libasan=yes], [has_libasan=no])
                    if test "$has_libasan" = "yes"; then
                        LIBS="$LIBS"
                    else
                        AC_MSG_ERROR([libasan not found])
                    fi
                    AC_CHECK_TOOL([VALGRIND], [valgrind], [no])
                    if test "$VALGRIND" = "no"; then
                        AC_MSG_ERROR([valgrind not found - not able to check memory leaks])
                    fi
                    CFLAGS="-O0 -g $CFLAGS"
                    CXXFLAGS="-O0 -g $CXXFLAGS"
                    LDFLAGS="-O0 -g $LDFLAGS"
                    MEMORY_LEAK_DIAGNOSTIC="valgrind --leak-check=full --show-leak-kinds=all -s "
                    AC_SUBST([MEMORY_LEAK_DIAGNOSTIC])
                    AM_CONDITIONAL([ENABLE_MEMORY_LEAK], [true])
                    ;;
                Clang)
                    AC_CHECK_TOOL([VALGRIND], [valgrind], [no])
                    if test "$VALGRIND" = "no"; then
                        AC_MSG_ERROR([valgrind not found - not able to check memory leaks])
                    fi
                    CFLAGS="-O0 -g -fsanitize=address $CFLAGS"
                    CXXFLAGS="-O0 -g -fsanitize=address $CXXFLAGS"
                    LDFLAGS="-O0 -g -fsanitize=address $LDFLAGS"
                    MEMORY_LEAK_DIAGNOSTIC="ASAN_OPTIONS=detect_leaks=1 "
                    AC_SUBST([MEMORY_LEAK_DIAGNOSTIC])
                    AM_CONDITIONAL([ENABLE_MEMORY_LEAK], [true])
                    ;;
                *)
                    AC_MSG_WARN([Memory leak diagnostic is not supported for this compiler.])
                    AM_CONDITIONAL([ENABLE_MEMORY_LEAK], [false])
                    ;;
            esac
            AM_CONDITIONAL([ENABLE_CODE_COVERAGE], [false])
            AM_CONDITIONAL([ENABLE_THREAD_SANITIZER], [false])
            ;;
        thread-sanitize)
            # Check if libtsan is available
            AC_MSG_CHECKING([for libtsan])
            AC_CHECK_LIB([tsan], [__tsan_init], [has_libtsan=yes], [has_libtsan=no])
            if test "$has_libtsan" = "yes"; then
                LIBS="$LIBS"
            else
                AC_MSG_ERROR([libtsan not found])
            fi
            AC_MSG_NOTICE([Compiling with thread error detection (ThreadSanitizer)])
            CFLAGS="-O0 -g -fsanitize=thread $CFLAGS"
            CXXFLAGS="-O0 -g -fsanitize=thread $CXXFLAGS"
            LDFLAGS="-O0 -g -fsanitize=thread $LDFLAGS"
            AM_CONDITIONAL([ENABLE_CODE_COVERAGE], [false])
            AM_CONDITIONAL([ENABLE_MEMORY_LEAK], [false])
            AM_CONDITIONAL([ENABLE_THREAD_SANITIZER], [true])
            ;;
        coverage)
            case "$COMPILER" in
                GCC)
                    AC_PATH_PROG([GCOV], [gcov], [no])
                    if test "$GCOV" = "no"; then
                        AC_MSG_WARN([gcov not found, code coverage reports will not be generated])
                    else
                        AC_MSG_NOTICE([gcov found, coverage reports enabled])
                    fi
                    AC_PATH_PROG([LCOV], [lcov], [no])
                    if test "$LCOV" = "no"; then
                        AC_MSG_WARN([lcov not found, code coverage reports will not be generated])
                    else
                        AC_MSG_NOTICE([lcov found, coverage reports enabled])
                    fi
                    AC_PATH_PROG([GENHTML], [genhtml], [no])
                    if test "$GENHTML" = "no"; then
                        AC_MSG_WARN([genhtml not found, code coverage reports will not be generated])
                    else
                        AC_MSG_NOTICE([genhtml found, coverage reports enabled])
                    fi
                    AC_PATH_PROG([GCOVR], [gcovr], [no])
                    if test "$GCOVR" = "no"; then
                        AC_MSG_ERROR([gcovr not found, code coverage reports will not be generated])
                    else
                        AC_MSG_NOTICE([gcovr found, coverage reports enabled])
                    fi
                    AC_MSG_NOTICE([Enabling code coverage for GCC])
                    CFLAGS="-fprofile-arcs -fprofile-update=atomic -ftest-coverage $CFLAGS"
                    CXXFLAGS="-fprofile-arcs -fprofile-update=atomic -ftest-coverage $CXXFLAGS"
                    LDFLAGS="-fprofile-arcs -fprofile-update=atomic -ftest-coverage $LDFLAGS"
                    AM_CONDITIONAL([ENABLE_CODE_COVERAGE], [true])
                    ;;
                Clang)
                    AC_PATH_PROG([LLVM_PROFDATA], [llvm-profdata], [no])
                    if test "$LLVM_PROFDATA" = "no"; then
                        AC_MSG_WARN([llvm-profdata not found, code coverage reports will not be generated])
                    else
                        AC_MSG_NOTICE([llvm-profdata found, coverage reports enabled])
                    fi
                    AC_PATH_PROG([LLVM_COV], [llvm-cov], [no])
                    if test "$LLVM_COV" = "no"; then
                        AC_MSG_WARN([llvm-cov not found, code coverage reports will not be generated])
                    else
                        AC_MSG_NOTICE([llvm-cov found, coverage reports enabled])
                    fi
                    AC_CHECK_PROG([JQ], [jq], [yes], [no])
                    if test "$JQ" = "no"; then
                        AC_MSG_ERROR([jq is required to generate coverage report but not found])
                    fi
                    AC_MSG_NOTICE([Enabling code coverage for Clang])
                    CFLAGS="$CFLAGS -fprofile-instr-generate -fcoverage-mapping $CFLAGS"
                    CXXFLAGS="$CXXFLAGS -fprofile-instr-generate -fcoverage-mapping $CXXFLAGS"
                    LDFLAGS="-fprofile-instr-generate -fcoverage-mapping $LDFLAGS"
                    AM_CONDITIONAL([ENABLE_CODE_COVERAGE], [true])
                    ;;
                *)
                    AC_MSG_WARN([Code coverage is not supported for this compiler: $COMPILER])
                    AM_CONDITIONAL([ENABLE_CODE_COVERAGE], [false])
                    ;;
            esac
            AM_CONDITIONAL([ENABLE_MEMORY_LEAK], [false])
            AM_CONDITIONAL([ENABLE_THREAD_SANITIZER], [false])
            ;;
        *)
            AC_MSG_ERROR([Invalid build mode: $build_mode])
            AM_CONDITIONAL([ENABLE_CODE_COVERAGE], [false])
            AM_CONDITIONAL([ENABLE_MEMORY_LEAK], [false])
            AM_CONDITIONAL([ENABLE_THREAD_SANITIZER], [false])
            ;;
    esac
    AH_BOTTOM([#include <nanologger.h>])
])

