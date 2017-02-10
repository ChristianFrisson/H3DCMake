# - Find GLEW
# Find the native GLEW headers and libraries.
#
#  GLEW_INCLUDE_DIR -  where to find GLEW.h, etc.
#  GLEW_LIBRARIES    - List of libraries when using GLEW.
#  GLEW_FOUND        - True if GLEW found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )

if( CMAKE_CL_64 )
  set( LIB "lib64" )
else( CMAKE_CL_64 )
  set( LIB "lib32" )
endif( CMAKE_CL_64 )

# Look for the header file.
find_path(GLEW_INCLUDE_DIR NAMES GL/glew.h
                           PATHS ${module_include_search_paths}
                                 ../../../support/H3D/External/include
                                 ${module_file_path}/../../../../support/H3D/External/include
                           DOC "Path in which the file GL/glew.h is located." )
mark_as_advanced(GLEW_INCLUDE_DIR)

# Look for the library.
find_library(GLEW_LIBRARY NAMES GLEW glew32
                                PATHS ${module_lib_search_paths}
                                      ../../../support/H3D/External/${LIB}
                                      ${module_file_path}/../../../../support/H3D/External/${LIB}
                                DOC "Path to glew32 library." )
mark_as_advanced(GLEW_LIBRARY)

if( WIN32 AND PREFER_STATIC_LIBRARIES )
  set( module_include_search_paths "")
  set( module_lib_search_paths "")
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )
  find_library( GLEW_STATIC_LIBRARY NAMES glew32s
                                         PATHS ${module_lib_search_paths}
                                         ../../../support/H3D/External/${LIB}/static
                                         ${module_file_path}/../../../../support/H3D/External/${LIB}/static
                                    DOC "Path to glew32 static library." )
  mark_as_advanced(GLEW_STATIC_LIBRARY)
endif( WIN32 AND PREFER_STATIC_LIBRARIES )

if( GLEW_LIBRARY OR GLEW_STATIC_LIBRARY )
  set( GLEW_LIBRARIES_FOUND 1 )
endif( GLEW_LIBRARY OR GLEW_STATIC_LIBRARY )

# Copy the results to the output variables.
if(GLEW_INCLUDE_DIR AND GLEW_LIBRARIES_FOUND)
  set(GLEW_FOUND 1)
  if( WIN32 AND PREFER_STATIC_LIBRARIES AND GLEW_STATIC_LIBRARY )
    set(GLEW_LIBRARIES ${GLEW_STATIC_LIBRARY})
    set( GLEW_STATIC 1 )
  else( WIN32 AND PREFER_STATIC_LIBRARIES AND GLEW_STATIC_LIBRARY )
    set(GLEW_LIBRARIES ${GLEW_LIBRARY})
  endif( WIN32 AND PREFER_STATIC_LIBRARIES AND GLEW_STATIC_LIBRARY )
  set(GLEW_INCLUDE_DIR ${GLEW_INCLUDE_DIR})
  set(GLEW_INCLUDE_DIRS ${GLEW_INCLUDE_DIR})
else(GLEW_INCLUDE_DIR AND GLEW_LIBRARIES_FOUND)
  set(GLEW_FOUND 0)
  set(GLEW_LIBRARIES)
  set(GLEW_INCLUDE_DIR)
endif(GLEW_INCLUDE_DIR AND GLEW_LIBRARIES_FOUND)

# Report the results.
if(NOT GLEW_FOUND)
  set(GLEW_DIR_MESSAGE
    "GLEW was not found. Make sure GLEW_LIBRARY and GLEW_INCLUDE_DIR are set to where you have your glew header and lib files. If you do not have the library you will not be able to use nodes that use OpenGL extensions.")
  if(GLEW_FIND_REQUIRED)
      message(FATAL_ERROR "${GLEW_DIR_MESSAGE}")
  elseif(NOT GLEW_FIND_QUIETLY)
    message(STATUS "${GLEW_DIR_MESSAGE}")
  endif(GLEW_FIND_REQUIRED)
endif(NOT GLEW_FOUND)
