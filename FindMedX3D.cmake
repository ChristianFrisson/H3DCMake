# - Find MEDX3D
# Find the native MEDX3D headers and libraries.
#
#  MEDX3D_INCLUDE_DIR -  where to find MEDX3D.h, etc.
#  MEDX3D_LIBRARIES    - List of libraries when using MEDX3D.
#  MEDX3D_FOUND        - True if MEDX3D found.

get_filename_component(module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

# Look for the header file.
find_path(MEDX3D_INCLUDE_DIR NAMES H3D/MedX3D/MedX3D.h H3D/MedX3D/MedX3D.cmake
           PATHS $ENV{H3D_ROOT}/../MedX3D/include
                 ../../../../MedX3D/include
                 ${module_file_path}/../../../include
                 ${module_file_path}/../../include
                 ../../../MedX3D/include
                 ${module_file_path}/../../../MedX3D/include                 )

mark_as_advanced(MEDX3D_INCLUDE_DIR)

# Look for the library.
if( MSVC )
  set( H3D_MSVC_VERSION 6 )
  set( TEMP_MSVC_VERSION 1299 )
  while( ${MSVC_VERSION} GREATER ${TEMP_MSVC_VERSION} )
    math( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
    # Increments one more time if MSVC version is 13 as it doesn't exist
    if(${H3D_MSVC_VERSION} EQUAL 13)
      math( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
    endif(${H3D_MSVC_VERSION} EQUAL 13)
    math( EXPR TEMP_MSVC_VERSION "${TEMP_MSVC_VERSION} + 100" )
  endwhile( ${MSVC_VERSION} GREATER ${TEMP_MSVC_VERSION} )
  set( MEDX3D_NAME "MedX3D_vc${H3D_MSVC_VERSION}" )
elseif(UNIX)
  set( MEDX3D_NAME h3dmedx3d )
else()
  set( MEDX3D_NAME MedX3D )
endif( MSVC )

set( DEFAULT_LIB_INSTALL "lib" )
if( WIN32 )
  set( DEFAULT_LIB_INSTALL "lib32" )
  if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    set( DEFAULT_LIB_INSTALL "lib64" )
  endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )
endif( WIN32 )

find_library( MEDX3D_LIBRARY NAMES ${MEDX3D_NAME}
              PATHS $ENV{H3D_ROOT}/../${DEFAULT_LIB_INSTALL}
                    $ENV{H3D_ROOT}/../MedX3D/${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../../${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../../MedX3D/${DEFAULT_LIB_INSTALL} )

find_library( MEDX3D_DEBUG_LIBRARY NAMES ${MEDX3D_NAME}_d
              PATHS $ENV{H3D_ROOT}/../${DEFAULT_LIB_INSTALL}
                    $ENV{H3D_ROOT}/../MedX3D/${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../../${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../../MedX3D/${DEFAULT_LIB_INSTALL} )
mark_as_advanced(MEDX3D_LIBRARY)
mark_as_advanced(MEDX3D_DEBUG_LIBRARY)

if(MEDX3D_LIBRARY OR MEDX3D_DEBUG_LIBRARY)
  set( HAVE_MEDX3D_LIBRARY 1 )
else(MEDX3D_LIBRARY OR MEDX3D_DEBUG_LIBRARY)
  set( HAVE_MEDX3D_LIBRARY 0 )
endif(MEDX3D_LIBRARY OR MEDX3D_DEBUG_LIBRARY)

# Copy the results to the output variables.
if(MEDX3D_INCLUDE_DIR AND HAVE_MEDX3D_LIBRARY)
  set(MEDX3D_FOUND 1)
  if(MEDX3D_LIBRARY)
    set(MEDX3D_LIBRARIES ${MEDX3D_LIBRARIES} optimized ${MEDX3D_LIBRARY} )
  else(MEDX3D_LIBRARY)
    set(MEDX3D_LIBRARIES ${MEDX3D_LIBRARIES} optimized ${MEDX3D_NAME} )
    message( STATUS "MEDX3D release libraries not found. Release build might not work." )
  endif(MEDX3D_LIBRARY)

  if(MEDX3D_DEBUG_LIBRARY)
    set(MEDX3D_LIBRARIES ${MEDX3D_LIBRARIES} debug ${MEDX3D_DEBUG_LIBRARY} )
  else(MEDX3D_DEBUG_LIBRARY)
    set(MEDX3D_LIBRARIES ${MEDX3D_LIBRARIES} debug ${MEDX3D_NAME}_d )
    message( STATUS "MEDX3D debug libraries not found. Debug build might not work." )
  endif(MEDX3D_DEBUG_LIBRARY)

  set(MEDX3D_INCLUDE_DIRS ${MEDX3D_INCLUDE_DIR})
else(MEDX3D_INCLUDE_DIR AND HAVE_MEDX3D_LIBRARY)
  set(MEDX3D_FOUND 0)
  set(MEDX3D_LIBRARIES)
  set(MEDX3D_INCLUDE_DIRS)
endif(MEDX3D_INCLUDE_DIR AND HAVE_MEDX3D_LIBRARY)

# Report the results.
if(NOT MEDX3D_FOUND)
  set(MEDX3D_DIR_MESSAGE
    "MEDX3D was not found. Make sure MEDX3D_LIBRARY ( and/or MEDX3D_DEBUG_LIBRARY ) and MEDX3D_INCLUDE_DIR are set.")
  if(MedX3D_FIND_REQUIRED)
    message(FATAL_ERROR "${MEDX3D_DIR_MESSAGE}")
  elseif(NOT MedX3D_FIND_QUIETLY)
    message(STATUS "${MEDX3D_DIR_MESSAGE}")
  endif(MedX3D_FIND_REQUIRED)
endif(NOT MEDX3D_FOUND)
