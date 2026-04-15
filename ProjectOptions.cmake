include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


include(CheckCXXSourceCompiles)


macro(KillAndKill_supports_sanitizers)
  # Emscripten doesn't support sanitizers
  if(EMSCRIPTEN)
    set(SUPPORTS_UBSAN OFF)
    set(SUPPORTS_ASAN OFF)
  elseif((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)

    message(STATUS "Sanity checking UndefinedBehaviorSanitizer, it should be supported on this platform")
    set(TEST_PROGRAM "int main() { return 0; }")

    # Check if UndefinedBehaviorSanitizer works at link time
    set(CMAKE_REQUIRED_FLAGS "-fsanitize=undefined")
    set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=undefined")
    check_cxx_source_compiles("${TEST_PROGRAM}" HAS_UBSAN_LINK_SUPPORT)

    if(HAS_UBSAN_LINK_SUPPORT)
      message(STATUS "UndefinedBehaviorSanitizer is supported at both compile and link time.")
      set(SUPPORTS_UBSAN ON)
    else()
      message(WARNING "UndefinedBehaviorSanitizer is NOT supported at link time.")
      set(SUPPORTS_UBSAN OFF)
    endif()
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    if (NOT WIN32)
      message(STATUS "Sanity checking AddressSanitizer, it should be supported on this platform")
      set(TEST_PROGRAM "int main() { return 0; }")

      # Check if AddressSanitizer works at link time
      set(CMAKE_REQUIRED_FLAGS "-fsanitize=address")
      set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=address")
      check_cxx_source_compiles("${TEST_PROGRAM}" HAS_ASAN_LINK_SUPPORT)

      if(HAS_ASAN_LINK_SUPPORT)
        message(STATUS "AddressSanitizer is supported at both compile and link time.")
        set(SUPPORTS_ASAN ON)
      else()
        message(WARNING "AddressSanitizer is NOT supported at link time.")
        set(SUPPORTS_ASAN OFF)
      endif()
    else()
      set(SUPPORTS_ASAN ON)
    endif()
  endif()
endmacro()

macro(KillAndKill_setup_options)
  option(KillAndKill_ENABLE_HARDENING "Enable hardening" ON)
  option(KillAndKill_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    KillAndKill_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    KillAndKill_ENABLE_HARDENING
    OFF)

  KillAndKill_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR KillAndKill_PACKAGING_MAINTAINER_MODE)
    option(KillAndKill_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(KillAndKill_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(KillAndKill_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(KillAndKill_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(KillAndKill_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(KillAndKill_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(KillAndKill_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(KillAndKill_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(KillAndKill_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(KillAndKill_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(KillAndKill_ENABLE_PCH "Enable precompiled headers" OFF)
    option(KillAndKill_ENABLE_CACHE "Enable ccache" OFF)
  elseif(ENABLE_DEVELOPER_MODE)
    option(KillAndKill_ENABLE_IPO "Enable IPO/LTO" ON)
    option(KillAndKill_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(KillAndKill_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(KillAndKill_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(KillAndKill_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(KillAndKill_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(KillAndKill_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(KillAndKill_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(KillAndKill_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(KillAndKill_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(KillAndKill_ENABLE_PCH "Enable precompiled headers" OFF)
    option(KillAndKill_ENABLE_CACHE "Enable ccache" ON)
  else()
    option(KillAndKill_ENABLE_IPO "Enable IPO/LTO" ON)
    option(KillAndKill_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(KillAndKill_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(KillAndKill_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(KillAndKill_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(KillAndKill_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(KillAndKill_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(KillAndKill_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(KillAndKill_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(KillAndKill_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(KillAndKill_ENABLE_PCH "Enable precompiled headers" OFF)
    option(KillAndKill_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      KillAndKill_ENABLE_IPO
      KillAndKill_WARNINGS_AS_ERRORS
      KillAndKill_ENABLE_SANITIZER_ADDRESS
      KillAndKill_ENABLE_SANITIZER_LEAK
      KillAndKill_ENABLE_SANITIZER_UNDEFINED
      KillAndKill_ENABLE_SANITIZER_THREAD
      KillAndKill_ENABLE_SANITIZER_MEMORY
      KillAndKill_ENABLE_UNITY_BUILD
      KillAndKill_ENABLE_CLANG_TIDY
      KillAndKill_ENABLE_CPPCHECK
      KillAndKill_ENABLE_LIZARD
      KillAndKill_ENABLE_BLOATY
      KillAndKill_ENABLE_COVERAGE
      KillAndKill_ENABLE_PCH
      KillAndKill_ENABLE_CACHE)
  endif()

  KillAndKill_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED AND (KillAndKill_ENABLE_SANITIZER_ADDRESS OR KillAndKill_ENABLE_SANITIZER_THREAD OR KillAndKill_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(KillAndKill_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(KillAndKill_global_options)
  if(KillAndKill_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    KillAndKill_enable_ipo()
  endif()

  KillAndKill_supports_sanitizers()

  if(KillAndKill_ENABLE_HARDENING AND KillAndKill_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR KillAndKill_ENABLE_SANITIZER_UNDEFINED
       OR KillAndKill_ENABLE_SANITIZER_ADDRESS
       OR KillAndKill_ENABLE_SANITIZER_THREAD
       OR KillAndKill_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${KillAndKill_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${KillAndKill_ENABLE_SANITIZER_UNDEFINED}")
    KillAndKill_enable_hardening(KillAndKill_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(KillAndKill_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(KillAndKill_warnings INTERFACE)
  add_library(KillAndKill_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  KillAndKill_set_project_warnings(
    KillAndKill_warnings
    ${KillAndKill_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  include(cmake/Linker.cmake)
  # Must configure each target with linker options, we're avoiding setting it globally for now

  if(NOT EMSCRIPTEN)
    include(cmake/Sanitizers.cmake)
    KillAndKill_enable_sanitizers(
      KillAndKill_options
      ${KillAndKill_ENABLE_SANITIZER_ADDRESS}
      ${KillAndKill_ENABLE_SANITIZER_LEAK}
      ${KillAndKill_ENABLE_SANITIZER_UNDEFINED}
      ${KillAndKill_ENABLE_SANITIZER_THREAD}
      ${KillAndKill_ENABLE_SANITIZER_MEMORY})
  endif()

  set_target_properties(KillAndKill_options PROPERTIES UNITY_BUILD ${KillAndKill_ENABLE_UNITY_BUILD})

  if(KillAndKill_ENABLE_PCH)
    target_precompile_headers(
      KillAndKill_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(KillAndKill_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    KillAndKill_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(KillAndKill_ENABLE_CLANG_TIDY)
    KillAndKill_enable_clang_tidy(KillAndKill_options ${KillAndKill_WARNINGS_AS_ERRORS})
  endif()

  if(KillAndKill_ENABLE_CPPCHECK)
    KillAndKill_enable_cppcheck(${KillAndKill_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()
  
  if(KillAndKill_ENABLE_LIZARD)
    KillAndKill_enable_lizard(${KillAndKill_WARNINGS_AS_ERRORS})
  endif()
  
  if(KillAndKill_ENABLE_BLOATY)
    KillAndKill_enable_bloaty()
  endif()

  if(KillAndKill_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    KillAndKill_enable_coverage(KillAndKill_options)
  endif()

  if(KillAndKill_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(KillAndKill_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(KillAndKill_ENABLE_HARDENING AND NOT KillAndKill_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR KillAndKill_ENABLE_SANITIZER_UNDEFINED
       OR KillAndKill_ENABLE_SANITIZER_ADDRESS
       OR KillAndKill_ENABLE_SANITIZER_THREAD
       OR KillAndKill_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    KillAndKill_enable_hardening(KillAndKill_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
