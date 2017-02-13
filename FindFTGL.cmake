# - Find FTGL
# Find the native FTGL headers and libraries.
#
#  FTGL_INCLUDE_DIR -  where to find FTGL.h, etc.
#  FTGL_LIBRARIES    - List of libraries when using FTGL.
#  FTGL_FOUND        - True if FTGL found.
#  FTGL_INCLUDE_IS_UPPER - True if the include file to use is FTGL.h.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "FTGL" )

# Look for the header file.
find_path( FTGL_INCLUDE_DIR NAMES FTGL/ftgl.h 
                            PATHS ${module_include_search_paths}
                            DOC "Path in which the file FTGL/ftgl.h is located." )

# This variable needs to be cached to know what the previous value was. The reason for this
# is because otherwise it would be set to 0 the second time FINDFTGL was run. Other solutions
# to find the file directly does not work since the FIND_FILE and if( EXISTS file_name ) are not
# case sensitive.
set( FTGL_INCLUDE_IS_UPPER "NO" CACHE BOOL "Variable used to check if FTGL include is upper. Must be changed to the correct value if FTGL_INCLUDE_DIR is set manually." )

if( NOT FTGL_INCLUDE_DIR )
  find_path( FTGL_INCLUDE_DIR NAMES FTGL/FTGL.h 
                              PATHS ${module_include_search_paths}
                              DOC "Path in which the file FTGL/FTGL.h is located." )
  # This code is only run if FTGL_INCLUDE_DIR was empty but now is not.
  if( FTGL_INCLUDE_DIR )
    set( FTGL_INCLUDE_IS_UPPER "YES" CACHE BOOL "Variable used to check if FTGL include is upper. Must be changed to the correct value if FTGL_INCLUDE_DIR is set manually." FORCE )
  endif()
endif()

mark_as_advanced( FTGL_INCLUDE_DIR )
mark_as_advanced( FTGL_INCLUDE_IS_UPPER )

# Look for the library.
find_library( FTGL_LIBRARY NAMES ftgl ftgl_dynamic_213rc5 ftgl_dynamic_MTD
                           PATHS ${module_lib_search_paths}
                           DOC "Path to ftgl library." )
mark_as_advanced( FTGL_LIBRARY )

if( WIN32 AND PREFER_STATIC_LIBRARIES )
  set( FTGL_STATIC_LIBRARY_NAME ftgl_static_MTD )
  if( MSVC80 )
    set( FTGL_STATIC_LIBRARY_NAME ftgl_static_MTD_vc8 )
  elseif( MSVC90 )
    set( FTGL_STATIC_LIBRARY_NAME ftgl_static_MTD_vc9 )
  endif()
  
  set( module_include_search_paths "" )
  set( module_lib_search_paths "" )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )
  
  find_library( FTGL_STATIC_LIBRARY NAMES ${FTGL_STATIC_LIBRARY_NAME}
                                         PATHS ${module_lib_search_paths}
                                    DOC "Path to ftgl static library." )
  mark_as_advanced( FTGL_STATIC_LIBRARY )
  
  find_library( FTGL_STATIC_DEBUG_LIBRARY NAMES ${FTGL_STATIC_LIBRARY_NAME}_d
                                                PATHS ${module_lib_search_paths}
                                          DOC "Path to ftgl static debug library." )
  mark_as_advanced( FTGL_STATIC_DEBUG_LIBRARY )
  
  if( FTGL_STATIC_LIBRARY OR FTGL_STATIC_DEBUG_LIBRARY )
    set( FTGL_STATIC_LIBRARIES_FOUND 1 )
  endif()
endif()

if( FTGL_LIBRARY OR FTGL_STATIC_LIBRARIES_FOUND )
  set( FTGL_LIBRARIES_FOUND 1 )
endif()

# Copy the results to the output variables.
if( FTGL_INCLUDE_DIR AND FTGL_LIBRARIES_FOUND )
  set( FTGL_FOUND 1 )
  
  if( WIN32 AND PREFER_STATIC_LIBRARIES AND FTGL_STATIC_LIBRARIES_FOUND )
    if( FTGL_STATIC_LIBRARY )
      set( FTGL_LIBRARIES optimized ${FTGL_STATIC_LIBRARY} )
    else()
      set( FTGL_LIBRARIES optimized ${FTGL_STATIC_LIBRARY_NAME} )
      message( STATUS "FTGL static release libraries not found. Release build might not work." )
    endif()

    if( FTGL_STATIC_DEBUG_LIBRARY )
      set( FTGL_LIBRARIES ${FTGL_LIBRARIES} debug ${FTGL_STATIC_DEBUG_LIBRARY} )
    else()
      set( FTGL_LIBRARIES ${FTGL_LIBRARIES} debug ${FTGL_STATIC_LIBRARY_NAME}_d )
      message( STATUS "FTGL static debug libraries not found. Debug build might not work." )
    endif()
    
    set( FTGL_LIBRARY_STATIC 1 )
  else()
    set( FTGL_LIBRARIES ${FTGL_LIBRARY} )
  endif()

  set( FTGL_INCLUDE_DIR ${FTGL_INCLUDE_DIR} )
else()
  set( FTGL_FOUND 0 )
  set( FTGL_LIBRARIES )
  set( FTGL_INCLUDE_DIR )
endif()

# Report the results.
if( NOT FTGL_FOUND )
  set( FTGL_DIR_MESSAGE
       "FTGL was not found. Make sure FTGL_LIBRARY and FTGL_INCLUDE_DIR are set to the directories containing the include and lib files for FTGL. If you do not have the library you will not be able to use the Text node." )
  if( FTGL_FIND_REQUIRED )
      message( FATAL_ERROR "${FTGL_DIR_MESSAGE}" )
  elseif( NOT FTGL_FIND_QUIETLY )
    message( STATUS "${FTGL_DIR_MESSAGE}" )
  else()
  endif()
endif()
