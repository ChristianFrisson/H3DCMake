# - Find LIBOVR
# Find the native LIBOVR headers and libraries.
#
#  LIBOVR_INCLUDE_DIR -  where to find OVR_CAPI_GL.h, etc.
#  LIBOVR_LIBRARIES    - List of libraries when using LIBOVR.
#  LIBOVR_FOUND        - True if LIBOVR found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "LibOVR" "static" )

# Look for the header file.
find_path( LIBOVR_INCLUDE_DIR NAMES OVR_CAPI_GL.h
                              PATHS ${module_include_search_paths}
                              DOC "Path in which the file OVR_CAPI_GL.h is located." )

mark_as_advanced( LIBOVR_INCLUDE_DIR )

# Look for the library.
find_library( LIBOVR_LIBRARY NAMES libovr
                             PATHS ${module_lib_search_paths}
                             DOC "Path to LibOVR library." )
mark_as_advanced( LIBOVR_LIBRARY )

# Copy the results to the output variables.
if( LIBOVR_INCLUDE_DIR AND LIBOVR_LIBRARY )
  set( LIBOVR_FOUND 1 )
  set( LIBOVR_LIBRARIES ${LIBOVR_LIBRARY} )
  set( LIBOVR_INCLUDE_DIR ${LIBOVR_INCLUDE_DIR} )
else()
  set( LIBOVR_FOUND 0 )
  set( LIBOVR_LIBRARIES )
  set( LIBOVR_INCLUDE_DIR )
endif()

# Report the results.
if( NOT LIBOVR_FOUND )
  set( LIBOVR_DIR_MESSAGE
       "LibOVR was not found. Make sure LIBOVR_LIBRARY and LIBOVR_INCLUDE_DIR are set." )
  if( LIBOVR_FIND_REQUIRED )
    set( LIBOVR_DIR_MESSAGE
         "${LIBOVR_DIR_MESSAGE} LibOVR is required to build." )
    message( FATAL_ERROR "${LIBOVR_DIR_MESSAGE}" )
  elseif( NOT LIBOVR_FIND_QUIETLY )
    set( LIBOVR_DIR_MESSAGE
         "${LIBOVR_DIR_MESSAGE} If you do not have it the OCULUS_RIFT stereo mode will not be supported." )
    message( STATUS "${LIBOVR_DIR_MESSAGE}" )
  endif()
endif()
