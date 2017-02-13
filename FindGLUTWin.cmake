# - Find GLUT on windows
#
#  GLUT_INCLUDE_DIR -  where to find GLUT headers
#  GLUT_LIBRARIES    - List of libraries when using GLUT.
#  GLUT_FOUND        - True if GLUT found.

if( WIN32 )
  set( GLUT_FIND_QUIETLY 1 )
  find_package(GLUT)
endif()

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )

# Look for the header file.
find_path( GLUT_INCLUDE_DIR NAMES GL/glut.h
           PATHS ${module_include_search_paths}
           DOC "Path in which the file GL/glut.h is located." )
mark_as_advanced( GLUT_INCLUDE_DIR )

set( GLUT_LIBRARY_NAMES freeglut glut32 )
if( WIN32 AND PREFER_FREEGLUT_STATIC_LIBRARIES )
set( GLUT_LIBRARY_NAMES freeglut_static )
endif()

# Look for the library.
find_library( GLUT_LIBRARY NAMES  ${GLUT_LIBRARY_NAMES}
              PATHS ${module_lib_search_paths}
              DOC "Path to glut32 library." )
mark_as_advanced( GLUT_LIBRARY )

# Copy the results to the output variables.
if( GLUT_INCLUDE_DIR AND GLUT_LIBRARY )
  set( GLUT_FOUND 1 )
  if( WIN32 AND PREFER_FREEGLUT_STATIC_LIBRARIES )
    set( FREEGLUT_STATIC 1 )
  endif()
  set( GLUT_LIBRARIES ${GLUT_LIBRARY} )
  set( GLUT_INCLUDE_DIR ${GLUT_INCLUDE_DIR} )
else()
  set( GLUT_FOUND 0 )
  set( GLUT_LIBRARIES )
  set( GLUT_INCLUDE_DIR )
endif()

# Report the results.
if( NOT GLUT_FOUND )
  set( GLUT_DIR_MESSAGE
       "GLUT was not found. Make sure GLUT_LIBRARY and GLUT_INCLUDE_DIR are set to where you have your glut header and lib files." )
  if( GLUTWin_FIND_REQUIRED )
      message( FATAL_ERROR "${GLUT_DIR_MESSAGE}" )
  elseif( NOT GLUTWin_FIND_QUIETLY )
    message( STATUS "${GLUT_DIR_MESSAGE}" )
  endif()
endif()
