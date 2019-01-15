# - Find Xerces
# Find the native Xerces headers and libraries.
#
#  XercesC_INCLUDE_DIRS - Where to find Xerces headers.
#  XercesC_LIBRARIES    - List of libraries when using Xerces.
#  XercesC_FOUND        - True if Xerces found.

include( H3DUtilityFunctions )

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES XercesC_INCLUDE_DIR XercesC_LIBRARY XercesC_STATIC_LIBRARY_RELEASE XercesC_STATIC_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES XERCES_INCLUDE_DIR XERCES_LIBRARY XERCES_STATIC_LIBRARY XERCES_STATIC_DEBUG_LIBRARY
                                              DOC_STRINGS "Path in which the file xercesc/sax2/Attributes.hpp is located."
                                                          "Path to xerces library."
                                                          "Path to xerces static library."
                                                          "Path to xerces static debug library." )

include( H3DCommonFindModuleFunctions )
set( msvc_before_vs2010 OFF )
if( MSVC )
  if( ${MSVC_VERSION} LESS 1600 )
    set( msvc_before_vs2010 ON )
  else()
    set( check_if_h3d_external_matches_vs_version ON )
  endif()
endif()

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )

# Look for the header file.
find_path( XercesC_INCLUDE_DIR NAMES xercesc/sax2/Attributes.hpp
                              PATHS ${module_include_search_paths}
                              DOC "Path in which the file xercesc/sax2/Attributes.hpp is located."
                              NO_SYSTEM_ENVIRONMENT_PATH )
mark_as_advanced( XercesC_INCLUDE_DIR )

# Look for the library.
find_library( XercesC_LIBRARY NAMES  xerces-c_3 xerces-c xerces-c_2
                             PATHS ${module_lib_search_paths}
                             DOC "Path to xerces library."
                             NO_SYSTEM_ENVIRONMENT_PATH )
mark_as_advanced( XercesC_LIBRARY )

set( XercesC_LIBRARIES_FOUND 0 )

if( WIN32 AND H3D_PREFER_STATIC_LIBRARIES )
  set( xercesc_static_library_name xerces-c_static_3 xerces-c_static_2 )
  if( MSVC80 )
    set( xercesc_static_library_name xerces-c_static_3_vc8 xerces-c_static_2_vc8 )
  elseif( MSVC90 )
    set( xercesc_static_library_name  xerces-c_static_3_vc9 xerces-c_static_2_vc9 )
  endif()
  set( module_include_search_paths "" )
  set( module_lib_search_paths "" )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )
  find_library( XercesC_STATIC_LIBRARY_RELEASE NAMES ${xercesc_static_library_name}
                                         PATHS ${module_lib_search_paths}
                                         DOC "Path to xerces static library."
                                         NO_SYSTEM_ENVIRONMENT_PATH )
  mark_as_advanced( XercesC_STATIC_LIBRARY_RELEASE )
  
  find_library( XercesC_STATIC_LIBRARY_DEBUG NAMES ${xercesc_static_library_name}_d
                                            PATHS ${module_lib_search_paths}
                                            DOC "Path to xerces static debug library."
                                            NO_SYSTEM_ENVIRONMENT_PATH )
  mark_as_advanced( XercesC_STATIC_LIBRARY_DEBUG )
endif()

include( SelectLibraryConfigurations )
select_library_configurations( fparser )

set( xercesc_staticlib 0 )
# handle the QUIETLY and REQUIRED arguments and set XercesC_FOUND to TRUE
# if all listed variables are TRUE
if( WIN32 AND H3D_PREFER_STATIC_LIBRARIES )
  include( SelectLibraryConfigurations )
  select_library_configurations( XercesC_STATIC )
  checkIfModuleFound( XercesC
                      REQUIRED_VARS XercesC_INCLUDE_DIR XercesC_STATIC_LIBRARY )
  set( XercesC_LIBRARIES ${XercesC_STATIC_LIBRARY} )
  set( xercesc_staticlib ${XercesC_FOUND} ) # XercesC_FOUND is set by checkIfModuleFound and should be up to date here.
  if( XercesC_FOUND )
    if( NOT XercesC_STATIC_LIBRARY_RELEASE )
      message( WARNING "XercesC static release library not found. Release build might not work properly. To get rid of this warning set XercesC_STATIC_LIBRARY_RELEASE." )
    endif()
    if( NOT XercesC_STATIC_LIBRARY_DEBUG )
      message( WARNING "XercesC static debug library not found. Debug build might not work properly. To get rid of this warning set XercesC_STATIC_LIBRARY_DEBUG." )
    endif()
    set( XercesC_LIBRARIES ${XercesC_LIBRARIES} ws2_32.lib )
  endif()
endif()

if( NOT xercesc_staticlib ) # This goes a bit against the standard, the reason is that if static libraries are desired the normal ones are only fallback.
  checkIfModuleFound( XercesC
                      REQUIRED_VARS XercesC_INCLUDE_DIR XercesC_LIBRARY )
  set( XercesC_LIBRARIES ${XercesC_LIBRARY} )
endif()

set( XercesC_INCLUDE_DIRS ${XercesC_INCLUDE_DIR} )

if( NOT XercesC_FOUND )
  checkCMakeInternalModule( XercesC REQUIRED_CMAKE_VERSION "3.1.0" )  # Will call CMakes internal find module for this feature.
endif()

# Backwards compatibility values set here.
set( XERCES_INCLUDE_DIR ${XercesC_INCLUDE_DIRS} )
set( XERCES_INCLUDE_DIRS ${XercesC_INCLUDE_DIRS} )
set( XERCES_LIBRARIES ${XercesC_LIBRARIES} )
set( XERCES_FOUND ${XercesC_FOUND} )