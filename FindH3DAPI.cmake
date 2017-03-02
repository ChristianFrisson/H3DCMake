# - Find H3DAPI
# Find the native H3DAPI headers and libraries.
#
#  H3DAPI_INCLUDE_DIR -  where to find H3DAPI.h, etc.
#  H3DAPI_LIBRARIES    - List of libraries when using H3DAPI.
#  H3DAPI_FOUND        - True if H3DAPI found.

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

# Look for the header file.
find_path( H3DAPI_INCLUDE_DIR NAMES H3D/H3DApi.h H3D/H3DApi.cmake
           PATHS $ENV{H3D_ROOT}/include
                 ../include
                 ${module_file_path}/../../include
                 ${module_file_path}/../../../H3DAPI/include
                 ../../include
                 ${module_file_path}/../../../include
                 ../../../support/H3D/H3DAPI/include
                 ${module_file_path}/../../../../support/H3D/H3DAPI/include
           DOC "Path in which the file H3D/H3DAPI.h is located." )
mark_as_advanced( H3DAPI_INCLUDE_DIR )

if( MSVC )
  set( H3D_MSVC_VERSION 6 )
  set( TEMP_MSVC_VERSION 1299 )
  while( ${MSVC_VERSION} GREATER ${TEMP_MSVC_VERSION} )
    math( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
    # Increments one more time if MSVC version is 13 as it doesn't exist
    if( ${H3D_MSVC_VERSION} EQUAL 13 )
      math( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
    endif()
    math( EXPR TEMP_MSVC_VERSION "${TEMP_MSVC_VERSION} + 100" )
  endwhile()
  set( H3DAPI_NAME "H3DAPI_vc${H3D_MSVC_VERSION}" )
else()
  set( H3DAPI_NAME h3dapi )
endif()

set( DEFAULT_LIB_INSTALL "lib" )
if( WIN32 )
  set( DEFAULT_LIB_INSTALL "lib32" )
  if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    set( DEFAULT_LIB_INSTALL "lib64" )
  endif()
endif()

# Look for the library.
find_library( H3DAPI_LIBRARY NAMES ${H3DAPI_NAME}
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

find_library( H3DAPI_DEBUG_LIBRARY NAMES ${H3DAPI_NAME}_d
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
mark_as_advanced( H3DAPI_LIBRARY )
mark_as_advanced( H3DAPI_DEBUG_LIBRARY )

if( H3DAPI_LIBRARY OR H3DAPI_DEBUG_LIBRARY )
  set( HAVE_H3DAPI_LIBRARY 1 )
else()
  set( HAVE_H3DAPI_LIBRARY 0 )
endif()

# Copy the results to the output variables.
if( H3DAPI_INCLUDE_DIR AND HAVE_H3DAPI_LIBRARY )
  
  # OpenGL is required for using the H3DAPI library.
  find_package( OpenGL REQUIRED )
  if( OPENGL_FOUND )
    set( H3DAPI_INCLUDE_DIR ${H3DAPI_INCLUDE_DIR} ${OPENGL_INCLUDE_DIR} )
    set( H3DAPI_LIBRARIES ${OPENGL_LIBRARIES} )
  endif()
  
  # Glew is required for using the H3DAPI library
  # On windows this will also find opengl header includes.
  find_package( GLEW REQUIRED )
  if( GLEW_FOUND )
    set( H3DAPI_INCLUDE_DIR ${H3DAPI_INCLUDE_DIR} ${GLEW_INCLUDE_DIR} )
    set( H3DAPI_LIBRARIES ${H3DAPI_LIBRARIES} ${GLEW_LIBRARIES} )
  endif()

  set( H3DAPI_FOUND 1 )
  if( H3DAPI_LIBRARY )
    set( H3DAPI_LIBRARIES ${H3DAPI_LIBRARIES} optimized ${H3DAPI_LIBRARY} )
  else()
    set( H3DAPI_LIBRARIES ${H3DAPI_LIBRARIES} optimized ${H3DAPI_NAME} )
    message( STATUS "H3DAPI release libraries not found. Release build might not work." )
  endif()

  if( H3DAPI_DEBUG_LIBRARY )
    set( H3DAPI_LIBRARIES ${H3DAPI_LIBRARIES} debug ${H3DAPI_DEBUG_LIBRARY} )
  else()
    set( H3DAPI_LIBRARIES ${H3DAPI_LIBRARIES} debug ${H3DAPI_NAME}_d )
    message( STATUS "H3DAPI debug libraries not found. Debug build might not work." )
  endif()
  
  set( H3DAPI_INCLUDE_DIR ${H3DAPI_INCLUDE_DIR} )
  set( H3DAPI_LIBRARIES ${H3DAPI_LIBRARIES} )
else()
  set( H3DAPI_FOUND 0 )
  set( H3DAPI_LIBRARIES )
  set( H3DAPI_INCLUDE_DIR )
endif()

# Report the results.
if( NOT H3DAPI_FOUND )
  set( H3DAPI_DIR_MESSAGE
       "H3DAPI was not found. Make sure H3DAPI_LIBRARY ( and/or H3DAPI_DEBUG_LIBRARY ) and H3DAPI_INCLUDE_DIR are set." )
  if( H3DAPI_FIND_REQUIRED )
    message( FATAL_ERROR "${H3DAPI_DIR_MESSAGE}" )
  elseif( NOT H3DAPI_FIND_QUIETLY )
    message( STATUS "${H3DAPI_DIR_MESSAGE}" )
  endif()
endif()
