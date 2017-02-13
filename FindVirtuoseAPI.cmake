# - Find VIRTUOSE
# Find the native VIRTUOSE headers and libraries.
#
#  VIRTUOSE_INCLUDE_DIR -  where to find VIRTUOSE headers
#  VIRTUOSE_LIBRARIES    - List of libraries when using VIRTUOSE.
#  VIRTUOSE_FOUND        - True if VIRTUOSE found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

set( VIRTUOSE_INCLUDE_SEARCH_PATHS "" )
set( VIRTUOSE_LIB_SEARCH_PATHS "" )
if( NOT MSVC14 )
  getExternalSearchPathsH3D( VIRTUOSE_INCLUDE_SEARCH_PATHS VIRTUOSE_LIB_SEARCH_PATHS ${module_file_path} )
endif()

# Look for the header file.
find_path( VIRTUOSE_INCLUDE_DIR NAMES VirtuoseAPI.h 
                                PATHS ${VIRTUOSE_INCLUDE_SEARCH_PATHS}
                                DOC "Path in which the file VirtuoseAPI.h is located." )
mark_as_advanced( VIRTUOSE_INCLUDE_DIR )


# Look for the library.
if( WIN32 )
  find_library( VIRTUOSE_LIBRARY NAMES virtuoseDLL
                           PATHS ${VIRTUOSE_LIB_SEARCH_PATHS}
                           DOC "Path to virtuoseDLL.lib library." )
else()
  find_library( VIRTUOSE_LIBRARY NAMES virtuose
                           PATHS ${VIRTUOSE_LIB_SEARCH_PATHS}
                           DOC "Path to dhd library." )

endif()
mark_as_advanced( VIRTUOSE_LIBRARY )


# Copy the results to the output variables.
if( VIRTUOSE_INCLUDE_DIR AND VIRTUOSE_LIBRARY )
  set( VIRTUOSE_FOUND 1 )
  set( VIRTUOSE_LIBRARIES ${VIRTUOSE_LIBRARY} )
  set( VIRTUOSE_INCLUDE_DIR ${VIRTUOSE_INCLUDE_DIR} )
else()
  set( VIRTUOSE_FOUND 0 )
  set( VIRTUOSE_LIBRARIES )
  set( VIRTUOSE_INCLUDE_DIR )
endif()

# Report the results.
if( NOT VIRTUOSE_FOUND )
  set( VIRTUOSE_DIR_MESSAGE
       "VIRTUOSE was not found. Make sure to set VIRTUOSE_LIBRARY" )
  set( VIRTUOSE_DIR_MESSAGE
       "${VIRTUOSE_DIR_MESSAGE} and VIRTUOSE_INCLUDE_DIR. If you do
       not have VirtuouseAPI library you will not be able to use the
       Haption haptics device such as the Virtuose series." )
  if( VIRTUOSE_FIND_REQUIRED )
    message( FATAL_ERROR "${VIRTUOSE_DIR_MESSAGE}" )
  elseif( NOT VIRTUOSE_FIND_QUIETLY )
    message( STATUS "${VIRTUOSE_DIR_MESSAGE}" )
  endif()
endif()
