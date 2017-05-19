# - Find SimballMedical
# Find the native SimballMedical headers and libraries.
#
#  SimballMedical_INCLUDE_DIRS - Where to find SimballMedicalHID.h, etc.
#  SimballMedical_LIBRARIES    - List of libraries when using SimballMedical.
#  SimballMedical_FOUND        - True if SimballMedical found.

include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES SimballMedical_INCLUDE_DIR SimballMedical_LIBRARY
                                              DOC_STRINGS "Path in which the file Simball/SimballMedicalHID.h is located. Needed to support Simball device."
                                                          "Path to SimballMedicalHID library. Needed to support Simball device." )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )

# Look for the header file.
find_path( SimballMedical_INCLUDE_DIR NAMES Simball/SimballMedicalHID.h
                                      PATHS ${module_include_search_paths}
                                      DOC "Path in which the file Simball/SimballMedicalHID.h is located. Needed to support Simball device." )
mark_as_advanced( SimballMedical_INCLUDE_DIR )

# Look for the library.
find_library( SimballMedical_LIBRARY NAMES SimballMedicalHID
                        PATHS ${module_lib_search_paths}
                        DOC "Path to SimballMedicalHID library. Needed to support Simball device." )
mark_as_advanced( SimballMedical_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set SimballMedical_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( SimballMedical DEFAULT_MSG
                                   SimballMedical_LIBRARY SimballMedical_INCLUDE_DIR )

set( SimballMedical_LIBRARIES ${SimballMedical_LIBRARY} )
set( SimballMedical_INCLUDE_DIRS ${SimballMedical_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( SIMBALLMEDICAL_INCLUDE_DIR ${SimballMedical_INCLUDE_DIRS} )
set( SIMBALLMEDICAL_LIBRARIES ${SimballMedical_LIBRARIES} )
set( SimballMedical_FOUND ${SIMBALLMEDICAL_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.