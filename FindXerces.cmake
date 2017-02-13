# - Find XERCES
# Find the native XERCES headers and libraries.
#
#  XERCES_INCLUDE_DIR -  where to find XERCES.h, etc.
#  XERCES_LIBRARIES    - List of libraries when using XERCES.
#  XERCES_FOUND        - True if XERCES found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )

# Look for the header file.
find_path( XERCES_INCLUDE_DIR NAMES xercesc/sax2/Attributes.hpp
                              PATHS ${module_include_search_paths}
                              DOC "Path in which the file xercesc/sax2/Attributes.hpp is located." )
mark_as_advanced( XERCES_INCLUDE_DIR )

# Look for the library.
find_library( XERCES_LIBRARY NAMES  xerces-c_3 xerces-c xerces-c_2
                             PATHS ${module_lib_search_paths}
                             DOC "Path to xerces library." )
mark_as_advanced( XERCES_LIBRARY )

set( XERCES_LIBRARIES_FOUND 0 )
set( XERCES_STATIC_LIBRARIES_FOUND 0 )

if( WIN32 AND PREFER_STATIC_LIBRARIES )
  set( XERCES_STATIC_LIBRARY_NAME xerces-c_static_3 xerces-c_static_2 )
  if( MSVC80 )
    set( XERCES_STATIC_LIBRARY_NAME xerces-c_static_3_vc8 xerces-c_static_2_vc8 )
  elseif( MSVC90 )
    set( XERCES_STATIC_LIBRARY_NAME  xerces-c_static_3_vc9 xerces-c_static_2_vc9 )
  endif()
  set( module_include_search_paths "" )
  set( module_lib_search_paths "" )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )
  find_library( XERCES_STATIC_LIBRARY NAMES ${XERCES_STATIC_LIBRARY_NAME}
                                         PATHS ${module_lib_search_paths}
                                         DOC "Path to xerces static library." )
  mark_as_advanced( XERCES_STATIC_LIBRARY )
  
  find_library( XERCES_STATIC_DEBUG_LIBRARY NAMES ${XERCES_STATIC_LIBRARY_NAME}_d
                                            PATHS ${module_lib_search_paths}
                                            DOC "Path to xerces static debug library." )
  mark_as_advanced( XERCES_STATIC_DEBUG_LIBRARY )
  
  if( XERCES_STATIC_LIBRARY OR XERCES_STATIC_DEBUG_LIBRARY )
    set( XERCES_STATIC_LIBRARIES_FOUND 1 )
  endif()

endif()

if( XERCES_LIBRARY OR XERCES_STATIC_LIBRARIES_FOUND )
  set( XERCES_LIBRARIES_FOUND 1 )
endif()

# Copy the results to the output variables.
if( XERCES_INCLUDE_DIR AND XERCES_LIBRARIES_FOUND )
  set( XERCES_FOUND 1 )
  
  if( WIN32 AND PREFER_STATIC_LIBRARIES AND XERCES_STATIC_LIBRARIES_FOUND )
    if( XERCES_STATIC_LIBRARY )
      set( XERCES_LIBRARIES optimized ${XERCES_STATIC_LIBRARY} )
    else()
      set( XERCES_LIBRARIES optimized ${XERCES_STATIC_LIBRARY_NAME} )
      message( STATUS "Xerces static release libraries not found. Release build might not work." )
    endif()

    if( XERCES_STATIC_DEBUG_LIBRARY )
      set( XERCES_LIBRARIES ${XERCES_LIBRARIES} debug ${XERCES_STATIC_DEBUG_LIBRARY} )
    else()
      set( XERCES_LIBRARIES ${XERCES_LIBRARIES} debug ${XERCES_STATIC_LIBRARY_NAME}_d )
      message( STATUS "Xerces static debug libraries not found. Debug build might not work." )
    endif()

    set( XERCES_LIBRARIES ${XERCES_LIBRARIES} ws2_32.lib )
    set( XML_LIBRARY 1 )
  else()
    set( XERCES_LIBRARIES ${XERCES_LIBRARY} )
  endif()

  set( XERCES_INCLUDE_DIR ${XERCES_INCLUDE_DIR} )
else()
  set( XERCES_FOUND 0 )
  set( XERCES_LIBRARIES )
  set( XERCES_INCLUDE_DIR )
endif()

# Report the results.
if( NOT XERCES_FOUND )
  set( XERCES_DIR_MESSAGE
       "Xerces-c was not found. Make sure XERCES_LIBRARY and "
       "XERCES_INCLUDE_DIR are set to the directory of your xerces lib and "
       "include files. If you do not have Xerces x3d/xml files cannot be parsed." )
  if( Xerces_FIND_REQUIRED )
    message( FATAL_ERROR "${XERCES_DIR_MESSAGE}" )
  elseif( NOT Xerces_FIND_QUIETLY )
    message( STATUS "${XERCES_DIR_MESSAGE}" )
  endif()
endif()
