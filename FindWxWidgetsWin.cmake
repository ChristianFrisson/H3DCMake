# - Find wxWidgets
# Find the native wxWidgets headers and libraries.
#
#  wxWidgets_INCLUDE_DIR -  where to find WxWidgets headers
#  wxWidgets_LIBRARIES    - List of libraries when using WxWidgets.
#  wxWidgets_FOUND        - True if WxWidgets found.

message( AUTHOR_WARNING "FindWxWidgetsWin.cmake is deprecated. Change from find_package( WxWidgetsWin ) or find_package( wxWidgetsWin ) to find_package( wxWidgets )." )
set( quiet_required_args )
if( WxWidgetsWin_FIND_QUIETLY )
  set( quiet_required_args QUIET )
endif()
if( WxWidgetsWin_FIND_REQUIRED )
  set( quiet_required_args ${quiet_required_args} REQUIRED )
endif()
find_package( wxWidgets ${quiet_required_args} )