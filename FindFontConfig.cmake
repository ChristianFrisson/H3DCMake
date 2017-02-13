# - Find FONTCONFIG
# Find the native FONTCONFIG headers and libraries.
#
#  FONTCONFIG_INCLUDE_DIR -  where to find fontconfig.h, etc.
#  FONTCONFIG_LIBRARIES    - List of libraries when using FONTCONFIG.
#  FONTCONFIG_FOUND        - True if FONTCONFIG found.


# Look for the header file.
find_path( FONTCONFIG_INCLUDE_DIR NAMES fontconfig/fontconfig.h
                                  DOC "Path in which the file fontconfig/fontconfig.h is located." )
mark_as_advanced( FONTCONFIG_INCLUDE_DIR )

# Look for the library.
find_library( FONTCONFIG_LIBRARY NAMES fontconfig
                                 DOC "Path to fontconfig library." )
mark_as_advanced( FONTCONFIG_LIBRARY )

# Copy the results to the output variables.
if( FONTCONFIG_INCLUDE_DIR AND FONTCONFIG_LIBRARY )
  set( FONTCONFIG_FOUND 1 )
  set( FONTCONFIG_LIBRARIES ${FONTCONFIG_LIBRARY} )
  set( FONTCONFIG_INCLUDE_DIR ${FONTCONFIG_INCLUDE_DIR} )
else()
  set( FONTCONFIG_FOUND 0 )
  set( FONTCONFIG_LIBRARIES )
  set( FONTCONFIG_INCLUDE_DIR )
endif()

# Report the results.
if( NOT FONTCONFIG_FOUND )
  set( FONTCONFIG_DIR_MESSAGE
       "FONTCONFIG was not found. Make sure FONTCONFIG_LIBRARY and FONTCONFIG_INCLUDE_DIR are set." )
  if( FontConfig_FIND_REQUIRED )
    message( FATAL_ERROR "${FONTCONFIG_DIR_MESSAGE}" )
  elseif( NOT FontConfig_FIND_QUIETLY )
    message( STATUS "${FONTCONFIG_DIR_MESSAGE}" )
  endif()
endif()
