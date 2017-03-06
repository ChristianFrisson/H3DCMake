# - Find H3DPhysics
# Find the native H3DPhysics headers and libraries.
#
#  H3DPhysics_INCLUDE_DIR -  where to find H3DPhysics.h, etc.
#  H3DPhysics_LIBRARIES    - List of libraries when using H3DPhysics.
#  H3DPhysics_FOUND        - True if H3DPhysics found.

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

# Look for the header file.
find_path( H3DPhysics_INCLUDE_DIR NAMES H3D/H3DPhysics/H3DPhysics.h H3D/H3DPhysics/H3DPhysics.cmake
           PATHS $ENV{H3D_ROOT}/../H3DPhysics/include
                 ../../../H3DPhysics/include
                 ${module_file_path}/../../../H3DPhysics/include )
mark_as_advanced( H3DPhysics_INCLUDE_DIR )

# Look for the library.
if( MSVC )
  set( H3D_MSVC_VERSION 6 )
  set( temp_msvc_version 1299 )
  while( ${MSVC_VERSION} GREATER ${temp_msvc_version} )
    math( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
    math( EXPR temp_msvc_version "${temp_msvc_version} + 100" )
  endwhile()
  set( H3DPhysics_NAME "H3DPhysics_vc${H3D_MSVC_VERSION}" )
elseif( UNIX )
  set( H3DPhysics_NAME h3dphysics )
else()
  set( H3DPhysics_NAME H3DPhysics )
endif()

set( default_lib_install "lib" )
if( WIN32 )
  set( default_lib_install "lib32" )
  if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    set( default_lib_install "lib64" )
  endif()
endif()

find_library( H3DPhysics_LIBRARY NAMES ${H3DPhysics_NAME}
              PATHS $ENV{H3D_ROOT}/../H3DPhysics/${default_lib_install}
                    ../../../${default_lib_install}
                    $ENV{H3D_ROOT}/../${default_lib_install} )

find_library( H3DPhysics_DEBUG_LIBRARY NAMES ${H3DPhysics_NAME}_d
              PATHS $ENV{H3D_ROOT}/../H3DPhysics/${default_lib_install}
                    ../../../${default_lib_install}
                    $ENV{H3D_ROOT}/../${default_lib_install} )
mark_as_advanced( H3DPhysics_LIBRARY )
mark_as_advanced( H3DPhysics_DEBUG_LIBRARY )

if( H3DPhysics_LIBRARY OR H3DPhysics_DEBUG_LIBRARY )
  set( HAVE_H3DPhysics_LIBRARY 1 )
else()
  set( HAVE_H3DPhysics_LIBRARY 0 )
endif()

# Copy the results to the output variables.
if( H3DPhysics_INCLUDE_DIR AND HAVE_H3DPhysics_LIBRARY )

  set( H3DPhysics_FOUND 1 )
  if( H3DPhysics_LIBRARY )
    set( H3DPhysics_LIBRARIES ${H3DPhysics_LIBRARIES} optimized ${H3DPhysics_LIBRARY} )
  else()
    set( H3DPhysics_LIBRARIES ${H3DPhysics_LIBRARIES} optimized ${H3DPhysics_NAME} )
    message( STATUS "H3DPhysics release libraries not found. Release build might not work." )
  endif()

  if( H3DPhysics_DEBUG_LIBRARY )
    set( H3DPhysics_LIBRARIES ${H3DPhysics_LIBRARIES} debug ${H3DPhysics_DEBUG_LIBRARY} )
  else()
    set( H3DPhysics_LIBRARIES ${H3DPhysics_LIBRARIES} debug ${H3DPhysics_NAME}_d )
    message( STATUS "H3DPhysics debug libraries not found. Debug build might not work." )
  endif()

  set( H3DPhysics_INCLUDE_DIR ${H3DPhysics_INCLUDE_DIR} )
  set( H3DPhysics_LIBRARIES ${H3DPhysics_LIBRARIES} )
else()
  set( H3DPhysics_FOUND 0 )
  set( H3DPhysics_LIBRARIES )
  set( H3DPhysics_INCLUDE_DIR )
endif()

# Report the results.
if( NOT H3DPhysics_FOUND )
  set( H3DPhysics_DIR_MESSAGE
       "H3DPhysics was not found. Make sure H3DPhysics_LIBRARY ( and/or H3DPhysics_DEBUG_LIBRARY ) and H3DPhysics_INCLUDE_DIR are set." )
  if( H3DPhysics_FIND_REQUIRED )
    message( FATAL_ERROR "${H3DPhysics_DIR_MESSAGE}" )
  elseif( NOT H3DPhysics_FIND_QUIETLY )
    message( STATUS "${H3DPhysics_DIR_MESSAGE}" )
  endif()
endif()
