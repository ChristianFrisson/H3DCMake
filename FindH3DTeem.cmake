# - Find TEEM
# Find the native TEEM headers and libraries.
#
#  Teem_INCLUDE_DIRS -  where to find Teem.h, etc.
#  Teem_LIBRARIES    - List of libraries when using Teem.
#  Teem_FOUND        - True if Teem found.
# Deprecated simply because the output from FindH3DTeem.cmake is not complying with CMake best practices.

message( AUTHOR_WARNING "FindH3DTeem.cmake is deprecated. Change from find_package( H3DTeem ) to find_package( Teem )." )
set( quiet_required_args )
if( H3DTeem_FIND_QUIETLY )
  set( quiet_required_args QUIET )
endif()
if( H3DTeem_FIND_REQUIRED )
  set( quiet_required_args ${quiet_required_args} REQUIRED )
endif()
find_package( Teem ${quiet_required_args} )