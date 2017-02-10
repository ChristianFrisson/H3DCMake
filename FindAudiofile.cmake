# - Find AUDIOFILE
# Find the native AUDIOFILE headers and libraries.
#
#  AUDIOFILE_INCLUDE_DIR -  where to find AUDIOFILE.h, etc.
#  AUDIOFILE_LIBRARIES    - List of libraries when using AUDIOFILE.
#  AUDIOFILE_FOUND        - True if AUDIOFILE found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "libaudiofile" )

# Look for the header file.
find_path( AUDIOFILE_INCLUDE_DIR NAMES audiofile.h
           PATHS /usr/local/include
                 ${module_include_search_paths}
           DOC "Path in which the file audiofile.h is located." )
mark_as_advanced(AUDIOFILE_INCLUDE_DIR)

# Look for the library.
# Does this work on UNIX systems? (LINUX)
find_library( AUDIOFILE_LIBRARY NAMES audiofile
              PATHS ${module_lib_search_paths}
              DOC "Path to audiofile library." )
mark_as_advanced(AUDIOFILE_LIBRARY)

# Copy the results to the output variables.
if(AUDIOFILE_INCLUDE_DIR AND AUDIOFILE_LIBRARY)
  set(AUDIOFILE_FOUND 1)
  set(AUDIOFILE_LIBRARIES ${AUDIOFILE_LIBRARY})
  set(AUDIOFILE_INCLUDE_DIR ${AUDIOFILE_INCLUDE_DIR})
else(AUDIOFILE_INCLUDE_DIR AND AUDIOFILE_LIBRARY)
  set(AUDIOFILE_FOUND 0)
  set(AUDIOFILE_LIBRARIES)
  set(AUDIOFILE_INCLUDE_DIR)
endif(AUDIOFILE_INCLUDE_DIR AND AUDIOFILE_LIBRARY)

# Report the results.
if(NOT AUDIOFILE_FOUND)
  set(AUDIOFILE_DIR_MESSAGE
    "AUDIOFILE was not found. Make sure AUDIOFILE_LIBRARY and AUDIOFILE_INCLUDE_DIR are set.")
  if(Audiofile_FIND_REQUIRED)
    message(FATAL_ERROR "${AUDIOFILE_DIR_MESSAGE}")
  elseif(NOT Audiofile_FIND_QUIETLY)
    message(STATUS "${AUDIOFILE_DIR_MESSAGE}")
  endif(Audiofile_FIND_REQUIRED)
endif(NOT AUDIOFILE_FOUND)
