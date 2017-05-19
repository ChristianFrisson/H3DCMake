# - Find DHD
# Find the native DHD headers and libraries.
#
#  DHD_INCLUDE_DIRS - Where to find DHD headers
#  DHD_LIBRARIES    - List of libraries when using DHD.
#  DHD_FOUND        - True if DHD found.
#  DHD_drd_FOUND    - True if drd header/library was actually found.

include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES DHD_drd_INCLUDE_DIR DHD_drd_LIBRARY DHD_IOKit_LIBRARY DHD_CoreFoundation_LIBRARY DHD_usb_LIBRARY DHD_pciscan_LIBRARY
                                              OLD_VARIABLE_NAMES DHD_DRD_INCLUDE_DIR DHD_DRD_LIBRARY DHD_IOKIT_LIBRARY DHD_COREFOUNDATION_LIBRARY DHD_USB_LIBRARY DHD_PCISCAN_LIBRARY
                                              DOC_STRINGS "Path in which the file drdc.h is located, not needed if DHD_INCLUDE_DIR and DHD_LIBRARY is set."
                                                          "Path to dhd library."
                                                          "Path to IOKit library."
                                                          "Path to CoreFoundation library."
                                                          "Path to usb library."
                                                          "Path to pciscan library." )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "DHD-API" )

# Look for the header file.
find_path( DHD_INCLUDE_DIR NAMES dhdc.h
                           PATHS ${module_include_search_paths}
                           DOC "Path in which the file dhdc.h is located." )
mark_as_advanced( DHD_INCLUDE_DIR )

find_path( DHD_drd_INCLUDE_DIR NAMES drdc.h
                               PATHS ${module_include_search_paths}
                               DOC "Path in which the file drdc.h is located, not needed if DHD_INCLUDE_DIR and DHD_LIBRARY is set." )
mark_as_advanced( DHD_drd_INCLUDE_DIR )

# Look for the library.
set( extra_required_libs )
if( WIN32 )
  find_library( DHD_LIBRARY NAMES dhdms dhdms64
                            PATHS ${module_lib_search_paths}
                            DOC "Path to dhdms library." )
  find_library( DHD_drd_LIBRARY NAMES drdms drdms64
                                PATHS ${module_lib_search_paths}
                                DOC "Path to drdms library, not needed if DHD_INCLUDE_DIR and DHD_LIBRARY is set." )
else()
  find_library( DHD_LIBRARY NAMES dhd
                            PATHS ${module_lib_search_paths}
                            DOC "Path to dhd library." )
  find_library( DHD_drd_LIBRARY NAMES drd
                                PATHS ${module_lib_search_paths}
                                DOC "Path to drd library, not needed if DHD_INCLUDE_DIR and DHD_LIBRARY is set." )

  if( APPLE )
    find_library( DHD_IOKit_LIBRARY NAMES IOKit
                  DOC "Path to IOKit library." )
    find_library( DHD_CoreFoundation_LIBRARY NAMES CoreFoundation
                  DOC "Path to CoreFoundation library." )
    mark_as_advanced( DHD_IOKit_LIBRARY DHD_CoreFoundation_LIBRARY )
    set( extra_required_libs ${extra_required_libs} DHD_IOKit_LIBRARY DHD_CoreFoundation_LIBRARY )
  else()
    if( UNIX )
      find_library( DHD_usb_LIBRARY NAMES usb
                    DOC "Path to usb library." )
      find_library( DHD_pciscan_LIBRARY NAMES pciscan
                    DOC "Path to pciscan library." )
      mark_as_advanced( DHD_usb_LIBRARY DHD_pciscan_LIBRARY )
      set( extra_required_libs ${extra_required_libs} DHD_usb_LIBRARY DHD_pciscan_LIBRARY )
    endif()
  endif()
endif()
mark_as_advanced( DHD_LIBRARY DHD_drd_LIBRARY )

checkIfModuleFound( DHD_drd
                    REQUIRED_VARS DHD_drd_INCLUDE_DIR DHD_drd_LIBRARY ${extra_required_libs} )

if( DHD_drd_FOUND )
  set( DHD_FOUND ${DHD_drd_FOUND} )
  set( DHD_LIBRARIES ${DHD_drd_LIBRARY} ${extra_required_libs} )
  set( DHD_INCLUDE_DIRS ${DHD_drd_INCLUDE_DIR} )
else()
  include( FindPackageHandleStandardArgs )
  # handle the QUIETLY and REQUIRED arguments and set DHD_FOUND to TRUE
  # if all listed variables are TRUE
  find_package_handle_standard_args( DHD DEFAULT_MSG
                                     DHD_INCLUDE_DIR DHD_LIBRARY ${extra_required_libs} )
  set( DHD_LIBRARIES ${DHD_LIBRARY} ${extra_required_libs} )
  set( DHD_INCLUDE_DIRS ${DHD_INCLUDE_DIR} )
endif()

# Backwards compatibility values set here.
set( DHD_DRD_FOUND ${DHD_drd_FOUND} )