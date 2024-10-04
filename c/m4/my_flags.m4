dnl Macro para configurar los flags
AC_DEFUN([CONFIGURE_FLAGS], [
    CFLAGS_COMMON="-Wall -Wextra -Werror -fstack-protector-strong -Wshadow -Wformat=2 -fstack-clash-protection -fPIE"
    CXXFLAGS_COMMON="$CFLAGS_COMMON"
    LDFLAGS_COMMON="-Wl,-z,relro -Wl,-z,now -pie"

    # Establece directorios de inclusión
    CPPFLAGS="$CPPFLAGS -I${srcdir}/include"

    case "$build_mode" in
        production)
            AC_MSG_NOTICE([Compilando en modo producción])
            CFLAGS="-O3 -fPIE -march=native -flto -funroll-loops $CFLAGS_COMMON"
            CXXFLAGS="-O3 -fPIE -march=native -flto -funroll-loops $CXXFLAGS_COMMON"
            LDFLAGS="-flto -pie $LDFLAGS_COMMON"
            AM_CONDITIONAL([ENABLE_CODE_COVERAGE], [false])
            AM_CONDITIONAL([ENABLE_MEMORY_LEAK], [false])
            AM_CONDITIONAL([ENABLE_THREAD_SANITIZER], [false])
            ;;
        debug)
            AC_MSG_NOTICE([Compilando en modo depuración])
            CFLAGS="-Og -g3 $CFLAGS_COMMON"
            CXXFLAGS="-Og -g3 $CXXFLAGS_COMMON"
            AM_CONDITIONAL([ENABLE_CODE_COVERAGE], [false])
            AM_CONDITIONAL([ENABLE_MEMORY_LEAK], [false])
            AM_CONDITIONAL([ENABLE_THREAD_SANITIZER], [false])
            ;;
        memleak)
            # Verificar si libasan está disponible
            AC_MSG_CHECKING([for libasan])
            AC_CHECK_LIB([asan], [__asan_init], [has_libasan=yes], [has_libasan=no])
            if test "$has_libasan" = "yes"; then
                LIBS="$LIBS -lasan"
            else
                AC_MSG_ERROR([libasan not found])
            fi
            AC_MSG_NOTICE([Compilando con detección de fugas de memoria (AddressSanitizer)])
            case "$COMPILER" in
                GCC)
                    AC_CHECK_TOOL([VALGRIND], [valgrind], [no])
                    if test "$VALGRIND" = "no"; then
                        AC_MSG_ERROR([valgrind not found - not able to check memory leaks])
                    fi
                    CFLAGS="-O0 -g -fsanitize=address -fno-omit-frame-pointer $CFLAGS_COMMON"
                    CXXFLAGS="-O0 -g -fsanitize=address -fno-omit-frame-pointer $CXXFLAGS_COMMON"
                    LDFLAGS="-O0 -g -fsanitize=address -fno-omit-frame-pointer $LDFLAGS_COMMON"
                    MEMORY_LEAK_DIAGNOSTIC="valgrind --leak-check=full --show-leak-kinds=all -s"
                    AC_SUBST([MEMORY_LEAK_DIAGNOSTIC])
                    AM_CONDITIONAL([ENABLE_MEMORY_LEAK], [true])
                    ;;
                Clang)
                    AC_CHECK_TOOL([VALGRIND], [valgrind], [no])
                    if test "$VALGRIND" = "no"; then
                        AC_MSG_ERROR([valgrind not found - not able to check memory leaks])
                    fi
                    CFLAGS="-O0 -g"
                    CXXFLAGS="-O0 -g"
                    LDFLAGS="-O0 -g"
                    MEMORY_LEAK_DIAGNOSTIC="valgrind --leak-check=full --show-leak-kinds=all -s"
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
            # Verificar si libtsan está disponible
            AC_MSG_CHECKING([for libtsan])
            AC_CHECK_LIB([tsan], [__tsan_init], [has_libtsan=yes], [has_libtsan=no])
            if test "$has_libtsan" = "yes"; then
                LIBS="$LIBS -ltsan"
            else
                AC_MSG_ERROR([libtsan not found])
            fi
            AC_MSG_NOTICE([Compilando con detección de errores de hilos (ThreadSanitizer)])
            CFLAGS="-O1 -g -fsanitize=thread $CFLAGS_COMMON"
            CXXFLAGS="-O1 -g -fsanitize=thread $CXXFLAGS_COMMON"
            LDFLAGS="-fsanitize=thread $LDFLAGS_COMMON"
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
                        AC_MSG_WARN([gcovr not found, code coverage reports will not be generated])
                    else
                        AC_MSG_NOTICE([gcovr found, coverage reports enabled])
                    fi
                    AC_MSG_NOTICE([Enabling code coverage for GCC])
                    CFLAGS="-fprofile-arcs -fprofile-update=atomic -ftest-coverage $CFLAGS_COMMON"
                    CXXFLAGS="-fprofile-arcs -fprofile-update=atomic -ftest-coverage $CXXFLAGS_COMMON"
                    LDFLAGS="-fprofile-arcs -fprofile-update=atomic -ftest-coverage $LDFLAGS_COMMON"
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
                    CFLAGS="$CFLAGS -fprofile-instr-generate -fcoverage-mapping $CFLAGS_COMMON"
                    CXXFLAGS="$CXXFLAGS -fprofile-instr-generate -fcoverage-mapping $CXXFLAGS_COMMON"
                    LDFLAGS="-fprofile-instr-generate -fcoverage-mapping $LDFLAGS_COMMON"
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
            AC_MSG_ERROR([Modo de compilación inválido: $build_mode])
            AM_CONDITIONAL([ENABLE_CODE_COVERAGE], [false])
            AM_CONDITIONAL([ENABLE_MEMORY_LEAK], [false])
            AM_CONDITIONAL([ENABLE_THREAD_SANITIZER], [false])
            ;;
    esac
])

