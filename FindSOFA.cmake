# - Find SOFA
# Find the native SOFA headers and libraries.
#
#  SOFA_INCLUDE_DIRS - Where to find sofa.h, etc.
#  SOFA_LIBRARIES    - List of libraries when using SOFA.
#  SOFA_FOUND        - True if SOFA found.

set( SOFA_DEFAULT_INSTALL_DIR "" )
if( MSVC10 )
  if( H3D_USE_DEPENDENCIES_ONLY )
    foreach( EXTERNAL_INCLUDE_DIR_TMP ${EXTERNAL_INCLUDE_DIR} )
      if( EXISTS ${EXTERNAL_INCLUDE_DIR_TMP}/sofa )
        set( SOFA_DEFAULT_INSTALL_DIR "${EXTERNAL_INCLUDE_DIR_TMP}/sofa" )
      endif()
    endforeach()
  elseif( $ENV{H3D_EXTERNAL_ROOT} )
    set( SOFA_DEFAULT_INSTALL_DIR "$ENV{H3D_EXTERNAL_ROOT}/include/sofa" )
  endif()
endif()
set( SOFA_INSTALL_DIR "${SOFA_DEFAULT_INSTALL_DIR}" CACHE PATH "Path to root of SOFA installation" )
mark_as_advanced( SOFA_INSTALL_DIR )

# Look for the header file.
find_path( SOFA_INCLUDE_DIR NAMES sofa/core/BehaviorModel.h
           PATHS /usr/local/include/sofa/framework
                 ${SOFA_INSTALL_DIR}/framework )
mark_as_advanced( SOFA_INCLUDE_DIR )

find_path( SOFA_INCLUDE_DIR_MODULES NAMES sofa/sofa.h
           PATHS /usr/local/include/sofa/modules
                 ${SOFA_INSTALL_DIR}/modules )
mark_as_advanced( SOFA_INCLUDE_DIR_MODULES )

find_path( SOFA_INCLUDE_DIR_APP NAMES sofa/gui/SofaGUI.h
           PATHS /usr/local/include/sofa/applications
                 ${SOFA_INSTALL_DIR}/applications )
mark_as_advanced( SOFA_INCLUDE_DIR_APP )

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
set( SOFA_LIBS ${SOFA_FIND_COMPONENTS} )

set( lib_search_paths )

set( SOFA_LIBS_FOUND 1 )
set( SOFA_LIBS_DEBUG_FOUND 1 )

set( SOFA_LIB_VERSION_MAJOR 1 )
set( SOFA_LIB_VERSION_MINOR 0 )

set( SOFA_LIB_SUFFIX "_${SOFA_LIB_VERSION_MAJOR}_${SOFA_LIB_VERSION_MINOR}" )

set( SOFA_LIBRARY_NAMES "" CACHE INTERNAL "Internal sofa library list variable. Can be used to setup delayload." FORCE )

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )

# Look for the libraries.
foreach( SOFA_LIB ${SOFA_LIBS} )
  string( TOUPPER ${SOFA_LIB} _upper_lib_name )
  set( SOFA_LIBRARY_NAMES ${SOFA_LIBRARY_NAMES} ${SOFA_LIB}${SOFA_LIB_SUFFIX}
       CACHE INTERNAL "Internal sofa library list variable. Can be used to setup delayload." FORCE )

  # Look for release library
  find_library( SOFA_${_upper_lib_name}_LIBRARY NAMES sofa${SOFA_LIB}${SOFA_LIB_SUFFIX}
                                                      sofa_${SOFA_LIB}${SOFA_LIB_SUFFIX}
                PATHS ${SOFA_INSTALL_DIR}/lib
                      ${module_lib_search_paths} )
  mark_as_advanced( SOFA_${_upper_lib_name}_LIBRARY )

  # Look for debug library
  find_library( SOFA_${_upper_lib_name}_DEBUG_LIBRARY NAMES sofa${SOFA_LIB}${SOFA_LIB_SUFFIX}d
                                                            sofa_${SOFA_LIB}${SOFA_LIB_SUFFIX}d
                PATHS ${SOFA_INSTALL_DIR}/lib
                      ${module_lib_search_paths} )
  mark_as_advanced( SOFA_${_upper_lib_name}_DEBUG_LIBRARY )

  if( SOFA_${_upper_lib_name}_LIBRARY )
    set( SOFA_LIBS_PATHS ${SOFA_LIBS_PATHS} optimized ${SOFA_${_upper_lib_name}_LIBRARY} )
  else()
    set( SOFA_LIBS_FOUND 0 )
    set( SOFA_LIBS_NOTFOUND ${SOFA_LIBS_NOTFOUND} ${SOFA_LIB} )
  endif()

  if( SOFA_${_upper_lib_name}_DEBUG_LIBRARY )
    set( SOFA_LIBS_DEBUG_PATHS ${SOFA_LIBS_DEBUG_PATHS} debug ${SOFA_${_upper_lib_name}_DEBUG_LIBRARY} )
  else()
    set( SOFA_LIBS_DEBUG_FOUND 0 )
    set( SOFA_LIBS_DEBUG_NOTFOUND ${SOFA_LIBS_DEBUG_NOTFOUND} ${SOFA_LIB} )
  endif()
endforeach()

# Copy the results to the output variables.
if( SOFA_INCLUDE_DIR AND SOFA_INCLUDE_DIR_MODULES AND SOFA_INCLUDE_DIR_APP AND SOFA_INCLUDE_DIR_BOOST AND SOFA_INCLUDE_DIR_EIGEN AND SOFA_INCLUDE_DIR_TINYXML AND SOFA_LIBS_FOUND )
  set( SOFA_FOUND 1 )
  set( SOFA_LIBRARIES ${SOFA_LIBS_PATHS} ${SOFA_LIBS_DEBUG_PATHS} )
  set( SOFA_INCLUDE_DIR ${SOFA_INCLUDE_DIR} ${SOFA_INCLUDE_DIR_MODULES} ${SOFA_INCLUDE_DIR_APP} ${SOFA_INCLUDE_DIR_BOOST} ${SOFA_INCLUDE_DIR_EIGEN} ${SOFA_INCLUDE_DIR_TINYXML} )
else()
  set( SOFA_FOUND 0 )
  set( SOFA_LIBRARIES )
  set( SOFA_INCLUDE_DIR )
endif()

# Report the results.
if( NOT SOFA_FOUND )
  if( SOFA_INCLUDE_DIR AND SOFA_INCLUDE_DIR_MODULES AND SOFA_INCLUDE_DIR_APP AND SOFA_INCLUDE_DIR_BOOST AND SOFA_INCLUDE_DIR_EIGEN AND SOFA_INCLUDE_DIR_TINYXML )
    set( SOFA_DIR_MESSAGE
         "SOFA was not found. Could not find the: ${SOFA_LIBS_NOTFOUND} component(s)." )
  else()
    set( SOFA_DIR_MESSAGE
         "SOFA was not found. Could not find the include files." )

  endif()

  set( SOFA_DIR_MESSAGE
       "${SOFA_DIR_MESSAGE} Try setting SOFA_INSTALL_DIR to the root of the SOFA installation." )

  if( SOFA_FIND_REQUIRED )
    message( FATAL_ERROR "${SOFA_DIR_MESSAGE}" )
  elseif( NOT SOFA_FIND_QUIETLY )
    message( STATUS "${SOFA_DIR_MESSAGE}" )
  endif()
elseif( NOT SOFA_FOUND )
  if( NOT SOFA_LIBS_DEBUG_FOUND )
    message( STATUS "Warning: SOFA debug libraries not found. The debug build will not work." )
    message( STATUS "Debug libraries for the following components were not found: ${SOFA_LIBS_DEBUG_NOTFOUND}" )
  endif()
endif()
