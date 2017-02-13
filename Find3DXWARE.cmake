# - Find 3dxware (www.3dconnexion.com)
#
#  3DXWARE_INCLUDE_DIR -  where to find si.h, siapp.h for Windows and xdrvlib.h, Xlib.h, Xutil.h, Xos.h, Xatom.h and keysym.h for LINUX.
#  3DXWARE_LIBRARIES    - List of libraries when using 3dxware.
#  3DXWARE_FOUND        - True if 3dxware is found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "3dconnexion/inc" )

# Look for the header file.
find_path( 3DXWARE_INCLUDE_DIR NAMES si.h siapp.h H3D/xdrvlib.h X11/Xlib.h X11/Xutil.h X11/Xos.h X11/Xatom.h X11/keysym.h
           PATHS  /usr/local/include 
                 ${module_include_search_paths}
           DOC "Path in which the files si.h, siapp.h, H3D/xdrvlib.h, X11/Xlib.h, X11/Xutil.h, X11/Xos.h, X11/Xatom.h and X11/keysym.h are located." )
mark_as_advanced( 3DXWARE_INCLUDE_DIR )

# Look for the library siapp.
# TODO: Does this work on UNIX systems? (LINUX) I strongly doubt it. What are the libraries to find on linux?
find_library( 3DXWARE_SIAPP_LIBRARY NAMES siapp
              PATHS ${module_lib_search_paths}
              DOC "Path to siapp library." )
mark_as_advanced( 3DXWARE_SIAPP_LIBRARY )

# Look for the library spwmath.
# Does this work on UNIX systems? (LINUX)
find_library( 3DXWARE_SPWMATH_LIBRARY NAMES spwmath
              PATHS ${module_lib_search_paths}
              DOC "Path to spwmath library." )
mark_as_advanced( 3DXWARE_SPWMATH_LIBRARY )

# Copy the results to the output variables.
if( 3DXWARE_INCLUDE_DIR AND 3DXWARE_SIAPP_LIBRARY AND 3DXWARE_SPWMATH_LIBRARY )
  set( 3DXWARE_FOUND 1 )
  set( 3DXWARE_LIBRARIES ${3DXWARE_SIAPP_LIBRARY} ${3DXWARE_SPWMATH_LIBRARY} )
  set( 3DXWARE_INCLUDE_DIR ${3DXWARE_INCLUDE_DIR} )
else()
  set( 3DXWARE_FOUND 0 )
  set( 3DXWARE_LIBRARIES )
  set( 3DXWARE_INCLUDE_DIR )
endif()

# Report the results.
if( NOT 3DXWARE_FOUND )
  set( 3DXWARE_DIR_MESSAGE
       "3dxware (www.3dconnexion) was not found. Make sure 3DXWARE_SIAPP_LIBRARY, 3DXWARE_SPWMATH_LIBRARY and 3DXWARE_INCLUDE_DIR are set." )
  if( 3DXWARE_FIND_REQUIRED )
    message( FATAL_ERROR "${3DXWARE_DIR_MESSAGE}" )
  elseif( NOT ${3DXWARE_FIND_QUIETLY} )
    message( STATUS "${3DXWARE_DIR_MESSAGE}" )
  endif()
endif()

