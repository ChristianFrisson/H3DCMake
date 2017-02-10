# - Find FREEIMAGE
# Find the native FREEIMAGE headers and libraries.
#
#  FREEIMAGE_INCLUDE_DIR -  where to find FREEIMAGE.h, etc.
#  FREEIMAGE_LIBRARIES    - List of libraries when using FREEIMAGE.
#  FREEIMAGE_FOUND        - True if FREEIMAGE found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "FreeImage/Dist" "static" )

# Look for the header file.
find_path(FREEIMAGE_INCLUDE_DIR NAMES FreeImage.h
                                PATHS ${module_include_search_paths}
                                DOC "Path in which the file FreeImage.h is located." )

mark_as_advanced(FREEIMAGE_INCLUDE_DIR)

# Look for the library.
find_library(FREEIMAGE_LIBRARY NAMES freeimage
                               PATHS ${module_lib_search_paths}
                               DOC "Path to freeimage library." )
mark_as_advanced(FREEIMAGE_LIBRARY)

if( WIN32 AND PREFER_STATIC_LIBRARIES )
  set( FREEIMAGE_STATIC_LIBRARY_NAME FreeImage_vc7 )
  
  if( MSVC80 )
    set( FREEIMAGE_STATIC_LIBRARY_NAME FreeImage_vc8 )
  elseif( MSVC90 )
    set( FREEIMAGE_STATIC_LIBRARY_NAME FreeImage_vc9 )
  elseif( MSVC10 )
    set( FREEIMAGE_STATIC_LIBRARY_NAME FreeImage_vc10 )
  endif( MSVC80 )
  
  find_library( FREEIMAGE_STATIC_LIBRARY NAMES ${FREEIMAGE_STATIC_LIBRARY_NAME}
                                         PATHS ${module_lib_search_paths}
                                         DOC "Path to freeimage static release library (windows only). For this configuration it might be called ${FREEIMAGE_STATIC_LIBRARY_NAME}" )
  mark_as_advanced(FREEIMAGE_STATIC_LIBRARY)
  
  if( FREEIMAGE_STATIC_LIBRARY )
    set( FREEIMAGE_STATIC_LIBRARIES_FOUND 1 )
  endif( FREEIMAGE_STATIC_LIBRARY )
  
  find_library( FREEIMAGE_STATIC_DEBUG_LIBRARY NAMES ${FREEIMAGE_STATIC_LIBRARY_NAME}_d
                                               PATHS ${module_lib_search_paths}
                                               DOC "Path to freeimage static debug library (windows only). For this configuration it might be called ${FREEIMAGE_STATIC_LIBRARY_NAME}_d" )
  mark_as_advanced(FREEIMAGE_STATIC_DEBUG_LIBRARY)
    
  if( FREEIMAGE_STATIC_DEBUG_LIBRARY )
    set( FREEIMAGE_STATIC_LIBRARIES_FOUND 1 )
  endif( FREEIMAGE_STATIC_DEBUG_LIBRARY )
endif( WIN32 AND PREFER_STATIC_LIBRARIES )

if( FREEIMAGE_LIBRARY OR FREEIMAGE_STATIC_LIBRARIES_FOUND )
  set( FREEIMAGE_LIBRARIES_FOUND 1 )
endif( FREEIMAGE_LIBRARY OR FREEIMAGE_STATIC_LIBRARIES_FOUND )

# Copy the results to the output variables.
if(FREEIMAGE_INCLUDE_DIR AND FREEIMAGE_LIBRARIES_FOUND)
  set(FREEIMAGE_FOUND 1)

  if( WIN32 AND PREFER_STATIC_LIBRARIES AND FREEIMAGE_STATIC_LIBRARIES_FOUND )
    if(FREEIMAGE_STATIC_LIBRARY)
      set(FREEIMAGE_LIBRARIES optimized ${FREEIMAGE_STATIC_LIBRARY} )
    else(FREEIMAGE_STATIC_LIBRARY)
      set(FREEIMAGE_LIBRARIES optimized ${FREEIMAGE_STATIC_LIBRARY_NAME} )
      message( STATUS "FreeImage static release libraries not found. Release build might not work." )
    endif(FREEIMAGE_STATIC_LIBRARY)

    if(FREEIMAGE_STATIC_DEBUG_LIBRARY)
      set(FREEIMAGE_LIBRARIES ${FREEIMAGE_LIBRARIES} debug ${FREEIMAGE_STATIC_DEBUG_LIBRARY} )
    else(FREEIMAGE_STATIC_DEBUG_LIBRARY)
      set(FREEIMAGE_LIBRARIES ${FREEIMAGE_LIBRARIES} debug ${FREEIMAGE_STATIC_LIBRARY_NAME}_d )
      message( STATUS "FreeImage static debug libraries not found. Debug build might not work." )
    endif(FREEIMAGE_STATIC_DEBUG_LIBRARY)

    set( FREEIMAGE_LIB 1 )
  else( WIN32 AND PREFER_STATIC_LIBRARIES AND FREEIMAGE_STATIC_LIBRARIES_FOUND )
    set(FREEIMAGE_LIBRARIES ${FREEIMAGE_LIBRARY})
  endif( WIN32 AND PREFER_STATIC_LIBRARIES AND FREEIMAGE_STATIC_LIBRARIES_FOUND )

  set(FREEIMAGE_INCLUDE_DIR ${FREEIMAGE_INCLUDE_DIR})
else(FREEIMAGE_INCLUDE_DIR AND FREEIMAGE_LIBRARIES_FOUND)
  set(FREEIMAGE_FOUND 0)
  set(FREEIMAGE_LIBRARIES)
  set(FREEIMAGE_INCLUDE_DIR)
endif(FREEIMAGE_INCLUDE_DIR AND FREEIMAGE_LIBRARIES_FOUND)

# Report the results.
if(NOT FREEIMAGE_FOUND)
  set( FREEIMAGE_DIR_MESSAGE
       "FREEIMAGE was not found. Make sure FREEIMAGE_LIBRARY")
  if( WIN32 )
  set( FREEIMAGE_DIR_MESSAGE
       "${FREEIMAGE_DIR_MESSAGE} ( and/or FREEIMAGE_STATIC_LIBRARY/FREEIMAGE_STATIC_DEBUG_LIBRARY )")
  endif( WIN32 )
  set( FREEIMAGE_DIR_MESSAGE
       "${FREEIMAGE_DIR_MESSAGE} and FREEIMAGE_INCLUDE_DIR are set.")
  if(FreeImage_FIND_REQUIRED)
    set( FREEIMAGE_DIR_MESSAGE
         "${FREEIMAGE_DIR_MESSAGE} FREEIMAGE is required to build.")
    message(FATAL_ERROR "${FREEIMAGE_DIR_MESSAGE}")
  elseif(NOT FreeImage_FIND_QUIETLY)
    set( FREEIMAGE_DIR_MESSAGE
         "${FREEIMAGE_DIR_MESSAGE} If you do not have it many image formats will not be available to use as textures.")
    message(STATUS "${FREEIMAGE_DIR_MESSAGE}")
  endif(FreeImage_FIND_REQUIRED)
endif(NOT FREEIMAGE_FOUND)
