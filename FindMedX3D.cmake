# - Find MedX3D
# Find the native MedX3D headers and libraries.
#
#  MedX3D_INCLUDE_DIRS - Where to find MedX3D.h, etc.
#  MedX3D_LIBRARIES    - List of libraries when using MedX3D.
#  MedX3D_FOUND        - True if MedX3D found.
include( H3DCommonFunctions )
if( MSVC )
  getMSVCPostFix( msvc_postfix )
  set( medx3d_name "MedX3D${msvc_postfix}" )
elseif( UNIX )
  set( medx3d_name h3dmedx3d )
else()
  set( medx3d_name MedX3D )
endif()


include( H3DExternalSearchPath )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES MedX3D_LIBRARY_RELEASE MedX3D_LIBRARY_DEBUG MedX3D_INCLUDE_DIR
                                              OLD_VARIABLE_NAMES MEDX3D_LIBRARY MEDX3D_DEBUG_LIBRARY
                                              DOC_STRINGS "Path to ${medx3d_name} library."
                                                          "Path to ${medx3d_name}_d library."
                                                          "Path in which the file MedX3D/MedX3D.h is located." )

getSearchPathsH3DLibs( module_include_search_paths module_lib_search_paths ${CMAKE_CURRENT_LIST_DIR} MedX3D )

# Look for the header file.
find_path( MedX3D_INCLUDE_DIR NAMES H3D/MedX3D/MedX3D.h H3D/MedX3D/MedX3D.cmake
                              PATHS ${module_include_search_paths}
                              DOC "Path in which the file MedX3D/MedX3D.h is located." )
mark_as_advanced( MedX3D_INCLUDE_DIR )

find_library( MedX3D_LIBRARY_RELEASE NAMES ${medx3d_name}
                                     PATHS ${module_lib_search_paths}
                                     DOC "Path to ${medx3d_name} library." )

find_library( MedX3D_LIBRARY_DEBUG NAMES ${medx3d_name}_d
                                   PATHS ${module_lib_search_paths}
                                   DOC "Path to ${medx3d_name}_d library." )

mark_as_advanced( MedX3D_LIBRARY_RELEASE MedX3D_LIBRARY_DEBUG )

include( SelectLibraryConfigurations )
select_library_configurations( MedX3D )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set MedX3D_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( MedX3D DEFAULT_MSG
                                   MedX3D_INCLUDE_DIR MedX3D_LIBRARY )

set( MedX3D_LIBRARIES ${MedX3D_LIBRARY} )
set( MedX3D_INCLUDE_DIRS ${MedX3D_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( MEDX3D_INCLUDE_DIR ${MedX3D_INCLUDE_DIRS} )
set( MEDX3D_LIBRARIES ${MedX3D_LIBRARIES} )
set( MedX3D_FOUND ${MEDX3D_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.

# Additional message on MSVC
if( MedX3D_FOUND AND MSVC )
  if( NOT MedX3D_LIBRARY_RELEASE )
    message( WARNING "MedX3D release library not found. Release build might not work properly. To get rid of this warning set MedX3D_LIBRARY_RELEASE." )
  endif()
  if( NOT MedX3D_LIBRARY_DEBUG )
    message( WARNING "MedX3D debug library not found. Debug build might not work properly. To get rid of this warning set MedX3D_LIBRARY_DEBUG." )
  endif()
endif()
