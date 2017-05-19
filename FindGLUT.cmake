# - Find GLUT on windows
#
#  GLUT_INCLUDE_DIR  - Where to find GLUT headers
#  GLUT_LIBRARIES    - List of libraries when using GLUT.
#  GLUT_FOUND        - True if GLUT found.

include( H3DCommonFindModuleFunctions )

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )

# Look for the header file.
find_path( GLUT_INCLUDE_DIR NAMES GL/glut.h
           PATHS ${module_include_search_paths}
           DOC "Path to directory in which the file GL/glut.h is located."
           NO_SYSTEM_ENVIRONMENT_PATH )
mark_as_advanced( GLUT_INCLUDE_DIR )

set( glut_library_names freeglut glut32 )
if( WIN32 AND PREFER_FREEGLUT_STATIC_LIBRARIES )
  set( glut_library_names freeglut_static )
endif()

# Look for the library.
find_library( GLUT_LIBRARY NAMES ${glut_library_names}
              PATHS ${module_lib_search_paths}
              DOC "Path to glut32 library."
              NO_SYSTEM_ENVIRONMENT_PATH )
mark_as_advanced( GLUT_LIBRARY )

checkIfModuleFound( GLUT
                    REQUIRED_VARS GLUT_INCLUDE_DIR GLUT_LIBRARY )

set( GLUT_LIBRARIES ${GLUT_LIBRARY} )

if( NOT GLUT_FOUND )
  checkCMakeInternalModule( GLUT )  # Will call CMakes internal find module for this feature.
endif()

if( GLUT_FOUND AND WIN32 AND PREFER_FREEGLUT_STATIC_LIBRARIES )
  set( FREEGLUT_STATIC 1 ) # cmake_define do not change name.
endif()