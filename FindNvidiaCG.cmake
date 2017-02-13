# - Find the NVIDIA CG Toolkit
#
#  NVIDIACG_INCLUDE_DIR -  where to find cg.h, etc.
#  NVIDIACG_LIBRARIES    - List of libraries when using NVIDIA CG Toolkit.
#  NVIDIACG_FOUND        - True if the NVIDIA CG Toolkit is found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "Cg" "cg" )

# Look for the header file.
find_path( NVIDIACG_INCLUDE_DIR NAMES cg.h cgGL.h
           PATHS /usr/local/include
                 ${module_include_search_paths}
           DOC "Path in which the file cg.h and cgGL.h are located." )
mark_as_advanced( NVIDIACG_INCLUDE_DIR )

# Look for the library cg.
# Does this work on UNIX systems? (LINUX)
find_library( NVIDIACG_LIBRARY NAMES cg Cg
              PATHS ${module_lib_search_paths}
              DOC "Path to cg library." )
mark_as_advanced( NVIDIACG_LIBRARY )

# Look for the library cg.
# Does this work on UNIX systems? (LINUX)
find_library( NVIDIACG_CGGL_LIBRARY NAMES cgGL CgGL
              PATHS ${module_lib_search_paths}
              DOC "Path to cgGL library." )
mark_as_advanced( NVIDIACG_CGGL_LIBRARY )

# Copy the results to the output variables.
if( NVIDIACG_INCLUDE_DIR AND NVIDIACG_LIBRARY AND NVIDIACG_CGGL_LIBRARY )
  set( NVIDIACG_FOUND 1 )
  set( NVIDIACG_LIBRARIES ${NVIDIACG_LIBRARY} ${NVIDIACG_CGGL_LIBRARY} )
  set( NVIDIACG_INCLUDE_DIR ${NVIDIACG_INCLUDE_DIR} )
else()
  set( NVIDIACG_FOUND 0 )
  set( NVIDIACG_LIBRARIES )
  set( NVIDIACG_INCLUDE_DIR )
endif()

# Report the results.
if( NOT NVIDIACG_FOUND )
  set( NVIDIACG_DIR_MESSAGE
       "NVIDIAs CG Toolkit was not found. Make sure NVIDIACG_LIBRARY and NVIDIACG_INCLUDE_DIR are set." )
  if( NvidiaCG_FIND_REQUIRED )
    message( FATAL_ERROR "${NVIDIACG_DIR_MESSAGE}" )
  elseif( NOT NvidiaCG_FIND_QUIETLY )
    message( STATUS "${NVIDIACG_DIR_MESSAGE}" )
  endif()
endif()
