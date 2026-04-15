macro(KillAndKill_configure_linker project_name)
  set(KillAndKill_USER_LINKER_OPTION
    "DEFAULT"
      CACHE STRING "Linker to be used")
    set(KillAndKill_USER_LINKER_OPTION_VALUES "DEFAULT" "SYSTEM" "LLD" "GOLD" "BFD" "MOLD" "SOLD" "APPLE_CLASSIC" "MSVC")
  set_property(CACHE KillAndKill_USER_LINKER_OPTION PROPERTY STRINGS ${KillAndKill_USER_LINKER_OPTION_VALUES})
  list(
    FIND
    KillAndKill_USER_LINKER_OPTION_VALUES
    ${KillAndKill_USER_LINKER_OPTION}
    KillAndKill_USER_LINKER_OPTION_INDEX)

  if(${KillAndKill_USER_LINKER_OPTION_INDEX} EQUAL -1)
    message(
      STATUS
        "Using custom linker: '${KillAndKill_USER_LINKER_OPTION}', explicitly supported entries are ${KillAndKill_USER_LINKER_OPTION_VALUES}")
  endif()

  set_target_properties(${project_name} PROPERTIES LINKER_TYPE "${KillAndKill_USER_LINKER_OPTION}")
endmacro()
