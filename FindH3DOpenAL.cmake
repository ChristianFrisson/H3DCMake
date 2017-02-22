# - Find OpenAL
# Find the native OpenAL headers and libraries.
# If none is found for Windows use the distributed one in External
#
#  OPENAL_INCLUDE_DIR -  where to find al.h, etc.
#  OPENAL_LIBRARIES    - List of libraries when using OpenAL.
#  OPENAL_FOUND        - True if OpenAL found.
# NOTE the upper case on the values is because the cmake find module uses upper case and we do not want to
# break that.

message( AUTHOR_WARNING "FindH3DOpenAL.cmake is deprecated. Change from find_package( H3DOpenAL ) to find_package( OpenAL )." )
set( quiet_required_args )
if( H3DOpenAL_FIND_QUIETLY )
  set( quiet_required_args QUIET )
endif()
if( H3DOpenAL_FIND_REQUIRED )
  set( quiet_required_args ${quiet_required_args} REQUIRED )
endif()
find_package( OpenAL ${quiet_required_args} )