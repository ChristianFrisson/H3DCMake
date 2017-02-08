# - Find H3DAPI
# Find the native H3DAPI headers and libraries.
#
#  H3DAPI_INCLUDE_DIR -  where to find H3DAPI.h, etc.
#  H3DAPI_LIBRARIES    - List of libraries when using H3DAPI.
#  H3DAPI_FOUND        - True if H3DAPI found.

GET_FILENAME_COMPONENT(module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

# Look for the header file.
FIND_PATH( H3DAPI_INCLUDE_DIR NAMES H3D/H3DApi.h H3D/H3DApi.cmake
           PATHS $ENV{H3D_ROOT}/include
                 ../include
                 ${module_file_path}/../../include
                 ${module_file_path}/../../../H3DAPI/include
                 ../../include
                 ${module_file_path}/../../../include
                 ../../../support/H3D/H3DAPI/include
                 ${module_file_path}/../../../../support/H3D/H3DAPI/include
           DOC "Path in which the file H3D/H3DAPI.h is located." )
MARK_AS_ADVANCED(H3DAPI_INCLUDE_DIR)

IF( MSVC )
  SET( H3D_MSVC_VERSION 6 )
  SET( TEMP_MSVC_VERSION 1299 )
  WHILE( ${MSVC_VERSION} GREATER ${TEMP_MSVC_VERSION} )
    MATH( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
    # Increments one more time if MSVC version is 13 as it doesn't exist
    IF(${H3D_MSVC_VERSION} EQUAL 13)
      MATH( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
    ENDIF(${H3D_MSVC_VERSION} EQUAL 13)
    MATH( EXPR TEMP_MSVC_VERSION "${TEMP_MSVC_VERSION} + 100" )
  ENDWHILE( ${MSVC_VERSION} GREATER ${TEMP_MSVC_VERSION} )
  SET( H3DAPI_NAME "H3DAPI_vc${H3D_MSVC_VERSION}" )
ELSE(MSVC)
  SET( H3DAPI_NAME h3dapi )
ENDIF( MSVC )

SET( DEFAULT_LIB_INSTALL "lib" )
IF( WIN32 )
  SET( DEFAULT_LIB_INSTALL "lib32" )
  IF( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    SET( DEFAULT_LIB_INSTALL "lib64" )
  ENDIF( CMAKE_SIZEOF_VOID_P EQUAL 8 )
ENDIF( WIN32 )

# Look for the library.
FIND_LIBRARY( H3DAPI_LIBRARY NAMES ${H3DAPI_NAME}
              PATHS $ENV{H3D_ROOT}/../${DEFAULT_LIB_INSTALL}
                    ../../${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../../${DEFAULT_LIB_INSTALL}
                    $ENV{H3D_ROOT}/../../../${DEFAULT_LIB_INSTALL}
                    $ENV{H3D_ROOT}/../../${DEFAULT_LIB_INSTALL}
                    ../../../support/H3D/${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../../../support/H3D/${DEFAULT_LIB_INSTALL}
                    ../../../${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../../../${DEFAULT_LIB_INSTALL}
              DOC "Path to ${H3DAPI_NAME} library." )

FIND_LIBRARY( H3DAPI_DEBUG_LIBRARY NAMES ${H3DAPI_NAME}_d
              PATHS $ENV{H3D_ROOT}/../${DEFAULT_LIB_INSTALL}
                    ../../${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../../${DEFAULT_LIB_INSTALL}
                    $ENV{H3D_ROOT}/../../../${DEFAULT_LIB_INSTALL}
                    $ENV{H3D_ROOT}/../../${DEFAULT_LIB_INSTALL}
                    ../../../support/H3D/${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../../../support/H3D/${DEFAULT_LIB_INSTALL}
                    ../../../${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../../../${DEFAULT_LIB_INSTALL}
              DOC "Path to ${H3DAPI_NAME}_d library." )
MARK_AS_ADVANCED(H3DAPI_LIBRARY)
MARK_AS_ADVANCED(H3DAPI_DEBUG_LIBRARY)

IF(H3DAPI_LIBRARY OR H3DAPI_DEBUG_LIBRARY)
  SET( HAVE_H3DAPI_LIBRARY 1 )
ELSE(H3DAPI_LIBRARY OR H3DAPI_DEBUG_LIBRARY)
  SET( HAVE_H3DAPI_LIBRARY 0 )
ENDIF(H3DAPI_LIBRARY OR H3DAPI_DEBUG_LIBRARY)

# Copy the results to the output variables.
IF(H3DAPI_INCLUDE_DIR AND HAVE_H3DAPI_LIBRARY)
  
  # OpenGL is required for using the H3DAPI library.
  FIND_PACKAGE(OpenGL REQUIRED)
  IF(OPENGL_FOUND)
    SET( H3DAPI_INCLUDE_DIR ${H3DAPI_INCLUDE_DIR} ${OPENGL_INCLUDE_DIR} )
    SET( H3DAPI_LIBRARIES ${OPENGL_LIBRARIES} )
  ENDIF(OPENGL_FOUND)
  
  # Glew is required for using the H3DAPI library
  # On windows this will also find opengl header includes.
  FIND_PACKAGE(GLEW REQUIRED)
  IF(GLEW_FOUND)
    SET( H3DAPI_INCLUDE_DIR ${H3DAPI_INCLUDE_DIR} ${GLEW_INCLUDE_DIR} )
    SET( H3DAPI_LIBRARIES ${H3DAPI_LIBRARIES} ${GLEW_LIBRARIES} )
  ENDIF(GLEW_FOUND)

  SET(H3DAPI_FOUND 1)
  IF(H3DAPI_LIBRARY)
    SET(H3DAPI_LIBRARIES ${H3DAPI_LIBRARIES} optimized ${H3DAPI_LIBRARY} )
  ELSE(H3DAPI_LIBRARY)
    SET(H3DAPI_LIBRARIES ${H3DAPI_LIBRARIES} optimized ${H3DAPI_NAME} )
    MESSAGE( STATUS "H3DAPI release libraries not found. Release build might not work." )
  ENDIF(H3DAPI_LIBRARY)

  IF(H3DAPI_DEBUG_LIBRARY)
    SET(H3DAPI_LIBRARIES ${H3DAPI_LIBRARIES} debug ${H3DAPI_DEBUG_LIBRARY} )
  ELSE(H3DAPI_DEBUG_LIBRARY)
    SET(H3DAPI_LIBRARIES ${H3DAPI_LIBRARIES} debug ${H3DAPI_NAME}_d )
    MESSAGE( STATUS "H3DAPI debug libraries not found. Debug build might not work." )
  ENDIF(H3DAPI_DEBUG_LIBRARY)
  
  SET(H3DAPI_INCLUDE_DIR ${H3DAPI_INCLUDE_DIR} )
  SET(H3DAPI_LIBRARIES ${H3DAPI_LIBRARIES} )
ELSE(H3DAPI_INCLUDE_DIR AND HAVE_H3DAPI_LIBRARY)
  SET(H3DAPI_FOUND 0)
  SET(H3DAPI_LIBRARIES)
  SET(H3DAPI_INCLUDE_DIR)
ENDIF(H3DAPI_INCLUDE_DIR AND HAVE_H3DAPI_LIBRARY)

# Report the results.
IF(NOT H3DAPI_FOUND)
  SET(H3DAPI_DIR_MESSAGE
    "H3DAPI was not found. Make sure H3DAPI_LIBRARY ( and/or H3DAPI_DEBUG_LIBRARY ) and H3DAPI_INCLUDE_DIR are set.")
  IF(H3DAPI_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR "${H3DAPI_DIR_MESSAGE}")
  ELSEIF(NOT H3DAPI_FIND_QUIETLY)
    MESSAGE(STATUS "${H3DAPI_DIR_MESSAGE}")
  ENDIF(H3DAPI_FIND_REQUIRED)
ENDIF(NOT H3DAPI_FOUND)