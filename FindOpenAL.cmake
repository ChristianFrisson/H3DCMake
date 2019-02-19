# - Find OpenAL
# Find the native OpenAL headers and libraries.
# If none is found for Windows use the distributed one in External
#
#  OPENAL_INCLUDE_DIRS - Where to find al.h, etc.
#  OPENAL_LIBRARIES    - List of libraries when using OpenAL.
#  OPENAL_FOUND        - True if OpenAL found.
# NOTE the upper case on the values is because the cmake find module uses upper case and we do not want to
# break that.

include( H3DCommonFindModuleFunctions )

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )
# Look for the header file.
find_path( OPENAL_INCLUDE_DIR NAMES AL/al.h
           PATHS ${module_include_search_paths}
           DOC "Path in which the file AL/al.h is located."
           NO_SYSTEM_ENVIRONMENT_PATH )

# Look for the library.
find_library( OPENAL_LIBRARY NAMES OpenAL32
              PATHS ${module_lib_search_paths}
              DOC "Path to OpenAL32 library."
              NO_SYSTEM_ENVIRONMENT_PATH )

checkIfModuleFound( OPENAL
                    REQUIRED_VARS OPENAL_INCLUDE_DIR OPENAL_LIBRARY )

if( NOT OPENAL_FOUND )
  checkCMakeInternalModule( OpenAL OUTPUT_AS_UPPER_CASE )  # Will call CMakes internal find module for this feature.
endif()

# The internal CMake find module does not define these variables, so we have to define them.
set( OPENAL_LIBRARIES ${OPENAL_LIBRARY} )
set( OPENAL_INCLUDE_DIRS ${OPENAL_INCLUDE_DIR} )
