# - Find PhysX4
# Find the native PhysX4 headers and libraries.
#
#  PhysX4_INCLUDE_DIRS - Where to find the include files of PhysX4.
#  PhysX4_LIBRARIES    - List of libraries when using PhysX4.
#  PhysX4_FOUND        - True if PhysX4 found.

if( PhysX4_FIND_COMPONENTS )
  set( physx4_libs ${PhysX4_FIND_COMPONENTS} )
else()
  if( PHYSX4_LIBS )
    set( physx4_libs ${PHYSX4_LIBS} )
  else()
    # Decide which libraries to add
    set( physx4_libs
      "FastXml_static"
      "LowLevel_static"
      "LowLevelAABB_static"
      "LowLevelDynamics_static"
      "SceneQuery_static"
      "SimulationController_static"
      "PhysXCommon"
      "PhysXExtensions_static"
      "PhysX"
      "PhysXTask_static"
      "PhysXVehicle_static"
      "PhysXCooking"
      "PhysXCharacterKinematic_static"
      "PhysXPvdSDK_static"
      "PhysXFoundation" )
  endif()
endif()

include( H3DUtilityFunctions )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "physx4" )

if( CMAKE_CL_64 )
  set( lib "64" )
else()
  set( lib "32" )
endif()

if( NOT DEFINED PhysX4_INSTALL_DIR )
  set( PhysX4_INSTALL_DIR "" CACHE PATH "Path to external PhysX 4 installation" )
endif()
mark_as_advanced( PhysX4_INSTALL_DIR )

set( PhysX4_LIB_TYPE "checked" CACHE STRING "PhysX library type" )
set_property( CACHE PhysX4_LIB_TYPE PROPERTY STRINGS release checked profile )
set( physx4_lib_type_dir ${PhysX4_LIB_TYPE} )

set( physx4_install_dir_include_search_paths /usr/local/include
                                             ${PhysX4_INSTALL_DIR}/Include
                                             ${PhysX4_INSTALL_DIR}/include/PhysX4 )
set( physx4_install_dir_lib_search_paths ${PhysX4_INSTALL_DIR}/Lib/win${lib}/${physx4_lib_type_dir}
                                         ${PhysX4_INSTALL_DIR}/Lib/linux${lib}/${physx4_lib_type_dir}
                                         ${PhysX4_INSTALL_DIR}/lib${lib}/${physx4_lib_type_dir} )
set( physx4_install_dir_debuglib_search_paths ${PhysX4_INSTALL_DIR}/Lib/win${lib}/debug
                                              ${PhysX4_INSTALL_DIR}/Lib/linux${lib}/debug
                                              ${PhysX4_INSTALL_DIR}/lib${lib}/debug )

if( MSVC )
  # The reason for doing this is that I (markus) prefer to add the additional
  # include and library paths based on our already existing and checked MSVC_VERSION
  # check code instead of having to repeat that kind of code here.
  getMSVCPostFix( msvc_post_fix )
  set( msvc_postfix_for_physx4 )
  if( ${msvc_post_fix} STREQUAL "_vc14" )
    set( msvc_postfix_for_physx4 "vs2015" )
  elseif( ${msvc_post_fix} STREQUAL "_vc15" )
    set( msvc_postfix_for_physx4 "vs2017" )
  endif()

  if( msvc_postfix_for_physx4 )
    set( physx4_install_dir_include_search_paths ${physx4_install_dir_include_search_paths}
                                                 ${PhysX4_INSTALL_DIR}/${msvc_postfix_for_physx4}/include/PhysX4 )
    set( physx4_install_dir_lib_search_paths ${physx4_install_dir_lib_search_paths}
                                             ${PhysX4_INSTALL_DIR}/${msvc_postfix_for_physx4}/Lib/win${lib}/${physx4_lib_type_dir}
                                             ${PhysX4_INSTALL_DIR}/${msvc_postfix_for_physx4}/Lib/linux${lib}/${physx4_lib_type_dir}
                                             ${PhysX4_INSTALL_DIR}/${msvc_postfix_for_physx4}/lib${lib}/${physx4_lib_type_dir} )
    set( physx4_install_dir_debuglib_search_paths ${physx4_install_dir_debuglib_search_paths}
                                                  ${PhysX4_INSTALL_DIR}/${msvc_postfix_for_physx4}/Lib/win${lib}/debug
                                                  ${PhysX4_INSTALL_DIR}/${msvc_postfix_for_physx4}/Lib/linux${lib}/debug
                                                  ${PhysX4_INSTALL_DIR}/${msvc_postfix_for_physx4}/lib${lib}/debug )
  endif()
endif()

# Look for the header file.
find_path( PhysX4_INCLUDE_DIR NAMES PxPhysics.h
           PATHS ${physx4_install_dir_include_search_paths}
                 ${module_include_search_paths} )

mark_as_advanced( PhysX4_INCLUDE_DIR )

set( required_vars PhysX4_INCLUDE_DIR )
set( physx4_libs_paths )
set( physx4_libs_debug_paths )
# Look for the libraries.
foreach( physx4_lib ${physx4_libs} )
  set( lib_name PhysX4_${physx4_lib}_LIBRARY_RELEASE )
  set( lib_debug_name PhysX4_${physx4_lib}_LIBRARY_DEBUG )
  # unset libraries so that they are always looked for. This is because we want it to automatically
  # update if the PhysX4_LIB_TYPE is changed.
  unset( ${lib_name} CACHE )

  # Find release libs.
  find_library( ${lib_name}
                NAMES ${physx4_lib}_${lib} ${physx4_lib}
                PATHS ${physx4_install_dir_lib_search_paths} )
  mark_as_advanced( ${lib_name} )

  if( ${lib_name} )
    if( UNIX )
      # To avoid undefined symbols at runtime we need to include the entire static library in our shared library
      set( ${lib_name} -Wl,-whole-archive ${${lib_name}} -Wl,-no-whole-archive )
    endif()
    set( physx4_libs_paths ${physx4_libs_paths} optimized ${${lib_name}} )
  endif()

  # Find Debug libs.
  find_library( ${lib_debug_name}
                NAMES ${physx4_lib}_${lib} ${physx4_lib}
                PATHS ${physx4_install_dir_debuglib_search_paths} )
  mark_as_advanced( ${lib_debug_name} )

  if( ${lib_debug_name} )
    if( UNIX )
      # To avoid undefined symbols at runtime we need to include the entire static library in our shared library
      set( ${lib_debug_name} -Wl,-whole-archive ${${lib_debug_name}} -Wl,-no-whole-archive )
    endif()
    set( physx4_libs_debug_paths ${physx4_libs_debug_paths} debug ${${lib_debug_name}} )
  endif()

  set( required_vars ${required_vars} ${lib_name} ${lib_debug_name} )
endforeach()

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set PhysX4_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( PhysX4 DEFAULT_MSG ${required_vars} )

set( PhysX4_LIBRARIES ${physx4_libs_paths} ${physx4_libs_debug_paths} )
set( PhysX4_INCLUDE_DIRS ${PhysX4_INCLUDE_DIR} )