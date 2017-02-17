# Contains a function which can be used to get default search paths
# for include and lib directory on windows.

# This variable can be set after this file is included but before getExternalSearchPathsH3D function is called.
# If set to true then then ExternalPath/include/ACKNOWLEDGMENTS file is checked if it corresponds to the current
# version of visual studio. If it is not then the External directory is not added to search path. There is one
# exception though, for visual studio versions below vs2010 the vs2010 year string is looked for.
set( check_if_h3d_external_matches_vs_version OFF )

if( MSVC )
  set( H3D_EXTERNAL_BASE_DIR_NAME "" )
  if( MSVC70 )
    set( H3D_EXTERNAL_BASE_DIR_NAME vs2002 ) #This is probably not entirely correct but we won't support this anyways I would assume
  elseif( MSVC71 )
    set( H3D_EXTERNAL_BASE_DIR_NAME vs2003 ) #This is probably not entirely correct but we won't support this anyways I would assume
  elseif( MSVC80 )
    set( H3D_EXTERNAL_BASE_DIR_NAME vs2005 )
  elseif( MSVC90 )
    set( H3D_EXTERNAL_BASE_DIR_NAME vs2008 )
  elseif( MSVC10 )
    set( H3D_EXTERNAL_BASE_DIR_NAME vs2010 )
  elseif( MSVC11 )
    set( H3D_EXTERNAL_BASE_DIR_NAME vs2012 )
  elseif( MSVC12 )
    set( H3D_EXTERNAL_BASE_DIR_NAME vs2013 )
  elseif( MSVC14 )
    set( H3D_EXTERNAL_BASE_DIR_NAME vs2015 )
  endif()

  if( NOT H3D_EXTERNAL_BASE_DIR_NAME ) # fallback for future compilers, this assumes cmake version 3.0 and up.
    string( REGEX MATCH "[^ ]+$" vsYearString ${CMAKE_GENERATOR} )
    if( vsYearString )
      if( vsYearString STREQUAL "Win64" )
        string( REGEX REPLACE "([^ ]+) Win64$" "\\1" vsYearString ${CMAKE_GENERATOR} )
        string( REGEX MATCH "[^ ]+$" vsYearString ${vsYearString} )
      endif()
      set( H3D_EXTERNAL_BASE_DIR_NAME vs${vsYearString} )
    endif()
  endif()

  if( CMAKE_CL_64 )
    set( LIB "lib64" )
  else()
    set( LIB "lib32" )
  endif()
endif()

function( checkIfValidH3DWinExternal arg1 arg2 )
  set( ${arg1} ON PARENT_SCOPE )
  if( check_if_h3d_external_matches_vs_version )
    set( ${arg1} OFF PARENT_SCOPE )
    if( EXISTS ${arg2}/include/ACKNOWLEDGEMENTS )
      file( STRINGS ${arg2}/include/ACKNOWLEDGEMENTS the_first_line LIMIT_COUNT 1 REGEX "[-][-][-][-] Compiled for ${H3D_EXTERNAL_BASE_DIR_NAME} [-][-][-][-]" ) # Check if first line contains the correct vsx string.
      if( the_first_line )
        set( ${arg1} ON PARENT_SCOPE )
      endif()
    endif()
  endif()
endfunction()

# Kept for backward compatibility. It prints a warning then calls the new function named getExternalSearchPathsH3D.
function( check_if_valid_H3D_Win_External arg1 arg2 )
  message( AUTHOR_WARNING "check_if_valid_H3D_Win_External is deprecated. Use checkIfValidH3DWinExternal instead. Called from this file ${CMAKE_PARENT_LIST_FILE}.")
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
    message( AUTHOR_WARNING "The upper case variable CHECK_IF_H3D_EXTERNAL_MATCHES_VS_VERSION probably defined in ${CMAKE_PARENT_LIST_FILE} is deprecated and no longer used. Please correct your code.")
  endif()
  if( WIN32 )
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
        list( APPEND h3d_external_base_lib_dirs ${h3d_ebd}/${LIB} )
      endif()
      if( H3D_EXTERNAL_BASE_DIR_NAME )
        foreach( external_dir_name ${H3D_EXTERNAL_BASE_DIR_NAME} )
          checkIfValidH3DWinExternal( add_dir ${h3d_ebd}/${external_dir_name} )
          if( add_dir )
            list( APPEND h3d_external_base_include_dirs ${h3d_ebd}/${external_dir_name}/include )
            list( APPEND h3d_external_base_lib_dirs ${h3d_ebd}/${external_dir_name}/${LIB} )
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
  message( AUTHOR_WARNING "get_external_search_paths_h3d is deprecated. Use getExternalSearchPathsH3D instead. Called from this file ${CMAKE_PARENT_LIST_FILE}.")
  getExternalSearchPathsH3D( ${arg1} ${arg2} ${arg3} ${ARGN} )
  set( ${arg1} ${${arg1}} PARENT_SCOPE )
  set( ${arg2} ${${arg2}} PARENT_SCOPE )
endfunction()

# arg1 Should contain the name of the module to check for.
# REQUIRED_CMAKE_VERSION - A one value argument which will contain a version string
# which will be compared against the current CMake version. If the cmake version is
# below the REQUIRED_CMAKE_VERSION then find_package will not be called because
# the find module is expected to not exist.
function( checkCMakeInternalModule arg1 )
  set( options )
  set( oneValueArgs REQUIRED_CMAKE_VERSION )
  set( multiValueArgs )
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
  set( find_quietly_old ${${arg1}_FIND_QUIETLY} )
  set( find_required_old ${${arg1}_FIND_REQUIRED} )
  if( WIN32 )
    set( ${arg1}_FIND_QUIETLY 1 )
    set( ${arg1}_FIND_REQUIRED 0 )
    find_package( ${arg1} )
  else()
    if( ${arg1}_FIND_REQUIRED )
      find_package( ${arg1} REQUIRED )
    else()
      find_package( ${arg1} )
    endif()
  endif()
  set( ${arg1}_FIND_QUIETLY ${find_quietly_old} )
  set( ${arg1}_FIND_REQUIRED ${find_required_old} )
  # Set back to use previous value of CMAKE_MODULE_PATH.
  set( CMAKE_MODULE_PATH ${tmp_cmake_module_path} )
endfunction()

function( handleRenamingVariablesBackwardCompatibility )
  set( options )
  set( oneValueArgs )
  set( multiValueArgs NEW_VARIABLE_NAMES OLD_VARIABLE_NAMES DOC_STRINGS )
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
        message( AUTHOR_WARNING "Variable ${_old_var_name} is deprecated. Its values has been copied to variable ${_var}. Please remove ${_old_var_name} from your CMake code and/or cache." )
      else()
        message( AUTHOR_WARNING "Variable ${_old_var_name} is deprecated. Please remove it from your CMake code and/or cache." )
      endif()
    endif()
    math( EXPR i "${i} + 1")
  endforeach()
endfunction()