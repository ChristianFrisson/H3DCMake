# - Find H3DPhysics
# Find the native H3DPhysics headers and libraries.
#
#  H3DPhysics_INCLUDE_DIRS - Where to find H3DPhysics.h, etc.
#  H3DPhysics_LIBRARIES    - List of libraries when using H3DPhysics.
#  H3DPhysics_FOUND        - True if H3DPhysics found.
#
# If the COMPONENTS feature of H3DPhysics is not set then it is assumed that
# the caller does not intend to use any of the supported components in the
# library/executable code (i.e does not intend to explicitly or implicitly include any headers
# or link against those libraries.)
# The allowed values for the COMPONENTS feature of H3DPhysics are considered optional components:
# SameComponentsAsInstalledLibrary - Will require all enabled features of the installed
#   library to be found. Enabled features can be found by searching for HAVE_<Feature> in the
#   installed header. This flag will be used as COMPONENTS to all H3D libraries that this library
#   depend on.
# ODE - Used to enable support for ODE physics engine.
# PhysX - Used to enable support for PhysX physics engine.
# PhysX3 - Used to enable support for PhysX3 physics engine.
# HACD - Used to enable support for HACD files used by PhysX3 engine.
# Bullet - Used to enable support for Bullet physics engine.
# SOFA - Used to enable support for SOFA physics engine.
# PythonLibs - Used to enable support for H3DPhysicsInterface python module.
include( H3DUtilityFunctions )
if( MSVC )
  getMSVCPostFix( msvc_postfix )
  set( h3dphysics_name "H3DPhysics${msvc_postfix}" )
elseif( UNIX )
  set( h3dphysics_name h3dphysics )
else()
  set( h3dphysics_name H3DPhysics )
endif()

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES H3DPhysics_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES H3DPhysics_DEBUG_LIBRARY
                                              DOC_STRINGS "Path to ${h3dphysics_name}_d library." )

include( H3DCommonFindModuleFunctions )
getSearchPathsH3DLibs( module_include_search_paths module_lib_search_paths ${CMAKE_CURRENT_LIST_DIR} H3DPhysics )

# Look for the header file.
find_path( H3DPhysics_INCLUDE_DIR NAMES H3D/H3DPhysics/H3DPhysics.h
                                  PATHS ${module_include_search_paths}
                                  DOC "Path in which the file H3DPhysics/H3DPhysics.h is located." )
mark_as_advanced( H3DPhysics_INCLUDE_DIR )

find_library( H3DPhysics_LIBRARY_RELEASE NAMES ${h3dphysics_name}
                                         PATHS ${module_lib_search_paths}
                                         DOC "Path to ${h3dphysics_name} library." )

find_library( H3DPhysics_LIBRARY_DEBUG NAMES ${h3dphysics_name}_d
                                       PATHS ${module_lib_search_paths}
                                       DOC "Path to ${h3dphysics_name}_d library." )

mark_as_advanced( H3DPhysics_LIBRARY_RELEASE H3DPhysics_LIBRARY_DEBUG )

if( H3DPhysics_INCLUDE_DIR )
  handleComponentsForLib( H3DPhysics
                          MODULE_HEADER_DIRS ${H3DPhysics_INCLUDE_DIR}
                          MODULE_HEADER_SUFFIX /H3D/H3DPhysics/H3DPhysics.h
                          DESIRED ${H3DPhysics_FIND_COMPONENTS}
                          REQUIRED H3DAPI
                          OPTIONAL         ODE      PhysX      PhysX3      HACD      Bullet      SOFA      PythonLibs
                          OPTIONAL_DEFINES HAVE_ODE HAVE_PHYSX HAVE_PHYSX3 HAVE_HACD HAVE_BULLET HAVE_SOFA HAVE_PYTHON
                          OUTPUT found_vars component_libraries component_include_dirs
                          H3D_MODULES H3DAPI )
endif()

include( SelectLibraryConfigurations )
select_library_configurations( H3DPhysics )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set H3DPhysics_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( H3DPhysics DEFAULT_MSG
                                   H3DPhysics_INCLUDE_DIR H3DPhysics_LIBRARY ${found_vars} )

set( H3DPhysics_LIBRARIES ${H3DPhysics_LIBRARY} ${component_libraries} )
set( H3DPhysics_INCLUDE_DIRS ${H3DPhysics_INCLUDE_DIR} ${component_include_dirs} )
list( REMOVE_DUPLICATES H3DPhysics_INCLUDE_DIRS )

# Backwards compatibility values set here.
set( H3DPhysics_INCLUDE_DIR ${H3DPhysics_INCLUDE_DIRS} )

# Additional message on MSVC
if( H3DPhysics_FOUND AND MSVC )
  if( NOT H3DPhysics_LIBRARY_RELEASE )
    message( WARNING "H3DPhysics release library not found. Release build might not work properly. To get rid of this warning set H3DPhysics_LIBRARY_RELEASE." )
  endif()
  if( NOT H3DPhysics_LIBRARY_DEBUG )
    message( WARNING "H3DPhysics debug library not found. Debug build might not work properly. To get rid of this warning set H3DPhysics_LIBRARY_DEBUG." )
  endif()
endif()
