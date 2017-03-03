# - Find GeoSpatial
# Find the native GeoSpatial headers and libraries.
#
#  GeoSpatial_INCLUDE_DIR -  where to find GeoSpatial.h, etc.
#  GeoSpatial_LIBRARIES    - List of libraries when using GeoSpatial.
#  GeoSpatial_FOUND        - True if GeoSpatial found.

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

# Look for the header file.
find_path( GeoSpatial_INCLUDE_DIR NAMES H3D/GeoSpatial/GeoSpatial.h
           PATHS $ENV{H3D_ROOT}/../GeoSpatial/include
                 ../../../GeoSpatial/include
                 ${module_file_path}/../../../GeoSpatial/include )
mark_as_advanced( GeoSpatial_INCLUDE_DIR )

# Look for the library.
if( MSVC )
  set( H3D_MSVC_VERSION 6 )
  set( TEMP_MSVC_VERSION 1299 )
  while( ${MSVC_VERSION} GREATER ${TEMP_MSVC_VERSION} )
    math( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
    math( EXPR TEMP_MSVC_VERSION "${TEMP_MSVC_VERSION} + 100" )
  endwhile()
  set( GeoSpatial_NAME "GeoSpatial_vc${H3D_MSVC_VERSION}" )
elseif( UNIX )
  set( GeoSpatial_NAME geospatial )
else()
  set( GeoSpatial_NAME GeoSpatial )
endif()

set( DEFAULT_LIB_INSTALL "lib" )
if( WIN32 )
  set( DEFAULT_LIB_INSTALL "lib32" )
  if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    set( DEFAULT_LIB_INSTALL "lib64" )
  endif()
endif()

find_library( GeoSpatial_LIBRARY NAMES ${GeoSpatial_NAME}
              PATHS $ENV{H3D_ROOT}/../GeoSpatial/${DEFAULT_LIB_INSTALL}
                    ../../../${DEFAULT_LIB_INSTALL} )

find_library( GeoSpatial_DEBUG_LIBRARY NAMES ${GeoSpatial_NAME}_d
              PATHS $ENV{H3D_ROOT}/../GeoSpatial/${DEFAULT_LIB_INSTALL}
                    ../../../${DEFAULT_LIB_INSTALL} )
mark_as_advanced( GeoSpatial_LIBRARY )
mark_as_advanced( GeoSpatial_DEBUG_LIBRARY )

if( GeoSpatial_LIBRARY OR GeoSpatial_DEBUG_LIBRARY )
  set( HAVE_GeoSpatial_LIBRARY 1 )
else( GeoSpatial_LIBRARY OR GeoSpatial_DEBUG_LIBRARY )
  set( HAVE_GeoSpatial_LIBRARY 0 )
endif()

# Copy the results to the output variables.
if( GeoSpatial_INCLUDE_DIR AND HAVE_GeoSpatial_LIBRARY )

  set( GeoSpatial_FOUND 1 )
  if( GeoSpatial_LIBRARY )
    set( GeoSpatial_LIBRARIES ${GeoSpatial_LIBRARIES} optimized ${GeoSpatial_LIBRARY} )
  else( GeoSpatial_LIBRARY )
    set( GeoSpatial_LIBRARIES ${GeoSpatial_LIBRARIES} optimized ${GeoSpatial_NAME} )
    message( STATUS "GeoSpatial release libraries not found. Release build might not work." )
  endif()

  if( GeoSpatial_DEBUG_LIBRARY )
    set( GeoSpatial_LIBRARIES ${GeoSpatial_LIBRARIES} debug ${GeoSpatial_DEBUG_LIBRARY} )
  else( GeoSpatial_DEBUG_LIBRARY )
    set( GeoSpatial_LIBRARIES ${GeoSpatial_LIBRARIES} debug ${GeoSpatial_NAME}_d )
    message( STATUS "GeoSpatial debug libraries not found. Debug build might not work." )
  endif()

  set( GeoSpatial_INCLUDE_DIR ${GeoSpatial_INCLUDE_DIR} )
  set( GeoSpatial_LIBRARIES ${GeoSpatial_LIBRARIES} )
else( GeoSpatial_INCLUDE_DIR AND HAVE_GeoSpatial_LIBRARY )
  set( GeoSpatial_FOUND 0 )
  set( GeoSpatial_LIBRARIES )
  set( GeoSpatial_INCLUDE_DIR )
endif()

# Report the results.
if( NOT GeoSpatial_FOUND )
  set( GeoSpatial_DIR_MESSAGE
    "GeoSpatial was not found. Make sure GeoSpatial_LIBRARY ( and/or GeoSpatial_DEBUG_LIBRARY ) and GeoSpatial_INCLUDE_DIR are set." )
  if( GeoSpatial_FIND_REQUIRED )
    message( FATAL_ERROR "${GeoSpatial_DIR_MESSAGE}" )
  elseif( NOT GeoSpatial_FIND_QUIETLY )
    message( STATUS "${GeoSpatial_DIR_MESSAGE}" )
  endif()
endif()
