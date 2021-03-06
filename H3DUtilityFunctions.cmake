if( POLICY CMP0054 )
  cmake_policy( SET CMP0054 NEW )
endif()
# Contains utility H3D functions that are used a bit here and there.

# Get the library/executable postfix commonly used by our library/executable names for MSVC.
# post_fix_output Contains the variable which should be set to the generated postfix.
# Only set if generator is MSVC.
function( getMSVCPostFix post_fix_output )
  if( MSVC )
    set( h3d_msvc_version 6 )
    set( temp_msvc_version 1299 )
    while( ${MSVC_VERSION} GREATER ${temp_msvc_version} )
      math( EXPR h3d_msvc_version "${h3d_msvc_version} + 1" )
      math( EXPR temp_msvc_version "${temp_msvc_version} + 100" )
    endwhile()

    if( ${h3d_msvc_version} GREATER 12 ) # MSVC skipped 13 in their numbering system.
      math( EXPR h3d_msvc_version "${h3d_msvc_version} + 1" )
    endif()
    if( ( ${h3d_msvc_version} GREATER 14 ) OR ( ${MSVC_VERSION} GREATER 1900 ) )
      # MSVC vs 2015 has number 1900 and vs 2017 has number 1910. So this is a guess on upcoming vs versions.
      math( EXPR h3d_msvc_version "${h3d_msvc_version} + 1" )
    endif()
    if( ( ${h3d_msvc_version} GREATER 15 ) OR ( ( ${MSVC_VERSION} GREATER 1920 ) OR ( ${MSVC_VERSION} EQUAL 1920 ) ) )
      # MSVC vs 2019 has number 1920 and should have _vc16. Anything between 1900 and 1920 should be _vc15 though
      math( EXPR h3d_msvc_version "${h3d_msvc_version} + 1" )
    endif()
    set( ${post_fix_output} _vc${h3d_msvc_version} PARENT_SCOPE )
  endif()
endfunction()

# Get the commonly used library and binary output directory name for H3D.
# default_bin_directory_output should contain a variable which will be set to the bin directory name.
# default_lib_directory_output should contain a variable which will be set to the lib directory name.
function( getDefaultH3DOutputDirectoryName default_bin_directory_output default_lib_directory_output )
  set( default_bin_install_internal "bin" )
  set( default_lib_install_internal "lib" )
  if( WIN32 )
    set( default_bin_install_internal "bin32" )
    set( default_lib_install_internal "lib32" )
    if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
      set( default_bin_install_internal "bin64" )
      set( default_lib_install_internal "lib64" )
    endif()
  endif()
  set( ${default_bin_directory_output} ${default_bin_install_internal} PARENT_SCOPE )
  set( ${default_lib_directory_output} ${default_lib_install_internal} PARENT_SCOPE )
endfunction()

# Checks if the compiler has support for c++11, or at least the features H3D uses ( MVSC 2010 supported ones ).
function( enableCpp11 )
  set( options )
  set( one_value_args FAIL_MESSAGE )
  set( multi_value_args )
  include( CMakeParseArguments )
  cmake_parse_arguments( enable_c++11 "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )
  if( enable_c++11_UNPARSED_ARGUMENTS )
    message( FATAL_ERROR "Unknown keywords given to enableCpp11(): \"${enable_c++11_UNPARSED_ARGUMENTS}\"" )
  endif()

  set( fail_message "Compiler does not support c++11." )
  if( enable_c++11_FAIL_MESSAGE )
    set( fail_message ${enable_c++11_FAIL_MESSAGE} )
  endif()

  if( "${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang" )
    include( CheckCXXCompilerFlag )
    check_cxx_compiler_flag( --std=gnu++11 SUPPORTS_STD_11 )
    check_cxx_compiler_flag( --std=gnu++0x SUPPORTS_STD_0X )
    if( SUPPORTS_STD_11 )
      if( CMAKE_VERSION VERSION_LESS 2.8.12 )
        add_definitions( "-std=gnu++11" )
      else()
        add_compile_options( "-std=gnu++11" )
      endif()
    elseif( SUPPORTS_STD_0X )
      if( CMAKE_VERSION VERSION_LESS 2.8.12 )
        add_definitions( "-std=gnu++0x" )
      else()
        add_compile_options( "-std=gnu++0x" )
      endif()
    else()
      message( FATAL_ERROR ${fail_message} )
    endif()
  elseif( "${CMAKE_CXX_COMPILER_ID}" MATCHES "MSVC" )
    if( ${MSVC_VERSION} LESS 1900 )
      message( FATAL_ERROR ${fail_message} )
    endif()
  else()
    message( FATAL_ERROR "Unknown compiler" )
  endif()
endfunction()

# This function will create a cache variable with the given old name
# in order to not break old CMakeLists.txt which relies on it.
# It will give it a special DOCSTRING so that the function checkIfCacheVarIsCreatedForBackwardsCompatibilityReasons
# can check why it exists.
function( createCacheVariablesMarkedAsDeprecated )
  set( options )
  set( one_value_args )
  set( multi_value_args NEW_VARIABLE_NAMES OLD_VARIABLE_NAMES )
  include( CMakeParseArguments )
  cmake_parse_arguments( create_cache_vars_marked_deprecated "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )
  if( create_cache_vars_marked_deprecated_UNPARSED_ARGUMENTS )
    message( FATAL_ERROR "Unknown keywords given to createCacheVariablesMarkedAsDeprecated(): \"${create_cache_vars_marked_deprecated_UNPARSED_ARGUMENTS}\"" )
  endif()
  
  foreach( required_arg ${multi_value_args} )
    if( NOT create_cache_vars_marked_deprecated_${required_arg} )
      message( FATAL_ERROR "The required argument ${required_arg} is missing when calling setupResourceFile." )
    endif()
  endforeach()

  set( i 0 )
  list( LENGTH create_cache_vars_marked_deprecated_OLD_VARIABLE_NAMES nr_old_var_names )
  list( LENGTH create_cache_vars_marked_deprecated_NEW_VARIABLE_NAMES nr_new_var_names )
  if( NOT ${nr_old_var_names} EQUAL ${nr_new_var_names} )
    message( FATAL_ERROR "The number of entries in OLD_VARIABLE_NAMES and NEW_VARIABLE_NAMES does not match." )
  endif()
  foreach( _old_var_name ${create_cache_vars_marked_deprecated_OLD_VARIABLE_NAMES} )
    if( NOT DEFINED ${_old_var_name} )
      list( GET create_cache_vars_marked_deprecated_NEW_VARIABLE_NAMES ${i} _new_var_name )
      get_property( var_type CACHE ${_new_var_name} PROPERTY TYPE )
      set( ${_old_var_name} ${${_new_var_name}} CACHE ${var_type} "VARIABLE IS DEPRECATED. This variable is created for backwards compatiblity reasons, please replace all checks with ${_new_var_name} in your CMake code." FORCE )
      mark_as_advanced( ${_old_var_name} )
    endif()
  endforeach()
endfunction()

# Check if a variable exists and if it exists a check is done to see if it was created by createDeprecatedCacheVariables.
# Which means it is created for backwards compatiblity reasons.
# If it exists and is set for backwards compatiblity reasons the OUTPUT_VARIABLE is set to true, otherwise false.
function( checkIfCacheVariableMarkedAsDeprecated )
  set( options )
  set( one_value_args CACHE_VARIABLE OUTPUT_VARIABLE )
  set( multi_value_args )
  include( CMakeParseArguments )
  cmake_parse_arguments( cache_variable_marked_as_deprecated "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )
  if( cache_variable_marked_as_deprecated_UNPARSED_ARGUMENTS )
    message( FATAL_ERROR "Unknown keywords given to checkIfCacheVariableMarkedAsDeprecated(): \"${cache_variable_marked_as_deprecated_UNPARSED_ARGUMENTS}\"" )
  endif()
  
  foreach( required_arg ${one_value_args} )
    if( NOT cache_variable_marked_as_deprecated_${required_arg} )
      message( FATAL_ERROR "The required argument ${required_arg} is missing when calling setupResourceFile." )
    endif()
  endforeach()

  if( DEFINED ${cache_variable_marked_as_deprecated_CACHE_VARIABLE} )
    get_property( var_doc CACHE ${cache_variable_marked_as_deprecated_CACHE_VARIABLE} PROPERTY HELPSTRING )
    set( return_value OFF )
    if( var_doc )
      string( FIND ${var_doc} "VARIABLE IS DEPRECATED." found_pos )
      if( found_pos EQUAL 0 )
        set( return_value ON )
      endif()
    endif()
    set( ${cache_variable_marked_as_deprecated_OUTPUT_VARIABLE} ${return_value} PARENT_SCOPE )
  endif()
endfunction()

# This function is only meant for cache variables and can be used to warn about
# a cache variable that should no longer be used.
function( handleRenamingVariablesBackwardCompatibility )
  set( options )
  set( one_value_args )
  set( multi_value_args NEW_VARIABLE_NAMES OLD_VARIABLE_NAMES DOC_STRINGS )
  include( CMakeParseArguments )
  cmake_parse_arguments( handle_old_upper_case_input "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )
  if( handle_old_upper_case_input_UNPARSED_ARGUMENTS )
    message( FATAL_ERROR "Unknown keywords given to handleRenamingVariablesBackwardCompatibility(): \"${handle_old_upper_case_input_UNPARSED_ARGUMENTS}\"" )
  endif()
  
  set( i 0 )
  list( LENGTH handle_old_upper_case_input_DOC_STRINGS nr_doc_strings )
  list( LENGTH handle_old_upper_case_input_OLD_VARIABLE_NAMES nr_old_variable_names )
  foreach( _var ${handle_old_upper_case_input_NEW_VARIABLE_NAMES} )
    set( _old_var_name "" )
    if( ${i} LESS ${nr_old_variable_names} )
      list( GET handle_old_upper_case_input_OLD_VARIABLE_NAMES ${i} _old_var_name )
    else()
      # Assume there was an upper case variable before.
      string( REGEX MATCH "[^_]+_" _var_prefix ${_var} )
      string( TOUPPER ${_var_prefix} _var_prefix_upper )
      string( REPLACE ${_var_prefix} ${_var_prefix_upper} _old_var_name ${_var} )
    endif()
    
    if( _old_var_name AND DEFINED ${_old_var_name} )
      if( NOT DEFINED ${_var} )
        set( _doc_string " " )
        if( ${i} LESS ${nr_doc_strings} )
          list( GET handle_old_upper_case_input_DOC_STRINGS ${i} _doc_string )
        endif()
        get_property( var_type CACHE ${_old_var_name} PROPERTY TYPE )
        set( ${_var} "${${_old_var_name}}" CACHE ${var_type} ${_doc_string} FORCE )
        message( AUTHOR_WARNING "Variable ${_old_var_name} is deprecated. Its value has been copied to variable ${_var}. Please remove ${_old_var_name} from your CMake code and/or cache." )
      else()
        checkIfCacheVariableMarkedAsDeprecated( CACHE_VARIABLE ${_old_var_name} OUTPUT_VARIABLE created_internally )
        if( NOT created_internally )
          message( AUTHOR_WARNING "Variable ${_old_var_name} is deprecated. Please remove it from your CMake code and/or cache or replace it with ${_var} in your code." )
        endif()
      endif()
    endif()
    math( EXPR i "${i} + 1" )
  endforeach()
endfunction()

# Will generate a library name using the naming scheme of H3D.
function( getH3DLibraryNameToSearchFor output_var base_name )
  if( MSVC )
    set( h3d_msvc_version 6 )
    set( temp_msvc_version 1299 )
    while( ${MSVC_VERSION} GREATER ${temp_msvc_version} )
      math( EXPR h3d_msvc_version "${h3d_msvc_version} + 1" )
      # Increments one more time if MSVC version is 13 as it doesn't exist
      if( ${h3d_msvc_version} EQUAL 13 )
        math( EXPR h3d_msvc_version "${h3d_msvc_version} + 1" )
      endif()
      math( EXPR temp_msvc_version "${temp_msvc_version} + 100" )
    endwhile()
    set( ${output_var} "${base_name}_vc${h3d_msvc_version}" PARENT_SCOPE )
  elseif( UNIX )
    set( name_to_use ${base_name} )
    if( ARGC GREATER 1 )
      set( name_to_use ${ARGV1} PARENT_SCOPE )
    endif()
    set( ${output_var} ${name_to_use} PARENT_SCOPE )
  else()
    set( name_to_use ${base_name} )
    if( ARGC GREATER 2 )
      set( name_to_use ${ARGV2} PARENT_SCOPE )
    endif()
    set( ${output_var} ${name_to_use} PARENT_SCOPE )
  endif()
endfunction()

# Can be used to handle deprecated function arguments
# Must be called after cmake_parse_arguments but before checking handle_deprecated_arguments_UNPARSED_ARGUMENTS.
# FUNCTION_NAME - the name of the function which should be checked.
# ARGUMENT_PREFIX - The argument prefix used with cmake_parse_arguments of the function named by FUNCTION_NAME
# OLD_ARGUMENTS - A list of old argument names.
# OLD_ARGUMENTS - A list of replacement argument names.
function( handleDeprecatedFunctionArguments )
  set( options )
  set( one_value_args FUNCTION_NAME ARGUMENT_PREFIX )
  set( multi_value_args OLD_ARGUMENTS NEW_ARGUMENTS )
  include( CMakeParseArguments )
  cmake_parse_arguments( handle_deprecated_arguments "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )
  if( handle_deprecated_arguments_UNPARSED_ARGUMENTS )
    message( FATAL_ERROR "Unknown keywords given to handleDeprecatedArguments(): \"${handle_deprecated_arguments_UNPARSED_ARGUMENTS}\"" )
  endif()
  
  foreach( required_arg ${one_value_args} ${multi_value_args} )
    if( NOT handle_deprecated_arguments_${required_arg} )
      message( FATAL_ERROR "The required argument ${required_arg} is missing when calling setupResourceFile." )
    endif()
  endforeach()
  
  set( i 0 )
  list( LENGTH handle_deprecated_arguments_OLD_ARGUMENTS nr_old_arguments )
  list( LENGTH handle_deprecated_arguments_NEW_ARGUMENTS nr_new_arguments )
  if( NOT ${nr_old_arguments} EQUAL ${nr_new_arguments} )
    message( FATAL_ERROR "The number of entries in OLD_ARGUMENTS and NEW_ARGUMENTS does not match." )
  endif()

  set( tmp_unparsed_list ${${handle_deprecated_arguments_ARGUMENT_PREFIX}UNPARSED_ARGUMENTS} )
  foreach( _var ${handle_deprecated_arguments_NEW_ARGUMENTS} )
    list( GET handle_deprecated_arguments_OLD_ARGUMENTS ${i} _old_arg_name )
    list( FIND tmp_unparsed_list ${_old_arg_name} old_arg_pos )

    if( ${old_arg_pos} GREATER -1 )
      message( AUTHOR_WARNING "The argument ${_old_arg_name} to function ${handle_deprecated_arguments_FUNCTION_NAME} is deprecated. Please use argument ${_var} instead." )
      set( ${handle_deprecated_arguments_ARGUMENT_PREFIX}${_var} ${${handle_deprecated_arguments_ARGUMENT_PREFIX}${_old_arg_name}} PARENT_SCOPE )
      list( REMOVE_AT tmp_unparsed_list ${old_arg_pos} )
    endif()
    math( EXPR i "${i} + 1" )
  endforeach()
  set( ${handle_deprecated_arguments_ARGUMENT_PREFIX}UNPARSED_ARGUMENTS ${tmp_unparsed_list} PARENT_SCOPE )
endfunction()

# Used to set common policies for H3D CMake builds
function( setCommonH3DCMakePolicies )
  if( APPLE AND POLICY CMP0042 )
  cmake_policy( SET CMP0042 NEW )
  endif()

  if( POLICY CMP0072 )
    cmake_policy( SET CMP0072 NEW )
  endif()
  
  if( POLICY CMP0054 )
    cmake_policy( SET CMP0054 NEW )
  endif()
endfunction()