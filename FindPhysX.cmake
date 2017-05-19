# - Find PhysX
# Find the native PhysX headers and libraries.
#
#  PhysX_INCLUDE_DIRS - Where to find the include files of PhysX
#  PhysX_LIBRARIES    - List of libraries when using PhysX.
#  PhysX_FOUND        - True if PhysX found.
#  PhysX_FLAGS        - Flags needed for ode to build

include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES PhysX_PhysXLoader_INCLUDE_DIR PhysX_Physics_INCLUDE_DIR PhysX_Foundation_INCLUDE_DIR PhysX_Cooking_INCLUDE_DIR PhysX_Loader_LIBRARY PhysX_Core_LIBRARY
                                              OLD_VARIABLE_NAMES PHYSX_PHYSXLOADER_INCLUDE_DIR PHYSX_PHYSICS_INCLUDE_DIR PHYSX_FOUNDATION_INCLUDE_DIR PHYSX_COOKING_INCLUDE_DIR PHYSX_LIB_LOADER PHYSX_LIB_CORE )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "PhysX/Physics" "PhysX/Foundation" "PhysX/PhysXLoader" "PhysX/Cooking" )

if( CMAKE_CL_64 )
  set( lib "64" )
else()
  set( lib "32" )
endif()

set( module_include_search_paths "C:/Program (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Physics/include"
                                 "C:/Program Files (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Physics/include"
                                 "C:/Program/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Physics/include"
                                 "C:/Program Files/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/Physics/include"
                                 ${module_include_search_paths} )

# Look for the header file.
find_path( PhysX_Physics_INCLUDE_DIR NAMES NxPhysics.h
           PATHS /usr/local/include
                 /usr/include/PhysX/v2.8.3/SDKs/Physics/include
                 ${module_include_search_paths} )

mark_as_advanced( PhysX_Physics_INCLUDE_DIR )

find_path( PhysX_Foundation_INCLUDE_DIR NAMES NxFoundation.h
           PATHS /usr/local/include
                 /usr/include/PhysX/v2.8.3/SDKs/Foundation/include
                 ${module_include_search_paths} )

mark_as_advanced( PhysX_Foundation_INCLUDE_DIR )

find_path( PhysX_PhysXLoader_INCLUDE_DIR NAMES PhysXLoader.h
           PATHS /usr/local/include
                 /usr/include/PhysX/v2.8.3/SDKs/PhysXLoader/include
                 ${module_include_search_paths} )

mark_as_advanced( PhysX_PhysXLoader_INCLUDE_DIR )

find_path( PhysX_Cooking_INCLUDE_DIR NAMES NxCooking.h
           PATHS /usr/local/include
                 /usr/include/PhysX/${version_string}/SDKs/Cooking/include
                 ${module_include_search_paths} )

mark_as_advanced( PhysX_Cooking_INCLUDE_DIR )

set( module_lib_search_paths "C:/Program (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${lib}"
                             "C:/Program Files (x86)/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${lib}"
                             "C:/Program/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${lib}"
                             "C:/Program Files/NVIDIA Corporation/NVIDIA PhysX SDK/v2.8.4_win/SDKs/lib/win${lib}"
                             ${module_lib_search_paths} )
# Look for the library.
find_library( PhysX_Loader_LIBRARY NAMES PhysXLoader PhysXLoader${lib}
                PATHS ${module_lib_search_paths} )

find_library( PhysX_Core_LIBRARY NAMES PhysXCore PhysXCore${lib}
                PATHS ${module_lib_search_paths} )

mark_as_advanced( PhysX_Loader_LIBRARY )
mark_as_advanced( PhysX_Core_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set PhysX_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( PhysX DEFAULT_MSG
                                   PhysX_PhysXLoader_INCLUDE_DIR PhysX_Physics_INCLUDE_DIR PhysX_Foundation_INCLUDE_DIR PhysX_Cooking_INCLUDE_DIR PhysX_Loader_LIBRARY PhysX_Core_LIBRARY )

set( PhysX_LIBRARIES ${PhysX_Loader_LIBRARY} ${PhysX_Core_LIBRARY} )
set( PhysX_INCLUDE_DIRS ${PhysX_PhysXLoader_INCLUDE_DIR} ${PhysX_Physics_INCLUDE_DIR} ${PhysX_Foundation_INCLUDE_DIR} ${PhysX_Cooking_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( PHYSX_INCLUDE_DIR ${PhysX_INCLUDE_DIRS} )
set( PHYSX_LIBRARIES ${PhysX_LIBRARIES} )
set( PhysX_FOUND ${PHYSX_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.