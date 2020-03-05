# - Find H3DAPI
# Find the native H3DAPI headers and libraries.
#
#  H3DAPI_INCLUDE_DIRS - Where to find H3DAPI.h, etc.
#  H3DAPI_LIBRARIES    - List of libraries when using H3DAPI.
#  H3DAPI_FOUND        - True if H3DAPI found.
#
# If the COMPONENTS feature of H3DAPI is not set then it is assumed that
# the caller does not intend to use any of the supported components in the
# library/executable code (i.e does not intend to explicitly or implicitly include any headers
# or link against those libraries.)
# The allowed values for the COMPONENTS feature of H3DAPI are considered optional components:
# SameComponentsAsInstalledLibrary - Will require all enabled features of the installed
#   library to be found. Enabled features can be found by searching for HAVE_<Feature> in the
#   installed header. This flag will be used as COMPONENTS to all H3D libraries that this library
#   depend on.
# XercesC - Used to parse x3d files.
# OpenAL - Used to support sound rendering.
# Vorbis - Used to support sound rendering.
# Audiofile - Used to support sound rendering.
# NvidiaCG - Used to support Nvidia CG toolkit.
# LibOVR - Used to support occulus rift features.
# FTGL - Used to support Text rendering.
# Freetype - Used to support Text rendering.
# 3DXWARE - Used to support Spaceware input devices.
# PythonLibs - Used to enable PythonScript nodes.
# CURL - Used to resolve some urls.
# SpiderMonkey - Used to enable Ecmascript support.
# DirectShow - Used for some video textures.
# SixenseSDK - Used to support razer hydra trackers.
# FFmpeg - Used for video textures.
# VirtualHand - Used to support some haptic hand devices.
# GLUT - Used for graphics rendering.
# OpenEXR - Used to handle .exr files.
include( H3DUtilityFunctions )
if( MSVC )
  getMSVCPostFix( msvc_postfix )
  set( h3dapi_name "H3DAPI${msvc_postfix}" )
else()
  set( h3dapi_name h3dapi )
endif()

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES H3DAPI_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES H3DAPI_DEBUG_LIBRARY
                                              DOC_STRINGS "Path to ${h3dapi_name}_d library." )

include( H3DCommonFindModuleFunctions )
getSearchPathsH3DLibs( module_include_search_paths module_lib_search_paths ${CMAKE_CURRENT_LIST_DIR} H3DAPI )

# Look for the header file.
find_path( H3DAPI_INCLUDE_DIR NAMES H3D/H3DApi.h
                              PATHS ${module_include_search_paths}
                              DOC "Path in which the file H3D/H3DAPI.h is located." )
mark_as_advanced( H3DAPI_INCLUDE_DIR )

# Look for the library.
find_library( H3DAPI_LIBRARY_RELEASE NAMES ${h3dapi_name}
                                     PATHS ${module_lib_search_paths}
                                     DOC "Path to ${h3dapi_name} library." )

find_library( H3DAPI_LIBRARY_DEBUG NAMES ${h3dapi_name}_d
                                   PATHS ${module_lib_search_paths}
                                   DOC "Path to ${h3dapi_name}_d library." )
mark_as_advanced( H3DAPI_LIBRARY_RELEASE H3DAPI_LIBRARY_DEBUG )

if( H3DAPI_INCLUDE_DIR )
  handleComponentsForLib( H3DAPI
                          MODULE_HEADER_DIRS ${H3DAPI_INCLUDE_DIR}
                          MODULE_HEADER_SUFFIX /H3D/H3DApi.h
                          DESIRED ${H3DAPI_FIND_COMPONENTS}
                          REQUIRED HAPI OpenGL GLEW
                          OPTIONAL         XercesC OpenAL Vorbis Audiofile NvidiaCG LibOVR FTGL Freetype 3DXWARE PythonLibs CURL
                                           SpiderMonkey DirectShow SixenseSDK FFmpeg VirtualHand GLUT OpenEXR
                          OPTIONAL_DEFINES HAVE_XERCES HAVE_OPENAL HAVE_LIBVORBIS HAVE_LIBAUDIOFILE HAVE_LIBOVR HAVE_FTGL HAVE_FREETYPE HAVE_3DXWARE HAVE_PYTHON HAVE_LIBCURL
                                           HAVE_SPIDERMONKEY HAVE_DSHOW HAVE_SIXENSE HAVE_FFMPEG HAVE_VIRTUAL_HAND_SDK HAVE_GLUT HAVE_OPENEXR
                          OUTPUT found_vars component_libraries component_include_dirs
                          H3D_MODULES HAPI )
endif()

include( SelectLibraryConfigurations )
select_library_configurations( H3DAPI )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set H3DAPI_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( H3DAPI DEFAULT_MSG
                                   H3DAPI_INCLUDE_DIR H3DAPI_LIBRARY ${found_vars} )

set( H3DAPI_LIBRARIES ${H3DAPI_LIBRARY} ${component_libraries} )
set( H3DAPI_INCLUDE_DIRS ${H3DAPI_INCLUDE_DIR} ${component_include_dirs} )
list( REMOVE_DUPLICATES H3DAPI_INCLUDE_DIRS )

# Backwards compatibility values set here.
set( H3DAPI_INCLUDE_DIR ${H3DAPI_INCLUDE_DIRS} )

# Additional message on MSVC
if( H3DAPI_FOUND AND MSVC )
  if( NOT H3DAPI_LIBRARY_RELEASE )
    message( WARNING "H3DAPI release library not found. Release build might not work properly. To get rid of this warning set H3DAPI_LIBRARY_RELEASE." )
  endif()
  if( NOT H3DAPI_LIBRARY_DEBUG )
    message( WARNING "H3DAPI debug library not found. Debug build might not work properly. To get rid of this warning set H3DAPI_LIBRARY_DEBUG." )
  endif()
endif()
