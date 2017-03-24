# - Find HAPI
# Find the native HAPI headers and libraries.
# Output:
#  HAPI_INCLUDE_DIRS - Where to find HAPI.h, etc.
#  HAPI_LIBRARIES    - List of libraries when using HAPI.
#  HAPI_FOUND        - True if HAPI found.
#
# If the COMPONENTS feature of HAPI is not set then it is assumed that
# the caller does not intend to use any of the supported components in the
# library/executable code (i.e does not intend to include any headers
# or link against those libraries.)
# The allowed values for the COMPONENTS feature of HAPI are:
# SameAsHAPI - HAPI decides which renderers are required to link. I.e
#              HAPI.h will be parsed and it is assumed that the library/executable that
#              will use HAPI will use the defines from HAPI.h to disable/enable
#              features regarding haptics renderers.
# OpenHapticsRenderer - OpenHaptics header/libraries must exist on the system.
# Chai3DRenderer - Chai3d header/libraries must exist on the system.
# 
# The following features are deprecated and the COMPONENTS feature of find_package should be used instead.
# HAPI_REQUIRED_RENDERERS
# HAPI_DECIDES_RENDERER_SUPPORT
include( H3DCommonFunctions )
set( hapi_library_suffix "" )
if( MSVC )
  getMSVCPostFix( hapi_library_suffix )
  set( hapi_name "HAPI${hapi_library_suffix}" )
else()
  set( hapi_name hapi )
endif()

include( H3DExternalSearchPath )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES HAPI_LIBRARY_DEBUG HAPI_OpenHapticsRenderer_LIBRARY_DEBUG HAPI_Chai3DRenderer_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES HAPI_DEBUG_LIBRARY
                                              DOC_STRINGS "Path to ${hapi_name}_d library."
                                                          "Path to OpenHapticsRenderer${hapi_library_suffix}_d library."
                                                          "Path to Chai3DRenderer${hapi_library_suffix}_d library." )

getSearchPathsH3DLibs( module_include_search_paths module_lib_search_paths ${CMAKE_CURRENT_LIST_DIR} HAPI )

# Look for the header file.
find_path( HAPI_INCLUDE_DIR NAMES HAPI/HAPI.h HAPI/HAPI.cmake
                            PATHS ${module_include_search_paths}
                            DOC "Path in which the file HAPI/HAPI.h is located." )
mark_as_advanced( HAPI_INCLUDE_DIR )

find_library( HAPI_LIBRARY_RELEASE NAMES ${hapi_name}
                           PATHS ${module_lib_search_paths}
                           DOC "Path to ${hapi_name} library." )

find_library( HAPI_LIBRARY_DEBUG NAMES ${hapi_name}_d
              PATHS ${module_lib_search_paths}
                    DOC "Path to ${hapi_name}_d library." )
mark_as_advanced( HAPI_LIBRARY_RELEASE HAPI_LIBRARY_DEBUG )

include( SelectLibraryConfigurations )
select_library_configurations( HAPI )

set( hapi_required_renderers_found YES )
set( hapi_renderers_include_dir )
set( hapi_renderers_libraries )
set( hapi_openhaptics_support NO )
set( hapi_chai3d_support NO )
set( renderer_vars_to_check )
set( hapi_release_lib_vars HAPI_LIBRARY_RELEASE )
set( hapi_debug_lib_vars HAPI_LIBRARY_DEBUG )

if( HAPI_LIBRARY AND HAPI_INCLUDE_DIR )
  foreach( hapi_include_dir_tmp ${HAPI_INCLUDE_DIR} )
    message( STATUS "${hapi_include_dir_tmp}")
    if( EXISTS ${hapi_include_dir_tmp}/HAPI/HAPI.h )
      set( regex_to_find "#define HAVE_OPENHAPTICS" )
      file( STRINGS ${hapi_include_dir_tmp}/HAPI/HAPI.h list_of_defines REGEX ${regex_to_find} )
      list( LENGTH list_of_defines list_of_defines_length )
      if( list_of_defines_length )
        set( hapi_openhaptics_support YES )
      endif()
    
      set( regex_to_find "#define HAVE_CHAI3D" )
      file( STRINGS ${hapi_include_dir_tmp}/HAPI/HAPI.h list_of_defines REGEX ${regex_to_find} )
      list( LENGTH list_of_defines list_of_defines_length )
      if( list_of_defines_length )
        set( hapi_chai3d_support YES )
      endif()
    endif()
  endforeach()

  if( HAPI_DECIDES_RENDERER_SUPPORT )
    message( AUTHOR_WARNING "The setting HAPI_DECIDES_RENDERER_SUPPORT is deprecated. Use the COMPONENTS feature of find_package instead." )
  endif()

  if( HAPI_REQUIRED_RENDERERS )
    message( AUTHOR_WARNING "The setting HAPI_REQUIRED_RENDERERS is deprecated. Use the COMPONENTS feature of find_package instead." )
  endif()

  set( hapi_renderers_to_use )
  if( HAPI_FIND_COMPONENTS )
    foreach( renderer ${HAPI_FIND_COMPONENTS} )
      if( "${renderer}" STREQUAL "SameAsHAPI" )
        if( hapi_openhaptics_support )
          set( hapi_renderers_to_use "OpenHapticsRenderer" )
        endif()
        if( hapi_chai3d_support )
          set( hapi_renderers_to_use ${hapi_renderers_to_use} "Chai3DRenderer" )
        endif()
        break()
      endif()
      set( hapi_renderers_to_use ${hapi_renderers_to_use} "${renderer}" )
    endforeach()
  else()
    if( HAPI_DECIDES_RENDERER_SUPPORT )
      if( hapi_openhaptics_support )
        set( hapi_renderers_to_use "OpenHapticsRenderer" )
      endif()
      if( hapi_chai3d_support )
        set( hapi_renderers_to_use ${hapi_renderers_to_use} "Chai3DRenderer" )
      endif()
    elseif( HAPI_REQUIRED_RENDERERS )
      set( hapi_renderers_to_use ${HAPI_REQUIRED_RENDERERS} )
    endif()
  endif()

  foreach( renderer_name ${hapi_renderers_to_use} )
    if( ( ${renderer_name} STREQUAL "OpenHapticsRenderer" ) AND NOT hapi_openhaptics_support )
      set( hapi_compiled_with_support_message "The found version of HAPI is not compiled with support for OpenHapticsRenderer" )
      if( HAPI_FIND_REQUIRED )
        message( FATAL_ERROR "${hapi_compiled_with_support_message}" )
      elseif( NOT HAPI_FIND_QUIETLY )
        message( STATUS "${hapi_compiled_with_support_message}" )
      endif()
    endif()
    
    
    if( ( ${renderer_name} STREQUAL "Chai3DRenderer" ) AND NOT hapi_chai3d_support )
      set( hapi_compiled_with_support_message "The found version of HAPI is not compiled with support for Chai3DRenderer" )
      if( HAPI_FIND_REQUIRED )
        message( FATAL_ERROR "${hapi_compiled_with_support_message}" )
      elseif( NOT HAPI_FIND_QUIETLY )
        message( STATUS "${hapi_compiled_with_support_message}" )
      endif()
    endif()
    
    getSearchPathsH3DLibs( module_include_search_paths module_lib_search_paths ${CMAKE_CURRENT_LIST_DIR} HAPI/${renderer_name} )
    find_path( HAPI_${renderer_name}_INCLUDE_DIR NAMES HAPI/${renderer_name}.h 
                                                 PATHS ${module_include_search_paths}
                                                 DOC "Path in which the file HAPI/${renderer_name}.h is located." )
    mark_as_advanced( HAPI_${renderer_name}_INCLUDE_DIR )

    if( WIN32 )
      find_library( HAPI_${renderer_name}_LIBRARY_RELEASE NAMES ${renderer_name}${hapi_library_suffix}
                                                          PATHS ${module_lib_search_paths}
                                                          DOC "Path to ${renderer_name}${hapi_library_suffix} library." )

      find_library( HAPI_${renderer_name}_LIBRARY_DEBUG NAMES ${renderer_name}${hapi_library_suffix}_d
                                                        PATHS ${module_lib_search_paths}
                                                        DOC "Path to ${renderer_name}${hapi_library_suffix}_d library." )
      mark_as_advanced( HAPI_${renderer_name}_LIBRARY_RELEASE HAPI_${renderer_name}_LIBRARY_DEBUG )
    endif()
    
    select_library_configurations( HAPI_${renderer_name} )
    set( renderer_vars_to_check ${renderer_vars_to_check} HAPI_${renderer_name}_INCLUDE_DIR HAPI_${renderer_name}_LIBRARY )
    set( hapi_renderers_include_dir ${hapi_renderers_include_dir} HAPI_${renderer_name}_INCLUDE_DIR )
    set( hapi_renderers_libraries ${hapi_renderers_libraries} ${HAPI_${renderer_name}_LIBRARY} )
    set( hapi_release_lib_vars ${hapi_release_lib_vars} HAPI_${renderer_name}_LIBRARY_RELEASE )
    set( hapi_debug_lib_vars ${hapi_debug_lib_vars} HAPI_${renderer_name}_LIBRARY_DEBUG )
    
    string( REGEX REPLACE "Renderer" "" renderer_name_stripped ${renderer_name} )
    # OpenHapticsRenderer or Chai3DRenderer library is found. Check for OpenHaptics/Chai3D on the system. It must exist for the library
    # using HAPI since it is assumed that the library using HAPI will include OpenHapticsRenderer.h/Chai3DRenderer.h.
    find_package( ${renderer_name_stripped} )
    set( renderer_vars_to_check ${renderer_vars_to_check} ${renderer_name_stripped}_FOUND )
    set( hapi_renderers_include_dir ${hapi_renderers_include_dir} ${${renderer_name_stripped}_INCLUDE_DIRS} )
    set( hapi_renderers_libraries ${hapi_renderers_libraries} ${${renderer_name_stripped}_LIBRARIES} )
  endforeach()
endif()

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set HAPI_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( HAPI DEFAULT_MSG
                                   HAPI_INCLUDE_DIR HAPI_LIBRARY ${renderer_vars_to_check} )

set( HAPI_LIBRARIES ${HAPI_LIBRARY} ${hapi_renderers_libraries} )
set( HAPI_INCLUDE_DIRS ${HAPI_INCLUDE_DIR} ${hapi_renderers_include_dir} )

# Backwards compatibility values set here.
set( HAPI_INCLUDE_DIR ${HAPI_INCLUDE_DIRS} )

# Additional message on MSVC
if( HAPI_FOUND AND MSVC )
  foreach( hapi_var ${hapi_release_lib_vars} )
    if( NOT ${hapi_var} )
      message( WARNING "HAPI release library not found. Release build might not work properly. To get rid of this warning set ${hapi_var}." )
    endif()
  endforeach()
  foreach( hapi_var ${hapi_debug_lib_vars} )
    if( NOT ${hapi_var} )
      message( WARNING "HAPI debug library not found. Debug build might not work properly. To get rid of this warning set ${hapi_var}." )
    endif()
  endforeach()
endif()