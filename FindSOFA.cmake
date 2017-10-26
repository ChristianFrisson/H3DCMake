# - Find SOFA
# Find the native SOFA headers and libraries.
#
#  SOFA_INCLUDE_DIRS - Where to find sofa.h, etc.
#  SOFA_LIBRARIES    - List of libraries when using SOFA.
#  SOFA_FOUND        - True if SOFA found.

set( sofa_default_install_dir "" )
if( MSVC10 )
  if( $ENV{H3D_EXTERNAL_ROOT} )
    set( sofa_default_install_dir "$ENV{H3D_EXTERNAL_ROOT}/include/sofa" )
  endif()
endif()
set( SOFA_INSTALL_DIR "${sofa_default_install_dir}" CACHE PATH "Path to root of SOFA installation" )
mark_as_advanced( SOFA_INSTALL_DIR )

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES SOFA_INCLUDE_DIR_APPLICATIONS
                                              OLD_VARIABLE_NAMES SOFA_INCLUDE_DIR_APP )

# Look for the header file.
find_path( SOFA_INCLUDE_DIR NAMES sofa/core/BehaviorModel.h
           PATHS /usr/local/include/sofa/framework
                 ${SOFA_INSTALL_DIR}/framework )
mark_as_advanced( SOFA_INCLUDE_DIR )

find_path( SOFA_INCLUDE_DIR_MODULES NAMES sofa/sofa.h
           PATHS /usr/local/include/sofa/modules
                 ${SOFA_INSTALL_DIR}/modules )
mark_as_advanced( SOFA_INCLUDE_DIR_MODULES )

find_path( SOFA_INCLUDE_DIR_APPLICATIONS NAMES sofa/gui/SofaGUI.h
           PATHS /usr/local/include/sofa/applications
                 ${SOFA_INSTALL_DIR}/applications )
mark_as_advanced( SOFA_INCLUDE_DIR_APPLICATIONS )

find_path( SOFA_INCLUDE_DIR_BOOST NAMES boost/version.hpp
           PATHS /usr/local/include/sofa/extlibs/miniBoost
                 ${SOFA_INSTALL_DIR}/extlibs/miniBoost )
mark_as_advanced( SOFA_INCLUDE_DIR_BOOST )

find_path( SOFA_INCLUDE_DIR_EIGEN NAMES Eigen/Core Eigen/src/Core
           PATHS /usr/local/include/sofa/extlibs/eigen-3.1.1
                 ${SOFA_INSTALL_DIR}/extlibs/eigen-3.1.1 )
mark_as_advanced( SOFA_INCLUDE_DIR_EIGEN )

find_path( SOFA_INCLUDE_DIR_TINYXML NAMES tinyxml.h
           PATHS /usr/local/include/sofa/extlibs/tinyxml
                 ${SOFA_INSTALL_DIR}/extlibs/tinyxml )
mark_as_advanced( SOFA_INCLUDE_DIR_TINYXML )

# SOFA_FIND_COMPONENTS hold the values from COMPONENTS
# in FindPackage( SOFA COMPONENTS core simulation )
set( sofa_libs ${SOFA_FIND_COMPONENTS} )

set( sofa_libs_debug_found 1 )

set( sofa_lib_version_major 1 )
set( sofa_lib_version_minor 0 )

set( sofa_lib_suffix "_${sofa_lib_version_major}_${sofa_lib_version_minor}" )

set( SOFA_LIBRARY_NAMES "" CACHE INTERNAL "Internal sofa library list variable. Can be used to setup delayload." FORCE )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )

# Look for the libraries.
set( required_release_lib_vars )
foreach( sofa_lib ${sofa_libs} )
  string( TOUPPER ${sofa_lib} _upper_lib_name )
  set( SOFA_LIBRARY_NAMES ${SOFA_LIBRARY_NAMES} ${sofa_lib}${sofa_lib_suffix}
       CACHE INTERNAL "Internal sofa library list variable. Can be used to setup delayload." FORCE )

  handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES SOFA_${sofa_lib}_LIBRARY_RELEASE SOFA_${sofa_lib}_LIBRARY_DEBUG
                                                OLD_VARIABLE_NAMES SOFA_${_upper_lib_name}_LIBRARY SOFA_${_upper_lib_name}_DEBUG_LIBRARY)

  # Look for release library
  find_library( SOFA_${sofa_lib}_LIBRARY_RELEASE NAMES sofa${sofa_lib}${sofa_lib_suffix}
                                                       sofa_${sofa_lib}${sofa_lib_suffix}
                PATHS ${SOFA_INSTALL_DIR}/lib
                      ${module_lib_search_paths} )
  mark_as_advanced( SOFA_${sofa_lib}_LIBRARY_RELEASE )
  set( required_release_lib_vars ${required_release_lib_vars} SOFA_${sofa_lib}_LIBRARY_RELEASE )

  # Look for debug library
  find_library( SOFA_${sofa_lib}_LIBRARY_DEBUG NAMES sofa${sofa_lib}${sofa_lib_suffix}d
                                                     sofa_${sofa_lib}${sofa_lib_suffix}d
                PATHS ${SOFA_INSTALL_DIR}/lib
                      ${module_lib_search_paths} )
  mark_as_advanced( SOFA_${sofa_lib}_LIBRARY_DEBUG )

  if( SOFA_${sofa_lib}_LIBRARY_RELEASE )
    set( sofa_libs_paths ${sofa_libs_paths} optimized ${SOFA_${sofa_lib}_LIBRARY_RELEASE} )
  endif()

  if( SOFA_${sofa_lib}_LIBRARY_DEBUG )
    set( sofa_libs_debug_paths ${sofa_libs_debug_paths} debug ${SOFA_${sofa_lib}_LIBRARY_DEBUG} )
  else()
    set( sofa_libs_debug_found 0 )
    set( sofa_libs_debug_notfound ${sofa_libs_debug_notfound} ${sofa_lib} )
  endif()
endforeach()

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set SOFA_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( SOFA DEFAULT_MSG
                                   SOFA_INCLUDE_DIR SOFA_INCLUDE_DIR_MODULES SOFA_INCLUDE_DIR_APPLICATIONS
                                   SOFA_INCLUDE_DIR_BOOST SOFA_INCLUDE_DIR_EIGEN SOFA_INCLUDE_DIR_TINYXML
                                   ${required_release_lib_vars} )

# Copy the results to the output variables.
set( SOFA_LIBRARIES ${sofa_libs_paths} ${sofa_libs_debug_paths} )
set( SOFA_INCLUDE_DIR ${SOFA_INCLUDE_DIR} ${SOFA_INCLUDE_DIR_MODULES} ${SOFA_INCLUDE_DIR_APPLICATIONS} ${SOFA_INCLUDE_DIR_BOOST} ${SOFA_INCLUDE_DIR_EIGEN} ${SOFA_INCLUDE_DIR_TINYXML} )

if( SOFA_FOUND AND NOT sofa_libs_debug_found )
  message( STATUS "Warning: SOFA debug libraries not found. The debug build will not work." )
  message( STATUS "Debug libraries for the following components were not found: ${sofa_libs_debug_notfound}" )
endif()
