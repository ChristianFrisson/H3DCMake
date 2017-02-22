# - Find GLUT on windows
#
#  GLUT_INCLUDE_DIR  - Where to find GLUT headers
#  GLUT_LIBRARIES    - List of libraries when using GLUT.
#  GLUT_FOUND        - True if GLUT found.

message( AUTHOR_WARNING "FindGLUTWin.cmake is deprecated. Change from find_package( GLUTWin ) to find_package( GLUT )." )
set( quiet_required_args )
if( GLUTWin_FIND_QUIETLY )
  set( quiet_required_args QUIET )
endif()
if( GLUTWin_FIND_REQUIRED )
  set( quiet_required_args ${quiet_required_args} REQUIRED )
endif()
find_package( GLUT ${quiet_required_args} )