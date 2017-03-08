# - Find Xerces
# Find the native Xerces headers and libraries.
#
#  XercesC_INCLUDE_DIRS - Where to find Xerces headers.
#  XercesC_LIBRARIES    - List of libraries when using Xerces.
#  XercesC_FOUND        - True if Xerces found.

message( AUTHOR_WARNING "FindXerces.cmake is deprecated. Change from find_package( Xerces ) to find_package( XercesC )." )
set( quiet_required_args )
if( Xerces_FIND_QUIETLY )
  set( quiet_required_args QUIET )
endif()
if( Xerces_FIND_REQUIRED )
  set( quiet_required_args ${quiet_required_args} REQUIRED )
endif()
find_package( XercesC ${quiet_required_args} )