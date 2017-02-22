# - Find GLUT on windows
#
#  GLUT_INCLUDE_DIR  - Where to find GLUT headers
#  GLUT_LIBRARIES    - List of libraries when using GLUT.
#  GLUT_FOUND        - True if GLUT found.

include( H3DExternalSearchPath )
checkCMakeInternalModule( GLUT ) # Will call CMakes internal find module for this feature.
if( ( DEFINED GLUT_FOUND ) AND GLUT_FOUND )
  return()
endif()

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )

# Look for the header file.
find_path( GLUT_INCLUDE_DIR NAMES GL/glut.h
           PATHS ${module_include_search_paths}
           DOC "Path to directory in which the file GL/glut.h is located." )
mark_as_advanced( GLUT_INCLUDE_DIR )

set( GLUT_LIBRARY_NAMES freeglut glut32 )
if( WIN32 AND PREFER_FREEGLUT_STATIC_LIBRARIES )
  set( GLUT_LIBRARY_NAMES freeglut_static )
endif()

# Look for the library.
find_library( GLUT_LIBRARY NAMES ${GLUT_LIBRARY_NAMES}
              PATHS ${module_lib_search_paths}
              DOC "Path to glut32 library." )
mark_as_advanced( GLUT_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set GLUT_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( GLUT DEFAULT_MSG
                                   GLUT_LIBRARY GLUT_INCLUDE_DIR )

set( GLUT_LIBRARIES ${GLUT_LIBRARY} )

if( GLUT_FOUND AND WIN32 AND PREFER_FREEGLUT_STATIC_LIBRARIES )
  set( FREEGLUT_STATIC 1 )
endif()