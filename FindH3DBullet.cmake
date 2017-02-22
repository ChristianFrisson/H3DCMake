# - Find BULLET
# Find the native BULLET headers and libraries.
#
#  BULLET_INCLUDE_DIR -  where to find ode.h, etc.
#  BULLET_LIBRARIES    - List of libraries when using BULLET.
#  BULLET_FOUND        - True if BULLET found.

message( AUTHOR_WARNING "FindH3DBullet.cmake is deprecated. Change from find_package( H3DBullet ) to find_package( Bullet )." )
set( quiet_required_args )
if( H3DBullet_FIND_QUIETLY )
  set( quiet_required_args QUIET )
endif()
if( H3DBullet_FIND_REQUIRED )
  set( quiet_required_args ${quiet_required_args} REQUIRED )
endif()
find_package( Bullet ${quiet_required_args} )