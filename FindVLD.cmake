# - Find vld(visual leak detector)
# Find the visual leak detector headers and libraries.
#
#  VLD_INCLUDE_DIR -  where to find vld.h,vld_def.h, etc.
#  VLD_LIBRARIES    - List of libraries when using vld.
#  VLD_FOUND        - True if vld found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )

if( CMAKE_CL_64 )
  message( SEND_ERROR "64 bit version of visual leak detector is not tested yet." )
endif()
# Look for the header file.
find_path( VLD_INCLUDE_DIR NAMES vld/vld.h
                           PATHS ${module_include_search_paths}
                           DOC "Path in which the file vld/vld.h is located." )
mark_as_advanced( VLD_INCLUDE_DIR )

# Look for the library.
find_library( VLD_LIBRARY NAMES  vld
                          PATHS ${module_lib_search_paths}
                          DOC "Path to vld library." )
mark_as_advanced( VLD_LIBRARY )

set( VLD_LIBRARIES_FOUND 0 )

if( VLD_LIBRARY )
  set( VLD_LIBRARIES_FOUND 1 )
endif()

# Copy the results to the output variables.
if( VLD_INCLUDE_DIR AND VLD_LIBRARIES_FOUND )
  set( VLD_FOUND 1 )
  set( VLD_LIBRARIES ${VLD_LIBRARY} )
  set( VLD_INCLUDE_DIR ${VLD_INCLUDE_DIR} )
else()
  set( VLD_FOUND 0 )
  set( VLD_LIBRARIES )
  set( VLD_INCLUDE_DIR )
endif()

# Report the results.
if( NOT VLD_FOUND )
  set( VLD_DIR_MESSAGE
       "visual leak detector was not found. Make sure VLD_LIBRARY and VLD_INCLUDE_DIR are set to the directory of your visual leak detector lib and include files." )
  if( VLD_FIND_REQUIRED )
    message( FATAL_ERROR "${VLD_DIR_MESSAGE}" )
  elseif( NOT VLD_FIND_QUIETLY )
    message( STATUS "${VLD_DIR_MESSAGE}" )
  endif()
endif()
