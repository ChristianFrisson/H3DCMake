# - Find PHYSX
# Find the native PHYSX headers and libraries.
#
#  PHYSX_INCLUDE_DIR -  where to find the include files of PhysX
#  PHYSX_LIBRARIES    - List of libraries when using PHYSX.
#  PHYSX_FOUND        - True if PHYSX found.
#  PHYSX_FLAGS        - Flags needed for ode to build 

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "PhysX/Physics" "PhysX/Foundation" "PhysX/PhysXLoader" "PhysX/Cooking" )

if( CMAKE_CL_64 )
  set( LIB "64" )
else()
  set( LIB "32" )
endif()

# Look for the header file.
find_path( PHYSX_PHYSICS_INCLUDE_DIR NAMES NxPhysics.h
           PATHS /usr/local/include
                 /usr/include/PhysX/v2.8.3/SDKs/Physics/include
                 "C:/Program (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Physics/include"
                 "C:/Program Files (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Physics/include"
                 "C:/Program/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Physics/include"
                 "C:/Program Files/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Physics/include"
                 ${module_include_search_paths} )

mark_as_advanced( PHYSX_PHYSICS_INCLUDE_DIR )

find_path( PHYSX_FOUNDATION_INCLUDE_DIR NAMES NxFoundation.h
           PATHS /usr/local/include
                 /usr/include/PhysX/v2.8.3/SDKs/Foundation/include
                 "C:/Program (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Foundation/include"
                 "C:/Program Files (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Foundation/include"
                 "C:/Program/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Foundation/include"
                 "C:/Program Files/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Foundation/include"
                 ${module_include_search_paths} )

mark_as_advanced( PHYSX_FOUNDATION_INCLUDE_DIR )

find_path( PHYSX_PHYSXLOADER_INCLUDE_DIR NAMES PhysXLoader.h
           PATHS /usr/local/include
                 /usr/include/PhysX/v2.8.3/SDKs/PhysXLoader/include
                 "C:/Program (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/PhysXLoader/include"
                 "C:/Program Files (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/PhysXLoader/include"
                 "C:/Program/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/PhysXLoader/include"
                 "C:/Program Files/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/PhysXLoader/include"
                 ${module_include_search_paths} )

mark_as_advanced( PHYSX_PHYSXLOADER_INCLUDE_DIR )

find_path( PHYSX_COOKING_INCLUDE_DIR NAMES NxCooking.h
           PATHS /usr/local/include
                 /usr/include/PhysX/${version_string}/SDKs/Cooking/include
                 "C:/Program (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Cooking/include"
                 "C:/Program Files (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Cooking/include"
                 "C:/Program/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Cooking/include"
                 "C:/Program Files/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Cooking/include"
                 ${module_include_search_paths} )

mark_as_advanced( PHYSX_COOKING_INCLUDE_DIR )
# Look for the library.
find_library( PHYSX_LIB_LOADER NAMES PhysXLoader PhysXLoader${LIB}
                PATHS ${module_lib_search_paths}
                      "C:/Program (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}"
                      "C:/Program Files (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}"
                      "C:/Program/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}"
                      "C:/Program Files/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}" )

find_library( PHYSX_LIB_CORE NAMES PhysXCore PhysXCore${LIB}
                PATHS ${module_lib_search_paths}
                      "C:/Program (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}"
                      "C:/Program Files (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}"
                      "C:/Program/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}"
                      "C:/Program Files/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${LIB}" )
                      
mark_as_advanced( PHYSX_LIB_LOADER )
mark_as_advanced( PHYSX_LIB_CORE )

# Copy the results to the output variables.
if( PHYSX_PHYSXLOADER_INCLUDE_DIR AND PHYSX_FOUNDATION_INCLUDE_DIR AND PHYSX_PHYSICS_INCLUDE_DIR AND PHYSX_COOKING_INCLUDE_DIR AND PHYSX_LIB_LOADER AND PHYSX_LIB_CORE )
  set( PHYSX_FOUND 1 )
  set( PHYSX_LIBRARIES ${PHYSX_LIB_LOADER} ${PHYSX_LIB_CORE} )
  set( PHYSX_INCLUDE_DIR ${PHYSX_PHYSICS_INCLUDE_DIR} )
  set( PHYSX_INCLUDE_DIR ${PHYSX_INCLUDE_DIR} ${PHYSX_PHYSXLOADER_INCLUDE_DIR} )
  set( PHYSX_INCLUDE_DIR ${PHYSX_INCLUDE_DIR} ${PHYSX_FOUNDATION_INCLUDE_DIR} )
  set( PHYSX_INCLUDE_DIR ${PHYSX_INCLUDE_DIR} ${PHYSX_COOKING_INCLUDE_DIR} )
else()
  set( PHYSX_FOUND 0 )
  set( PHYSX_LIBRARIES )
  set( PHYSX_INCLUDE_DIR )
endif()

# Report the results.
if( NOT PHYSX_FOUND )
  set( PHYSX_DIR_MESSAGE
       "PHYSX was not found. Make sure PHYSX_LIBRARY and PHYSX_INCLUDE_DIR are set." )
  if( PHYSX_FIND_REQUIRED )
    message( FATAL_ERROR "${PHYSX_DIR_MESSAGE}" )
  elseif( NOT PHYSX_FIND_QUIETLY )
    message( STATUS "${PHYSX_DIR_MESSAGE}" )
  endif()
endif()
