# - Find OpenAL
# Find the native OpenAL headers and libraries.
# If none is found for Windows use the distributed one in External
#
#  OPENAL_INCLUDE_DIR  - Where to find al.h, etc.
#  OPENAL_LIBRARIES    - List of libraries when using OpenAL.
#  OPENAL_FOUND        - True if OpenAL found.
# NOTE the upper case on the values is because the cmake find module uses upper case and we do not want to
# break that.

include( H3DExternalSearchPath )
checkCMakeInternalModule( OpenAL ) # Will call CMakes internal find module for this feature.
if( ( DEFINED OPENAL_FOUND ) AND OPENAL_FOUND )
  return()
endif()

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

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set OPENAL_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( OpenAL DEFAULT_MSG
                                   OPENAL_LIBRARY OPENAL_INCLUDE_DIR )

set( OPENAL_LIBRARIES ${OPENAL_LIBRARY} )