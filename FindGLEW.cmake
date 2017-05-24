# - Find GLEW
# Find the native GLEW headers and libraries.
#
#  GLEW_INCLUDE_DIRS - Where to find GLEW.h, etc.
#  GLEW_LIBRARIES    - List of libraries when using GLEW.
#  GLEW_FOUND        - True if GLEW found.

include( H3DCommonFindModuleFunctions )

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )

if( CMAKE_CL_64 )
  set( lib "lib64" )
else()
  set( lib "lib32" )
endif()

# Look for the header file.
find_path( GLEW_INCLUDE_DIR NAMES GL/glew.h
                            PATHS ${module_include_search_paths}
                                  ../../../support/H3D/External/include
                                  ${module_file_path}/../../../../support/H3D/External/include
                            DOC "Path in which the file GL/glew.h is located. Needed to support OpenGL extensions."
                            NO_SYSTEM_ENVIRONMENT_PATH )
mark_as_advanced( GLEW_INCLUDE_DIR )

# Look for the library.
find_library( GLEW_LIBRARY NAMES GLEW glew32
                                 PATHS ${module_lib_search_paths}
                                       ../../../support/H3D/External/${lib}
                                       ${module_file_path}/../../../../support/H3D/External/${lib}
                                 DOC "Path to glew32 library. Needed to support OpenGL extensions."
                                 NO_SYSTEM_ENVIRONMENT_PATH )
mark_as_advanced( GLEW_LIBRARY )

if( WIN32 AND H3D_PREFER_STATIC_LIBRARIES )
  set( module_include_search_paths "" )
  set( module_lib_search_paths "" )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )
  find_library( GLEW_STATIC_LIBRARY NAMES glew32s
                                    PATHS ${module_lib_search_paths}
                                          ../../../support/H3D/External/${lib}/static
                                          ${module_file_path}/../../../../support/H3D/External/${lib}/static
                                    DOC "Path to glew32 static library. Needed to support OpenGL extensions."
                                    NO_SYSTEM_ENVIRONMENT_PATH )
  mark_as_advanced( GLEW_STATIC_LIBRARY )
endif()

set( glew_static_libraries_found )
if( WIN32 AND H3D_PREFER_STATIC_LIBRARIES )
  checkIfModuleFound( GLEW
                      REQUIRED_VARS GLEW_INCLUDE_DIR GLEW_STATIC_LIBRARY )
  set( GLEW_LIBRARIES ${GLEW_STATIC_LIBRARY} )
  set( glew_static_libraries_found ${GLEW_FOUND} )
endif()

if( NOT glew_static_libraries_found )
  checkIfModuleFound( GLEW
                      REQUIRED_VARS GLEW_INCLUDE_DIR GLEW_LIBRARY )
  set( GLEW_LIBRARIES ${GLEW_LIBRARY} )
endif()

set( GLEW_INCLUDE_DIRS ${GLEW_INCLUDE_DIR} )

if( NOT GLEW_FOUND )
  checkCMakeInternalModule( GLEW REQUIRED_CMAKE_VERSION "2.8.10" ) # Will call CMakes internal find module for this feature.
endif()
