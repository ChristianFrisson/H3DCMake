# - Find BULLET
# Find the native BULLET headers and libraries.
#
#  BULLET_INCLUDE_DIRS -  where to find ode.h, etc.
#  BULLET_LIBRARIES    - List of libraries when using BULLET.
#  BULLET_FOUND        - True if BULLET found.

include( H3DUtilityFunctions )
set( bullet_cache_var_names BULLET_COLLISION_LIBRARY BULLET_DYNAMICS_LIBRARY BULLET_MATH_LIBRARY BULLET_SOFTBODY_LIBRARY )

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES ${bullet_cache_var_names}
                                                                 BULLET_COLLISION_LIBRARY_DEBUG BULLET_DYNAMICS_LIBRARY_DEBUG BULLET_MATH_LIBRARY_DEBUG
                                                                 BULLET_SOFTBODY_LIBRARY_DEBUG BULLET_COLLISION_OBJECT_WRAPPER_H
                                              OLD_VARIABLE_NAMES BULLET_H3D_COLLISION_LIBRARY BULLET_H3D_DYNAMICS_LIBRARY BULLET_H3D_MATH_LIBRARY BULLET_H3D_SOFTBODY_LIBRARY
                                                                 BULLET_H3D_COLLISION_DEBUG_LIBRARY BULLET_H3D_DYNAMICS_DEBUG_LIBRARY BULLET_H3D_MATH_DEBUG_LIBRARY
                                                                 BULLET_H3D_SOFTBODY_DEBUG_LIBRARY BULLET_H3D_COLLISION_OBJECT_WRAPPER_H )

include( H3DCommonFindModuleFunctions )
set( BULLET_INSTALL_DIR "" CACHE PATH "Path to bullet installation" )
mark_as_advanced( BULLET_INSTALL_DIR )

set( bullet_library_search_paths "" )
set( bullet_include_search_paths "" )
if( MSVC )
  set( check_if_h3d_external_matches_vs_version ON )
  get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
  getExternalSearchPathsH3D( bullet_include_search_paths bullet_library_search_paths ${module_file_path} "bullet" "static" )
endif()

# Look for the header file.
find_path( BULLET_INCLUDE_DIR NAMES btBulletCollisionCommon.h
           PATHS /usr/local/include
                 /usr/local/include/bullet
                 /opt/local/include
                 /opt/local/include/bullet
                 ${bullet_include_search_paths}
                 ${BULLET_INSTALL_DIR}/src
                 ${BULLET_INSTALL_DIR}/include/bullet )

mark_as_advanced( BULLET_INCLUDE_DIR )

# Look for the library.
set( bullet_cache_var_debug_names )
if( WIN32 )
  set( bullet_cache_var_debug_names BULLET_COLLISION_LIBRARY_DEBUG BULLET_DYNAMICS_LIBRARY_DEBUG BULLET_MATH_LIBRARY_DEBUG BULLET_SOFTBODY_LIBRARY_DEBUG )
  find_library( BULLET_COLLISION_LIBRARY NAMES BulletCollision libBulletCollision libbulletcollision
                PATHS ${bullet_library_search_paths}
                      ${BULLET_INSTALL_DIR}/lib/release
                      ${BULLET_INSTALL_DIR}/lib
                NO_SYSTEM_ENVIRONMENT_PATH )

  find_library( BULLET_COLLISION_LIBRARY_DEBUG NAMES BulletCollision_Debug
                PATHS ${bullet_library_search_paths}
                      ${BULLET_INSTALL_DIR}/lib/release
                NO_SYSTEM_ENVIRONMENT_PATH )

  find_library( BULLET_DYNAMICS_LIBRARY NAMES BulletDynamics libBulletDynamics libbulletdynamics
                PATHS ${bullet_library_search_paths}
                      ${BULLET_INSTALL_DIR}/lib/release
                      ${BULLET_INSTALL_DIR}/lib
                NO_SYSTEM_ENVIRONMENT_PATH )

  find_library( BULLET_DYNAMICS_LIBRARY_DEBUG NAMES BulletDynamics_Debug
                PATHS ${bullet_library_search_paths}
                      ${BULLET_INSTALL_DIR}/lib/release
                NO_SYSTEM_ENVIRONMENT_PATH )

  find_library( BULLET_MATH_LIBRARY NAMES LinearMath libLinearMath libbulletmath
                PATHS ${bullet_library_search_paths}
                      ${BULLET_INSTALL_DIR}/lib/release
                      ${BULLET_INSTALL_DIR}/lib
                NO_SYSTEM_ENVIRONMENT_PATH )

  find_library( BULLET_MATH_LIBRARY_DEBUG NAMES LinearMath_Debug
                PATHS ${bullet_library_search_paths}
                      ${BULLET_INSTALL_DIR}/lib/release
                NO_SYSTEM_ENVIRONMENT_PATH )

  find_library( BULLET_SOFTBODY_LIBRARY NAMES BulletSoftBody libBulletSoftBody
                PATHS ${bullet_library_search_paths}
                      ${BULLET_INSTALL_DIR}/lib/release
                      ${BULLET_INSTALL_DIR}/lib
                NO_SYSTEM_ENVIRONMENT_PATH )

  find_library( BULLET_SOFTBODY_LIBRARY_DEBUG NAMES BulletSoftBody_Debug
                PATHS ${bullet_library_search_paths}
                      ${BULLET_INSTALL_DIR}/lib/release
                NO_SYSTEM_ENVIRONMENT_PATH )

  mark_as_advanced( BULLET_COLLISION_LIBRARY_DEBUG )
  mark_as_advanced( BULLET_DYNAMICS_LIBRARY_DEBUG )
  mark_as_advanced( BULLET_MATH_LIBRARY_DEBUG )
  mark_as_advanced( BULLET_SOFTBODY_LIBRARY_DEBUG )
else()
  find_library( BULLET_COLLISION_LIBRARY NAMES BulletCollision )
  find_library( BULLET_DYNAMICS_LIBRARY NAMES BulletDynamics )
  find_library( BULLET_MATH_LIBRARY NAMES LinearMath )
  find_library( BULLET_SOFTBODY_LIBRARY NAMES BulletSoftBody )
endif()

mark_as_advanced( BULLET_COLLISION_LIBRARY )
mark_as_advanced( BULLET_DYNAMICS_LIBRARY )
mark_as_advanced( BULLET_MATH_LIBRARY )
mark_as_advanced( BULLET_SOFTBODY_LIBRARY )

checkIfModuleFound( BULLET
                    REQUIRED_VARS BULLET_INCLUDE_DIR ${bullet_cache_var_names} ${bullet_cache_var_debug_names} )

set( BULLET_INCLUDE_DIRS ${BULLET_INCLUDE_DIR} )
set( BULLET_LIBRARIES )
foreach( bullet_cache_var_name ${bullet_cache_var_names} )
  if( WIN32 )
    set( BULLET_LIBRARIES ${BULLET_LIBRARIES} optimized ${${bullet_cache_var_name}} debug ${${bullet_cache_var_name}_DEBUG} )
  else()
    set( BULLET_LIBRARIES ${BULLET_LIBRARIES} ${${bullet_cache_var_name}} )
  endif()
endforeach()

if( NOT BULLET_FOUND )
  checkCMakeInternalModule( Bullet OUTPUT_AS_UPPER_CASE )  # Will call CMakes internal find module for this feature.
endif()

if( BULLET_FOUND )
  find_path( BULLET_COLLISION_OBJECT_WRAPPER_H NAMES BulletCollision/CollisionDispatch/btCollisionObjectWrapper.h
             PATHS ${BULLET_INCLUDE_DIRS}
             NO_SYSTEM_PATH )
  mark_as_advanced( BULLET_COLLISION_OBJECT_WRAPPER_H )

  if( BULLET_COLLISION_OBJECT_WRAPPER_H )
    set( BULLET_HAVE_COLLISION_OBJECT_WRAPPER 1 )
  else()
    set( BULLET_HAVE_COLLISION_OBJECT_WRAPPER 0 )
  endif()
endif()

