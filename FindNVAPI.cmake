#  - Find the nvapi library
#
#  NVAPI_INCLUDE_DIRS
#  NVAPI_LIBRARIES
#  NVAPI_FOUND
#
#

include( H3DUtilityFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH  )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "nvapi" )

set(NVAPI_INSTALL_DIR "" CACHE PATH "NVAPI library installation directory which contains nvapi.h")
# Look for the header file
find_path( NVAPI_INCLUDE_DIR NAMES nvapi.h
           PATHS ${NVAPI_INSTALL_DIR}
                 ${module_include_search_paths}
           DOC "Path in which the file nvapi.h is located." )
mark_as_advanced( NVAPI_INCLUDE_DIR )
set(NVAPI_INCLUDE_DIRS ${NVAPI_INCLUDE_DIR})

getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )

if ( WIN32 )
  if( CMAKE_CL_64 )
    set( sdk_lib "amd64" )
    set( LIBPOSTFIX "64" )
  else( CMAKE_CL_64 )
    set( sdk_lib "x86" )
    set( LIBPOSTFIX "" )
  endif( CMAKE_CL_64 )
endif()
# Look for the library.
find_library( NVAPI_LIBRARY NAMES  nvapi${LIBPOSTFIX}
                          PATHS ${NVAPI_INSTALL_DIR}/${sdk_lib}
                                ${module_lib_search_paths}
                                
                          DOC "Path to nvapi library." )
mark_as_advanced( NVAPI_LIBRARY )
set(NVAPI_LIBRARIES ${NVAPI_LIBRARY})

include( FindPackageHandleStandardArgs )
find_package_handle_standard_args( NVAPI DEFAULT_MSG
                                   NVAPI_LIBRARIES NVAPI_INCLUDE_DIRS )