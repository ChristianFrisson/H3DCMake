# - Find fparser
# Find the native fparser headers and libraries.
#
#  fparser_INCLUDE_DIRS -  where to find fparser headers
#  fparser_LIBRARIES    - List of libraries when using fparser.
#  fparser_FOUND        - True if fparser found.
message( AUTHOR_WARNING "FindH3Dfparser.cmake is deprecated. Change from find_package( H3Dfparser ) to find_package( fparser )." )
set( quiet_required_args )
if( H3Dfparser_FIND_QUIETLY )
  set( quiet_required_args QUIET )
endif()
if( H3Dfparser_FIND_REQUIRED )
  set( quiet_required_args ${quiet_required_args} REQUIRED )
endif()
find_package( fparser ${quiet_required_args} )