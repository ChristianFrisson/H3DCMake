# - Find PhysX3
# Find the native PhysX3 headers and libraries.
#
#  PhysX3_INCLUDE_DIRS - Where to find the include files of PhysX3
#  PhysX3_LIBRARIES    - List of libraries when using PhysX3.
#  PhysX3_FOUND        - True if PhysX3 found.

if( PHYSX3_LIBS )
  message( AUTHOR_WARNING "The setting PHYSX3_LIBS is deprecated. Use the COMPONENTS feature of find_package instead." )
endif()

if( PhysX3_FIND_COMPONENTS )
  set( physx3_libs ${PhysX3_FIND_COMPONENTS} )
else()
  if( PHYSX3_LIBS )
    set( physx3_libs ${PHYSX3_LIBS} )
  else()
    # Decide which libraries to add
    set( physx3_libs
      "PxTask"
      "PhysX3Common"
      "PhysX3Extensions"
      "PhysX3"
      "PhysX3Vehicle"
      "PhysX3Cooking"
      "PhysX3CharacterKinematic"
      "PhysXProfileSDK"
      "PhysXVisualDebuggerSDK" )

    if( UNIX )
      set( physx3_libs ${physx3_libs}
	# TODO: Having these included for PhysX 3.3 causes runtime error of symbol not found.
	# Everything seems to run fine without them but leaving them here cpmmented out for now to
	# make it easier for other people to try to add if they have other issues because of this change.
	# It is very hard to find otherwise.
#        "PvdRuntime"
#        "LowLevel"
#        "LowLevelCloth"
#        "SceneQuery"
#        "SimulationController"
)
    endif()
  endif()
endif()

include( H3DUtilityFunctions )

set( old_lib_names )
set( new_lib_names )
foreach( physx3_lib ${physx3_libs} )
  set( new_lib_names ${new_lib_names} PhysX3_${physx3_lib}_LIBRARY_RELEASE PhysX3_${physx3_lib}_LIBRARY_DEBUG )
  string( TOUPPER ${physx3_lib} _upper_lib_name )
  set( old_lib_names ${old_lib_names} PHYSX3_${_upper_lib_name}_LIBRARY PHYSX3_${_upper_lib_name}_DEBUG_LIBRARY )
endforeach()
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES ${new_lib_names} PhysX3_INCLUDE_DIR PhysX3_INSTALL_DIR PhysX3_LIB_TYPE
                                              OLD_VARIABLE_NAMES ${old_lib_names} )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "physx3" )

if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set( lib "64" )
  set( arch "x64" )
else()
  set( lib "32" )
  set( arch "x86" )
endif()

if( NOT DEFINED PhysX3_INSTALL_DIR )
  set( PhysX3_INSTALL_DIR "" CACHE PATH "Path to external PhysX 3 installation" )
endif()
mark_as_advanced( PhysX3_INSTALL_DIR )

set( physx3_install_dir_include_search_paths ${PhysX3_INSTALL_DIR}/Include
                                             ${PhysX3_INSTALL_DIR}/include/PhysX3 )
set( physx3_install_dir_lib_search_paths ${PhysX3_INSTALL_DIR}/Lib/win${lib}
                                         ${PhysX3_INSTALL_DIR}/Lib/vc10win${lib}
                                         ${PhysX3_INSTALL_DIR}/Bin/linux${lib}
                                         ${PhysX3_INSTALL_DIR}/Lib/linux${lib}
                                         ${PhysX3_INSTALL_DIR}/lib${lib} )

if( MSVC )
  # The reason for doing this is that I (markus) prefer to add the additional
  # include and library paths based on our already existing and checked MSVC_VERSION
  # check code instead of having to repeat that kind of code here.
  getMSVCPostFix( msvc_post_fix )
  set( msvc_postfix_for_physx3 )
  if( ${msvc_post_fix} STREQUAL "_vc14" )
    set( msvc_postfix_for_physx3 "vs2015" )
  elseif( ${msvc_post_fix} STREQUAL "_vc15" )
    set( msvc_postfix_for_physx3 "vs2017" )
  endif()

  if( msvc_postfix_for_physx3 )
    set( physx3_install_dir_include_search_paths ${physx3_install_dir_include_search_paths}
                                                 ${PhysX3_INSTALL_DIR}/${msvc_postfix_for_physx3}/include/PhysX3 )
    set( physx3_install_dir_lib_search_paths ${physx3_install_dir_lib_search_paths}
                                             ${PhysX3_INSTALL_DIR}/${msvc_postfix_for_physx3}/lib${lib} )
  endif()
endif()

# Look for the header file.
find_path( PhysX3_INCLUDE_DIR NAMES PxPhysics.h
           PATHS /usr/local/include
                 ${physx3_install_dir_include_search_paths}
                 ${module_include_search_paths} )

mark_as_advanced( PhysX3_INCLUDE_DIR )

set( PhysX3_LIB_TYPE "CHECKED" CACHE STRING "PhysX library type" )
set_property( CACHE PhysX3_LIB_TYPE PROPERTY STRINGS RELEASE CHECKED PROFILE )
if( ${PhysX3_LIB_TYPE} STREQUAL RELEASE )
  set( physx3_lib_type_suffix "" )
else()
  set( physx3_lib_type_suffix ${PhysX3_LIB_TYPE} )
endif()


set( required_vars PhysX3_INCLUDE_DIR )
set( physx3_libs_paths )
set( physx3_libs_debug_paths )
# Look for the libraries.
if( UNIX )
   # To avoid undefined symbols at runtime we need to include the entire static library in our shared library
   set( physx3_libs_paths ${physx3_libs_paths} -Wl,-whole-archive )
   set( physx3_libs_debug_paths ${physx3_libs_debug_paths} -Wl,-whole-archive )
endif()

foreach( physx3_lib ${physx3_libs} )
  set( lib_name PhysX3_${physx3_lib}_LIBRARY_RELEASE )
  set( lib_debug_name PhysX3_${physx3_lib}_LIBRARY_DEBUG )
  # unset libraries so that they are always looked for. This is because we want it to automatically
  # update if the PhysX3_LIB_TYPE is changed.
  unset( ${lib_name} CACHE )

  # Find release libs.
  find_library( ${lib_name}
                NAMES ${physx3_lib}${physx3_lib_type_suffix}_${arch}
                      ${physx3_lib}${physx3_lib_type_suffix}
                PATHS ${physx3_install_dir_lib_search_paths}
                      ${module_lib_search_paths} )
  mark_as_advanced( ${lib_name} )

  if( ${lib_name} )
    set( physx3_libs_paths ${physx3_libs_paths} optimized ${${lib_name}} )
  endif()

  # Find Debug libs.
  find_library( ${lib_debug_name}
                NAMES ${physx3_lib}DEBUG_${arch}
                      ${physx3_lib}DEBUG
                PATHS ${physx3_install_dir_lib_search_paths}
                      ${module_lib_search_paths} )
  mark_as_advanced( ${lib_debug_name} )

  if( ${lib_debug_name} )
    set( physx3_libs_debug_paths ${physx3_libs_debug_paths} debug ${${lib_debug_name}} )
  endif()

  set( required_vars ${required_vars} ${lib_name} ${lib_debug_name} )
endforeach()

if( UNIX )
   # To avoid undefined symbols at runtime we need to include the entire static library in our shared library
   set( physx3_libs_paths ${physx3_libs_paths} -Wl,-no-whole-archive )
   set( physx3_libs_debug_paths ${physx3_libs_debug_paths} -Wl,-no-whole-archive )
 endif()

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set PhysX3_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( PhysX3 DEFAULT_MSG ${required_vars} )

set( PhysX3_LIBRARIES ${physx3_libs_paths}  ${physx3_libs_debug_paths} )
set( PhysX3_INCLUDE_DIRS ${PhysX3_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( PHYSX3_INCLUDE_DIR ${PhysX3_INCLUDE_DIRS} )
set( PHYSX3_INCLUDE_DIRS ${PhysX3_INCLUDE_DIRS} )
set( PHYSX3_LIBRARIES ${PhysX3_LIBRARIES} )
set( PhysX3_FOUND ${PHYSX3_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.
