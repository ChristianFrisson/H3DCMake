# - Find BULLET
# Find the native BULLET headers and libraries.
#
#  BULLET_INCLUDE_DIRS -  where to find ode.h, etc.
#  BULLET_LIBRARIES    - List of libraries when using BULLET.
#  BULLET_FOUND        - True if BULLET found.

include( H3DExternalSearchPath )
set( bullet_cache_var_names BULLET_COLLISION_LIBRARY BULLET_DYNAMICS_LIBRARY BULLET_MATH_LIBRARY BULLET_SOFTBODY_LIBRARY )

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES ${bullet_cache_var_names}
                                                                 BULLET_COLLISION_LIBRARY_DEBUG BULLET_DYNAMICS_LIBRARY_DEBUG BULLET_MATH_LIBRARY_DEBUG
                                                                 BULLET_SOFTBODY_LIBRARY_DEBUG BULLET_COLLISION_OBJECT_WRAPPER_H
                                              OLD_VARIABLE_NAMES BULLET_H3D_COLLISION_LIBRARY BULLET_H3D_DYNAMICS_LIBRARY BULLET_H3D_MATH_LIBRARY BULLET_H3D_SOFTBODY_LIBRARY
                                                                 BULLET_H3D_COLLISION_DEBUG_LIBRARY BULLET_H3D_DYNAMICS_DEBUG_LIBRARY BULLET_H3D_MATH_DEBUG_LIBRARY
                                                                 BULLET_H3D_SOFTBODY_DEBUG_LIBRARY BULLET_H3D_COLLISION_OBJECT_WRAPPER_H )

checkCMakeInternalModule( Bullet ) # Will call CMakes internal find module for this feature. Do not return if found due to check further down.

set( BULLET_INSTALL_DIR "$ENV{ProgramFiles}/bullet-2.80" CACHE PATH "Path to bullet installation" )
mark_as_advanced( BULLET_INSTALL_DIR )

set( BULLET_LIBRARY_SEARCH_PATHS "" )
set( BULLET_INCLUDE_SEARCH_PATHS "" )
if( MSVC )
  set( check_if_h3d_external_matches_vs_version ON )
  get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
  getExternalSearchPathsH3D( BULLET_INCLUDE_SEARCH_PATHS BULLET_LIBRARY_SEARCH_PATHS ${module_file_path} "bullet" "static" )
endif()

# Look for the header file.
find_path( BULLET_INCLUDE_DIR NAMES btBulletCollisionCommon.h
           PATHS /usr/local/include
                 /usr/local/include/bullet
                 /opt/local/include
                 /opt/local/include/bullet
                 ${BULLET_INCLUDE_SEARCH_PATHS}
                 ${BULLET_INSTALL_DIR}/src
                 ${BULLET_INSTALL_DIR}/include/bullet )

mark_as_advanced( BULLET_INCLUDE_DIR )

# Look for the library.
set( bullet_cache_var_debug_names )
if( WIN32 )
  set( bullet_cache_var_debug_names BULLET_COLLISION_LIBRARY_DEBUG BULLET_DYNAMICS_LIBRARY_DEBUG BULLET_MATH_LIBRARY_DEBUG BULLET_SOFTBODY_LIBRARY_DEBUG )
  find_library( BULLET_COLLISION_LIBRARY NAMES BulletCollision libBulletCollision libbulletcollision
                PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                      ${BULLET_INSTALL_DIR}/lib/release
                      ${BULLET_INSTALL_DIR}/lib )

  find_library( BULLET_COLLISION_LIBRARY_DEBUG NAMES BulletCollision_Debug
                PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                      ${BULLET_INSTALL_DIR}/lib/release )

  find_library( BULLET_DYNAMICS_LIBRARY NAMES BulletDynamics libBulletDynamics libbulletdynamics
                PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                      ${BULLET_INSTALL_DIR}/lib/release
                      ${BULLET_INSTALL_DIR}/lib )

  find_library( BULLET_DYNAMICS_LIBRARY_DEBUG NAMES BulletDynamics_Debug
                PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                      ${BULLET_INSTALL_DIR}/lib/release )

  find_library( BULLET_MATH_LIBRARY NAMES LinearMath libLinearMath libbulletmath
                PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                      ${BULLET_INSTALL_DIR}/lib/release
                      ${BULLET_INSTALL_DIR}/lib )

  find_library( BULLET_MATH_LIBRARY_DEBUG NAMES LinearMath_Debug
                PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                      ${BULLET_INSTALL_DIR}/lib/release )

  find_library( BULLET_SOFTBODY_LIBRARY NAMES BulletSoftBody libBulletSoftBody
                PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                      ${BULLET_INSTALL_DIR}/lib/release
                      ${BULLET_INSTALL_DIR}/lib )

  find_library( BULLET_SOFTBODY_LIBRARY_DEBUG NAMES BulletSoftBody_Debug
                PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                      ${BULLET_INSTALL_DIR}/lib/release )

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

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set BULLET_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( BULLET DEFAULT_MSG
                                   ${bullet_cache_var_names} ${bullet_cache_var_debug_names} BULLET_INCLUDE_DIR )

set( BULLET_INCLUDE_DIRS ${BULLET_INCLUDE_DIR} )
set( BULLET_LIBRARIES )
foreach( bullet_cache_var_name ${bullet_cache_var_names} )
  if( WIN32 )
    set( BULLET_LIBRARIES ${BULLET_LIBRARIES} optimized ${${bullet_cache_var_name}} debug ${${bullet_cache_var_name}_DEBUG} )
  else()
    set( BULLET_LIBRARIES ${BULLET_LIBRARIES} ${${bullet_cache_var_name}} )
  endif()
endforeach()

if( BULLET_FOUND )
  find_path( BULLET_COLLISION_OBJECT_WRAPPER_H NAMES BulletCollision/CollisionDispatch/btCollisionObjectWrapper.h
             PATHS ${BULLET_INCLUDE_DIRS} )
  mark_as_advanced( BULLET_COLLISION_OBJECT_WRAPPER_H )

  if( BULLET_COLLISION_OBJECT_WRAPPER_H )
    set( BULLET_HAVE_COLLISION_OBJECT_WRAPPER 1 )
  else()
    set( BULLET_HAVE_COLLISION_OBJECT_WRAPPER 0 )
  endif()
endif()

