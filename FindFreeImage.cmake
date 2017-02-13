# - Find FreeImage
# Find the native FreeImage headers and libraries.
#
#  FreeImage_INCLUDE_DIRS -  where to find FreeImage.h, etc.
#  FreeImage_LIBRARIES    - List of libraries when using FreeImage.
#  FreeImage_FOUND        - True if FreeImage found.

include( H3DExternalSearchPath )
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

if( WIN32 AND PREFER_STATIC_LIBRARIES )
  set( FreeImage_STATIC_LIBRARY_NAME FreeImage_vc7 )
  
  if( MSVC80 )
    set( FreeImage_STATIC_LIBRARY_NAME FreeImage_vc8 )
  elseif( MSVC90 )
    set( FreeImage_STATIC_LIBRARY_NAME FreeImage_vc9 )
  elseif( MSVC10 )
    set( FreeImage_STATIC_LIBRARY_NAME FreeImage_vc10 )
  endif()
  
  find_library( FreeImage_STATIC_LIBRARY NAMES ${FreeImage_STATIC_LIBRARY_NAME}
                                         PATHS ${module_lib_search_paths}
                                         DOC "Path to freeimage static release library (windows only). For this configuration it might be called ${FreeImage_STATIC_LIBRARY_NAME}" )
  mark_as_advanced( FreeImage_STATIC_LIBRARY )
  
  if( FreeImage_STATIC_LIBRARY )
    set( FreeImage_STATIC_LIBRARIES_FOUND 1 )
  endif()
  
  find_library( FreeImage_STATIC_DEBUG_LIBRARY NAMES ${FreeImage_STATIC_LIBRARY_NAME}_d
                                               PATHS ${module_lib_search_paths}
                                               DOC "Path to freeimage static debug library (windows only). For this configuration it might be called ${FreeImage_STATIC_LIBRARY_NAME}_d" )
  mark_as_advanced( FreeImage_STATIC_DEBUG_LIBRARY )
    
  if( FreeImage_STATIC_DEBUG_LIBRARY )
    set( FreeImage_STATIC_LIBRARIES_FOUND 1 )
  endif()
endif()

if( FreeImage_LIBRARY OR FreeImage_STATIC_LIBRARIES_FOUND )
  set( FreeImage_LIBRARIES_FOUND 1 )
endif()

# Copy the results to the output variables.
if( FreeImage_INCLUDE_DIR AND FreeImage_LIBRARIES_FOUND )
  set( FreeImage_FOUND 1 )

  if( WIN32 AND PREFER_STATIC_LIBRARIES AND FreeImage_STATIC_LIBRARIES_FOUND )
    if( FreeImage_STATIC_LIBRARY )
      set( FreeImage_LIBRARIES optimized ${FreeImage_STATIC_LIBRARY} )
    else()
      set( FreeImage_LIBRARIES optimized ${FreeImage_STATIC_LIBRARY_NAME} )
      message( STATUS "FreeImage static release libraries not found. Release build might not work." )
    endif()

    if( FreeImage_STATIC_DEBUG_LIBRARY )
      set( FreeImage_LIBRARIES ${FreeImage_LIBRARIES} debug ${FreeImage_STATIC_DEBUG_LIBRARY} )
    else()
      set( FreeImage_LIBRARIES ${FreeImage_LIBRARIES} debug ${FreeImage_STATIC_LIBRARY_NAME}_d )
      message( STATUS "FreeImage static debug libraries not found. Debug build might not work." )
    endif()

    set( FreeImage_LIB 1 )
  else()
    set( FreeImage_LIBRARIES ${FreeImage_LIBRARY} )
  endif()

  set( FreeImage_INCLUDE_DIRS ${FreeImage_INCLUDE_DIR} )
else()
  set( FreeImage_FOUND 0 )
  set( FreeImage_LIBRARIES )
  set( FreeImage_INCLUDE_DIRS )
endif()

# Report the results.
if( NOT FreeImage_FOUND )
  set( FreeImage_DIR_MESSAGE
       "FreeImage was not found. Make sure FreeImage_LIBRARY" )
  if( WIN32 )
  set( FreeImage_DIR_MESSAGE
       "${FreeImage_DIR_MESSAGE} ( and/or FreeImage_STATIC_LIBRARY/FreeImage_STATIC_DEBUG_LIBRARY )" )
  endif()
  set( FreeImage_DIR_MESSAGE
       "${FreeImage_DIR_MESSAGE} and FreeImage_INCLUDE_DIR are set." )
  if( FreeImage_FIND_REQUIRED )
    set( FreeImage_DIR_MESSAGE
         "${FreeImage_DIR_MESSAGE} FreeImage is required to build." )
    message( FATAL_ERROR "${FreeImage_DIR_MESSAGE}" )
  elseif( NOT FreeImage_FIND_QUIETLY )
    set( FreeImage_DIR_MESSAGE
         "${FreeImage_DIR_MESSAGE} If you do not have it many image formats will not be available to use as textures." )
    message( STATUS "${FreeImage_DIR_MESSAGE}" )
  endif()
endif()

# Handle backwards compatibility issues. Issues stemming from the fact that this module was incorrectly written before.
set( FREEIMAGE_INCLUDE_DIR ${FreeImage_INCLUDE_DIRS} )
set( FREEIMAGE_LIBRARIES ${FreeImage_LIBRARIES} )
set( FREEIMAGE_FOUND ${FreeImage_FOUND} )