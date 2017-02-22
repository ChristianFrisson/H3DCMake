# - Find FREETYPE
# Find the native FREETYPE headers and libraries.
#
#  FREETYPE_FOUND        - True if FREETYPE found.
#  FREETYPE_INCLUDE_DIRS -  where to find FREETYPE.h, etc.
#  FREETYPE_LIBRARIES    - List of libraries when using FREETYPE.

message( AUTHOR_WARNING "FindH3DFreetype.cmake is deprecated. Change from find_package( H3DFreetype ) to find_package( Freetype )." )
set( quiet_required_args )
if( H3DFreetype_FIND_QUIETLY )
  set( quiet_required_args QUIET )
endif()
if( H3DFreetype_FIND_REQUIRED )
  set( quiet_required_args ${quiet_required_args} REQUIRED )
endif()
find_package( Freetype ${quiet_required_args} )