# - Find PHYSX
# Find the native PHYSX headers and libraries.
#
#  PHYSX_INCLUDE_DIR -  where to find the include files of PhysX
#  PHYSX_LIBRARIES    - List of libraries when using PHYSX.
#  PHYSX_FOUND        - True if PHYSX found.
#  PHYSX_FLAGS        - Flags needed for ode to build 

include( H3DExternalSearchPath )
GET_FILENAME_COMPONENT( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
get_external_search_paths_h3d( module_include_search_paths module_lib_search_paths ${module_file_path} "PhysX/Physics" "PhysX/Foundation" "PhysX/PhysXLoader" "PhysX/Cooking" )

IF( CMAKE_CL_64 )
  SET( LIB "64" )
ELSE( CMAKE_CL_64 )
  SET( LIB "32" )
ENDIF( CMAKE_CL_64 )

# Look for the header file.
FIND_PATH( PHYSX_PHYSICS_INCLUDE_DIR NAMES NxPhysics.h
           PATHS /usr/local/include
                 /usr/include/PhysX/v2.8.3/SDKs/Physics/include
                 "C:/Program (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Physics/include"
                 "C:/Program Files (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Physics/include"
                 "C:/Program/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Physics/include"
                 "C:/Program Files/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Physics/include"
                 ${module_include_search_paths} )

MARK_AS_ADVANCED(PHYSX_PHYSICS_INCLUDE_DIR)

FIND_PATH( PHYSX_FOUNDATION_INCLUDE_DIR NAMES NxFoundation.h
           PATHS /usr/local/include
                 /usr/include/PhysX/v2.8.3/SDKs/Foundation/include
                 "C:/Program (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Foundation/include"
                 "C:/Program Files (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Foundation/include"
                 "C:/Program/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Foundation/include"
                 "C:/Program Files/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Foundation/include"
                 ${module_include_search_paths} )

MARK_AS_ADVANCED(PHYSX_FOUNDATION_INCLUDE_DIR)

FIND_PATH( PHYSX_PHYSXLOADER_INCLUDE_DIR NAMES PhysXLoader.h
           PATHS /usr/local/include
                 /usr/include/PhysX/v2.8.3/SDKs/PhysXLoader/include
                 "C:/Program (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/PhysXLoader/include"
                 "C:/Program Files (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/PhysXLoader/include"
                 "C:/Program/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/PhysXLoader/include"
                 "C:/Program Files/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/PhysXLoader/include"
                 ${module_include_search_paths} )

MARK_AS_ADVANCED(PHYSX_PHYSXLOADER_INCLUDE_DIR)

FIND_PATH( PHYSX_COOKING_INCLUDE_DIR NAMES NxCooking.h
           PATHS /usr/local/include
                 /usr/include/PhysX/${version_string}/SDKs/Cooking/include
                 "C:/Program (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Cooking/include"
                 "C:/Program Files (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Cooking/include"
                 "C:/Program/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Cooking/include"
                 "C:/Program Files/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Cooking/include"
                 ${module_include_search_paths} )

MARK_AS_ADVANCED(PHYSX_COOKING_INCLUDE_DIR)
# Look for the library.
FIND_LIBRARY( PHYSX_LIB_LOADER NAMES PhysXLoader PhysXLoader${LIB}
                PATHS ${module_lib_search_paths}
                      "C:/Program (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}"
                      "C:/Program Files (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}"
                      "C:/Program/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}"
                      "C:/Program Files/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}" )

FIND_LIBRARY( PHYSX_LIB_CORE NAMES PhysXCore PhysXCore${LIB}
                PATHS ${module_lib_search_paths}
                      "C:/Program (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}"
                      "C:/Program Files (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}"
                      "C:/Program/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}"
                      "C:/Program Files/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}" )
                      
MARK_AS_ADVANCED(PHYSX_LIB_LOADER)
MARK_AS_ADVANCED(PHYSX_LIB_CORE)

# Copy the results to the output variables.
IF(PHYSX_PHYSXLOADER_INCLUDE_DIR AND PHYSX_FOUNDATION_INCLUDE_DIR AND PHYSX_PHYSICS_INCLUDE_DIR AND PHYSX_COOKING_INCLUDE_DIR AND PHYSX_LIB_LOADER AND PHYSX_LIB_CORE)
  SET(PHYSX_FOUND 1)
  SET(PHYSX_LIBRARIES ${PHYSX_LIB_LOADER} ${PHYSX_LIB_CORE})
  SET(PHYSX_INCLUDE_DIR ${PHYSX_PHYSICS_INCLUDE_DIR} )
  SET(PHYSX_INCLUDE_DIR ${PHYSX_INCLUDE_DIR} ${PHYSX_PHYSXLOADER_INCLUDE_DIR} )
  SET(PHYSX_INCLUDE_DIR ${PHYSX_INCLUDE_DIR} ${PHYSX_FOUNDATION_INCLUDE_DIR} )
  SET(PHYSX_INCLUDE_DIR ${PHYSX_INCLUDE_DIR} ${PHYSX_COOKING_INCLUDE_DIR} )
ELSE(PHYSX_PHYSXLOADER_INCLUDE_DIR AND PHYSX_FOUNDATION_INCLUDE_DIR AND PHYSX_PHYSICS_INCLUDE_DIR AND PHYSX_COOKING_INCLUDE_DIR AND PHYSX_LIB_LOADER AND PHYSX_LIB_CORE)
  SET(PHYSX_FOUND 0)
  SET(PHYSX_LIBRARIES)
  SET(PHYSX_INCLUDE_DIR)
ENDIF(PHYSX_PHYSXLOADER_INCLUDE_DIR AND PHYSX_FOUNDATION_INCLUDE_DIR AND PHYSX_PHYSICS_INCLUDE_DIR AND PHYSX_COOKING_INCLUDE_DIR AND PHYSX_LIB_LOADER AND PHYSX_LIB_CORE)

# Report the results.
IF(NOT PHYSX_FOUND)
  SET(PHYSX_DIR_MESSAGE
    "PHYSX was not found. Make sure PHYSX_LIBRARY and PHYSX_INCLUDE_DIR are set.")
  IF(PHYSX_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR "${PHYSX_DIR_MESSAGE}")
  ELSEIF(NOT PHYSX_FIND_QUIETLY)
    MESSAGE(STATUS "${PHYSX_DIR_MESSAGE}")
  ENDIF(PHYSX_FIND_REQUIRED)
ENDIF(NOT PHYSX_FOUND)
