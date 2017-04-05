# Contains common H3D functions that are used a bit here and there.

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
    set( ${post_fix_output} _vc${h3d_msvc_version} PARENT_SCOPE )
  endif()
endfunction()

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

# goes through a list of libraries and adds them to be delayloaded
function( addDelayLoadFlags libraries_list link_flags_container )
  if( MSVC )
    set( link_flags_container_internal "" )
    foreach( lib_path ${${libraries_list}} )
      get_filename_component( lib_name ${lib_path} NAME_WE )
      set( link_flags_container_internal "${link_flags_container_internal} /DELAYLOAD:\"${lib_name}.dll\"" )
    endforeach()
    set( ${link_flags_container} "${${link_flags_container}} ${link_flags_container_internal}" PARENT_SCOPE )
  endif()
endfunction()

function( addDelayLoadFlagsFromNames dll_names_list link_flags_container )
  if( MSVC )
    set( link_flags_container_internal "" )
    foreach( dll_name ${${dll_names_list}} )
      set( link_flags_container_internal "${link_flags_container_internal} /DELAYLOAD:\"${dll_name}.dll\"" )
    endforeach()
    set( ${link_flags_container} "${${link_flags_container}} ${link_flags_container_internal}" PARENT_SCOPE )
  endif()
endfunction()

# Get the commonly used lib directory name for H3D 
# default_lib_directory_output Contains the variable which should be set to the lib directory name.
function( getDefaultH3DLibDirectory default_lib_directory_output )
  set( default_lib_install "lib" )
  if( WIN32 )
    set( default_lib_install "lib32" )
    if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
      set( default_lib_install "lib64" )
    endif()
  endif()
  set( ${default_lib_directory_output} ${default_lib_install} PARENT_SCOPE )
endfunction()

# Setup the desired RPath settings for H3D projects.
function( setupRPathForLib )
  # use, i.e. don't skip the full RPATH for the build tree
  set( CMAKE_SKIP_BUILD_RPATH FALSE )

  # when building, don't use the install RPATH already
  # (but later on when installing)
  set( CMAKE_BUILD_WITH_INSTALL_RPATH FALSE )

  # Add the automatically determined parts of the RPATH
  # which point to directories outside the build tree to the install RPATH
  set( CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE )

  # The RPATH to be used when installing, but only if it's not a system directory
  list( FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" is_system_dir )
  if( "${is_system_dir}" STREQUAL "-1" )
     set( CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib" )
  endif()
endfunction()

# Handles common cache variables for H3D projects. Some of which might be CMAKE variables.
# Arguments are:
# GENERATE_CPACK_PROJECT - Will be initialized to OFF
# PREFER_STATIC_LIBRARIES - Will be initialized to OFF
# CMAKE_INSTALL_PREFIX <prefix_path> - Will set CMAKE_INSTALL_PREFIX to the given path if it was not already initialized. 
function( handleCommonCacheVar )
  set( options GENERATE_CPACK_PROJECT PREFER_STATIC_LIBRARIES )
  set( oneValueArgs CMAKE_INSTALL_PREFIX )
  set( multiValueArgs )
  include( CMakeParseArguments )
  cmake_parse_arguments( setup_common_cache_var "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
  
  if( setup_common_cache_var_CMAKE_INSTALL_PREFIX )
    # set the install directory to the H3D directory on Windows
    if( WIN32 AND CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT AND NOT H3D_CMAKE_INSTALL_PREFIX_ALREADY_SET )
      set( CMAKE_INSTALL_PREFIX ${setup_common_cache_var_CMAKE_INSTALL_PREFIX} CACHE PATH "Install path prefix, prepended onto install directories." FORCE )
      set( H3D_CMAKE_INSTALL_PREFIX_ALREADY_SET ON PARENT_SCOPE )
    endif()
  endif()

  if( setup_common_cache_var_GENERATE_CPACK_PROJECT AND NOT DEFINED GENERATE_CPACK_PROJECT )
    # Add a cache variable GENERATE_CPACK_PROJECT to have the choice of generating a project
    # for packagin the library. Default is OFF since most people will not use this.
    set( GENERATE_CPACK_PROJECT OFF CACHE BOOL "Decides if a cpack project should be generated. The project in the first loaded CMakeLists will configure CPack." )
    mark_as_advanced( GENERATE_CPACK_PROJECT )
  endif()
  
  if( setup_common_cache_var_PREFER_STATIC_LIBRARIES AND NOT DEFINED PREFER_STATIC_LIBRARIES )
    # Add a cache variable PREFER_STATIC_LIBRARIES to have the choice of generating a project
    # linking against static libraries if they exist. Default is OFF since most people will not use this.
    set( PREFER_STATIC_LIBRARIES OFF CACHE BOOL "Decides if CMake should prefer static libraries to dynamic libraries when both exist." )
    mark_as_advanced( PREFER_STATIC_LIBRARIES )

    if( PREFER_STATIC_LIBRARIES )
      set( CMAKE_FIND_LIBRARY_SUFFIXES .a;${CMAKE_FIND_LIBRARY_SUFFIXES} PARENT_SCOPE )  
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
function( setupResourceFile target_name  )
  # Add a cache variable ENABLE_SVN_REVISION to have the choice of using
  # SubWCRev.exe to embed svn revision number in generated DLLs.
  # Default is YES for Visual Studio and NMake generators, NO otherwise.
  if( MSVC )
    set( options )
    set( oneValueArgs VERSION_PREFIX SVN_DIR_CANDIDATE RESOURCE_FILE_CMAKE_TEMPLATE RESOURCE_FILE_OUTPUT_LOCATION UPDATERESOURCEFILE_EXE )
    set( multiValueArgs UPDATERESOURCEFILE_EXE_EXTRA_ARGS )
    include( CMakeParseArguments )
    cmake_parse_arguments( setup_resource_file "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
    
    foreach( required_arg ${oneValueArgs} )
      if( NOT DEFINED setup_resource_file_${required_arg} )
        message( FATAL_ERROR "The required argument ${required_arg} is missing when calling setupResourceFile.")
      endif()
    endforeach()
  
    if( NOT DEFINED ENABLE_SVN_REVISION )
      set( enable_svn_revision_default OFF )
      if( CMAKE_GENERATOR MATCHES "Visual Studio|NMake" )
        set( enable_svn_revision_default ON )
      endif()
      set( ENABLE_SVN_REVISION ${enable_svn_revision_default} CACHE BOOL "Use SubWCRev.exe to embed svn revision number in generated DLLs." )
    endif()
    
    set( ${setup_resource_file_VERSION_PREFIX}_SVN_VERSION "0" )
    if( ENABLE_SVN_REVISION )
      # Find SubWCRev.exe
      find_file( SubWCRev
                 NAMES "SubWCRev.exe"
                 DOC   "Set to SubWCRev.exe that comes with TortoiseSVN. Used to find svn revision number." )
      mark_as_advanced( SubWCRev )
    endif()

    set( code_is_svn_working_copy 10 )
    if( ENABLE_SVN_REVISION AND SubWCRev )
      execute_process( COMMAND ${SubWCRev} ${setup_resource_file_SVN_DIR_CANDIDATE}
                       RESULT_VARIABLE code_is_svn_working_copy )
      if( ${code_is_svn_working_copy} EQUAL 0 )
        set( ${setup_resource_file_VERSION_PREFIX}_SVN_VERSION "$WCREV$" )
      endif()
    endif()

    # autogenerate the resource file depending on the version
    configure_file( ${setup_resource_file_RESOURCE_FILE_CMAKE_TEMPLATE} ${setup_resource_file_RESOURCE_FILE_OUTPUT_LOCATION} )
    
    if( ENABLE_SVN_REVISION )
      add_custom_command( TARGET ${target_name}
                          PRE_BUILD
                          COMMAND ${setup_resource_file_UPDATERESOURCEFILE_EXE}
                          ARGS ${setup_resource_file_VERSION_PREFIX} ${setup_resource_file_RESOURCE_FILE_OUTPUT_LOCATION} ${setup_resource_file_RESOURCE_FILE_CMAKE_TEMPLATE}
                          ${${setup_resource_file_VERSION_PREFIX}_MAJOR_VERSION} ${${setup_resource_file_VERSION_PREFIX}_MINOR_VERSION}
                          ${${setup_resource_file_VERSION_PREFIX}_BUILD_VERSION} "${${setup_resource_file_VERSION_PREFIX}_SVN_VERSION}"
                          ${setup_resource_file_UPDATERESOURCEFILE_EXE_EXTRA_ARGS}  )
    endif()

    if( ENABLE_SVN_REVISION AND SubWCRev AND ${code_is_svn_working_copy} EQUAL 0 )
      # Update SVN revision in file.
      execute_process( COMMAND ${SubWCRev} ${setup_resource_file_SVN_DIR_CANDIDATE} ${setup_resource_file_RESOURCE_FILE_OUTPUT_LOCATION} ${setup_resource_file_RESOURCE_FILE_OUTPUT_LOCATION} )

      add_custom_command( TARGET ${target_name} 
                          PRE_BUILD 
                          COMMAND ${SubWCRev} 
                          ARGS ${setup_resource_file_SVN_DIR_CANDIDATE} ${setup_resource_file_RESOURCE_FILE_OUTPUT_LOCATION} ${setup_resource_file_RESOURCE_FILE_OUTPUT_LOCATION} )
    endif()
  endif()
endfunction()