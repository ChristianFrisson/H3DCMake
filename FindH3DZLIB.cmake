# - Find zlib
# Find the native ZLIB headers and libraries.
# If none is found for Windows use the distributed one in External
#
#  ZLIB_INCLUDE_DIRS -  where to find zlib.h, etc.
#  ZLIB_LIBRARIES    - List of libraries when using zlib.
#  ZLIB_FOUND        - True if zlib found.

message( AUTHOR_WARNING "FindH3DZLIB.cmake is deprecated. Change from find_package( H3DZLIB ) to find_package( ZLIB )." )
set( quiet_required_args )
if( H3DZLIB_FIND_QUIETLY )
  set( quiet_required_args QUIET )
endif()
if( H3DZLIB_FIND_REQUIRED )
  set( quiet_required_args ${quiet_required_args} REQUIRED )
endif()
find_package( ZLIB ${quiet_required_args} )