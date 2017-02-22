# - Find curl
# Find the native curl headers and libraries.
# If none is found for Windows use the distributed one in External
#
#  CURL_INCLUDE_DIRS - Where to find curl.h, etc.
#  CURL_LIBRARIES    - List of libraries when using curl.
#  CURL_FOUND        - True if curlfound.

message( AUTHOR_WARNING "FindH3DCURL.cmake is deprecated. Change from find_package( H3DCURL ) to find_package( CURL )." )
set( quiet_required_args )
if( H3DCURL_FIND_QUIETLY )
  set( quiet_required_args QUIET )
endif()
if( H3DCURL_FIND_REQUIRED )
  set( quiet_required_args ${quiet_required_args} REQUIRED )
endif()
find_package( CURL ${quiet_required_args} )