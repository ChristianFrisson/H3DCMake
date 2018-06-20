# - Find 3dxware (www.3dconnexion.com)
#
#  3DXWARE_INCLUDE_DIRS - Where to find si.h, siapp.h for Windows and xdrvlib.h, Xlib.h, Xutil.h, Xos.h, Xatom.h and keysym.h for LINUX.
#  3DXWARE_LIBRARIES    - List of libraries when using 3dxware.
#  3DXWARE_FOUND        - True if 3dxware is found.

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "3dconnexion/inc" )

# Look for the header file.
find_path( 3DXWARE_INCLUDE_DIR NAMES si.h siapp.h H3D/xdrvlib.h X11/Xlib.h X11/Xutil.h X11/Xos.h X11/Xatom.h X11/keysym.h
           PATHS  /usr/local/include
                 ${module_include_search_paths}
           DOC "Path in which the files si.h, siapp.h, H3D/xdrvlib.h, X11/Xlib.h, X11/Xutil.h, X11/Xos.h, X11/Xatom.h and X11/keysym.h are located." )
mark_as_advanced( 3DXWARE_INCLUDE_DIR )

# Look for the library siapp.
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

if( COMMAND cmake_policy )
  # For some reason the CMake macro find_package_handle_standard_args seems to interpret
  # 3DXWARE_FIND_REQUIRED as something that should be affected by policy CMP0012
  # So that policy have to be set before including FindPackageHandleStandardArgs.
  if( POLICY CMP0012 )
    cmake_policy( SET CMP0012 NEW )
  endif()
endif()

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set 3DXWARE_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( 3DXWARE DEFAULT_MSG
                                   3DXWARE_SIAPP_LIBRARY 3DXWARE_SPWMATH_LIBRARY 3DXWARE_INCLUDE_DIR )

set( 3DXWARE_LIBRARIES ${3DXWARE_SIAPP_LIBRARY} ${3DXWARE_SPWMATH_LIBRARY} )
set( 3DXWARE_INCLUDE_DIRS ${3DXWARE_INCLUDE_DIR} )
