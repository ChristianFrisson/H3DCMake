# - Find sofa helper library
# Find the sofahelper headers and libraries.

#  SofaHelper_INCLUDE_DIRS -  where to find helper.h, AdvancedTimer.h etc.
#  SofaHelper_LIBRARIES    - List of libraries when using sofa helper component.
#  SofaHelper_FOUND        - True if sofa helper found.


include( H3DUtilityFunctions )

if( WIN32 )
  set( SOFA_LIBRARY_POSTFIX "_17_06" )
  if( MSVC AND MSVC_VERSION LESS 1700 )
    set( SOFA_LIBRARY_POSTFIX "_16_08" )
  endif()
endif()

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES SofaHelper_INCLUDE_DIR SofaHelper_LIBRARY_RELEASE SofaHelper_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES SOFAHELPER_INCLUDE_DIR SOFAHELPER_LIBRARY SOFAHELPER_DEBUG_LIBRARY
                                              DOC_STRINGS "Path in which the file AdvancedTimer.h is located."
                                                          "Path to SofaHelper${SOFA_LIBRARY_POSTFIX}_h3d library."
                                                          "Path to SofaHelper${SOFA_LIBRARY_POSTFIX}d_h3d library." )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "sofahelper" "sofahelper/framework" )

# Look for the header file.
find_path( SofaHelper_INCLUDE_DIR NAMES   sofa_h3d/helper/AdvancedTimer.h
                                  PATHS   ${module_include_search_paths}
                                  NO_DEFAULT_PATH 
                                  DOC     "Path in which the file AdvancedTimer.h is located." )
# Look for the library.
find_library( SofaHelper_LIBRARY_RELEASE   NAMES   SofaHelper${SOFA_LIBRARY_POSTFIX}_h3d
                                   PATHS   ${module_lib_search_paths}
                                   DOC     "Path to SofaHelper${SOFA_LIBRARY_POSTFIX}_h3d library." )
find_library( SofaHelper_LIBRARY_DEBUG NAMES   SofaHelper${SOFA_LIBRARY_POSTFIX}d_h3d
                                       PATHS   ${module_lib_search_paths}
                                       DOC     "Path to SofaHelper${SOFA_LIBRARY_POSTFIX}d_h3d library." )
                                       
mark_as_advanced( SofaHelper_INCLUDE_DIR )
mark_as_advanced( SofaHelper_LIBRARY_RELEASE )
mark_as_advanced( SofaHelper_LIBRARY_DEBUG )


include( SelectLibraryConfigurations )
select_library_configurations( SofaHelper )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set SofaHelper_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( SofaHelper DEFAULT_MSG
                                   SofaHelper_LIBRARY SofaHelper_INCLUDE_DIR )
set( SofaHelper_INCLUDE_DIRS ${SofaHelper_INCLUDE_DIR} )
set( SofaHelper_LIBRARIES ${SofaHelper_LIBRARY} )

# Backwards compatibility values set here.
set( SOFAHELPER_INCLUDE_DIR ${SofaHelper_INCLUDE_DIRS} )
set( SOFAHELPER_LIBRARIES ${SofaHelper_LIBRARIES} )
set( SofaHelper_FOUND ${SOFAHELPER_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.