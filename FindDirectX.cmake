# - Find DirectX on windows
#
#  DirectX_INCLUDE_DIR -  where to find DirectX headers
#  DirectX_LIBRARIES    - List of libraries when using DirectX.
#  DirectX_FOUND        - True if DirectX found.


# Look for the header file.
find_path( DirectX_INCLUDE_DIR NAMES d3d9.h
           PATHS $ENV{DXSDK_DIR}/Include
           DOC "Path in which the file d3d9.h is located." )
mark_as_advanced(DirectX_INCLUDE_DIR)

# Look for the library.
find_library( DirectX_d3d9_LIBRARY NAMES d3d9
              PATHS $ENV{DXSDK_DIR}/Lib/$ENV{PROCESSOR_ARCHITECTURE}
              DOC "Path to d3d9 library." )

find_library( DirectX_d3dx9_LIBRARY NAMES d3dx9
              PATHS $ENV{DXSDK_DIR}/Lib/$ENV{PROCESSOR_ARCHITECTURE}
              DOC "Path to d3dx9 library." )

mark_as_advanced(DirectX_d3d9_LIBRARY)
mark_as_advanced(DirectX_d3dx9_LIBRARY)

# Copy the results to the output variables.
if(DirectX_INCLUDE_DIR AND DirectX_d3d9_LIBRARY AND DirectX_d3dx9_LIBRARY )
  set(DirectX_FOUND 1)
  set(DirectX_LIBRARIES ${DirectX_d3d9_LIBRARY} ${DirectX_d3dx9_LIBRARY} )
  set(DirectX_INCLUDE_DIR ${DirectX_INCLUDE_DIR})
else(DirectX_INCLUDE_DIR AND DirectX_d3d9_LIBRARY AND DirectX_d3dx9_LIBRARY )
  set(DirectX_FOUND 0)
  set(DirectX_LIBRARIES)
  set(DirectX_INCLUDE_DIR)
endif(DirectX_INCLUDE_DIR AND DirectX_d3d9_LIBRARY AND DirectX_d3dx9_LIBRARY )

# Report the results.
if(NOT DirectX_FOUND)
  set(DirectX_DIR_MESSAGE
    "DirectX was not found. Make sure to set DirectX_d3d9_LIBRARY and DirectX_d3dx9_LIBRARY and DirectX_INCLUDE_DIR to the location of the library and include files. If you do not have it you will not be able to build the DirectXExample of HAPI.")
  if(DirectX_FIND_REQUIRED)
    message(FATAL_ERROR "${DirectX_DIR_MESSAGE}")
  elseif(NOT DirectX_FIND_QUIETLY)
    message(STATUS "${DirectX_DIR_MESSAGE}")
  endif(DirectX_FIND_REQUIRED)
endif(NOT DirectX_FOUND)
