# - Find OpenAL
# Find the native OpenAL headers and libraries.
# If none is found for Windows use the distributed one in External
#
#  OPENAL_INCLUDE_DIR -  where to find al.h, etc.
#  OPENAL_LIBRARIES    - List of libraries when using OpenAL.
#  OPENAL_FOUND        - True if OpenAL found.
if( WIN32 )
  set(OpenAL_FIND_QUIETLY 1)
endif( WIN32 )

find_package(OpenAL)

if(NOT OPENAL_FOUND AND WIN32)
  include( H3DExternalSearchPath )
  get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )
  # Look for the header file.
  find_path( OPENAL_INCLUDE_DIR NAMES AL/al.h
             PATHS ${module_include_search_paths}
             DOC "Path in which the file AL/al.h is located." )

  # Look for the library.
  find_library( OPENAL_LIBRARY NAMES OpenAL32
                PATHS ${module_lib_search_paths}
                DOC "Path to OpenAL32 library." )

  if(OPENAL_INCLUDE_DIR AND OPENAL_LIBRARY)
    set(OPENAL_FOUND 1)
    set(OPENAL_LIBRARIES ${OPENAL_LIBRARY})
    set(OPENAL_INCLUDE_DIR ${OPENAL_INCLUDE_DIR})
  endif(OPENAL_INCLUDE_DIR AND OPENAL_LIBRARY)
elseif( OPENAL_FOUND)
  # Apparently this variable is not set on linux.
  set(OPENAL_LIBRARIES ${OPENAL_LIBRARY})
endif(NOT OPENAL_FOUND AND WIN32)

# Report the results.
if(NOT OPENAL_FOUND)
  set(OPENAL_DIR_MESSAGE
    "OpenAL was not found. Make sure OPENAL_LIBRARY and OPENAL_INCLUDE_DIR are set.")
  if(OpenAL_FIND_REQUIRED)
    set(OPENAL_DIR_MESSAGE
        "${OPENAL_DIR_MESSAGE} OpenAL is required to build.")
    message(FATAL_ERROR "${OPENAL_DIR_MESSAGE}")
  elseif(NOT OpenAL_FIND_QUIETLY)
    message(STATUS "${OPENAL_DIR_MESSAGE}")
  endif(OpenAL_FIND_REQUIRED)
endif(NOT OPENAL_FOUND)

mark_as_advanced(OPENAL_INCLUDE_DIR OPENAL_LIBRARY)
