# - Find UI
# Find the native UI headers and libraries.
#
#  UI_INCLUDE_DIR -  where to find UI.h, etc.
#  UI_LIBRARIES    - List of libraries when using UI.
#  UI_FOUND        - True if UI found.

GET_FILENAME_COMPONENT(module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

# Look for the header file.
FIND_PATH( UI_INCLUDE_DIR NAMES H3D/UI/UI.h H3D/UI/UI.cmake
           PATHS $ENV{H3D_ROOT}/../UI/include
                 ../include
                 ${module_file_path}/../../include
                 ../../../UI/include
                 ${module_file_path}/../../../UI/include
           DOC "Path in which the file H3D/UI/UI.h is located." )
MARK_AS_ADVANCED(UI_INCLUDE_DIR)

IF( MSVC )
  SET( H3D_MSVC_VERSION 6 )
  SET( TEMP_MSVC_VERSION 1299 )
  WHILE( ${MSVC_VERSION} GREATER ${TEMP_MSVC_VERSION} )
    MATH( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
    MATH( EXPR TEMP_MSVC_VERSION "${TEMP_MSVC_VERSION} + 100" )
  ENDWHILE( ${MSVC_VERSION} GREATER ${TEMP_MSVC_VERSION} )
  SET( UI_NAME "UI_vc${H3D_MSVC_VERSION}" )
ELSEIF(UNIX)
  SET( UI_NAME h3dui )
ELSE()
  SET( UI_NAME UI )
ENDIF( MSVC )

SET( DEFAULT_LIB_INSTALL "lib" )
IF( WIN32 )
  SET( DEFAULT_LIB_INSTALL "lib32" )
  IF( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    SET( DEFAULT_LIB_INSTALL "lib64" )
  ENDIF( CMAKE_SIZEOF_VOID_P EQUAL 8 )
ENDIF( WIN32 )

# Look for the library.
FIND_LIBRARY( UI_LIBRARY NAMES ${UI_NAME}
              PATHS $ENV{H3D_ROOT}/../UI/${DEFAULT_LIB_INSTALL}
                    ../../${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../../${DEFAULT_LIB_INSTALL}
                    ../../../${DEFAULT_LIB_INSTALL}
                    $ENV{H3D_ROOT}/../${DEFAULT_LIB_INSTALL}
              DOC "Path to ${UI_NAME} library." )

FIND_LIBRARY( UI_DEBUG_LIBRARY NAMES ${UI_NAME}_d
              PATHS $ENV{H3D_ROOT}/../UI/${DEFAULT_LIB_INSTALL}
                    ../../${DEFAULT_LIB_INSTALL}
                    ${module_file_path}/../../../${DEFAULT_LIB_INSTALL}
                    ../../../${DEFAULT_LIB_INSTALL}
                    $ENV{H3D_ROOT}/../${DEFAULT_LIB_INSTALL}
              DOC "Path to ${UI_NAME}_d library." )
MARK_AS_ADVANCED(UI_LIBRARY)
MARK_AS_ADVANCED(UI_DEBUG_LIBRARY)

IF(UI_LIBRARY OR UI_DEBUG_LIBRARY)
  SET( HAVE_UI_LIBRARY 1 )
ELSE(UI_LIBRARY OR UI_DEBUG_LIBRARY)
  SET( HAVE_UI_LIBRARY 0 )
ENDIF(UI_LIBRARY OR UI_DEBUG_LIBRARY)

# Copy the results to the output variables.
IF(UI_INCLUDE_DIR AND HAVE_UI_LIBRARY)

  SET(UI_FOUND 1)
  IF(UI_LIBRARY)
    SET(UI_LIBRARIES ${UI_LIBRARIES} optimized ${UI_LIBRARY} )
  ELSE(UI_LIBRARY)
    SET(UI_LIBRARIES ${UI_LIBRARIES} optimized ${UI_NAME} )
    MESSAGE( STATUS "UI release libraries not found. Release build might not work." )
  ENDIF(UI_LIBRARY)

  IF(UI_DEBUG_LIBRARY)
    SET(UI_LIBRARIES ${UI_LIBRARIES} debug ${UI_DEBUG_LIBRARY} )
  ELSE(UI_DEBUG_LIBRARY)
    SET(UI_LIBRARIES ${UI_LIBRARIES} debug ${UI_NAME}_d )
    MESSAGE( STATUS "UI debug libraries not found. Debug build might not work." )
  ENDIF(UI_DEBUG_LIBRARY)
  
  SET(UI_INCLUDE_DIR ${UI_INCLUDE_DIR} )
  SET(UI_LIBRARIES ${UI_LIBRARIES} )
ELSE(UI_INCLUDE_DIR AND HAVE_UI_LIBRARY)
  SET(UI_FOUND 0)
  SET(UI_LIBRARIES)
  SET(UI_INCLUDE_DIR)
ENDIF(UI_INCLUDE_DIR AND HAVE_UI_LIBRARY)

# Report the results.
IF(NOT UI_FOUND)
  SET(UI_DIR_MESSAGE
    "UI was not found. Make sure UI_LIBRARY ( and/or UI_DEBUG_LIBRARY ) and UI_INCLUDE_DIR are set.")
  IF(UI_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR "${UI_DIR_MESSAGE}")
  ELSEIF(NOT UI_FIND_QUIETLY)
    MESSAGE(STATUS "${UI_DIR_MESSAGE}")
  ENDIF(UI_FIND_REQUIRED)
ENDIF(NOT UI_FOUND)