# - Find SOFA
# Find the native SOFA headers and libraries.
#
#  SOFA_INCLUDE_DIR -  where to find ode.h, etc.
#  SOFA_LIBRARIES    - List of libraries when using SOFA.
#  SOFA_FOUND        - True if SOFA found.

SET( SOFA_DEFAULT_INSTALL_DIR "" )
IF( MSVC10 )
  IF( H3D_USE_DEPENDENCIES_ONLY)
    foreach( EXTERNAL_INCLUDE_DIR_TMP ${EXTERNAL_INCLUDE_DIR} )
      IF( EXISTS ${EXTERNAL_INCLUDE_DIR_TMP}/sofa )
        SET(SOFA_DEFAULT_INSTALL_DIR "${EXTERNAL_INCLUDE_DIR_TMP}/sofa" )
      ENDIF( EXISTS ${EXTERNAL_INCLUDE_DIR_TMP}/sofa )
    endforeach( EXTERNAL_INCLUDE_DIR_TMP ${EXTERNAL_INCLUDE_DIR} )
  ELSEIF( $ENV{H3D_EXTERNAL_ROOT} )
    SET(SOFA_DEFAULT_INSTALL_DIR "$ENV{H3D_EXTERNAL_ROOT}/include/sofa" )
  ENDIF( H3D_USE_DEPENDENCIES_ONLY )
ENDIF( MSVC10 )
SET(SOFA_INSTALL_DIR "${SOFA_DEFAULT_INSTALL_DIR}" CACHE PATH "Path to root of SOFA installation" )
MARK_AS_ADVANCED(SOFA_INSTALL_DIR)

# Look for the header file.
FIND_PATH( SOFA_INCLUDE_DIR NAMES sofa/core/BehaviorModel.h
           PATHS /usr/local/include/sofa/framework
                 ${SOFA_INSTALL_DIR}/framework )
MARK_AS_ADVANCED(SOFA_INCLUDE_DIR)

FIND_PATH( SOFA_INCLUDE_DIR_MODULES NAMES sofa/sofa.h
           PATHS /usr/local/include/sofa/modules
                 ${SOFA_INSTALL_DIR}/modules )
MARK_AS_ADVANCED(SOFA_INCLUDE_DIR_MODULES)

FIND_PATH( SOFA_INCLUDE_DIR_APP NAMES sofa/gui/SofaGUI.h
           PATHS /usr/local/include/sofa/applications
                 ${SOFA_INSTALL_DIR}/applications )
MARK_AS_ADVANCED(SOFA_INCLUDE_DIR_APP)

FIND_PATH( SOFA_INCLUDE_DIR_BOOST NAMES boost/version.hpp
           PATHS /usr/local/include/sofa/extlibs/miniBoost
                 ${SOFA_INSTALL_DIR}/extlibs/miniBoost )
MARK_AS_ADVANCED(SOFA_INCLUDE_DIR_BOOST)

FIND_PATH( SOFA_INCLUDE_DIR_EIGEN NAMES Eigen/Core Eigen/src/Core
           PATHS /usr/local/include/sofa/extlibs/eigen-3.1.1
                 ${SOFA_INSTALL_DIR}/extlibs/eigen-3.1.1 )
MARK_AS_ADVANCED(SOFA_INCLUDE_DIR_EIGEN)

FIND_PATH( SOFA_INCLUDE_DIR_TINYXML NAMES tinyxml.h
           PATHS /usr/local/include/sofa/extlibs/tinyxml
                 ${SOFA_INSTALL_DIR}/extlibs/tinyxml )
MARK_AS_ADVANCED(SOFA_INCLUDE_DIR_TINYXML)

# SOFA_FIND_COMPONENTS hold the values from COMPONENTS
# in FindPackage(SOFA COMPONENTS core simulation )
SET( SOFA_LIBS ${SOFA_FIND_COMPONENTS} )

SET( LIB_SEARCH_PATHS  )

SET( SOFA_LIBS_FOUND 1 )
SET( SOFA_LIBS_DEBUG_FOUND 1 )

SET( SOFA_LIB_VERSION_MAJOR 1 )
SET( SOFA_LIB_VERSION_MINOR 0 )

SET ( SOFA_LIB_SUFFIX "_${SOFA_LIB_VERSION_MAJOR}_${SOFA_LIB_VERSION_MINOR}" )

SET( SOFA_LIBRARY_NAMES "" CACHE INTERNAL "Internal sofa library list variable. Can be used to setup delayload." FORCE )

include( H3DExternalSearchPath )
GET_FILENAME_COMPONENT( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
get_external_search_paths_h3d( module_include_search_paths module_lib_search_paths ${module_file_path} )

# Look for the libraries.
FOREACH( SOFA_LIB ${SOFA_LIBS})
  STRING(TOUPPER ${SOFA_LIB} _upper_lib_name)
  SET( SOFA_LIBRARY_NAMES ${SOFA_LIBRARY_NAMES} ${SOFA_LIB}${SOFA_LIB_SUFFIX}
       CACHE INTERNAL "Internal sofa library list variable. Can be used to setup delayload." FORCE )
  
  # Look for release library
  FIND_LIBRARY( SOFA_${_upper_lib_name}_LIBRARY NAMES sofa${SOFA_LIB}${SOFA_LIB_SUFFIX}
                                                      sofa_${SOFA_LIB}${SOFA_LIB_SUFFIX}
                PATHS ${SOFA_INSTALL_DIR}/lib
                      ${module_lib_search_paths} )
  MARK_AS_ADVANCED(SOFA_${_upper_lib_name}_LIBRARY)
                      
  # Look for debug library
  FIND_LIBRARY( SOFA_${_upper_lib_name}_DEBUG_LIBRARY NAMES sofa${SOFA_LIB}${SOFA_LIB_SUFFIX}d
                                                            sofa_${SOFA_LIB}${SOFA_LIB_SUFFIX}d
                PATHS ${SOFA_INSTALL_DIR}/lib
                      ${module_lib_search_paths} )
  MARK_AS_ADVANCED(SOFA_${_upper_lib_name}_DEBUG_LIBRARY)
                      
  IF( SOFA_${_upper_lib_name}_LIBRARY )
    SET( SOFA_LIBS_PATHS ${SOFA_LIBS_PATHS} optimized ${SOFA_${_upper_lib_name}_LIBRARY} )
  ELSE( SOFA_${_upper_lib_name}_LIBRARY )
    SET( SOFA_LIBS_FOUND 0 )
    SET( SOFA_LIBS_NOTFOUND ${SOFA_LIBS_NOTFOUND} ${SOFA_LIB} ) 
  ENDIF( SOFA_${_upper_lib_name}_LIBRARY )
  
  IF( SOFA_${_upper_lib_name}_DEBUG_LIBRARY )
    SET( SOFA_LIBS_DEBUG_PATHS ${SOFA_LIBS_DEBUG_PATHS} debug ${SOFA_${_upper_lib_name}_DEBUG_LIBRARY} )
  ELSE( SOFA_${_upper_lib_name}_DEBUG_LIBRARY )
    SET( SOFA_LIBS_DEBUG_FOUND 0 )
    SET( SOFA_LIBS_DEBUG_NOTFOUND ${SOFA_LIBS_DEBUG_NOTFOUND} ${SOFA_LIB} ) 
  ENDIF( SOFA_${_upper_lib_name}_DEBUG_LIBRARY )
ENDFOREACH( SOFA_LIB ${SOFA_LIBS})

# Copy the results to the output variables.
IF(SOFA_INCLUDE_DIR AND SOFA_INCLUDE_DIR_MODULES AND SOFA_INCLUDE_DIR_APP AND SOFA_INCLUDE_DIR_BOOST AND SOFA_INCLUDE_DIR_EIGEN AND SOFA_INCLUDE_DIR_TINYXML AND SOFA_LIBS_FOUND )
  SET(SOFA_FOUND 1)
  SET(SOFA_LIBRARIES ${SOFA_LIBS_PATHS} ${SOFA_LIBS_DEBUG_PATHS} )
  SET(SOFA_INCLUDE_DIR ${SOFA_INCLUDE_DIR} ${SOFA_INCLUDE_DIR_MODULES} ${SOFA_INCLUDE_DIR_APP} ${SOFA_INCLUDE_DIR_BOOST} ${SOFA_INCLUDE_DIR_EIGEN} ${SOFA_INCLUDE_DIR_TINYXML} )
ELSE()
  SET(SOFA_FOUND 0)
  SET(SOFA_LIBRARIES)
  SET(SOFA_INCLUDE_DIR)
ENDIF()

# Report the results.
IF(NOT SOFA_FOUND)
  IF( SOFA_INCLUDE_DIR AND SOFA_INCLUDE_DIR_MODULES AND SOFA_INCLUDE_DIR_APP AND SOFA_INCLUDE_DIR_BOOST AND SOFA_INCLUDE_DIR_EIGEN AND SOFA_INCLUDE_DIR_TINYXML )
    SET(SOFA_DIR_MESSAGE
      "SOFA was not found. Could not find the: ${SOFA_LIBS_NOTFOUND} component(s).")
  ELSE()
    SET(SOFA_DIR_MESSAGE
      "SOFA was not found. Could not find the include files.")

  ENDIF()

  SET(SOFA_DIR_MESSAGE
      "${SOFA_DIR_MESSAGE} Try setting SOFA_INSTALL_DIR to the root of the SOFA installation.")

  IF(SOFA_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR "${SOFA_DIR_MESSAGE}")
  ELSEIF(NOT SOFA_FIND_QUIETLY)
    MESSAGE(STATUS "${SOFA_DIR_MESSAGE}")
  ENDIF(SOFA_FIND_REQUIRED)
ELSEIF(NOT SOFA_FOUND)
  IF(NOT SOFA_LIBS_DEBUG_FOUND)
    MESSAGE(STATUS "Warning: SOFA debug libraries not found. The debug build will not work.")
    MESSAGE(STATUS "Debug libraries for the following components were not found: ${SOFA_LIBS_DEBUG_NOTFOUND}")
  ENDIF(NOT SOFA_LIBS_DEBUG_FOUND)
ENDIF(NOT SOFA_FOUND)
