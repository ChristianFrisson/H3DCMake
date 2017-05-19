# - Find MedX3D
# Find the native MedX3D headers and libraries.
#
#  MedX3D_INCLUDE_DIRS - Where to find MedX3D.h, etc.
#  MedX3D_LIBRARIES    - List of libraries when using MedX3D.
#  MedX3D_FOUND        - True if MedX3D found.
#
# If the COMPONENTS feature of MedX3D is not set then it is assumed that
# the caller does not intend to use any of the supported components in the
# library/executable code (i.e does not intend to explicitly or implicitly include any headers
# or link against those libraries.)
# The allowed values for the COMPONENTS feature of MedX3D are considered optional components:
# SameComponentsAsInstalledLibrary - Will require all enabled features of the installed
#   library to be found. Enabled features can be found by searching for HAVE_<Feature> in the
#   installed header. This flag will be used as COMPONENTS to all H3D libraries that this library
#   depend on.
include( H3DUtilityFunctions )
if( MSVC )
  getMSVCPostFix( msvc_postfix )
  set( medx3d_name "MedX3D${msvc_postfix}" )
elseif( UNIX )
  set( medx3d_name h3dmedx3d )
else()
  set( medx3d_name MedX3D )
endif()


handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES MedX3D_LIBRARY_RELEASE MedX3D_LIBRARY_DEBUG MedX3D_INCLUDE_DIR
                                              OLD_VARIABLE_NAMES MEDX3D_LIBRARY MEDX3D_DEBUG_LIBRARY
                                              DOC_STRINGS "Path to ${medx3d_name} library."
                                                          "Path to ${medx3d_name}_d library."
                                                          "Path in which the file MedX3D/MedX3D.h is located." )

include( H3DCommonFindModuleFunctions )
getSearchPathsH3DLibs( module_include_search_paths module_lib_search_paths ${CMAKE_CURRENT_LIST_DIR} MedX3D )

# Look for the header file.
find_path( MedX3D_INCLUDE_DIR NAMES H3D/MedX3D/MedX3D.h
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

if( MedX3D_INCLUDE_DIR )
  handleComponentsForLib( MedX3D
                          MODULE_HEADER ${MedX3D_INCLUDE_DIR}/H3D/MedX3D/MedX3D.h
                          DESIRED ${MedX3D_FIND_COMPONENTS}
                          REQUIRED H3DAPI
                          OUTPUT found_vars component_libraries component_include_dirs
                          H3D_MODULES H3DAPI )
endif()

include( SelectLibraryConfigurations )
select_library_configurations( MedX3D )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set MedX3D_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( MedX3D DEFAULT_MSG
                                   MedX3D_INCLUDE_DIR MedX3D_LIBRARY ${found_vars} )

set( MedX3D_LIBRARIES ${MedX3D_LIBRARY} ${component_libraries} )
set( MedX3D_INCLUDE_DIRS ${MedX3D_INCLUDE_DIR} ${component_include_dirs} )
list( REMOVE_DUPLICATES MedX3D_INCLUDE_DIRS )

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
