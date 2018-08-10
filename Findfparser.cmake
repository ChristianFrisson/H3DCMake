# - Find fparser
# Find the native fparser headers and libraries.
#
#  fparser_INCLUDE_DIRS - Where to find fparser headers
#  fparser_LIBRARIES    - List of libraries when using fparser.
#  fparser_FOUND        - True if fparser found.
include( H3DUtilityFunctions )

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES fparser_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES fparser_DEBUG_LIBRARY
                                              DOC_STRINGS "Path to fparser debug library." )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "fparser" )

# Look for the header file.
find_path( fparser_INCLUDE_DIR NAMES fparser.hh
                               PATHS ${module_include_search_paths}
                                     "/usr/local/include/fparser"
                               DOC "Path in which the file fparser.hh is located." )
mark_as_advanced( fparser_INCLUDE_DIR )


# Look for the library.
find_library( fparser_LIBRARY_RELEASE NAMES fparser
                                      PATHS ${module_lib_search_paths}
                                      DOC "Path to fparser library." )
mark_as_advanced( fparser_LIBRARY_RELEASE )

find_library( fparser_LIBRARY_DEBUG NAMES fparser_d
                                    PATHS ${module_lib_search_paths}
                                    DOC "Path to fparser debug library." )
mark_as_advanced( fparser_LIBRARY_DEBUG )

include( SelectLibraryConfigurations )
select_library_configurations( fparser )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set fparser_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( fparser DEFAULT_MSG
                                   fparser_INCLUDE_DIR fparser_LIBRARY )

set( fparser_LIBRARIES ${fparser_LIBRARY} )
set( fparser_INCLUDE_DIRS ${fparser_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( fparser_INCLUDE_DIR ${fparser_INCLUDE_DIRS} )
set( fparser_FOUND ${FPARSER_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.

# Additional message on MSVC
if( fparser_FOUND AND MSVC )
  if( NOT fparser_LIBRARY_RELEASE )
    message( WARNING "fparser release library not found. Release build might not work properly. To get rid of this warning set fparser_LIBRARY_RELEASE." )
  endif()
  if( NOT fparser_LIBRARY_DEBUG )
    message( WARNING "fparser debug library not found. Debug build might not work properly. To get rid of this warning set fparser_LIBRARY_DEBUG." )
  endif()
endif()
