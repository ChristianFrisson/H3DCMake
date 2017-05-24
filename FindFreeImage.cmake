# - Find FreeImage
# Find the native FreeImage headers and libraries.
#
#  FreeImage_INCLUDE_DIRS -  where to find FreeImage.h, etc.
#  FreeImage_LIBRARIES    - List of libraries when using FreeImage.
#  FreeImage_FOUND        - True if FreeImage found.

include( H3DUtilityFunctions )

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES FreeImage_INCLUDE_DIR FreeImage_LIBRARY
                                              DOC_STRINGS "Path in which the file FreeImage.h is located."
                                                          "Path to freeimage library." )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "FreeImage/Dist" "static" )

# Look for the header file.
find_path( FreeImage_INCLUDE_DIR NAMES FreeImage.h
                                 PATHS ${module_include_search_paths}
                                 DOC "Path in which the file FreeImage.h is located." )

mark_as_advanced( FreeImage_INCLUDE_DIR )

# Look for the library.
find_library( FreeImage_LIBRARY NAMES freeimage
                                PATHS ${module_lib_search_paths}
                                DOC "Path to freeimage library." )
mark_as_advanced( FreeImage_LIBRARY )

if( WIN32 AND H3D_PREFER_STATIC_LIBRARIES )
  set( freeimage_static_library_name FreeImage_vc7 )

  if( MSVC80 )
    set( freeimage_static_library_name FreeImage_vc8 )
  elseif( MSVC90 )
    set( freeimage_static_library_name FreeImage_vc9 )
  elseif( MSVC10 )
    set( freeimage_static_library_name FreeImage_vc10 )
  endif()

  handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES FreeImage_STATIC_LIBRARY_RELEASE FreeImage_STATIC_LIBRARY_DEBUG
                                                OLD_VARIABLE_NAMES FREEIMAGE_STATIC_LIBRARY FREEIMAGE_STATIC_DEBUG_LIBRARY
                                                DOC_STRINGS "Path to freeimage static release library ( windows only ). For this configuration it might be called ${freeimage_static_library_name}"
                                                            "Path to freeimage static debug library ( windows only ). For this configuration it might be called ${freeimage_static_library_name}_d" )

  find_library( FreeImage_STATIC_LIBRARY_RELEASE NAMES ${freeimage_static_library_name}
                                         PATHS ${module_lib_search_paths}
                                         DOC "Path to freeimage static release library ( windows only ). For this configuration it might be called ${freeimage_static_library_name}" )
  mark_as_advanced( FreeImage_STATIC_LIBRARY_RELEASE )

  find_library( FreeImage_STATIC_LIBRARY_DEBUG NAMES ${freeimage_static_library_name}_d
                                               PATHS ${module_lib_search_paths}
                                               DOC "Path to freeimage static debug library ( windows only ). For this configuration it might be called ${freeimage_static_library_name}_d" )
  mark_as_advanced( FreeImage_STATIC_LIBRARY_DEBUG )
endif()

include( FindPackageHandleStandardArgs )
include( SelectLibraryConfigurations )
set( freeimage_static_lib 0 )

# handle the QUIETLY and REQUIRED arguments and set FreeImage_FOUND to TRUE
# if all listed variables are TRUE
if( WIN32 AND H3D_PREFER_STATIC_LIBRARIES )
  select_library_configurations( FreeImage_STATIC )
  find_package_handle_standard_args( FreeImage DEFAULT_MSG
                                     FreeImage_STATIC_LIBRARY FreeImage_INCLUDE_DIR )
  set( FreeImage_LIBRARIES ${FreeImage_STATIC_LIBRARIES} )
  set( freeimage_static_lib ${FREEIMAGE_FOUND} ) # FREEIMAGE_FOUND is set by find_package_handle_standard_args and should be up to date here.
  if( FREEIMAGE_FOUND AND MSVC )
    if( NOT FreeImage_STATIC_LIBRARY_RELEASE )
      message( WARNING "FreeImage static release library not found. Release build might not work properly. To get rid of this warning set FreeImage_STATIC_LIBRARY_RELEASE." )
    endif()
    if( NOT FreeImage_STATIC_LIBRARY_DEBUG )
      message( WARNING "FreeImage static debug library not found. Debug build might not work properly. To get rid of this warning set FreeImage_STATIC_LIBRARY_DEBUG." )
    endif()
  endif()
endif()

if( NOT freeimage_static_lib ) # This goes a bit against the standard, the reason is that if static libraries are desired the normal ones are only fallback.
  find_package_handle_standard_args( FreeImage DEFAULT_MSG
                                     FreeImage_LIBRARY FreeImage_INCLUDE_DIR )
  set( FreeImage_LIBRARIES ${FreeImage_LIBRARY} )
endif()

set( FreeImage_INCLUDE_DIRS ${FreeImage_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( FREEIMAGE_INCLUDE_DIR ${FreeImage_INCLUDE_DIRS} )
set( FREEIMAGE_LIBRARIES ${FreeImage_LIBRARIES} )
set( FreeImage_FOUND ${FREEIMAGE_FOUND} )  # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.