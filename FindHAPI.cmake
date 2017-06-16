# - Find HAPI
# Find the native HAPI headers and libraries.
# Output:
#  HAPI_INCLUDE_DIRS - Where to find HAPI.h, etc.
#  HAPI_LIBRARIES    - List of libraries when using HAPI.
#  HAPI_FOUND        - True if HAPI found.
#
# If the COMPONENTS feature of HAPI is not set then it is assumed that
# the caller does not intend to use any of the supported components in the
# library/executable code (i.e does not intend to explicitly or implicitly include any headers
# or link against those libraries.)
# Valid values for the COMPONENTS argument are:
# SameComponentsAsInstalledLibrary - Will require all enabled features of the installed
#   library to be found. Enabled features can be found by searching for HAVE_<Feature> in the
#   installed header.
# OpenHaptics - Support for devices interfacing through OpenHaptics as well as enabling OpenHapticsRenderer surface haptics rendering.
# Chai3D - Support for Chai3DRenderer surface haptics rendering.
# EntactAPI - Support for devices using Entact api.
# DHD - Support for devices from ForceDimension.
# VirtuoseAPI - Support for devices usign virtuose api.
# FalconAPI - Support for the falcon haptics device (on windows).
# NiFalconAPI - Support for the falcon haptics device using the open source library nifalconapi.
# fparser - Support for some specific force effects that can be defined by a function.
# Haptik - Support for devices interfacing through the haptik library.
# SimballMedical - Support for devices using the simball medical api.
# MLHI - Support for devices from MLHI.
# OpenGL - Support for some extra OpenGL features such as using FeedbackBufferCollector to create haptic surfaces.
#
# If the COMPONENTS feature of HAPI is not set then it is assumed that
# the caller does not intend to use any of the supported components in the
# library/executable code (i.e does not intend to include any headers
# or link against those libraries.)
# Required components will always be:
# H3DUtil
#
# The allowed values for the COMPONENTS feature of HAPI are considered optional components:
# SameComponentsAsInstalledLibrary - Will require all enabled features of the installed
#   library to be found. Enabled features can be found by searching for HAVE_<Feature> in the
#   installed header. This flag will be used as COMPONENTS to all H3D libraries that this library
#   depend on.
# OpenHaptics - Used to add support for haptics devices and haptics rendering using OpenHaptics.
# Chai3D - Used to add support for haptics devices and haptics rendering using Chai3d.
# EntactAPI - Used to add support for haptics devices using EntactAPI.
# DHD - Used to add support for haptics devices using DHD and DRD api.
# VirtuoseAPI - Used to add support for haptics devices using VirtuoseAPI.
# FalconAPI - Used to add support for Falcon haptics device.
# NiFalconAPI - Used to add support for haptics devices using open source drivers for Falcon haptics device.
# fparser - Used to add support for some special haptics surfaces which can be defined by a function.
# Haptik - Used to add support for haptics devices supported by the Haptik library.
# SimballMedical - Used to add support for some semi haptics devices.
# MLHI - Used to add support for some haptics devices.
# OpenGL - Used to add support for some opengl features of HAPI used for example
#          to automatically collect haptic triangles.
# OpenHapticsRenderer - Deprecated, use OpenHaptics component instead.
# Chai3DRenderer - Deprecated, use Chai3D component instead. Chai3d header/libraries must exist on the system.
# 
# The following features are deprecated and the COMPONENTS feature of find_package should be used instead.
# HAPI_REQUIRED_RENDERERS
# HAPI_DECIDES_RENDERER_SUPPORT
include( H3DUtilityFunctions )
set( hapi_library_suffix "" )
if( MSVC )
  getMSVCPostFix( hapi_library_suffix )
  set( hapi_name "HAPI${hapi_library_suffix}" )
else()
  set( hapi_name hapi )
endif()

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES HAPI_LIBRARY_DEBUG HAPI_OpenHapticsRenderer_LIBRARY_DEBUG HAPI_Chai3DRenderer_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES HAPI_DEBUG_LIBRARY HAPI_OpenHapticsRenderer_DEBUG_LIBRARY HAPI_Chai3DRenderer_DEBUG_LIBRARY
                                              DOC_STRINGS "Path to ${hapi_name}_d library."
                                                          "Path to OpenHapticsRenderer${hapi_library_suffix}_d library."
                                                          "Path to Chai3DRenderer${hapi_library_suffix}_d library." )

include( H3DCommonFindModuleFunctions )
getSearchPathsH3DLibs( module_include_search_paths module_lib_search_paths ${CMAKE_CURRENT_LIST_DIR} HAPI )

# Look for the header file.
find_path( HAPI_INCLUDE_DIR NAMES HAPI/HAPI.h
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

if( HAPI_DECIDES_RENDERER_SUPPORT )
  message( AUTHOR_WARNING "The setting HAPI_DECIDES_RENDERER_SUPPORT is deprecated. Use the COMPONENTS feature of find_package instead." )
endif()

if( HAPI_REQUIRED_RENDERERS )
  message( AUTHOR_WARNING "The setting HAPI_REQUIRED_RENDERERS is deprecated. Use the COMPONENTS feature of find_package instead." )
endif()

set( hapi_release_lib_vars HAPI_LIBRARY_RELEASE )
set( hapi_debug_lib_vars HAPI_LIBRARY_DEBUG )

if( HAPI_INCLUDE_DIR )
  set( components_to_search_for )
  foreach( component ${HAPI_FIND_COMPONENTS} )
    if( "${component}" STREQUAL "OpenHapticsRenderer" )
      message( AUTHOR_WARNING "The component OpenHapticsRenderer is deprecated. Use the OpenHaptics component instead." )
      list( APPEND components_to_search_for OpenHaptics )
    elseif( "${component}" STREQUAL "Chai3DRenderer" )
      message( AUTHOR_WARNING "The component Chai3DRenderer is deprecated. Use the Chai3D component instead." )
      list( APPEND components_to_search_for Chai3D )
    else()
      list( APPEND components_to_search_for ${component} )
    endif()
  endforeach()
  handleComponentsForLib( HAPI
                          MODULE_HEADER_DIRS ${HAPI_INCLUDE_DIR}
                          MODULE_HEADER_SUFFIX /HAPI/HAPI.h
                          DESIRED ${components_to_search_for}
                          REQUIRED H3DUtil
                          OPTIONAL         OpenHaptics      Chai3D      EntactAPI      DHD         VirtuoseAPI      FalconAPI      NiFalconAPI       fparser      Haptik              SimballMedical          MLHI      OpenGL
                          OPTIONAL_DEFINES HAVE_OPENHAPTICS HAVE_CHAI3D HAVE_ENTACTAPI HAVE_DHDAPI HAVE_VIRTUOSEAPI HAVE_FALCONAPI HAVE_NIFALCONAPI  HAVE_FPARSER HAVE_HAPTIK_LIBRARY HAVE_SIMBALLMEDICAL_API HAVE_MLHI HAVE_OPENGL
                          OUTPUT extra_vars_to_check component_libraries component_include_dirs
                          H3D_MODULES H3DUtil )

  set( hapi_renderers_to_use )
  
  # Check if OpenHaptics was desired, in that case add OpenHapticsRenderer to be searched for.
  list( FIND extra_vars_to_check OpenHaptics_FOUND location )
  if( OpenHaptics_FOUND AND NOT ( ${location} EQUAL -1 ) )
    # Find 
    set( hapi_renderers_to_use OpenHapticsRenderer )
  endif()
  
  # Check if Chai3D was desired, in that case add OpenHapticsRenderer to be searched for.
  list( FIND extra_vars_to_check Chai3D_FOUND location )
  if( Chai3D_FOUND AND NOT ( ${location} EQUAL -1 ) )
    # Find 
    set( hapi_renderers_to_use ${hapi_renderers_to_use} Chai3DRenderer )
  endif()
  
  foreach( renderer_name ${hapi_renderers_to_use} )
    getSearchPathsH3DLibs( module_include_search_paths module_lib_search_paths ${CMAKE_CURRENT_LIST_DIR} HAPI/${renderer_name} )
    find_path( HAPI_${renderer_name}_INCLUDE_DIR NAMES HAPI/${renderer_name}.h 
                                                 PATHS ${HAPI_INCLUDE_DIR}/../${renderer_name}/include
                                                       ${module_include_search_paths}
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
    set( extra_vars_to_check ${extra_vars_to_check} HAPI_${renderer_name}_INCLUDE_DIR HAPI_${renderer_name}_LIBRARY )
    set( component_include_dirs ${component_include_dirs} ${HAPI_${renderer_name}_INCLUDE_DIR} )
    set( component_libraries ${component_libraries} ${HAPI_${renderer_name}_LIBRARY} )
    set( hapi_release_lib_vars ${hapi_release_lib_vars} HAPI_${renderer_name}_LIBRARY_RELEASE )
    set( hapi_debug_lib_vars ${hapi_debug_lib_vars} HAPI_${renderer_name}_LIBRARY_DEBUG )
  endforeach()
endif()


include( SelectLibraryConfigurations )
select_library_configurations( HAPI )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set HAPI_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( HAPI DEFAULT_MSG
                                   HAPI_INCLUDE_DIR HAPI_LIBRARY ${extra_vars_to_check} )

set( HAPI_LIBRARIES ${HAPI_LIBRARY} ${component_libraries} )
set( HAPI_INCLUDE_DIRS ${HAPI_INCLUDE_DIR} ${component_include_dirs} )
list( REMOVE_DUPLICATES HAPI_INCLUDE_DIRS )

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
