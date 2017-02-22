# - Find bzip2
# Find the native BZIP2 headers and libraries.
# If none is found for Windows use the distributed one in External
#
#  BZIP2_INCLUDE_DIR -  where to find bzlip.h, etc.
#  BZIP2_LIBRARIES    - List of libraries when using bzip2.
#  BZIP2_FOUND        - True if bzip2 found.

message( AUTHOR_WARNING "FindH3DBZip2.cmake is deprecated. Change from find_package( H3DBZip2 ) to find_package( BZip2 )." )
set( quiet_required_args )
if( H3DBZip2_FIND_QUIETLY )
  set( quiet_required_args QUIET )
endif()
if( H3DBZip2_FIND_REQUIRED )
  set( quiet_required_args ${quiet_required_args} REQUIRED )
endif()
find_package( BZip2 ${quiet_required_args} )