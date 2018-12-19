cmake_minimum_required( VERSION 2.8.7 )
cmake_policy( VERSION 2.8.7 )

if( POLICY CMP0054)
  cmake_policy( SET CMP0054 NEW )
endif()

# Contains common H3D functions that are used by CMakeLists.txt to setup projects.
include( H3DUtilityFunctions )

# Set the output name of a H3D target to handle proper postfix depending on compiler version.
# the_target Will contain search path for the include directories.
# target_base_name Must be the base name for the target.
# Optional argument can be given which will be set to the postfix appended to the name.
function( setH3DMSVCOutputName the_target target_base_name )
  if( MSVC )
    # change the name depending on compiler to be able to tell them apart
    # since they are not compatible with each other. 
    # the_target can not link incrementally on vc8 for some reason. We shut of incremental linking for
    # all visual studio versions.
    getMSVCPostFix( msvc_post_fix )
    set_target_properties( ${the_target} PROPERTIES OUTPUT_NAME ${target_base_name}${msvc_post_fix} )
    if( ARGC GREATER 2 )
      set( ${ARGV2} ${msvc_post_fix} PARENT_SCOPE )
    endif()
  endif()
endfunction()

# Add common compile flags that are used by MSVC compilers for H3D projects.
# compile_flags_container Compile flags will be added here.
function( addCommonH3DMSVCCompileFlags compile_flags_container )
  if( MSVC )
    # Treat wchar_t as built in type for all visual studio versions.
    # This is default for every version above 7 (so far) but we still set it for all.
    set( compile_flags_container_internal "/Zc:wchar_t" )

    if( MSVC80 )
      # This might be useful for visual studio 2005 users that often recompile the api.
      if( NOT DEFINED USE_VC8_MP_FLAG )
        set( USE_VC8_MP_FLAG "NO" CACHE BOOL "In visual studio 8 the MP flag exists but is not documented. Maybe it is unsafe to use. If you want to use it then set this flag to yes." )
      endif()

      if( USE_VC8_MP_FLAG )
        set( compile_flags_container_internal "${compile_flags_container_internal} /MP" )
      endif()
    endif()

    if( ${MSVC_VERSION} GREATER 1399 )
      # Remove compiler warnings about deprecation for visual studio versions 8 and above.
      set( compile_flags_container_internal "${compile_flags_container_internal} -D_CRT_SECURE_NO_DEPRECATE" )
    endif()

    if( ${MSVC_VERSION} GREATER 1499 )
      # Build using several threads for visual studio versions 9 and above.
      set( compile_flags_container_internal "${compile_flags_container_internal} /MP" )
    endif()
    set( ${compile_flags_container} "${${compile_flags_container}} ${compile_flags_container_internal}" PARENT_SCOPE )
  endif()
endfunction()

# Add common compile flags that are used by GNU (GCC/G++) compilers for H3D projects.
# compile_flags_container Compile flags will be added here
function( addCommonH3DGNUCompileFlags compile_flags_container )
  
  # Versions of g++ greater than 6.0 have the c++ standard set to 14 by default.
  # Compiling with these will cause deprecation warnings regarding auto_ptr to be given
  # so deprecation warnings are switched off for these versions of g++.
  set( compile_flags_container_internal "" )
  execute_process( COMMAND ${CMAKE_CXX_COMPILER} -dumpversion OUTPUT_VARIABLE GPP_VERSION )
  set( force_deprecated_declarations )
  if( ${ARGC} GREATER 1 )
    list( GET ARGN 0 force_deprecated_declarations )
  endif()
  if( ( GPP_VERSION VERSION_GREATER 6.0 ) OR ( GPP_VERSION VERSION_EQUAL 6.0 ) OR force_deprecated_declarations )
    set( compile_flags_container_internal "${compile_flags_container_internal} -Wno-deprecated-declarations" )
    set( warning_message "A version of GNU C++ compiler which is greater than 6.0 has been detected. Deprecated declaration warnings have been disabled to avoid auto_ptr warnings." )
    if( force_deprecated_declarations )
      set( warning_message "Deprecated declaration warnings have been disabled to avoid auto_ptr warnings." )
    endif()
    message( WARNING ${warning_message} )
  endif()
  
  set( ${compile_flags_container} "${${compile_flags_container}} ${compile_flags_container_internal}" PARENT_SCOPE )
  
endfunction()

# Iterates through a list of libraries and adds them to be delayloaded
# you can optionally pass a fourth argument which will be used to specify configuration
function( addDelayLoadFlags libraries_list link_flags_container )
  if( MSVC )
    set( link_flags_container_internal "" )
    set( previous_str "")
    foreach( lib_path ${${libraries_list}} )
      get_filename_component( lib_name ${lib_path} NAME_WE )
      if( ( NOT "${lib_name}" STREQUAL "debug" ) AND ( NOT "${lib_name}" STREQUAL "optimized" ) )
        if( ( ${ARGC} EQUAL 3 AND "${ARGV2}" STREQUAL "${previous_str}" ) OR "${previous_str}" STREQUAL "" )
          set( link_flags_container_internal "${link_flags_container_internal} /DELAYLOAD:\"${lib_name}.dll\"" )
          set( previous_str "" )
        endif()
      elseif( ( NOT ( ${ARGC} EQUAL 3 AND "${ARGV2}" STREQUAL "" ) ) )
        set( previous_str "${lib_name}" )
      endif()
    endforeach()
    set( ${link_flags_container} "${${link_flags_container}} ${link_flags_container_internal}" PARENT_SCOPE )
  endif()
endfunction()

# Iterates through a list of dll names and adds them to be delayloaded
function( addDelayLoadFlagsFromNames dll_names_list link_flags_container )
  if( MSVC )
    set( link_flags_container_internal "" )
    foreach( dll_name ${${dll_names_list}} )
      set( link_flags_container_internal "${link_flags_container_internal} /DELAYLOAD:\"${dll_name}.dll\"" )
    endforeach()
    set( ${link_flags_container} "${${link_flags_container}} ${link_flags_container_internal}" PARENT_SCOPE )
  endif()
endfunction()

# Setup the desired RPath settings for H3D projects.
function( setupRPathForLib )
  # use, i.e. don't skip the full RPATH for the build tree
  set( CMAKE_SKIP_BUILD_RPATH FALSE PARENT_SCOPE )

  # when building, don't use the install RPATH already
  # (but later on when installing)
  set( CMAKE_BUILD_WITH_INSTALL_RPATH FALSE PARENT_SCOPE )

  # Add the automatically determined parts of the RPATH
  # which point to directories outside the build tree to the install RPATH
  set( CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE PARENT_SCOPE )

  # The RPATH to be used when installing, but only if it's not a system directory
  list( FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" is_system_dir )
  if( "${is_system_dir}" STREQUAL "-1" )
     set( CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib" PARENT_SCOPE )
  endif()
endfunction()

# Handles common cache variables for H3D projects. Some of which might be CMAKE variables.
# Arguments are:
# GENERATE_H3D_PACKAGE_PROJECT - Will be initialized to OFF
# H3D_PREFER_STATIC_LIBRARIES - Will be initialized to OFF
# CMAKE_INSTALL_PREFIX <prefix_path> - Will set CMAKE_INSTALL_PREFIX to the given path if it was not already initialized. 
# USE_thread_lock_debug - If not set to a false value then USE_thread_lock_debug is created and initialized to OFF
#                            if it did not already exist. Otherwise the value is checked if it and the target H3DUtil exists
#                            otherwise the file H3DUtil.h is looked for and if found will be parsed to see if
#                            THREAD_LOCK_DEBUG is defined. If USE_thread_lock_debug is true or THREAD_LOCK_DEBUG is
#                            defined in H3DUtil.h then C++11 functionality is required.
# GENERATE_NodeRoutesToDotFile_BUILD - Will be initialized to OFF.
# Deprecated arguments:
# GENERATE_CPACK_PROJECT - replaced with GENERATE_H3D_PACKAGE_PROJECT
# PREFER_STATIC_LIBRARIES - replaced with H3D_PREFER_STATIC_LIBRARIES
# ENABLE_THREAD_LOCK_DEBUG - replaced with USE_thread_lock_debug
function( handleCommonCacheVar )
  set( options GENERATE_H3D_PACKAGE_PROJECT H3D_PREFER_STATIC_LIBRARIES GENERATE_NodeRoutesToDotFile_BUILD )
  set( one_value_args CMAKE_INSTALL_PREFIX USE_thread_lock_debug )
  set( multi_value_args )
  include( CMakeParseArguments )
  cmake_parse_arguments( setup_common_cache_var "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )
  handleDeprecatedFunctionArguments( ARGUMENT_PREFIX setup_common_cache_var_
                                     FUNCTION_NAME handleCommonCacheVar
                                     OLD_ARGUMENTS GENERATE_CPACK_PROJECT PREFER_STATIC_LIBRARIES ENABLE_THREAD_LOCK_DEBUG
                                     NEW_ARGUMENTS GENERATE_H3D_PACKAGE_PROJECT H3D_PREFER_STATIC_LIBRARIES USE_thread_lock_debug )

  if( setup_common_cache_var_UNPARSED_ARGUMENTS )
    message( FATAL_ERROR "Unknown keywords given to handleCommonCacheVar(): \"${setup_common_cache_var_UNPARSED_ARGUMENTS}\"" )
  endif()

  if( setup_common_cache_var_CMAKE_INSTALL_PREFIX )
    # set the install directory to the H3D directory on Windows
    if( WIN32 AND CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT AND NOT H3D_CMAKE_INSTALL_PREFIX_ALREADY_SET )
      set( CMAKE_INSTALL_PREFIX ${setup_common_cache_var_CMAKE_INSTALL_PREFIX} CACHE PATH "Install path prefix, prepended onto install directories." FORCE )
      set( H3D_CMAKE_INSTALL_PREFIX_ALREADY_SET ON PARENT_SCOPE )
    endif()
  endif()

  if( setup_common_cache_var_GENERATE_H3D_PACKAGE_PROJECT )
    handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES GENERATE_H3D_PACKAGE_PROJECT
                                                  OLD_VARIABLE_NAMES GENERATE_CPACK_PROJECT
                                                  DOC_STRINGS "Decides if a cpack project should be generated. The project in the first loaded CMakeLists will configure CPack." )
    if( NOT DEFINED GENERATE_H3D_PACKAGE_PROJECT )
      # Add a cache variable GENERATE_H3D_PACKAGE_PROJECT to have the choice of generating a project
      # for packagin the library. Default is OFF since most people will not use this.
      set( GENERATE_H3D_PACKAGE_PROJECT OFF CACHE BOOL "Decides if a cpack project should be generated. The project in the first loaded CMakeLists will configure CPack." )
      mark_as_advanced( GENERATE_H3D_PACKAGE_PROJECT )
      createCacheVariablesMarkedAsDeprecated( NEW_VARIABLE_NAMES GENERATE_H3D_PACKAGE_PROJECT
                                              OLD_VARIABLE_NAMES GENERATE_CPACK_PROJECT )
    endif()
  endif()
  
  if( setup_common_cache_var_H3D_PREFER_STATIC_LIBRARIES )
    handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES H3D_PREFER_STATIC_LIBRARIES
                                                  OLD_VARIABLE_NAMES PREFER_STATIC_LIBRARIES
                                                  DOC_STRINGS "Decides if CMake should prefer static libraries to dynamic libraries when both exist." )
    if( NOT DEFINED H3D_PREFER_STATIC_LIBRARIES )
      # Add a cache variable H3D_PREFER_STATIC_LIBRARIES to have the choice of generating a project
      # linking against static libraries if they exist. Default is OFF since most people will not use this.
      set( H3D_PREFER_STATIC_LIBRARIES OFF CACHE BOOL "Decides if CMake should prefer static libraries to dynamic libraries when both exist." )
      mark_as_advanced( H3D_PREFER_STATIC_LIBRARIES )
      createCacheVariablesMarkedAsDeprecated( NEW_VARIABLE_NAMES H3D_PREFER_STATIC_LIBRARIES
                                              OLD_VARIABLE_NAMES PREFER_STATIC_LIBRARIES )

      if( H3D_PREFER_STATIC_LIBRARIES )
        set( CMAKE_FIND_LIBRARY_SUFFIXES .a;${CMAKE_FIND_LIBRARY_SUFFIXES} PARENT_SCOPE )  
      endif()
    endif()
  endif()
  
  if( DEFINED setup_common_cache_var_USE_thread_lock_debug )
    handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES USE_thread_lock_debug
                                                  OLD_VARIABLE_NAMES ENABLE_THREAD_LOCK_DEBUG
                                                  DOC_STRINGS "Switcher to control the thread lock debug collection." )
    if( setup_common_cache_var_USE_thread_lock_debug AND NOT DEFINED USE_thread_lock_debug )
      set( USE_thread_lock_debug OFF CACHE BOOL "Switcher to control the thread lock debug collection." )
      createCacheVariablesMarkedAsDeprecated( NEW_VARIABLE_NAMES USE_thread_lock_debug
                                              OLD_VARIABLE_NAMES ENABLE_THREAD_LOCK_DEBUG )
    endif()
    
    set( check_for_c++11 OFF )
    if( TARGET H3DUtil )
      set( check_for_c++11 ${USE_thread_lock_debug} )
    elseif( H3DUtil_INCLUDE_DIR )
      foreach( h3dutil_include_dir_tmp ${H3DUtil_INCLUDE_DIR} )
        if( EXISTS ${h3dutil_include_dir_tmp}/H3DUtil/H3DUtil.h )
          file( STRINGS ${h3dutil_include_dir_tmp}/H3DUtil/H3DUtil.h list_of_defines REGEX "#define THREAD_LOCK_DEBUG" )
          list( LENGTH list_of_defines list_of_defines_length )
          if( list_of_defines_length )
            set( check_for_c++11 ON )
            break()
          endif()
        endif()
      endforeach()
    endif()
    
    if( check_for_c++11 )
      enableCpp11( FAIL_MESSAGE "Enabling USE_thread_lock_debug requires C++11 support. This compiler lacks such support." )
      set( THREAD_LOCK_DEBUG 1 PARENT_SCOPE )
    endif()
  endif()

  if( DEFINED setup_common_cache_var_GENERATE_NodeRoutesToDotFile_BUILD )
    handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES GENERATE_NodeRoutesToDotFile_BUILD
                                                  OLD_VARIABLE_NAMES GENERATE_NODEROUTESTODOTFILE_BUILD
                                                  DOC_STRINGS "Breaks H3D for normal use but this flag must be set to yes when using the NodeRoutesToDotFile project, located in H3DAPI/Util/NodeRoutesToDotFile." )

    # Add a cache variable GENERATE_NodeRoutesToDotFile_BUILD that should be
    # set to yes if NodeRoutesToDotFile project should be run using this
    # build of H3D.
    if( NOT DEFINED GENERATE_NodeRoutesToDotFile_BUILD )
      set( GENERATE_NodeRoutesToDotFile_BUILD OFF CACHE BOOL "Breaks H3D for normal use but this flag must be set to yes when using the NodeRoutesToDotFile project, located in H3DAPI/Util/NodeRoutesToDotFile." )
      mark_as_advanced( GENERATE_NodeRoutesToDotFile_BUILD )
    endif()
  endif()
endfunction()

# Sets up cache variable and other commands needed for a resource file for visual studio.
# VERSION_PREFIX - The prefix is used to replace variables in the resource file cmake template.
#                  Variables named <VERSION_PREFIX>_[MAJOR/MINOR/BUILD/SVN]_VERSION.
# SVN_DIR_CANDIDATE - The directory which should be checked for whether it is a svn repository.
# RESOURCE_FILE_CMAKE_TEMPLATE - The path to the cmake template of the resource file.
# RESOURCE_FILE_OUTPUT_LOCATION - The location of the output resource file.
# UPDATERESOURCEFILE_EXE - The location of UpdateResourceFile executable.
# UPDATERESOURCEFILE_EXE_EXTRA_ARGS - Extra arguments that should be given to UpdateResourceFile in those
# cases when the resource file has more info than just version.
function( setupResourceFile target_name )
  # Add a cache variable USE_svn_info to have the choice of using
  # SubWCRev.exe to embed svn revision number in generated DLLs.
  # Default is YES for Visual Studio and NMake generators, NO otherwise.
  if( MSVC )
    set( options )
    set( one_value_args VERSION_PREFIX SVN_DIR_CANDIDATE RESOURCE_FILE_CMAKE_TEMPLATE RESOURCE_FILE_OUTPUT_LOCATION UPDATERESOURCEFILE_EXE )
    set( multi_value_args UPDATERESOURCEFILE_EXE_EXTRA_ARGS )
    include( CMakeParseArguments )
    cmake_parse_arguments( setup_resource_file "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )
    if( setup_resource_file_UNPARSED_ARGUMENTS )
      message( FATAL_ERROR "Unknown keywords given to setupResourceFile(): \"${setup_resource_file_UNPARSED_ARGUMENTS}\"" )
    endif()
    
    foreach( required_arg ${one_value_args} )
      if( NOT setup_resource_file_${required_arg} )
        message( FATAL_ERROR "The required argument ${required_arg} is missing when calling setupResourceFile." )
      endif()
    endforeach()

    handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES USE_svn_info
                                                  OLD_VARIABLE_NAMES ENABLE_SVN_REVISION
                                                  DOC_STRINGS "Use SubWCRev.exe ( if found ) to embed svn revision number in generated DLLs." )
  
    if( NOT DEFINED USE_svn_info )
      set( enable_svn_revision_default OFF )
      if( CMAKE_GENERATOR MATCHES "Visual Studio|NMake" )
        set( enable_svn_revision_default ON )
      endif()
      set( USE_svn_info ${enable_svn_revision_default} CACHE BOOL "Use SubWCRev.exe ( if found ) to embed svn revision number in generated DLLs." )
      createCacheVariablesMarkedAsDeprecated( NEW_VARIABLE_NAMES USE_svn_info
                                              OLD_VARIABLE_NAMES ENABLE_SVN_REVISION )
    endif()
    
    set( ${setup_resource_file_VERSION_PREFIX}_SVN_VERSION "0" )
    if( USE_svn_info )
      # Find SubWCRev.exe
      find_file( SubWCRev
                 NAMES "SubWCRev.exe"
                 DOC   "Set to SubWCRev.exe that comes with TortoiseSVN. Used to find svn revision number." )
      mark_as_advanced( SubWCRev )
    endif()

    set( code_is_svn_working_copy 10 )
    if( USE_svn_info AND SubWCRev )
      execute_process( COMMAND ${SubWCRev} ${setup_resource_file_SVN_DIR_CANDIDATE}
                       RESULT_VARIABLE code_is_svn_working_copy )
      if( ${code_is_svn_working_copy} EQUAL 0 )
        set( ${setup_resource_file_VERSION_PREFIX}_SVN_VERSION "$WCREV$" )
      endif()
    endif()

    # autogenerate the resource file depending on the version
    configure_file( ${setup_resource_file_RESOURCE_FILE_CMAKE_TEMPLATE} ${setup_resource_file_RESOURCE_FILE_OUTPUT_LOCATION} )
    
    if( USE_svn_info )
      add_custom_command( TARGET ${target_name}
                          PRE_BUILD
                          COMMAND ${setup_resource_file_UPDATERESOURCEFILE_EXE}
                          ARGS ${setup_resource_file_VERSION_PREFIX} ${setup_resource_file_RESOURCE_FILE_OUTPUT_LOCATION} ${setup_resource_file_RESOURCE_FILE_CMAKE_TEMPLATE}
                          ${${setup_resource_file_VERSION_PREFIX}_MAJOR_VERSION} ${${setup_resource_file_VERSION_PREFIX}_MINOR_VERSION}
                          ${${setup_resource_file_VERSION_PREFIX}_BUILD_VERSION} "${${setup_resource_file_VERSION_PREFIX}_SVN_VERSION}"
                          ${setup_resource_file_UPDATERESOURCEFILE_EXE_EXTRA_ARGS} )
    endif()

    if( USE_svn_info AND SubWCRev AND ${code_is_svn_working_copy} EQUAL 0 )
      # Update SVN revision in file.
      execute_process( COMMAND ${SubWCRev} ${setup_resource_file_SVN_DIR_CANDIDATE} ${setup_resource_file_RESOURCE_FILE_OUTPUT_LOCATION} ${setup_resource_file_RESOURCE_FILE_OUTPUT_LOCATION} )

      add_custom_command( TARGET ${target_name} 
                          PRE_BUILD 
                          COMMAND ${SubWCRev} 
                          ARGS ${setup_resource_file_SVN_DIR_CANDIDATE} ${setup_resource_file_RESOURCE_FILE_OUTPUT_LOCATION} ${setup_resource_file_RESOURCE_FILE_OUTPUT_LOCATION} )
    endif()
  endif()
endfunction()

# Set up unity build cache variables and optional compile flags and also handles
# detection of cache changes.
# PROJECT_NAME - The name of the project which calls this function. Used in warnings/errors and to
#                create a cache variable for enabling/disabling per project.
# SOURCE_FILES - The list of source files that should be included in the UnityBuild.cpp file.
# OUTPUT_VARIABLE - The name of the variable in which to set the list of sources in case unity build should
#                   be used.
# SOURCE_PREFIX_PATH - Optional. A path used as prefix to the source files listed in SOURCE_FILES.
# COMPILE_FLAGS_VARIABLE - Optional. If given it should contain the name of the variable in which to put
#                          the /bigobj compile flags. It is an indication that the Unitybuild.cpp file
#                          will end up being very large. Only used if compiler is MSVC.
# UNITY_BUILD_SOURCES - Optional. A list of source files that should be given to the OUTPUT_VARIABLE if
#                       unity build is enabled. If omitted then only UnityBuild.cpp will be given to OUTPUT_VARIABLE.
function( handleUnityBuild )
  set( options )
  set( one_value_args PROJECT_NAME SOURCE_PREFIX_PATH COMPILE_FLAGS_VARIABLE OUTPUT_VARIABLE )
  set( multi_value_args SOURCE_FILES UNITY_BUILD_SOURCES )
  include( CMakeParseArguments )
  cmake_parse_arguments( handle_unity_build "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )
  if( handle_unity_build_UNPARSED_ARGUMENTS )
    message( FATAL_ERROR "Unknown keywords given to handleUnityBuild(): \"${handle_unity_build_UNPARSED_ARGUMENTS}\"" )
  endif()
  
  set( required_arguments PROJECT_NAME OUTPUT_VARIABLE SOURCE_FILES )
  foreach( required_arg ${required_arguments} )
    if( NOT handle_unity_build_${required_arg} )
      message( FATAL_ERROR "The required argument ${required_arg} is missing when calling handleUnityBuild." )
    endif()
  endforeach()

  # Add a cache variable GENERATE_UNITY_BUILD to have the choice of selecting
  # a unity build project. Default is NO.
  if( NOT DEFINED GENERATE_UNITY_BUILD )
    set( GENERATE_UNITY_BUILD OFF CACHE BOOL "Decides if a the generated project files should build through a unity build instead of a normal build. A unity builds packs all .cpp files into a UnityBuild.cpp file and then only include this in the project. This greatly reduces build times." )
  endif()

  if( GENERATE_UNITY_BUILD )
    if( NOT DEFINED UNITY_BUILD_${handle_unity_build_PROJECT_NAME} )
      set( UNITY_BUILD_${handle_unity_build_PROJECT_NAME} ON CACHE BOOL "Decides if a the generated project files should build through a unity build instead of a normal build. A unity builds packs all .cpp files into a UnityBuild.cpp file and then only include this in the project. This greatly reduces build times." )
    endif()

    if( UNITY_BUILD_${handle_unity_build_PROJECT_NAME} )  
      # Generate a unity build, by creating the UnityBuild.cpp and only including the required 
      # source files.
      set( UNITYBUILD_INCLUDES )

      foreach( filename ${handle_unity_build_SOURCE_FILES} )
        if( handle_unity_build_SOURCE_PREFIX_PATH )
          set( filename ${handle_unity_build_SOURCE_PREFIX_PATH}${filename} )
        endif()
        set( UNITYBUILD_INCLUDES "${UNITYBUILD_INCLUDES}#include \"${filename}\"\n" )
      endforeach()

      # Using a cached variable with our string in it. Because cmake doesn't support multi-line strings we have to replace the newlines with a delimiter, so we arbitrarily use +=+.
      string( REPLACE "
" "+=+" UnitybuildIncludesConverted ${UNITYBUILD_INCLUDES} ) # Convert the file we're going to write to use our delimiter instead of newlines
      if( NOT ( UNITY_BUILD_CACHE_${handle_unity_build_PROJECT_NAME} ) OR NOT ( UnitybuildIncludesConverted STREQUAL UNITY_BUILD_CACHE_${handle_unity_build_PROJECT_NAME} )) # If we don't have the cache variable or if its contents don't match our new string then we write the unmodified new UnityBuild file and store the one with the swapped out delimiters in the cache variable
        message( STATUS "Updating UnityBuild.cpp for " ${handle_unity_build_PROJECT_NAME} )
        string( REPLACE "
" "+=+" unityBuildCacheNew ${UNITYBUILD_INCLUDES} )
        set( UNITY_BUILD_CACHE_${handle_unity_build_PROJECT_NAME} ${unityBuildCacheNew} CACHE INTERNAL "Used for determining if UnityBuild.cpp should be updated or not." )
        file( WRITE UnityBuild.cpp ${UNITYBUILD_INCLUDES} )
      else()
        message( STATUS "Unitybuild.cpp for ${handle_unity_build_PROJECT_NAME} already up to date" )
      endif()
      if( MSVC AND handle_unity_build_COMPILE_FLAGS_VARIABLE )
        set( ${handle_unity_build_COMPILE_FLAGS_VARIABLE} "${${handle_unity_build_COMPILE_FLAGS_VARIABLE}} /bigobj" PARENT_SCOPE )
      endif()
      if( handle_unity_build_UNITY_BUILD_SOURCES )
        set( ${handle_unity_build_OUTPUT_VARIABLE} ${handle_unity_build_UNITY_BUILD_SOURCES} PARENT_SCOPE )
      else()
        set( ${handle_unity_build_OUTPUT_VARIABLE} "UnityBuild.cpp" PARENT_SCOPE )
      endif()
    endif()
  endif()
endfunction()

# Set up precompiled headers. Will do nothing for non MSVC generators.
# PROJECT_NAME - The name of the project which calls this function. Used in warnings/errors and to
#                create a cache variable for enabling/disabling per project.
# HEADERS_VARIABLE - The name of a variable which contain all the headers of the project.
# SRCS_VARIABLE - The name of a variable which contain all the source files of the project.
# STDAFX_HEADER_LOCATION - The location in which StdAfx.h should be created.
# STDAFX_SOURCE_LOCATION - The location in which StdAfx.cpp should be created.
function( handlePrecompiledHeaders )
  set( options )
  set( one_value_args PROJECT_NAME HEADERS_VARIABLE SRCS_VARIABLE STDAFX_HEADER_LOCATION STDAFX_SOURCE_LOCATION )
  set( multi_value_args )
  include( CMakeParseArguments )
  cmake_parse_arguments( handle_precompiled_headers "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )
  if( handle_precompiled_headers_UNPARSED_ARGUMENTS )
    message( FATAL_ERROR "Unknown keywords given to handlePrecompiledHeaders(): \"${handle_precompiled_headers_UNPARSED_ARGUMENTS}\"" )
  endif()
  
  foreach( required_arg ${one_value_args} )
    if( NOT handle_precompiled_headers_${required_arg} )
      message( FATAL_ERROR "The required argument ${required_arg} is missing when calling handlePrecompiledHeaders." )
    endif()
  endforeach()

  set( PRECOMPILED_HEADERS_${handle_precompiled_headers_PROJECT_NAME} ON CACHE BOOL "Decides if a the generated project files should use precompiled headers. This greatly reduces build times after first build." )

  # set up precompiled headers  
  if( MSVC AND PRECOMPILED_HEADERS_${handle_precompiled_headers_PROJECT_NAME} )
    list( APPEND ${handle_precompiled_headers_HEADERS_VARIABLE} ${handle_precompiled_headers_STDAFX_HEADER_LOCATION}StdAfx.h )
    list( APPEND ${handle_precompiled_headers_SRCS_VARIABLE} ${handle_precompiled_headers_STDAFX_SOURCE_LOCATION}StdAfx.cpp )
    string( REGEX REPLACE ".*include/" "" stdafx_header_location_no_include ${handle_precompiled_headers_STDAFX_HEADER_LOCATION} )
    if( stdafx_header_location_no_include STREQUAL ${handle_precompiled_headers_STDAFX_HEADER_LOCATION} )
      set( stdafx_header_location_no_include )
    endif()
    if( ${MSVC_VERSION} LESS 1900 )
      set_source_files_properties( ${${handle_precompiled_headers_SRCS_VARIABLE}}
                                   PROPERTIES COMPILE_FLAGS "/Zm900 /FI${stdafx_header_location_no_include}StdAfx.h /Yu${stdafx_header_location_no_include}StdAfx.h" )
      set_source_files_properties( ${handle_precompiled_headers_STDAFX_SOURCE_LOCATION}StdAfx.cpp 
                                   PROPERTIES COMPILE_FLAGS "/Zm900 /Yc${stdafx_header_location_no_include}StdAfx.h" )
    else()
      set_source_files_properties( ${${handle_precompiled_headers_SRCS_VARIABLE}}
                                   PROPERTIES COMPILE_FLAGS "/FI${stdafx_header_location_no_include}StdAfx.h /Yu${stdafx_header_location_no_include}StdAfx.h" )
      set_source_files_properties( ${handle_precompiled_headers_STDAFX_SOURCE_LOCATION}StdAfx.cpp
                                   PROPERTIES COMPILE_FLAGS "/Yc${stdafx_header_location_no_include}StdAfx.h" )
    endif()
    set( ${handle_precompiled_headers_HEADERS_VARIABLE} ${${handle_precompiled_headers_HEADERS_VARIABLE}} PARENT_SCOPE )
    set( ${handle_precompiled_headers_SRCS_VARIABLE} ${${handle_precompiled_headers_SRCS_VARIABLE}} PARENT_SCOPE )
  endif()
endfunction()

# Given a couple of project names check if a target with that name exists. In that case
# link against it, if not then try to use the find module to find it. For each project a
# <project_name>_FOUND variable will be set indicating if the project was found.
# PROJECT_NAMES - A list of names of projects for which to find include directories and libraries.
# INCLUDE_DIRS_OUTPUT_VAR - The name of the output variable in which to list include directories.
# LIBRARIES_OUTPUT_VAR - The name of the output variable in which to list libraries.
# REQUIRED_PROJECTS - If any of the projects listed here is not found the configuration will fail.
# REQUIRED_PROJECTS_COMPONENTS - Components for each library in REQUIRED_PROJECTS are used if the project is not
#                                a target in the current build. Each component have to be listed as
#                                ProjectName_ComponentName where ProjectName refers to a project in REQUIRED_PROJECTS
#                                and ComponentName is the name of the component for that project.
# PROJECTS_USE_CPP11_OUTPUT_VAR - If set then it will be set to true if any of the found H3D projects enable c++11 support. Currently only H3DAPI is checked though.
function( findIncludeDirsAndLibrariesForH3DProjects )
  set( options )
  set( one_value_args PROJECTS_USE_CPP11_OUTPUT_VAR )
  set( multi_value_args PROJECT_NAMES INCLUDE_DIRS_OUTPUT_VAR LIBRARIES_OUTPUT_VAR REQUIRED_PROJECTS REQUIRED_PROJECTS_COMPONENTS )
  include( CMakeParseArguments )
  cmake_parse_arguments( find_h3d_projects_dirs_libs "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )
  if( find_h3d_projects_dirs_libs_UNPARSED_ARGUMENTS )
    message( FATAL_ERROR "Unknown keywords given to findIncludeDirsAndLibrariesForH3DProjects (): \"${find_h3d_projects_dirs_libs_UNPARSED_ARGUMENTS}\"" )
  endif()

  set( required_args PROJECT_NAMES )
  foreach( required_arg ${required_args} )
    if( NOT find_h3d_projects_dirs_libs_${required_arg} )
      message( FATAL_ERROR "The required argument ${required_arg} is missing when calling findIncludeDirsAndLibrariesForH3DProjects ." )
    endif()
  endforeach()

  if( DEFINED H3D_USE_DEPENDENCIES_ONLY )
    checkIfCacheVariableMarkedAsDeprecated( CACHE_VARIABLE H3D_USE_DEPENDENCIES_ONLY OUTPUT_VARIABLE created_internally )
    if( NOT created_internally )
      message( AUTHOR_WARNING "The variable H3D_USE_DEPENDENCIES_ONLY is deprecated and will be removed in the future. Please replace it by checking for existing targets instead." )
    endif()
  endif()

  if( find_h3d_projects_dirs_libs_PROJECTS_USE_CPP11_OUTPUT_VAR )
    set( ${find_h3d_projects_dirs_libs_PROJECTS_USE_CPP11_OUTPUT_VAR} NO PARENT_SCOPE )
  endif()

  set( tmp_include_dirs )
  set( tmp_libraries )
  foreach( project_name ${find_h3d_projects_dirs_libs_PROJECT_NAMES} )
    set( ${project_name}_FOUND NO PARENT_SCOPE )
    if( TARGET ${project_name} )
      if( "${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}.${CMAKE_PATCH_VERSION}" VERSION_GREATER "2.8.7" )
        get_target_property( target_include_dirs ${project_name} INCLUDE_DIRECTORIES )
        set( tmp_include_dirs ${tmp_include_dirs} ${target_include_dirs} )
      else()
        if( NOT DEFINED ${project_name}_INCLUDE_DIRS )
          message( FATAL_ERROR "The target ${project_name} does not define an internal variable named ${project_name}_INCLUDE_DIRS. There is therefore no way of adding include directories. " )
        endif()
        set( tmp_include_dirs ${tmp_include_dirs} ${${project_name}_INCLUDE_DIRS} )
      endif()
      set( tmp_libraries ${tmp_libraries} ${project_name} )
      set( ${project_name}_FOUND YES )
      set( ${project_name}_FOUND YES PARENT_SCOPE )
      set( INSTALL_RUNTIME_AND_LIBRARIES_ONLY_DEPENDENCIES ${INSTALL_RUNTIME_AND_LIBRARIES_ONLY_DEPENDENCIES} ${project_name} PARENT_SCOPE )
    else()
      set( required_flag )
      if( find_h3d_projects_dirs_libs_REQUIRED_PROJECTS )
        list( FIND find_h3d_projects_dirs_libs_REQUIRED_PROJECTS ${project_name} list_pos )
        if( ${list_pos} GREATER -1 )
          set( required_flag REQUIRED )
        endif()
      endif()
      if( required_flag AND find_h3d_projects_dirs_libs_REQUIRED_PROJECTS_COMPONENTS )
        foreach( project_component ${find_h3d_projects_dirs_libs_REQUIRED_PROJECTS_COMPONENTS} )
          string( REGEX REPLACE "_.+$" "" project_name_part ${project_component} )
          string( REGEX REPLACE "^[^_]+_" "" component_name_part ${project_component} )
          if( ${project_name_part} STREQUAL ${project_name} )
            set( required_flag ${required_flag} ${component_name_part} )
          endif()
        endforeach()
      endif()
      find_package( ${project_name} ${required_flag} )
      if( ${project_name}_FOUND )
        set( tmp_include_dirs ${tmp_include_dirs} ${${project_name}_INCLUDE_DIRS} )
        set( tmp_libraries ${tmp_libraries} ${${project_name}_LIBRARIES} )
        set( ${project_name}_FOUND ${${project_name}_FOUND} PARENT_SCOPE )
      endif()
    endif()
    if( ( ${project_name} STREQUAL "H3DAPI" ) AND ${project_name}_FOUND )
      # Check if h3dapi version is 3 or higher. In that case call the not entirely accurately named enableCpp11.
      foreach( h3dapi_include_dir_tmp ${tmp_include_dirs} )
        if( EXISTS ${h3dapi_include_dir_tmp}/H3D/H3DApi.h )
          file( STRINGS ${h3dapi_include_dir_tmp}/H3D/H3DApi.h major_version REGEX "#define H3DAPI_MAJOR_VERSION ([0-9]+)" )
          if( major_version MATCHES "H3DAPI_MAJOR_VERSION ([0-9]+)" ) # This line is only here because CMAKE_MATCH_1 is apparently not set by file( STRINGS )
            if( ${CMAKE_MATCH_1} GREATER 2 )
              # H3DAPI is version 3 or later.
              enableCpp11( FAIL_MESSAGE "H3DAPI ${CMAKE_MATCH_1} used by this library requires partial C++11 support. This compiler lacks such support." )
              if( find_h3d_projects_dirs_libs_PROJECTS_USE_CPP11_OUTPUT_VAR )
                set( ${find_h3d_projects_dirs_libs_PROJECTS_USE_CPP11_OUTPUT_VAR} YES PARENT_SCOPE )
              endif()
            endif()
          endif()
        endif()
      endforeach()
    endif()
  endforeach()
  
  if( find_h3d_projects_dirs_libs_INCLUDE_DIRS_OUTPUT_VAR )
    list( REMOVE_DUPLICATES tmp_include_dirs )
    set( ${find_h3d_projects_dirs_libs_INCLUDE_DIRS_OUTPUT_VAR} ${tmp_include_dirs} PARENT_SCOPE )
  endif()
  if( find_h3d_projects_dirs_libs_LIBRARIES_OUTPUT_VAR )
    set( ${find_h3d_projects_dirs_libs_LIBRARIES_OUTPUT_VAR} ${tmp_libraries} PARENT_SCOPE )
  endif()
endfunction()

# Setups an internal cache variable which contains the include directories for the
# current CMakeLists.txt. Note that this function should be called just before creating targets.
# If H3D ever changes the required cmake system to be one that has INCLUDE_DIRECTORIES property
# on targets then we can update this function.
# VARIABLE_NAME - The name of the internal cache variable.
# DEPRECATED_VARIABLE_NAMES - Old names for this variable which should output a warning the first time
# and which will also be set to handle backwards compatiblity.
function( populateProjectIncludeDirectoriesCacheVar )
  set( options )
  set( one_value_args VARIABLE_NAME )
  set( multi_value_args DEPRECATED_VARIABLE_NAMES )
  include( CMakeParseArguments )
  cmake_parse_arguments( populate_project_include_dirs_cache_var "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )
  if( populate_project_include_dirs_cache_var_UNPARSED_ARGUMENTS )
    message( FATAL_ERROR "Unknown keywords given to populateProjectIncludeDirectoriesCacheVar(): \"${populate_project_include_dirs_cache_var_UNPARSED_ARGUMENTS}\"" )
  endif()
  
  set( required_args VARIABLE_NAME )
  foreach( required_arg ${required_args} )
    if( NOT populate_project_include_dirs_cache_var_${required_arg} )
      message( FATAL_ERROR "The required argument ${required_arg} is missing when calling populateProjectIncludeDirectoriesCacheVar." )
    endif()
  endforeach()
  
  if( NOT DEFINED ${populate_project_include_dirs_cache_var_VARIABLE_NAME} )
    if( populate_project_include_dirs_cache_var_DEPRECATED_VARIABLE_NAMES )
      set( deprecated_names_used )
      foreach( deprecated_var_name ${populate_project_include_dirs_cache_var_DEPRECATED_VARIABLE_NAMES} )
        if( DEFINED ${deprecated_var_name} )
          if( deprecated_names_used )
            set( deprecated_names_used "${deprecated_names_used}, ${deprecated_var_name}" )
          else()
            set( deprecated_names_used "${deprecated_names_used} ${deprecated_var_name}" )
          endif()
        endif()
      endforeach()
      if( deprecated_names_used )
        message( AUTHOR_WARNING "The variables ${deprecated_names_used} are deprecated and should be replaced with ${populate_project_include_dirs_cache_var_VARIABLE_NAME} in your CMakeLists.txt. This warning message will not be showed again due to the variables existing in internal cache." )
      endif()
    endif()
  endif()
  
  get_filename_component( parent_dir ${CMAKE_PARENT_LIST_FILE} PATH )
  get_directory_property( include_dir_tmp DIRECTORY ${parent_dir} INCLUDE_DIRECTORIES )
  set( ${populate_project_include_dirs_cache_var_VARIABLE_NAME} ${include_dir_tmp} CACHE INTERNAL "Set to internal to propagate change" FORCE )
  list( REMOVE_DUPLICATES ${populate_project_include_dirs_cache_var_VARIABLE_NAME} )
  
  # Handle backwards compatibility
  foreach( deprecated_var_name ${populate_project_include_dirs_cache_var_DEPRECATED_VARIABLE_NAMES} )
    set( ${deprecated_var_name} ${${populate_project_include_dirs_cache_var_VARIABLE_NAME}} CACHE INTERNAL "Set to internal to propagate change" FORCE )
  endforeach()
endfunction()

# Add common compile flags that are used by Apple clang compilers for H3D projects.
# compile_flags_container Compile flags will be added here
function( addCommonAppleClangCompileFlags compile_flags_container )

  if( APPLE AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang" )
    set( ${compile_flags_container} "${${compile_flags_container}} -Wno-deprecated-declarations" PARENT_SCOPE )
    message( WARNING "Deprecated declaration warnings have been disabled to avoid deprecated glu and glut warnings." )
  endif()

endfunction()

# Add common compile flags that are used by various compilers for H3D projects.
# compile_flags_container Compile flags will be added here.
function( addCommonH3DCompileFlags compile_flags_container )
  set( compile_flags_container_internal )
  addCommonH3DMSVCCompileFlags( compile_flags_container_internal )
  if( CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" )
    addCommonH3DGNUCompileFlags( compile_flags_container_internal )
  endif()
  addCommonAppleClangCompileFlags( compile_flags_container_internal )

  set( ${compile_flags_container} "${${compile_flags_container}} ${compile_flags_container_internal}" PARENT_SCOPE )
endfunction()
