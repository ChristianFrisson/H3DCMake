# - Find DirectX on windows
#
#  DirectX_INCLUDE_DIRS - Where to find DirectX headers
#  DirectX_LIBRARIES    - List of libraries when using DirectX.
#  DirectX_FOUND        - True if DirectX found.


# Look for the header file.
find_path( DirectX_INCLUDE_DIR NAMES d3d9.h
           PATHS $ENV{DXSDK_DIR}/Include
           DOC "Path in which the file d3d9.h is located."
           NO_DEFAULT_PATH )
mark_as_advanced( DirectX_INCLUDE_DIR )

set( proc_arch x86 )
if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set( proc_arch  x64 )
endif()

# Look for the library.
find_library( DirectX_d3d9_LIBRARY NAMES d3d9
              PATHS $ENV{DXSDK_DIR}/Lib/${proc_arch}
              DOC "Path to d3d9 library."
              NO_DEFAULT_PATH )

find_library( DirectX_d3dx9_LIBRARY NAMES d3dx9
              PATHS $ENV{DXSDK_DIR}/Lib/${proc_arch}
              DOC "Path to d3dx9 library."
              NO_DEFAULT_PATH )

mark_as_advanced( DirectX_d3d9_LIBRARY )
mark_as_advanced( DirectX_d3dx9_LIBRARY )


include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set DirectX_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( DirectX DEFAULT_MSG
                                   DirectX_d3d9_LIBRARY DirectX_d3dx9_LIBRARY DirectX_INCLUDE_DIR )

set( DirectX_LIBRARIES ${DirectX_d3d9_LIBRARY} ${DirectX_d3dx9_LIBRARY} )
set( DirectX_INCLUDE_DIRS ${DirectX_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( DirectX_FOUND ${DIRECTX_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.