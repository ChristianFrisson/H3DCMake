# - Find UI
# Find the native UI headers and libraries.
#
#  UI_INCLUDE_DIR -  where to find UI.h, etc.
#  UI_LIBRARIES    - List of libraries when using UI.
#  UI_FOUND        - True if UI found.

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

# Look for the header file.
find_path( UI_INCLUDE_DIR NAMES H3D/UI/UI.h H3D/UI/UI.cmake
           PATHS $ENV{H3D_ROOT}/../UI/include
                 ../include
                 ${module_file_path}/../../include
                 ../../../UI/include
                 ${module_file_path}/../../../UI/include
           DOC "Path in which the file H3D/UI/UI.h is located." )
mark_as_advanced( UI_INCLUDE_DIR )

if( MSVC )
  set( H3D_MSVC_VERSION 6 )
  set( TEMP_MSVC_VERSION 1299 )
  while( ${MSVC_VERSION} GREATER ${TEMP_MSVC_VERSION} )
    math( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
    math( EXPR TEMP_MSVC_VERSION "${TEMP_MSVC_VERSION} + 100" )
  endwhile()
  set( UI_NAME "UI_vc${H3D_MSVC_VERSION}" )
elseif( UNIX )
  set( UI_NAME h3dui )
else()
  set( UI_NAME UI )
endif()

set( DEFAULT_LIB_INSTALL "lib" )
if( WIN32 )
  set( DEFAULT_LIB_INSTALL "lib32" )
  if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    set( DEFAULT_LIB_INSTALL "lib64" )
  endif()
endif()

# Look for the library.
find_library( UI_LIBRARY NAMES ${UI_NAME}
              PATHS $ENV{H3D_ROOT}/../UI/${DEFAULT_LIB_INSTALL}
                    ../../${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../../${DEFAULT_LIB_INSTALL}
                    ../../../${DEFAULT_LIB_INSTALL}
                    $ENV{H3D_ROOT}/../${DEFAULT_LIB_INSTALL}
              DOC "Path to ${UI_NAME} library." )

find_library( UI_DEBUG_LIBRARY NAMES ${UI_NAME}_d
              PATHS $ENV{H3D_ROOT}/../UI/${DEFAULT_LIB_INSTALL}
                    ../../${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../../${DEFAULT_LIB_INSTALL}
                    ../../../${DEFAULT_LIB_INSTALL}
                    $ENV{H3D_ROOT}/../${DEFAULT_LIB_INSTALL}
              DOC "Path to ${UI_NAME}_d library." )
mark_as_advanced( UI_LIBRARY )
mark_as_advanced( UI_DEBUG_LIBRARY )

if( UI_LIBRARY OR UI_DEBUG_LIBRARY )
  set( HAVE_UI_LIBRARY 1 )
else()
  set( HAVE_UI_LIBRARY 0 )
endif()

# Copy the results to the output variables.
if( UI_INCLUDE_DIR AND HAVE_UI_LIBRARY )

  set( UI_FOUND 1 )
  if( UI_LIBRARY )
    set( UI_LIBRARIES ${UI_LIBRARIES} optimized ${UI_LIBRARY} )
  else()
    set( UI_LIBRARIES ${UI_LIBRARIES} optimized ${UI_NAME} )
    message( STATUS "UI release libraries not found. Release build might not work." )
  endif()

  if( UI_DEBUG_LIBRARY )
    set( UI_LIBRARIES ${UI_LIBRARIES} debug ${UI_DEBUG_LIBRARY} )
  else()
    set( UI_LIBRARIES ${UI_LIBRARIES} debug ${UI_NAME}_d )
    message( STATUS "UI debug libraries not found. Debug build might not work." )
  endif()
  
  set( UI_INCLUDE_DIR ${UI_INCLUDE_DIR} )
  set( UI_LIBRARIES ${UI_LIBRARIES} )
else()
  set( UI_FOUND 0 )
  set( UI_LIBRARIES )
  set( UI_INCLUDE_DIR )
endif()

# Report the results.
if( NOT UI_FOUND )
  set( UI_DIR_MESSAGE
       "UI was not found. Make sure UI_LIBRARY ( and/or UI_DEBUG_LIBRARY ) and UI_INCLUDE_DIR are set." )
  if( UI_FIND_REQUIRED )
    message( FATAL_ERROR "${UI_DIR_MESSAGE}" )
  elseif( NOT UI_FIND_QUIETLY )
    message( STATUS "${UI_DIR_MESSAGE}" )
  endif()
endif()
