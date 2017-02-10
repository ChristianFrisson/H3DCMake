# - Find BULLET
# Find the native BULLET headers and libraries.
#
#  BULLET_INCLUDE_DIR -  where to find ode.h, etc.
#  BULLET_LIBRARIES    - List of libraries when using BULLET.
#  BULLET_FOUND        - True if BULLET found.
if(H3DBullet_FIND_REQUIRED)
  if( WIN32 )
    find_package(Bullet QUIET)
  else( WIN32 )
    find_package(Bullet REQUIRED)
  endif( WIN32 )
else(H3DBullet_FIND_REQUIRED)
  if( WIN32 )
    find_package(Bullet QUIET)
  else( WIN32 )
    find_package(Bullet)
  endif( WIN32 )
endif(H3DBullet_FIND_REQUIRED)

if( NOT BULLET_FOUND )
  set(BULLET_INSTALL_DIR "$ENV{ProgramFiles}/bullet-2.80" CACHE PATH "Path to bullet installation" )
  mark_as_advanced(BULLET_INSTALL_DIR)

  set( BULLET_LIBRARY_SEARCH_PATHS "" )
  set( BULLET_INCLUDE_SEARCH_PATHS "" )
  if( MSVC )
    include( H3DExternalSearchPath )
    set( check_if_h3d_external_matches_vs_version ON )
    get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
    getExternalSearchPathsH3D( BULLET_INCLUDE_SEARCH_PATHS BULLET_LIBRARY_SEARCH_PATHS ${module_file_path} "bullet" "static" )
  endif( MSVC )

  # Look for the header file.
  find_path( BULLET_INCLUDE_DIR NAMES btBulletCollisionCommon.h
             PATHS /usr/local/include
                   /usr/local/include/bullet
                   /opt/local/include
                   /opt/local/include/bullet
                   ${BULLET_INCLUDE_SEARCH_PATHS}
                   ${BULLET_INSTALL_DIR}/src
                   ${BULLET_INSTALL_DIR}/include/bullet )

  mark_as_advanced(BULLET_INCLUDE_DIR)

  # Look for the library.
  if(WIN32)
    find_library( BULLET_H3D_COLLISION_LIBRARY NAMES BulletCollision libBulletCollision libbulletcollision
                  PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                        ${BULLET_INSTALL_DIR}/lib/release
                        ${BULLET_INSTALL_DIR}/lib )

    find_library( BULLET_H3D_COLLISION_DEBUG_LIBRARY NAMES BulletCollision_Debug
                  PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                        ${BULLET_INSTALL_DIR}/lib/release )

    find_library( BULLET_H3D_DYNAMICS_LIBRARY NAMES BulletDynamics libBulletDynamics libbulletdynamics
                  PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                        ${BULLET_INSTALL_DIR}/lib/release
                        ${BULLET_INSTALL_DIR}/lib )

    find_library( BULLET_H3D_DYNAMICS_DEBUG_LIBRARY NAMES BulletDynamics_Debug
                  PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                        ${BULLET_INSTALL_DIR}/lib/release )

    find_library( BULLET_H3D_MATH_LIBRARY NAMES LinearMath libLinearMath libbulletmath
                  PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                        ${BULLET_INSTALL_DIR}/lib/release
                        ${BULLET_INSTALL_DIR}/lib )

    find_library( BULLET_H3D_MATH_DEBUG_LIBRARY NAMES LinearMath_Debug
                  PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                        ${BULLET_INSTALL_DIR}/lib/release )

    find_library( BULLET_H3D_SOFTBODY_LIBRARY NAMES BulletSoftBody libBulletSoftBody
                  PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                        ${BULLET_INSTALL_DIR}/lib/release
                        ${BULLET_INSTALL_DIR}/lib )

    find_library( BULLET_H3D_SOFTBODY_DEBUG_LIBRARY NAMES BulletSoftBody_Debug
                  PATHS ${BULLET_LIBRARY_SEARCH_PATHS}
                        ${BULLET_INSTALL_DIR}/lib/release )

    mark_as_advanced(BULLET_H3D_COLLISION_DEBUG_LIBRARY)
    mark_as_advanced(BULLET_H3D_DYNAMICS_DEBUG_LIBRARY)
    mark_as_advanced(BULLET_H3D_MATH_DEBUG_LIBRARY)
    mark_as_advanced(BULLET_H3D_SOFTBODY_DEBUG_LIBRARY)
  else(WIN32)
    find_library( BULLET_H3D_COLLISION_LIBRARY NAMES BulletCollision )
    find_library( BULLET_H3D_DYNAMICS_LIBRARY NAMES BulletDynamics )
    find_library( BULLET_H3D_MATH_LIBRARY NAMES LinearMath )
    find_library( BULLET_H3D_SOFTBODY_LIBRARY NAMES BulletSoftBody )
  endif(WIN32)

  mark_as_advanced(BULLET_H3D_COLLISION_LIBRARY)
  mark_as_advanced(BULLET_H3D_DYNAMICS_LIBRARY)
  mark_as_advanced(BULLET_H3D_MATH_LIBRARY)
  mark_as_advanced(BULLET_H3D_SOFTBODY_LIBRARY)

  # Copy the results to the output variables.
  if(BULLET_INCLUDE_DIR AND BULLET_H3D_COLLISION_LIBRARY AND BULLET_H3D_DYNAMICS_LIBRARY AND BULLET_H3D_MATH_LIBRARY AND BULLET_H3D_SOFTBODY_LIBRARY )
    set(BULLET_FOUND 1)
    if( WIN32 )
      set(BULLET_LIBRARIES "" )
      
      if( BULLET_H3D_COLLISION_DEBUG_LIBRARY )
        set(BULLET_LIBRARIES ${BULLET_LIBRARIES} optimized ${BULLET_H3D_COLLISION_LIBRARY} debug ${BULLET_H3D_COLLISION_DEBUG_LIBRARY} )
      else( BULLET_H3D_COLLISION_DEBUG_LIBRARY )
        set(BULLET_LIBRARIES ${BULLET_LIBRARIES} ${BULLET_H3D_COLLISION_LIBRARY} )
      endif( BULLET_H3D_COLLISION_DEBUG_LIBRARY )
      
      if( BULLET_H3D_DYNAMICS_DEBUG_LIBRARY )
        set(BULLET_LIBRARIES ${BULLET_LIBRARIES} optimized ${BULLET_H3D_DYNAMICS_LIBRARY} debug ${BULLET_H3D_DYNAMICS_DEBUG_LIBRARY} )
      else( BULLET_H3D_DYNAMICS_DEBUG_LIBRARY )
        set(BULLET_LIBRARIES ${BULLET_LIBRARIES} ${BULLET_H3D_DYNAMICS_LIBRARY} )
      endif( BULLET_H3D_DYNAMICS_DEBUG_LIBRARY )
      
      if( BULLET_H3D_MATH_DEBUG_LIBRARY )
        set(BULLET_LIBRARIES ${BULLET_LIBRARIES} optimized ${BULLET_H3D_MATH_LIBRARY} debug ${BULLET_H3D_MATH_DEBUG_LIBRARY} )
      else( BULLET_H3D_MATH_DEBUG_LIBRARY )
        set(BULLET_LIBRARIES ${BULLET_LIBRARIES} ${BULLET_H3D_MATH_LIBRARY} )
      endif( BULLET_H3D_MATH_DEBUG_LIBRARY )
      
      if( BULLET_H3D_SOFTBODY_DEBUG_LIBRARY )
        set(BULLET_LIBRARIES ${BULLET_LIBRARIES} optimized ${BULLET_H3D_SOFTBODY_LIBRARY} debug ${BULLET_H3D_SOFTBODY_DEBUG_LIBRARY} )
      else( BULLET_H3D_SOFTBODY_DEBUG_LIBRARY )
        set(BULLET_LIBRARIES ${BULLET_LIBRARIES} ${BULLET_H3D_SOFTBODY_LIBRARY} )
      endif( BULLET_H3D_SOFTBODY_DEBUG_LIBRARY )

    else( WIN32 )
      set(BULLET_LIBRARIES ${BULLET_H3D_COLLISION_LIBRARY} ${BULLET_H3D_DYNAMICS_LIBRARY} ${BULLET_H3D_MATH_LIBRARY} ${BULLET_H3D_SOFTBODY_LIBRARY} )
    endif( WIN32 )
    set(BULLET_INCLUDE_DIR ${BULLET_INCLUDE_DIR})
  else(BULLET_INCLUDE_DIR AND BULLET_H3D_COLLISION_LIBRARY AND BULLET_H3D_DYNAMICS_LIBRARY AND BULLET_H3D_MATH_LIBRARY AND BULLET_H3D_SOFTBODY_LIBRARY )
    set(BULLET_FOUND 0)
    set(BULLET_LIBRARIES)
    set(BULLET_INCLUDE_DIR)
  endif(BULLET_INCLUDE_DIR AND BULLET_H3D_COLLISION_LIBRARY AND BULLET_H3D_DYNAMICS_LIBRARY AND BULLET_H3D_MATH_LIBRARY AND BULLET_H3D_SOFTBODY_LIBRARY )

  if( WIN32 AND ( NOT BULLET_FIND_QUIETLY ) AND ( ( NOT BULLET_H3D_COLLISION_DEBUG_LIBRARY ) OR ( NOT BULLET_H3D_DYNAMICS_DEBUG_LIBRARY ) OR ( NOT BULLET_H3D_MATH_DEBUG_LIBRARY ) OR ( NOT BULLET_H3D_SOFTBODY_DEBUG_LIBRARY ) ) )
    message( STATUS "One or several of Bullet debug libraries could not be found. Debug build might not work." )
  endif( WIN32 AND ( NOT BULLET_FIND_QUIETLY ) AND ( ( NOT BULLET_H3D_COLLISION_DEBUG_LIBRARY ) OR ( NOT BULLET_H3D_DYNAMICS_DEBUG_LIBRARY ) OR ( NOT BULLET_H3D_MATH_DEBUG_LIBRARY ) OR ( NOT BULLET_H3D_SOFTBODY_DEBUG_LIBRARY ) ) )

  # Report the results.
  if(NOT BULLET_FOUND)
    set(BULLET_DIR_MESSAGE
      "BULLET was not found. Try setting BULLET_INSTALL_DIR to the bullet installation path.")
    if(BULLET_FIND_REQUIRED)
      message(FATAL_ERROR "${BULLET_DIR_MESSAGE}")
    elseif(NOT BULLET_FIND_QUIETLY)
      message(STATUS "${BULLET_DIR_MESSAGE}")
    endif(BULLET_FIND_REQUIRED)
  endif(NOT BULLET_FOUND)
endif()

if( BULLET_FOUND )
  find_path( BULLET_H3D_COLLISION_OBJECT_WRAPPER_H NAMES BulletCollision/CollisionDispatch/btCollisionObjectWrapper.h
             PATHS ${BULLET_INCLUDE_DIR} )
  mark_as_advanced( BULLET_H3D_COLLISION_OBJECT_WRAPPER_H )

  if( BULLET_H3D_COLLISION_OBJECT_WRAPPER_H )
    set( BULLET_HAVE_COLLISION_OBJECT_WRAPPER 1 )
  else( BULLET_H3D_COLLISION_OBJECT_WRAPPER_H )
    set( BULLET_HAVE_COLLISION_OBJECT_WRAPPER 0 )
  endif( BULLET_H3D_COLLISION_OBJECT_WRAPPER_H )
endif( BULLET_FOUND )

