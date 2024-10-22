dnl This configuration ensures a package that complies with GNU standards.
dnl And provides the following functionalities.

dnl ================================
dnl Macro SUMMARY
dnl -------------------------------
dnl This macro generates a project summary displaying:
dnl - Package name ($PACKAGE_NAME)
dnl - Package version ($VERSION)
dnl - Compilation mode ($build_mode)
dnl - Compiler used ($COMPILER)
dnl - Compilation flags (CFLAGS, CXXFLAGS, LDFLAGS)
dnl The information is passed to a script to format it into a clear output.
dnl ================================

dnl ================================
dnl Macro CONFIGURE_FLAGS
dnl -------------------------------
dnl This macro configures the compilation flags based on the selected mode:
dnl - production: Maximum optimization (-O3), includes flags for security and performance.
dnl - debug: Enables debugging (-Og -g3).
dnl - memleak: Enables AddressSanitizer and checks for memory leaks using valgrind.
dnl - thread-sanitize: Enables ThreadSanitizer to detect thread issues.
dnl - coverage: Enables code coverage (gcov/lcov for GCC, llvm-profdata for Clang).
dnl Additionally, it defines conditional variables to enable/disable diagnostics
dnl for memory leaks, code coverage, and thread sanitization.
dnl ================================

dnl ================================
dnl Macro CONFIGURE_DOXYGEN
dnl -------------------------------
dnl This macro checks if Doxygen is available to generate the project documentation.
dnl If enabled (option --enable-doxygen-doc), it creates the 'docs' directory and
dnl generates documentation in HTML format, and optionally in PDF if `pdflatex` is available.
dnl ================================

dnl ================================
dnl Macro DETECT_COMPILER
dnl -------------------------------
dnl Detects the compiler used by the CC variable:
dnl - GCC (if gcc is detected)
dnl - Clang (if clang is detected)
dnl - MinGW (if mingw is detected)
dnl The detection is used to adjust subsequent configurations and is exported
dnl in the $COMPILER variable.
dnl ================================

dnl ================================
dnl Macro DEFINE_MODE
dnl -------------------------------
dnl Defines the compilation mode through the --enable-build-mode option.
dnl Available modes: production (default), debug, memleak, thread-sanitize, coverage.
dnl ================================

dnl ================================
dnl Macro COMPILE_COMMANDS
dnl -------------------------------
dnl Checks if Bear is available to generate the compile_commands.json file,
dnl used by analysis tools like clangd. Generation is enabled with the 
dnl --enable-compile-commands option.
dnl ================================
AC_DEFUN([MY_CONFIGURATION], [
  AM_INIT_AUTOMAKE([-Wall -Werror subdir-objects silent-rules])
  AM_SILENT_RULES([yes])

  DETECT_COMPILER

  DEFINE_MODE

  CONFIGURE_FLAGS

  CONFIGURE_DOXYGEN

  COMPILE_COMMANDS

  SUMMARY

  AH_TOP([
#include <unistd.h>

/*! @brief Bad result of operation */
#define ERROR_CODE 0

/*! @brief Good result of operation */
#define SUCCESS_CODE 1
  ])
  AC_CONFIG_HEADERS([include/config.h])
  AC_CONFIG_FILES([Makefile])
  AC_OUTPUT
])

