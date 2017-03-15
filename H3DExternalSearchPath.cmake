# Contains a function which can be used to get default search paths
# for include and lib directory on windows.

# This variable can be set after this file is included but before getExternalSearchPathsH3D function is called.
# If set to true then then ExternalPath/include/ACKNOWLEDGMENTS file is checked if it corresponds to the current
# version of visual studio. If it is not then the External directory is not added to search path. There is one
# exception though, for visual studio versions below vs2010 the vs2010 year string is looked for.
set( check_if_h3d_external_matches_vs_version OFF )

if( DEFINED H3D_EXTERNAL_BASE_DIR_NAME )
  message( AUTHOR_WARNING "The variable 'H3D_EXTERNAL_BASE_DIR_NAME' is deprecated and no longer used. Please use the variable 'h3d_external_base_dir_name' instead which is most likely set in ${CMAKE_PARENT_LIST_FILE}" )
endif()
if( NOT DEFINED h3d_external_base_dir_name )
  # This variable can be set after this file is included but before getExternalSearchPathsH3D function is called.
  # If set to something and the compiles is not a supported MSVC version then it is expected that the setter of
  # h3d_external_base_dir_name has setup an External directory in the same manner as for MSVC compilers but for
  # their compiler version instead. The variable is expected to be global for the entire build.
  if( DEFINED H3D_EXTERNAL_BASE_DIR_NAME )
    set( h3d_external_base_dir_name ${H3D_EXTERNAL_BASE_DIR_NAME} )
  else()
    set( h3d_external_base_dir_name )
  endif()
endif()

if( MSVC )
  set( h3d_external_base_dir_name )
  if( MSVC70 )
    set( h3d_external_base_dir_name vs2002 ) #This is probably not entirely correct but we won't support this anyways I would assume
  elseif( MSVC71 )
    set( h3d_external_base_dir_name vs2003 ) #This is probably not entirely correct but we won't support this anyways I would assume
  elseif( MSVC80 )
    set( h3d_external_base_dir_name vs2005 )
  elseif( MSVC90 )
    set( h3d_external_base_dir_name vs2008 )
  elseif( MSVC10 )
    set( h3d_external_base_dir_name vs2010 )
  elseif( MSVC11 )
    set( h3d_external_base_dir_name vs2012 )
  elseif( MSVC12 )
    set( h3d_external_base_dir_name vs2013 )
  elseif( MSVC14 )
    set( h3d_external_base_dir_name vs2015 )
  endif()

  if( NOT h3d_external_base_dir_name ) # fallback for future compilers, this assumes cmake version 3.0 and up.
    string( REGEX MATCH "[^ ]+$" vsYearString ${CMAKE_GENERATOR} )
    if( vsYearString )
      if( vsYearString STREQUAL "Win64" )
        string( REGEX REPLACE "([^ ]+) Win64$" "\\1" vsYearString ${CMAKE_GENERATOR} )
        string( REGEX MATCH "[^ ]+$" vsYearString ${vsYearString} )
      endif()
      set( h3d_external_base_dir_name vs${vsYearString} )
    endif()
  endif()
endif()

function( checkIfValidH3DWinExternal arg1 arg2 )
  set( ${arg1} ON PARENT_SCOPE )
  if( check_if_h3d_external_matches_vs_version )
    set( ${arg1} OFF PARENT_SCOPE )
    if( EXISTS ${arg2}/include/ACKNOWLEDGEMENTS )
      file( STRINGS ${arg2}/include/ACKNOWLEDGEMENTS the_first_line LIMIT_COUNT 1 REGEX "[-][-][-][-] Compiled for ${h3d_external_base_dir_name} [-][-][-][-]" ) # Check if first line contains the correct vsx string.
      if( the_first_line )
        set( ${arg1} ON PARENT_SCOPE )
      endif()
    endif()
  endif()
endfunction()

# Kept for backward compatibility. It prints a warning then calls the new function named getExternalSearchPathsH3D.
function( check_if_valid_H3D_Win_External arg1 arg2 )
  message( AUTHOR_WARNING "check_if_valid_H3D_Win_External is deprecated. Use checkIfValidH3DWinExternal instead." )
  checkIfValidH3DWinExternal( ${arg1} ${arg2} )
  set( ${arg1} ${${arg1}} PARENT_SCOPE )
endfunction()

# arg1 Will contain search path for the include directories.
# arg2 Will contain search path for library directories.
# arg3 Should contain FindXX.cmake module path or empty,
# or basically additional base paths External is expected to possibly exists
# like this relative to this path ../../../External
function( getExternalSearchPathsH3D arg1 arg2 arg3 )
  if( DEFINED CHECK_IF_H3D_EXTERNAL_MATCHES_VS_VERSION )
    message( AUTHOR_WARNING "The variable 'CHECK_IF_H3D_EXTERNAL_MATCHES_VS_VERSION' is deprecated and no longer used. Please use the variable 'check_if_h3d_external_matches_vs_version' instead which is most likely set in ${CMAKE_PARENT_LIST_FILE}" )
  endif()
  if( WIN32 )
    if( CMAKE_CL_64 )
      set( lib "lib64" )
    else()
      set( lib "lib32" )
    endif()
    set( h3d_external_base_dirs $ENV{H3D_EXTERNAL_ROOT}
                                $ENV{H3D_ROOT}/../External
                                ${arg3}/../../../External
                                ${arg3}/../../../../External )
    set( h3d_external_base_include_dirs "" )
    set( h3d_external_base_lib_dirs "" )
    foreach( h3d_ebd ${h3d_external_base_dirs} )
      checkIfValidH3DWinExternal( add_dir ${h3d_ebd} )
      if( add_dir )
        list( APPEND h3d_external_base_include_dirs ${h3d_ebd}/include )
        list( APPEND h3d_external_base_lib_dirs ${h3d_ebd}/${lib} )
      endif()
      if( h3d_external_base_dir_name )
        foreach( external_dir_name ${h3d_external_base_dir_name} )
          checkIfValidH3DWinExternal( add_dir ${h3d_ebd}/${external_dir_name} )
          if( add_dir )
            list( APPEND h3d_external_base_include_dirs ${h3d_ebd}/${external_dir_name}/include )
            list( APPEND h3d_external_base_lib_dirs ${h3d_ebd}/${external_dir_name}/${lib} )
          endif()
        endforeach()
      endif()
    endforeach()
    
    set( tmp_include_dir_output "" )
    foreach( h3d_base_include_dir ${h3d_external_base_include_dirs} )
      list( APPEND tmp_include_dir_output ${h3d_base_include_dir} )
      foreach( f ${ARGN} )
        list( APPEND tmp_include_dir_output ${h3d_base_include_dir}/${f} )
      endforeach()
    endforeach()
    set( ${arg1} ${tmp_include_dir_output} PARENT_SCOPE )
    
    set( tmp_lib_dir_output "" )
    foreach( h3d_base_lib_dir ${h3d_external_base_lib_dirs} )
      list( APPEND tmp_lib_dir_output ${h3d_base_lib_dir} )
      foreach( f ${ARGN} )
        list( APPEND tmp_lib_dir_output ${h3d_base_lib_dir}/${f} )
      endforeach()
    endforeach()
    set( ${arg2} ${tmp_lib_dir_output} PARENT_SCOPE )
  endif()
endfunction()

# Kept for backward compatibility. It prints a warning then calls the new function named getExternalSearchPathsH3D.
function( get_external_search_paths_h3d arg1 arg2 arg3 )
  message( AUTHOR_WARNING "get_external_search_paths_h3d is deprecated. Use getExternalSearchPathsH3D instead." )
  getExternalSearchPathsH3D( ${arg1} ${arg2} ${arg3} ${ARGN} )
  set( ${arg1} ${${arg1}} PARENT_SCOPE )
  set( ${arg2} ${${arg2}} PARENT_SCOPE )
endfunction()

# module_name Should contain the name of the module to check for.
# REQUIRED_CMAKE_VERSION - A one value argument which will contain a version string
# which will be compared against the current CMake version. If the cmake version is
# below the REQUIRED_CMAKE_VERSION then find_package will not be called because
# the find module is expected to not exist.
function( checkCMakeInternalModule module_name )
  set( options )
  set( oneValueArgs REQUIRED_CMAKE_VERSION OUTPUT_AS_UPPER_CASE )
  set( multiValueArgs )
  include( CMakeParseArguments )
  cmake_parse_arguments( check_cmake_internal_module "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
  if( check_cmake_internal_module_UNPARSED_ARGUMENTS )
    message( FATAL_ERROR "Unknown keywords given to checkCMakeInternalModule(): \"${check_cmake_internal_module_UNPARSED_ARGUMENTS}\"" )
  endif()

  if( check_cmake_internal_module_REQUIRED_CMAKE_VERSION )
    if( "${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}.${CMAKE_PATCH_VERSION}" VERSION_LESS "${check_cmake_internal_module_REQUIRED_CMAKE_VERSION}" )
      return()
    endif()
  endif()
  # Store old value of CMAKE_MODULE_PATH and set it to search only
  # predefined paths.
  set( tmp_cmake_module_path ${CMAKE_MODULE_PATH} )
  set( CMAKE_MODULE_PATH "" )
  set( quiet_required_args )
  if( ${module_name}_FIND_QUIETLY )
    set( quiet_required_args QUIET )
  endif()
  if( ${module_name}_FIND_REQUIRED )
    set( quiet_required_args ${quiet_required_args} REQUIRED )
  endif()
  find_package( ${module_name} ${quiet_required_args} )
  # Set back to use previous value of CMAKE_MODULE_PATH.
  set( CMAKE_MODULE_PATH ${tmp_cmake_module_path} )

  set( output_prefix ${module_name} )
  if( DEFINED check_cmake_internal_module_OUTPUT_AS_UPPER_CASE )
    string( TOUPPER ${output_prefix} output_prefix )
  endif()
  set( ${output_prefix}_FOUND ${${output_prefix}_FOUND} PARENT_SCOPE )
  set( ${module_name}_FOUND ${${output_prefix}_FOUND} PARENT_SCOPE )
  set( ${output_prefix}_LIBRARIES ${${output_prefix}_LIBRARIES} PARENT_SCOPE )
  set( ${output_prefix}_INCLUDE_DIRS ${${output_prefix}_INCLUDE_DIRS} PARENT_SCOPE )
  if( ${output_prefix}_FOUND AND NOT ${output_prefix}_INCLUDE_DIRS ) # Some of CMakes internal modules are giving incorrect output ( _INCLUDE_DIRS not set )
    set( ${output_prefix}_INCLUDE_DIRS ${${output_prefix}_INCLUDE_DIR} PARENT_SCOPE )
  endif()
  set( ${output_prefix}_USE_FILE ${${output_prefix}_USE_FILE} PARENT_SCOPE )
endfunction()

function( handleRenamingVariablesBackwardCompatibility )
  set( options )
  set( oneValueArgs )
  set( multiValueArgs NEW_VARIABLE_NAMES OLD_VARIABLE_NAMES DOC_STRINGS )
  include( CMakeParseArguments )
  cmake_parse_arguments( handle_old_upper_case_input "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
  if( handle_old_upper_case_input_UNPARSED_ARGUMENTS )
    message( FATAL_ERROR "Unknown keywords given to handleOldUppercaseCacheVariables(): \"${handle_old_upper_case_input_UNPARSED_ARGUMENTS}\"" )
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
        set( ${_var} "${${_old_var_name}}" CACHE PATH ${_doc_string} FORCE )
        message( AUTHOR_WARNING "Variable ${_old_var_name} is deprecated. Its value has been copied to variable ${_var}. Please remove ${_old_var_name} from your CMake code and/or cache." )
      else()
        message( AUTHOR_WARNING "Variable ${_old_var_name} is deprecated. Please remove it from your CMake code and/or cache or replace it with ${_var} in your code." )
      endif()
    endif()
    math( EXPR i "${i} + 1" )
  endforeach()
endfunction()

# This function can be used to check the given variables and output a proper
# message in the case of everything being ok as well as setting a
# _module_name_FOUND variable to true or false
# _module_name Should contain the name of the module to check for.
# REQUIRED_VARS - A list of variables that must be set in order for this
# function to set _module_name_FOUND to true.
function( checkIfModuleFound _module_name )
  set( options )
  set( oneValueArgs )
  set( multiValueArgs REQUIRED_VARS )
  include( CMakeParseArguments )
  cmake_parse_arguments( _check_if_module_found "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
  if( _check_if_module_found_UNPARSED_ARGUMENTS )
    message( FATAL_ERROR "Unknown keywords given to checkCMakeInternalModule(): \"${_check_if_module_found_UNPARSED_ARGUMENTS}\"" )
  endif()

  string( TOUPPER ${_module_name} _module_name_upper )
  
  set( ${_module_name}_FOUND FALSE PARENT_SCOPE )
  set( ${_module_name_upper}_FOUND FALSE PARENT_SCOPE )
  set( details )
  foreach( _module_name ${_check_if_module_found_REQUIRED_VARS} )
    set( details "${details}[${${_module_name}}]" )
    if( NOT ${_module_name} )
      return()
    endif()
  endforeach()
  set( ${_module_name}_FOUND TRUE PARENT_SCOPE )
  set( ${_module_name_upper}_FOUND TRUE PARENT_SCOPE )
  list( GET _check_if_module_found_REQUIRED_VARS 0 first_required_var )
  include( FindPackageMessage )
  find_package_message( ${_module_name} "Found ${_module_name}: ${${first_required_var}}" "${details}" )
endfunction()