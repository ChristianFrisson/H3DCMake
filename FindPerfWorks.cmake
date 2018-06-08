#  - Find the PerfWorks library
#
#  PerfWorks_INCLUDE_DIRS
#  PerfWorks_FOUND
#  PerfWorks_LIBRARIES
#
#

include( H3DUtilityFunctions )

set(PerfWorks_INSTALL_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../../PerfWorks" CACHE PATH "PerfWorks_INSTALL_DIR")
# Look for the header file
find_path( PerfWorks_INCLUDE_DIR NAMES nvperfapi.h
           PATHS ${PerfWorks_INSTALL_DIR}/include
           DOC "Path in which the file nvperfapi.h is located." )
mark_as_advanced( PerfWorks_INCLUDE_DIR )
set( PerfWorks_INCLUDE_DIRS ${PerfWorks_INCLUDE_DIR} )

if ( WIN32 )
  if( CMAKE_CL_64 )
    set( sdk_lib "x64" )
    set( LIBPOSTFIX "64" )
  else( CMAKE_CL_64 )
    set( sdk_lib "x86" )
    set( LIBPOSTFIX "32" )
  endif( CMAKE_CL_64 )
endif()

# Look for the library.
find_library( PerfWorks_LIBRARY NAMES nvperfapi${LIBPOSTFIX}
                                PATHS ${PerfWorks_INSTALL_DIR}/bin/${sdk_lib} )
mark_as_advanced( PerfWorks_LIBRARY )
set( PerfWorks_LIBRARIES ${PerfWorks_LIBRARY} )

include( FindPackageHandleStandardArgs )
find_package_handle_standard_args( PerfWorks DEFAULT_MSG
                                   PerfWorks_LIBRARIES PerfWorks_INCLUDE_DIRS )