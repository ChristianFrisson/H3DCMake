# - Find SPIDERMONKEY
# Find the native SPIDERMONKEY headers and libraries.
#
#  SpiderMonkey_INCLUDE_DIR -  where to find jsapi.h, etc.
#  SpiderMonkey_LIBRARIES    - List of libraries when using SpiderMonkey.
#  SpiderMonkey_FOUND        - True if SpiderMonkey found.

include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES SpiderMonkey_INCLUDE_DIR SpiderMonkey_LIBRARY
                                              DOC_STRINGS "Path in which the file jsapi.h is located."
                                                          "Path to js32 or mozjs library." )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "js" )

# Look for the header file.
find_path( SpiderMonkey_INCLUDE_DIR NAMES jsapi.h
           PATHS /usr/local/include
                 /usr/local/include/mozjs
                 /usr/local/include/js
                 /opt/local/include/js
                 /usr/include/mozjs
                 /usr/include/js
                 ${module_include_search_paths}
           DOC "Path in which the file jsapi.h is located." )
mark_as_advanced( SpiderMonkey_INCLUDE_DIR )

# Look for the library.
# Does this work on UNIX systems? (LINUX)
if( WIN32 )
  find_library( SpiderMonkey_LIBRARY NAMES js32
                PATHS ${module_lib_search_paths}
                DOC "Path to js32 library." )
else()
  find_library( SpiderMonkey_LIBRARY NAMES mozjs js
                                     DOC "Path to mozjs library." )
endif()
mark_as_advanced( SpiderMonkey_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set SpiderMonkey_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( SpiderMonkey DEFAULT_MSG
                                   SpiderMonkey_LIBRARY SpiderMonkey_INCLUDE_DIR )

set( SpiderMonkey_LIBRARIES ${SpiderMonkey_LIBRARY} )
set( SpiderMonkey_INCLUDE_DIRS ${SpiderMonkey_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( SPIDERMONKEY_INCLUDE_DIR ${SpiderMonkey_INCLUDE_DIRS} )
set( SPIDERMONKEY_LIBRARIES ${SpiderMonkey_LIBRARIES} )
set( SpiderMonkey_FOUND ${SPIDERMONKEY_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.