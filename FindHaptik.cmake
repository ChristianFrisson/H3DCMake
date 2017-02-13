# - Find Haptik
# Find the native HAPTIK headers and libraries.
#
#  HAPTIK_INCLUDE_DIR -  where to find Haptik headers
#  HAPTIK_LIBRARIES    - List of libraries when using Haptik.
#  HAPTIK_FOUND        - True if Haptik found.


# Look for the header file.
find_path( HAPTIK_INCLUDE_DIR NAMES RSLib/Haptik.hpp
                              DOC "Path in which the file RSLib/Haptik.hpp is located." )
mark_as_advanced( HAPTIK_INCLUDE_DIR )

# Look for the library.
find_library( HAPTIK_LIBRARY NAMES Haptik.Library
                             DOC "Path to Haptik.Library library." )
mark_as_advanced( HAPTIK_LIBRARY )

# Copy the results to the output variables.
if( HAPTIK_INCLUDE_DIR AND HAPTIK_LIBRARY )
  set( HAPTIK_FOUND 1 )
  set( HAPTIK_LIBRARIES ${HAPTIK_LIBRARY} )
  set( HAPTIK_INCLUDE_DIR ${HAPTIK_INCLUDE_DIR} )
else()
  set( HAPTIK_FOUND 0 )
  set( HAPTIK_LIBRARIES )
  set( HAPTIK_INCLUDE_DIR )
endif()

# Report the results.
if( NOT HAPTIK_FOUND )
  set( HAPTIK_DIR_MESSAGE
       "The HAPTIK API was not found. Make sure to set HAPTIK_LIBRARY and HAPTIK_INCLUDE_DIR to the location of the library. If you do not have it you will not be able to use the haptik device." )
  if( Haptik_FIND_REQUIRED )
    message( FATAL_ERROR "${HAPTIK_DIR_MESSAGE}" )
  elseif( NOT Haptik_FIND_QUIETLY )
    message( STATUS "${HAPTIK_DIR_MESSAGE}" )
  endif()
endif()
