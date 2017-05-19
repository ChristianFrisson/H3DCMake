# - Find FontConfig
# Find the native FontConfig headers and libraries.
#
#  FontConfig_INCLUDE_DIRS - Where to find fontconfig.h, etc.
#  FontConfig_LIBRARIES    - List of libraries when using FontConfig.
#  FontConfig_FOUND        - True if FontConfig found.

include( H3DUtilityFunctions )

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES FontConfig_INCLUDE_DIR FontConfig_LIBRARY
                                              DOC_STRINGS "Path in which the file fontconfig/fontconfig.h is located."
                                                          "Path to fontconfig library." )

# Look for the header file.
find_path( FontConfig_INCLUDE_DIR NAMES fontconfig/fontconfig.h
                                  DOC "Path in which the file fontconfig/fontconfig.h is located." )
mark_as_advanced( FontConfig_INCLUDE_DIR )

# Look for the library.
find_library( FontConfig_LIBRARY NAMES fontconfig
                                 DOC "Path to fontconfig library." )
mark_as_advanced( FontConfig_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set FontConfig_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( FontConfig DEFAULT_MSG
                                   FontConfig_LIBRARY FontConfig_INCLUDE_DIR )

set( FontConfig_LIBRARIES ${FontConfig_LIBRARY} )
set( FontConfig_INCLUDE_DIRS ${FontConfig_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( FONTCONFIG_INCLUDE_DIR ${FontConfig_INCLUDE_DIRS} )
set( FONTCONFIG_LIBRARIES ${FontConfig_LIBRARIES} )
set( FontConfig_FOUND ${FONTCONFIG_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.