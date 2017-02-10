# - Find HACD
# Find the native HACD headers and libraries.
#
#  HACD_INCLUDE_DIR -  where to find the include files of HACD
#  HACD_LIBRARIES    - List of libraries when using HACD.
#  HACD_FOUND        - True if HACD found.
#  HACD_FLAGS        - Flags needed for ode to build 

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "hacd" "static" )

if( CMAKE_CL_64 )
  set( LIB "64" )
else( CMAKE_CL_64 )
  set( LIB "32" )
endif( CMAKE_CL_64 )

set(HACD_INSTALL_DIR "" CACHE PATH "Path to external HACD installation" )

# Look for the header file.
find_path( HACD_INCLUDE_DIR NAMES hacdHACD.h
           PATHS /usr/local/include
                 ${HACD_INSTALL_DIR}/build/win${LIB}/output/include
                 ${module_include_search_paths} )

mark_as_advanced(HACD_INCLUDE_DIR)

# Look for the library.
if(WIN32)

  find_library( HACD_LIB NAMES HACD_LIB
                PATHS ${HACD_INSTALL_DIR}/build/win${LIB}/output/bin
                      ${module_lib_search_paths} )

  find_library( HACD_DEBUG_LIB NAMES HACD_LIB_DEBUG
                PATHS ${HACD_INSTALL_DIR}/build/win${LIB}/output/bin
                      ${module_lib_search_paths} )
   
   mark_as_advanced(HACD_DEBUG_LIB)
                      
else(WIN32)
  find_library( HACD_LIB NAMES HACD_LIB )  
endif(WIN32)

mark_as_advanced(HACD_LIB)

# Copy the results to the output variables.
if ( HACD_INCLUDE_DIR AND 
     HACD_LIB )
  set(HACD_FOUND 1)
  
  if( WIN32 )
    
    set(HACD_LIBRARIES "" )
    
    if( HACD_DEBUG_LIB )
      set(HACD_LIBRARIES ${HACD_LIBRARIES} optimized ${HACD_LIB} debug ${HACD_DEBUG_LIB} )
    else( HACD_DEBUG_LIB )
      set(HACD_LIBRARIES ${HACD_LIB})
    endif( HACD_DEBUG_LIB )
    
  else( WIN32 )
    set(HACD_LIBRARIES ${HACD_LIB})
  endif( WIN32 )
  
  
  set(HACD_INCLUDE_DIR ${HACD_INCLUDE_DIR} )
else()
  set(HACD_FOUND 0)
  set(HACD_LIBRARIES)
  set(HACD_INCLUDE_DIR)
endif()

# Report the results.
if(NOT HACD_FOUND)
  set(HACD_DIR_MESSAGE
    "HACD was not found. Set HACD_INSTALL_DIR to the root directory of the "
    "installation containing the 'build' folders.")
  if(HACD_FIND_REQUIRED)
    message(FATAL_ERROR "${HACD_DIR_MESSAGE}")
  elseif(NOT HACD_FIND_QUIETLY)
    message(STATUS "${HACD_DIR_MESSAGE}")
  endif(HACD_FIND_REQUIRED)
endif(NOT HACD_FOUND)
