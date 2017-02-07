# - Find LIBOVR
# Find the native LIBOVR headers and libraries.
#
#  LIBOVR_INCLUDE_DIR -  where to find OVR_CAPI_GL.h, etc.
#  LIBOVR_LIBRARIES    - List of libraries when using LIBOVR.
#  LIBOVR_FOUND        - True if LIBOVR found.

include( H3DExternalSearchPath )
GET_FILENAME_COMPONENT( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
get_external_search_paths_h3d( module_include_search_paths module_lib_search_paths ${module_file_path} "LibOVR" "static" )

# Look for the header file.
FIND_PATH(LIBOVR_INCLUDE_DIR NAMES OVR_CAPI_GL.h
                                PATHS ${module_include_search_paths}
                                DOC "Path in which the file OVR_CAPI_GL.h is located." )
							
MARK_AS_ADVANCED(LIBOVR_INCLUDE_DIR)

# Look for the library.
FIND_LIBRARY(LIBOVR_LIBRARY NAMES libovr
                               PATHS ${module_lib_search_paths}
                               DOC "Path to LibOVR library." )
MARK_AS_ADVANCED(LIBOVR_LIBRARY)

# Copy the results to the output variables.
IF(LIBOVR_INCLUDE_DIR AND LIBOVR_LIBRARY)
  SET(LIBOVR_FOUND 1)
  SET(LIBOVR_LIBRARIES ${LIBOVR_LIBRARY})
  SET(LIBOVR_INCLUDE_DIR ${LIBOVR_INCLUDE_DIR})
ELSE()
  SET(LIBOVR_FOUND 0)
  SET(LIBOVR_LIBRARIES)
  SET(LIBOVR_INCLUDE_DIR)
ENDIF()

# Report the results.
IF(NOT LIBOVR_FOUND)
  SET( LIBOVR_DIR_MESSAGE
       "LibOVR was not found. Make sure LIBOVR_LIBRARY and LIBOVR_INCLUDE_DIR are set.")
  IF(LIBOVR_FIND_REQUIRED)
    SET( LIBOVR_DIR_MESSAGE
         "${LIBOVR_DIR_MESSAGE} LibOVR is required to build.")
    MESSAGE(FATAL_ERROR "${LIBOVR_DIR_MESSAGE}")
  ELSEIF(NOT LIBOVR_FIND_QUIETLY)
    SET( LIBOVR_DIR_MESSAGE
         "${LIBOVR_DIR_MESSAGE} If you do not have it the OCULUS_RIFT stereo mode will not be supported.")
    MESSAGE(STATUS "${LIBOVR_DIR_MESSAGE}")
  ENDIF(LIBOVR_FIND_REQUIRED)
ENDIF(NOT LIBOVR_FOUND)
