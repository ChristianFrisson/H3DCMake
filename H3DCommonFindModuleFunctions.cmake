# Contains functionality that can be used by find modules to make it easier to write them.

include( H3DUtilityFunctions )

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
    if( ${MSVC_VERSION} GREATER 1900 )
      set( h3d_external_base_dir_name vs2017 )
    else()
      set( h3d_external_base_dir_name vs2015 )
    endif()
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

# Check the ACKNOWLEDGMENTS file of the given External directory for a specific string to know if the directory contains
# libraries that are built for the current compiler.
# arg1 Will contain the result of the validation check.
# arg2 Should contain the external base folder
# if specified, arg3 Should be appended with a warning string if the located library directory is not sutiable for the current compiler being used
function( checkIfValidH3DWinExternal arg1 arg2 arg3 )
  if( ${arg3} )
    # get existing msg from arg3 if any and put into validation_failure_msg 
    set( validation_failure_msg ${${arg3}} )
  endif()
  set( ${arg1} ON PARENT_SCOPE )
  if( check_if_h3d_external_matches_vs_version )
    set( ${arg1} OFF PARENT_SCOPE )
    if( EXISTS ${arg2}/include/ACKNOWLEDGEMENTS )
      file( STRINGS ${arg2}/include/ACKNOWLEDGEMENTS the_first_line LIMIT_COUNT 1 REGEX "[-][-][-][-] Compiled for ${h3d_external_base_dir_name} [-][-][-][-]" ) # Check if first line contains the correct vsx string.
      if( the_first_line )
        set( ${arg1} ON PARENT_SCOPE )
      else( the_first_line )
        if( ARGC GREATER 2 )
          # append failure message
          set( validation_failure_msg ${validation_failure_msg} "Library located in ${arg2} is not suitable for ${h3d_external_base_dir_name}" )
        endif()
      endif()
    endif()
  endif()
  if( ARGC GREATER 2 AND validation_failure_msg )
    set( ${arg3} "${validation_failure_msg}" PARENT_SCOPE )
  endif()
endfunction()

# Kept for backward compatibility. It prints a warning then calls the new function named getExternalSearchPathsH3D.
function( check_if_valid_H3D_Win_External arg1 arg2 )
  message( AUTHOR_WARNING "check_if_valid_H3D_Win_External is deprecated. Use checkIfValidH3DWinExternal instead." )
  checkIfValidH3DWinExternal( ${arg1} ${arg2} )
  set( ${arg1} ${${arg1}} PARENT_SCOPE )
endfunction()

# Set up search paths to libraries and include files for external features.
# arg1 Will contain search path for the include directories.
# arg2 Will contain search path for library directories.
# arg3 Should contain FindXX.cmake module path or empty,
# or basically additional base paths External is expected to possibly exists
# like this relative to this path ../../../External
# warning will be print out if either include or library directories are empty due to checkIfValidH3DWinExternal failure
function( getExternalSearchPathsH3D arg1 arg2 arg3 )
  if( DEFINED CHECK_IF_H3D_EXTERNAL_MATCHES_VS_VERSION )
    message( AUTHOR_WARNING "The variable 'CHECK_IF_H3D_EXTERNAL_MATCHES_VS_VERSION' is deprecated and no longer used. Please use the variable 'check_if_h3d_external_matches_vs_version' instead which is most likely set in ${CMAKE_PARENT_LIST_FILE}" )
  endif()
  if( WIN32 )
    if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
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
      checkIfValidH3DWinExternal( add_dir ${h3d_ebd} searched_path_not_valid_msg )
      if( add_dir )
        list( APPEND h3d_external_base_include_dirs ${h3d_ebd}/include )
        list( APPEND h3d_external_base_lib_dirs ${h3d_ebd}/${lib} )
      endif()
      if( h3d_external_base_dir_name )
        foreach( external_dir_name ${h3d_external_base_dir_name} )
          checkIfValidH3DWinExternal( add_dir ${h3d_ebd}/${external_dir_name} searched_path_not_valid_msg )
          if( add_dir )
            list( APPEND h3d_external_base_include_dirs ${h3d_ebd}/${external_dir_name}/include )
            list( APPEND h3d_external_base_lib_dirs ${h3d_ebd}/${external_dir_name}/${lib} )
          endif()
        endforeach()
      endif()
    endforeach()
    
    if ( h3d_external_base_include_dirs STREQUAL "" OR h3d_external_base_lib_dirs STREQUAL "" AND searched_path_not_valid_msg )
      foreach( line ${searched_path_not_valid_msg} )
        message( WARNING "${line}" )
      endforeach()
    endif()
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

# Can be used to call an already existing find modules in CMake.
# module_name Should contain the name of the module to check for.
# REQUIRED_CMAKE_VERSION - A one value argument which will contain a version string
# which will be compared against the current CMake version. If the cmake version is
# below the REQUIRED_CMAKE_VERSION then find_package will not be called because
# the find module is expected to not exist.
function( checkCMakeInternalModule module_name )
  set( options OUTPUT_AS_UPPER_CASE )
  set( one_value_args REQUIRED_CMAKE_VERSION )
  set( multi_value_args )
  include( CMakeParseArguments )
  cmake_parse_arguments( check_cmake_internal_module "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )
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
  if( check_cmake_internal_module_OUTPUT_AS_UPPER_CASE )
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
  if( ${output_prefix}_LIBRARY_DIRS )
    set( ${output_prefix}_LIBRARY_DIRS ${${output_prefix}_LIBRARY_DIRS} PARENT_SCOPE )
  endif()
  if( ${output_prefix}_DEFINITIONS )
    set( ${output_prefix}_DEFINITIONS ${${output_prefix}_DEFINITIONS} PARENT_SCOPE )
  endif()
  if( ${output_prefix}_DEFINITIONS_DEBUG )
    set( ${output_prefix}_DEFINITIONS_DEBUG ${${output_prefix}_DEFINITIONS_DEBUG} PARENT_SCOPE )
  endif()
  if( ${output_prefix}_CXX_FLAGS )
    set( ${output_prefix}_CXX_FLAGS ${${output_prefix}_CXX_FLAGS} PARENT_SCOPE )
  endif()
endfunction()

# This function can be used by find modules to check the given variables and output a proper
# message in the case of everything being ok as well as setting a
# _module_name_FOUND variable to true or false
# _module_name Should contain the name of the module to check for.
# REQUIRED_VARS - A list of variables that must be set in order for this
# function to set _module_name_FOUND to true.
function( checkIfModuleFound _module_name )
  set( options )
  set( one_value_args )
  set( multi_value_args REQUIRED_VARS )
  include( CMakeParseArguments )
  cmake_parse_arguments( _check_if_module_found "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )
  if( _check_if_module_found_UNPARSED_ARGUMENTS )
    message( FATAL_ERROR "Unknown keywords given to checkIfModuleFound(): \"${_check_if_module_found_UNPARSED_ARGUMENTS}\"" )
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

# Get search paths for H3D libraries.
# include_paths_output Will contain search path for the include directories.
# lib_path_output Will contain search path for library directories.
# module_path Should contain FindXX.cmake module path or empty
# module_name Should contain the name of the module to search for.
function( getSearchPathsH3DLibs include_paths_output lib_path_output module_path module_name )
  set( ${include_paths_output} $ENV{H3D_ROOT}/include
                               $ENV{H3D_ROOT}/../${module_name}/include
                               ${module_path}/../../include
                               ${module_path}/../../../include
                               ${module_path}/../../../${module_name}/include
                               ${module_path}/../../../../${module_name}/include
                               ../../include
                               ../../../include
                               ../../../${module_name}/include
                               ../../../../${module_name}/include
                               PARENT_SCOPE )
  set( default_lib_install "lib" )
  if( WIN32 )
    set( default_lib_install "lib32" )
    if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
      set( default_lib_install "lib64" )
    endif()
  endif()
  set( ${lib_path_output} $ENV{H3D_ROOT}/../${default_lib_install}
                          $ENV{H3D_ROOT}/../${module_name}/${default_lib_install}
                          $ENV{H3D_ROOT}/../../${default_lib_install}
                          $ENV{H3D_ROOT}/../../${module_name}/${default_lib_install}
                          $ENV{H3D_ROOT}/../../../${default_lib_install}
                          $ENV{H3D_ROOT}/../../../${module_name}/${default_lib_install}
                          ${module_path}/../../${default_lib_install}
                          ${module_path}/../../${module_name}/${default_lib_install}
                          ${module_path}/../../../${default_lib_install}
                          ${module_path}/../../../${module_name}/${default_lib_install}
                          ${module_path}/../../../../${default_lib_install}
                          ${module_path}/../../../../${module_name}/${default_lib_install}
                          ../../${default_lib_install}
                          ../../${module_name}/${default_lib_install}
                          ../../../${default_lib_install}
                          ../../../${module_name}/${default_lib_install}
                          ../../../../${default_lib_install}
                          ../../../../${module_name}/${default_lib_install}
                          ../../../support/H3D/${default_lib_install}
                          ${module_file_path}/../../../../support/H3D/${default_lib_install}
                          PARENT_SCOPE )
endfunction()

# Tries to handle all components for the given H3D module_name.
# MODULE_HEADER - Should point to the header of the H3D module, if not set then MODULE_HEADER_SUFFIX and MODULE_HEADER_DIRS must be set.
# MODULE_HEADER_SUFFIX - Will be appended to each path in MODULE_HEADER_DIRS to try to find a proper header file.
#                        Only used if MODULE_HEADER is not set
# MODULE_HEADER_DIRS - Used with MODULE_HEADER_SUFFIX. Only used if MODULE_HEADER is not set
# REQUIRED - Required supported components.
# OPTIONAL - OPTIONAL supported components, will only be checked if they are listed in DESIRED.
# OPTIONAL_DEFINES - List the defines to search for in the MODULE_HEADER to know whether an optional
#                    component is enabled or not.
# DESIRED - Contains a list of the desired components. The desired components listed must exist in OPTIONAL
#           argument with the exception of the special reserved name "SameComponentsAsInstalledLibrary". If that names is
#           used then it means that the given header will be searched and all features enabled will be searched for.
# OUTPUT - Should contain up to three variable names. The first will contain all module_FOUND variable names.
#          The second will contain all the libraries found, and the third will contain all the include directories
#          that were found.
# H3D_MODULES - List any modules that are H3D modules here. If a module is in H3D_MODULES and the
#               SameComponentsAsInstalledLibrary special name is given then it means that all H3D modules
#               should also get the SameComponentsAsInstalledLibrary
#               special name.
function( handleComponentsForLib module_name )
  if( POLICY CMP0072 )
    cmake_policy( SET CMP0072 NEW )
  endif()
  set( options )
  set( one_value_args MODULE_HEADER MODULE_HEADER_SUFFIX )
  set( multi_value_args REQUIRED OPTIONAL OPTIONAL_DEFINES DESIRED OUTPUT H3D_MODULES MODULE_HEADER_DIRS )
  include( CMakeParseArguments )
  cmake_parse_arguments( handle_components_for_lib "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )
  if( handle_components_for_lib_UNPARSED_ARGUMENTS )
    message( FATAL_ERROR "Unknown keywords given to handleComponentsForLib(): \"${handle_components_for_lib_UNPARSED_ARGUMENTS}\"" )
  endif()

  set( same_component_as_installed_library )
  foreach( optional_component ${handle_components_for_lib_DESIRED} )
    string( TOUPPER ${optional_component} optional_component_upper )
    if( optional_component_upper STREQUAL "SAMECOMPONENTSASINSTALLEDLIBRARY" )
      set( same_component_as_installed_library SameComponentsAsInstalledLibrary )
      break()
    endif()
  endforeach()

  set( output_found )
  set( output_libraries )
  set( output_include_dirs )
  # Handle required components
  list( REMOVE_DUPLICATES handle_components_for_lib_REQUIRED )
  foreach( required_component ${handle_components_for_lib_REQUIRED} )
    set( extra_arg )
    if( same_component_as_installed_library AND handle_components_for_lib_H3D_MODULES )
      list( FIND handle_components_for_lib_H3D_MODULES ${required_component} is_h3d_module )
      if( NOT ( ${is_h3d_module} EQUAL -1 ) )
        set( extra_arg COMPONENTS SameComponentsAsInstalledLibrary )
      endif()
    endif()
    find_package( ${required_component} ${extra_arg} )
    string( TOUPPER ${required_component} required_component_upper )
    
    if( DEFINED ${required_component}_FOUND )
      list( APPEND output_found ${required_component}_FOUND )
    else()
      if( DEFINED ${required_component_upper}_FOUND )
        list( APPEND output_found ${required_component}_FOUND )
      else()
        message( FATAL_ERROR "The module ${required_component} does not have a FOUND variable. Neither ${required_component}_FOUND or ${required_component_upper}_FOUND is defined." )
      endif()
    endif()

    if( DEFINED ${required_component}_LIBRARIES )
      list( APPEND output_libraries ${${required_component}_LIBRARIES} )
    elseif( DEFINED ${required_component_upper}_LIBRARIES )
      list( APPEND output_libraries ${${required_component_upper}_LIBRARIES} )
    endif()

    if( DEFINED ${required_component}_INCLUDE_DIRS )
      list( APPEND output_include_dirs ${${required_component}_INCLUDE_DIRS} )
    elseif( DEFINED ${required_component}_INCLUDE_DIR )
      list( APPEND output_include_dirs ${${required_component}_INCLUDE_DIR} )
    elseif( DEFINED ${required_component_upper}_INCLUDE_DIRS )
      list( APPEND output_include_dirs ${${required_component_upper}_INCLUDE_DIRS} )
    elseif( DEFINED ${required_component_upper}_INCLUDE_DIR )
      list( APPEND output_include_dirs ${${required_component_upper}_INCLUDE_DIR} )
    endif()
  endforeach()

  # Handle desired components.
  if( handle_components_for_lib_OPTIONAL )
    set( components_to_search_for ${handle_components_for_lib_DESIRED} )
    if( same_component_as_installed_library )
      set( components_to_search_for ${handle_components_for_lib_OPTIONAL} )
    endif()
    if( components_to_search_for )
      set( module_header_to_use ${handle_components_for_lib_MODULE_HEADER} )
      if( ( NOT module_header_to_use ) OR NOT EXISTS ${module_header_to_use} )
        foreach( module_dir ${handle_components_for_lib_MODULE_HEADER_DIRS} )
          if( EXISTS ${module_dir}${handle_components_for_lib_MODULE_HEADER_SUFFIX} )
            set( module_header_to_use ${module_dir}${handle_components_for_lib_MODULE_HEADER_SUFFIX} )
            break()
          endif()
        endforeach()
        if( ( NOT module_header_to_use ) OR NOT EXISTS ${module_header_to_use} )
          message( FATAL_ERROR "Missing or invalid value for finding a header. Use either argument MODULE_HEADER or both arguments MODULE_HEADER_SUFFIX and MODULE_HEADER_DIRS of handleComponentsForLib." )
        endif()
      endif()
      if( NOT handle_components_for_lib_OPTIONAL_DEFINES )
        message( FATAL_ERROR "Missing or invalid value for argument OPTIONAL_DEFINES of handleComponentsForLib. It must exist and be of the same length as the argument OPTIONAL." )
      endif()
      list( LENGTH handle_components_for_lib_OPTIONAL nr_optional_libs )
      list( LENGTH handle_components_for_lib_OPTIONAL_DEFINES nr_optional_defines )
      if( NOT ( ${nr_optional_libs} EQUAL ${nr_optional_defines} ) )
        message( FATAL_ERROR "Invalid value for argument OPTIONAL_DEFINES of handleComponentsForLib. It must be of the same length as the argument OPTIONAL (${nr_optional_libs})." )
      endif()
      list( REMOVE_DUPLICATES components_to_search_for )
      foreach( optional_component ${components_to_search_for} )
        list( FIND handle_components_for_lib_OPTIONAL ${optional_component} optional_lib_index )
        if( ${optional_lib_index} EQUAL -1 )
          message( AUTHOR_WARNING "Trying to find a component named ${optional_component} not used by the module ${module_name}. The component will be ignored." )
        else()
          list( GET handle_components_for_lib_OPTIONAL_DEFINES ${optional_lib_index} optional_define )
          set( regex_to_find "#define[ ]+${optional_define}" )
          file( STRINGS ${module_header_to_use} list_of_defines REGEX ${regex_to_find} )
          list( LENGTH list_of_defines list_of_defines_length )
          if( list_of_defines_length )
            set( extra_arg )
            if( same_component_as_installed_library AND handle_components_for_lib_H3D_MODULES )
              list( FIND handle_components_for_lib_H3D_MODULES ${optional_component} is_h3d_module )
              if( NOT ( ${is_h3d_module} EQUAL -1 ) )
                set( extra_arg COMPONENTS SameComponentsAsInstalledLibrary )
              endif()
            endif()
            find_package( ${optional_component} ${extra_arg} )
            string( TOUPPER ${optional_component} optional_component_upper )

            set( tmp_found )
            if( DEFINED ${optional_component}_FOUND )
              list( APPEND output_found ${optional_component}_FOUND )
              set( tmp_found ${${optional_component}_FOUND} )
            else()
              if( DEFINED ${optional_component_upper}_FOUND )
                list( APPEND output_found ${optional_component_upper}_FOUND )
                set( tmp_found ${${optional_component_upper}_FOUND} )
              else()
                message( FATAL_ERROR "The module ${optional_component} does not have a FOUND variable. Neither ${optional_component}_FOUND or ${optional_component_upper}_FOUND is defined." )
              endif()
            endif()

            if( tmp_found )
              if( DEFINED ${optional_component}_LIBRARIES )
                list( APPEND output_libraries ${${optional_component}_LIBRARIES} )
              elseif( DEFINED ${optional_component_upper}_LIBRARIES )
                list( APPEND output_libraries ${${optional_component_upper}_LIBRARIES} )
              endif()

              if( DEFINED ${optional_component}_INCLUDE_DIRS )
                list( APPEND output_include_dirs ${${optional_component}_INCLUDE_DIRS} )
              elseif( DEFINED ${optional_component}_INCLUDE_DIR )
                list( APPEND output_include_dirs ${${optional_component}_INCLUDE_DIR} )
              elseif( DEFINED ${optional_component_upper}_INCLUDE_DIRS )
                list( APPEND output_include_dirs ${${optional_component_upper}_INCLUDE_DIRS} )
              elseif( DEFINED ${optional_component_upper}_INCLUDE_DIR )
                list( APPEND output_include_dirs ${${optional_component_upper}_INCLUDE_DIR} )
              endif()
            endif()
          endif()
        endif()
      endforeach()
    endif()
  elseif( handle_components_for_lib_DESIRED AND NOT same_component_as_installed_library )
    message( AUTHOR_WARNING "The DESIRED option to handleComponentsForLib is not empty even though there are no OPTIONAL components. " )
  endif()
  
  if( handle_components_for_lib_OUTPUT )
    list( LENGTH handle_components_for_lib_OUTPUT nr_output_vars )
    if( ${nr_output_vars} GREATER 0 )
      list( GET handle_components_for_lib_OUTPUT 0 output_found_parent_var )
      set( ${output_found_parent_var} ${output_found} PARENT_SCOPE )
      foreach( found_var ${output_found} )
        set( ${found_var} ${found_var} PARENT_SCOPE )
      endforeach()
    endif()
    if( ${nr_output_vars} GREATER 1 )
      list( GET handle_components_for_lib_OUTPUT 1 output_libraries_parent_var )
      set( ${output_libraries_parent_var} ${output_libraries} PARENT_SCOPE )
    endif()
    if( ${nr_output_vars} GREATER 2 )
      list( GET handle_components_for_lib_OUTPUT 2 output_include_dirs_parent_var )
      set( ${output_include_dirs_parent_var} ${output_include_dirs} PARENT_SCOPE )
    endif()
  endif()
endfunction()
