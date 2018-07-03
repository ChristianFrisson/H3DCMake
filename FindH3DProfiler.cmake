# - Find H3DProfiler
# Find the native H3DProfiler headers and libraries.
#
# H3DProfiler_INCLUDE_DIRS - Where to find H3DProfiler.h, etc.
# H3DProfiler_LIBRARIES    - List of libraries when using H3DProfiler.
# H3DProfiler_FOUND        - True if H3DProfiler is found.

include( H3DUtilityFunctions )

if( MSVC )
  getMSVCPostFix( msvc_postfix )
  set( h3dprofiler_name "H3DProfiler${msvc_postfix}" )
else()
  set( h3dprofiler_name h3dprofiler )
endif()

set(H3DProfiler_INSTALL_DIR "$ENV{H3DPROFILER_ROOT}" CACHE PATH "H3DProfiler_INSTALL_DIR")
# Look for the header file
find_path( H3DProfiler_INCLUDE_DIR NAMES H3DProfiler.h
           PATHS ${H3DProfiler_INSTALL_DIR}/include/H3DProfiler
           DOC "Path in which the file H3DProfiler.h is located." )
mark_as_advanced( H3DProfiler_INCLUDE_DIR )
set( H3DProfiler_INCLUDE_DIRS ${H3DProfiler_INCLUDE_DIR}/.. )

if ( WIN32 )
  if( CMAKE_CL_64 )
    set( lib_folder "lib64" )
  else( CMAKE_CL_64 )
    set( lib_folder "lib32" )
  endif( CMAKE_CL_64 )
endif()

# Look for the library.
find_library( H3DProfiler_LIBRARY_RELEASE NAMES ${h3dprofiler_name}
              PATHS ${H3DProfiler_INSTALL_DIR}/${lib_folder}
              DOC "Path to ${h3dprofiler_name} library." )

find_library( H3DProfiler_LIBRARY_DEBUG NAMES ${h3dprofiler_name}_d
              PATHS ${H3DProfiler_INSTALL_DIR}/${lib_folder}
              DOC "Path to ${h3dprofiler_name}_d library." )

mark_as_advanced( H3DUtil_LIBRARY_RELEASE H3DUtil_LIBRARY_DEBUG )

set( H3DProfiler_LIBRARIES debug ${H3DProfiler_LIBRARY_DEBUG} optimized ${H3DProfiler_LIBRARY_RELEASE} )

include( FindPackageHandleStandardArgs )
find_package_handle_standard_args( H3DProfiler DEFAULT_MSG
                                   H3DProfiler_LIBRARIES H3DProfiler_INCLUDE_DIRS )