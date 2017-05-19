# - Find Haptik
# Find the native Haptik headers and libraries.
#
#  Haptik_INCLUDE_DIRS -  where to find Haptik headers
#  Haptik_LIBRARIES    - List of libraries when using Haptik.
#  Haptik_FOUND        - True if Haptik found.

include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES Haptik_INCLUDE_DIR Haptik_LIBRARY
                                              DOC_STRINGS "Path in which the file RSLib/Haptik.hpp is located. Needed to support the haptik device."
                                                          "Path to Haptik.Library library. Needed to support the haptik device." )

# Look for the header file.
find_path( Haptik_INCLUDE_DIR NAMES RSLib/Haptik.hpp
                              DOC "Path in which the file RSLib/Haptik.hpp is located. Needed to support the haptik device." )
mark_as_advanced( Haptik_INCLUDE_DIR )

# Look for the library.
find_library( Haptik_LIBRARY NAMES Haptik.Library
                             DOC "Path to Haptik.Library library. Needed to support the haptik device." )
mark_as_advanced( Haptik_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set Haptik_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( Haptik DEFAULT_MSG
                                   Haptik_LIBRARY Haptik_INCLUDE_DIR )

set( Haptik_LIBRARIES ${Haptik_LIBRARY} )
set( Haptik_INCLUDE_DIRS ${Haptik_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( HAPTIK_INCLUDE_DIR ${Haptik_INCLUDE_DIRS} )
set( HAPTIK_LIBRARIES ${Haptik_LIBRARIES} )
set( Haptik_FOUND ${HAPTIK_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.