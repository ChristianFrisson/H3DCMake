# - Find HACD
# Find the native HACD headers and libraries.
#
#  HACD_INCLUDE_DIR -  where to find the include files of HACD
#  HACD_LIBRARIES    - List of libraries when using HACD.
#  HACD_FOUND        - True if HACD found.
#  HACD_FLAGS        - Flags needed for ode to build 

include( H3DExternalSearchPath )
GET_FILENAME_COMPONENT( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
get_external_search_paths_h3d( module_include_search_paths module_lib_search_paths ${module_file_path} "hacd" "static" )

IF( CMAKE_CL_64 )
  SET( LIB "64" )
ELSE( CMAKE_CL_64 )
  SET( LIB "32" )
ENDIF( CMAKE_CL_64 )

SET(HACD_INSTALL_DIR "" CACHE PATH "Path to external HACD installation" )

# Look for the header file.
FIND_PATH( HACD_INCLUDE_DIR NAMES hacdHACD.h
           PATHS /usr/local/include
                 ${HACD_INSTALL_DIR}/build/win${LIB}/output/include
                 ${module_include_search_paths} )

MARK_AS_ADVANCED(HACD_INCLUDE_DIR)

# Look for the library.
IF(WIN32)

  FIND_LIBRARY( HACD_LIB NAMES HACD_LIB
                PATHS ${HACD_INSTALL_DIR}/build/win${LIB}/output/bin
                      ${module_lib_search_paths} )

  FIND_LIBRARY( HACD_DEBUG_LIB NAMES HACD_LIB_DEBUG
                PATHS ${HACD_INSTALL_DIR}/build/win${LIB}/output/bin
                      ${module_lib_search_paths} )
   
   MARK_AS_ADVANCED(HACD_DEBUG_LIB)
                      
ELSE(WIN32)
  FIND_LIBRARY( HACD_LIB NAMES HACD_LIB )  
ENDIF(WIN32)

MARK_AS_ADVANCED(HACD_LIB)

# Copy the results to the output variables.
IF ( HACD_INCLUDE_DIR AND 
     HACD_LIB )
  SET(HACD_FOUND 1)
  
  IF( WIN32 )
    
    SET(HACD_LIBRARIES "" )
    
    IF( HACD_DEBUG_LIB )
      SET(HACD_LIBRARIES ${HACD_LIBRARIES} optimized ${HACD_LIB} debug ${HACD_DEBUG_LIB} )
    ELSE( HACD_DEBUG_LIB )
      SET(HACD_LIBRARIES ${HACD_LIB})
    ENDIF( HACD_DEBUG_LIB )
    
  ELSE( WIN32 )
    SET(HACD_LIBRARIES ${HACD_LIB})
  ENDIF( WIN32 )
  
  
  SET(HACD_INCLUDE_DIR ${HACD_INCLUDE_DIR} )
ELSE()
  SET(HACD_FOUND 0)
  SET(HACD_LIBRARIES)
  SET(HACD_INCLUDE_DIR)
ENDIF()

# Report the results.
IF(NOT HACD_FOUND)
  SET(HACD_DIR_MESSAGE
    "HACD was not found. Set HACD_INSTALL_DIR to the root directory of the "
    "installation containing the 'build' folders.")
  IF(HACD_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR "${HACD_DIR_MESSAGE}")
  ELSEIF(NOT HACD_FIND_QUIETLY)
    MESSAGE(STATUS "${HACD_DIR_MESSAGE}")
  ENDIF(HACD_FIND_REQUIRED)
ENDIF(NOT HACD_FOUND)
