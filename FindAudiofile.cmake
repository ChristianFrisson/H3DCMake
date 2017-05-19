# - Find Audiofile
# Find the native Audiofile headers and libraries.
#
#  Audiofile_INCLUDE_DIRS -  where to find audiofile.h, etc.
#  Audiofile_LIBRARIES    - List of libraries when using Audiofile.
#  Audiofile_FOUND        - True if Audiofile found.

include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES Audiofile_INCLUDE_DIR Audiofile_LIBRARY
                                              DOC_STRINGS "Path in which the file audiofile.h is located."
                                                          "Path to audiofile library." )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "libaudiofile" )

# Look for the header file.
find_path( Audiofile_INCLUDE_DIR NAMES audiofile.h
           PATHS /usr/local/include
                 ${module_include_search_paths}
           DOC "Path in which the file audiofile.h is located." )
mark_as_advanced( Audiofile_INCLUDE_DIR )

# Look for the library.
# Does this work on UNIX systems? (LINUX)
find_library( Audiofile_LIBRARY NAMES audiofile
              PATHS ${module_lib_search_paths}
              DOC "Path to audiofile library." )
mark_as_advanced( Audiofile_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set Audiofile_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( Audiofile DEFAULT_MSG
                                   Audiofile_LIBRARY Audiofile_INCLUDE_DIR )

set( Audiofile_LIBRARIES ${Audiofile_LIBRARY} )
set( Audiofile_INCLUDE_DIRS ${Audiofile_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( AUDIOFILE_INCLUDE_DIR ${Audiofile_INCLUDE_DIRS} )
set( AUDIOFILE_LIBRARIES ${Audiofile_LIBRARIES} )
set( Audiofile_FOUND ${AUDIOFILE_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.