# - Find TEEM
# Find the native TEEM headers and libraries.
#
#  Teem_INCLUDE_DIR -  where to find Teem.h, etc.
#  Teem_LIBRARIES    - List of libraries when using Teem.
#  Teem_FOUND        - True if Teem found.
if( NOT WIN32 )
  set( Teem_NO_LIBRARY_DEPENDS "YES" )
endif( NOT WIN32 )
if(H3DTeem_FIND_REQUIRED)
    find_package(Teem QUIET REQUIRED)
else(H3DTeem_FIND_REQUIRED)
    find_package(Teem QUIET)
endif(H3DTeem_FIND_REQUIRED)

if( Teem_FOUND AND Teem_USE_FILE )
  # We do not use Teem_USE_FILE simply because it uses link_directories which is
  # discouraged nowadays. So we use the TeemConfig.cmake definitions to create
  # Teem_LIBRARIES and Teem_INCLUDE_DIR. If Teem_USE_FILE is ever updated we can
  # check the Teem_VERSION* cmake variables to update this module.
  # include( ${Teem_USE_FILE} ) should be the normal way to do this.
  # On windows Teem_USE_FILE does not work at all due to it not handling Release and Debug
  # sub directories.
  set( Teem_INCLUDE_DIR ${Teem_INCLUDE_DIRS} )
  set( Teem_LIBRARIES_tmp ${Teem_LIBRARIES} )
  # Do we need to loop here? In that case beware of optimized and debug keywords.
  if( EXISTS "${Teem_LIBRARY_DIRS}/lib${Teem_LIBRARIES}.so" )
    set( Teem_LIBRARIES "${Teem_LIBRARY_DIRS}/lib${Teem_LIBRARIES}.so" )
  elseif( EXISTS "${Teem_LIBRARY_DIRS}/lib${Teem_LIBRARIES}.dylib" )
    set( Teem_LIBRARIES "${Teem_LIBRARY_DIRS}/lib${Teem_LIBRARIES}.dylib" )
  else( EXISTS "${Teem_LIBRARY_DIRS}/lib${Teem_LIBRARIES}.so" )
    # The library version is now assumed to be in a default location so we can actually use the UseFile.
    include( ${Teem_USE_FILE} )
  endif( EXISTS "${Teem_LIBRARY_DIRS}/lib${Teem_LIBRARIES}.so" )
else( Teem_FOUND AND Teem_USE_FILE )
  set( Teem_PNG "NO" CACHE BOOL "If teem is built with png support then this variable should be set to ON." )
  if( WIN32 )
    set( Teem_BZIP2 "YES" CACHE BOOL "If teem is built with bz2 support then this variable should be set to ON." )
    set( Teem_ZLIB "YES" CACHE BOOL "If teem is built with zlib support then this variable should be set to ON." )
  else( WIN32 )
    set( Teem_BZIP2 "NO" CACHE BOOL "If teem is built with bz2 support then this variable should be set to ON." )
    set( Teem_ZLIB "NO" CACHE BOOL "If teem is built with zlib support then this variable should be set to ON." )
  endif( WIN32 )

  mark_as_advanced( Teem_BZIP2 )
  mark_as_advanced( Teem_PNG )
  mark_as_advanced( Teem_ZLIB )

  include( H3DExternalSearchPath )
  get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "teem" )

  # Look for the header file.
  find_path(Teem_INCLUDE_DIR NAMES teem/nrrd.h
                             PATHS /usr/local/include
                                   ${module_include_search_paths}
                             DOC "Path in which the file teem/nrrd.h is located." )
  mark_as_advanced(Teem_INCLUDE_DIR)

  # Look for the library.
  find_library(Teem_LIBRARY NAMES teem 
                            PATHS /usr/local/lib
                                  ${module_lib_search_paths}
                            DOC "Path to teem library." )
  mark_as_advanced(Teem_LIBRARY)

  if( Teem_LIBRARY )
    set( FOUND_Teem_LIBRARIES 1 )
  else( Teem_LIBRARY )
    set( FOUND_Teem_LIBRARIES 0 )
  endif( Teem_LIBRARY )

  if( Teem_ZLIB )
    find_package(H3DZLIB)
    if( NOT ZLIB_FOUND )
      set( FOUND_Teem_LIBRARIES 0 )
    endif( NOT ZLIB_FOUND )
  endif( Teem_ZLIB )
  
  if( Teem_ZLIB )
    find_package(H3DZLIB)
    if( NOT ZLIB_FOUND )
      set( FOUND_Teem_LIBRARIES 0 )
    endif( NOT ZLIB_FOUND )
  endif( Teem_ZLIB )

  if( Teem_PNG )
    find_package(PNG)
    if( NOT PNG_FOUND )
      set( FOUND_Teem_LIBRARIES 0 )
    endif( NOT PNG_FOUND )
  endif( Teem_PNG )
  
  if( Teem_BZIP2 )
    find_package(H3DBZip2)
    if( NOT BZIP2_FOUND )
      set( FOUND_Teem_LIBRARIES 0 )
    endif( NOT BZIP2_FOUND )
  endif( Teem_BZIP2 )

  # Copy the results to the output variables.
  if(Teem_INCLUDE_DIR AND FOUND_Teem_LIBRARIES)
    set(Teem_FOUND 1)
    set(Teem_LIBRARIES ${Teem_LIBRARY})

    if( ZLIB_FOUND )
      set(Teem_LIBRARIES ${Teem_LIBRARIES} ${ZLIB_LIBRARIES})
    endif( ZLIB_FOUND )
    if( PNG_FOUND )
      set(Teem_LIBRARIES ${Teem_LIBRARIES} ${PNG_LIBRARIES})
    endif( PNG_FOUND )
    if( BZIP2_FOUND )
      set(Teem_LIBRARIES ${Teem_LIBRARIES} ${BZIP2_LIBRARIES})
    endif( BZIP2_FOUND )
    if( AIR_LIBRARY )
      set(Teem_LIBRARIES ${Teem_LIBRARIES} ${AIR_LIBRARY})
    endif( AIR_LIBRARY )
    if( BIFF_LIBRARY )
      set(Teem_LIBRARIES ${Teem_LIBRARIES} ${BIFF_LIBRARY})
    endif( BIFF_LIBRARY )

    set(Teem_INCLUDE_DIR ${Teem_INCLUDE_DIR})
  else(Teem_INCLUDE_DIR AND FOUND_Teem_LIBRARIES)
    set(Teem_FOUND 0)
    set(Teem_LIBRARIES)
    set(Teem_INCLUDE_DIR)
  endif(Teem_INCLUDE_DIR AND FOUND_Teem_LIBRARIES)
endif( Teem_FOUND AND Teem_USE_FILE )

# Report the results.
if(NOT Teem_FOUND)
  set(Teem_DIR_MESSAGE
    "Teem was not found. Make sure Teem_LIBRARY are set and external libraries required by teem are found.")
  if(Teem_FIND_REQUIRED)
    set( Teem_DIR_MESSAGE
         "${Teem_DIR_MESSAGE} Teem is required to build.")
    message(FATAL_ERROR "${Teem_DIR_MESSAGE}")
  elseif(NOT Teem_FIND_QUIETLY)
    set( Teem_DIR_MESSAGE
         "${Teem_DIR_MESSAGE} If you do not have the libraries you will not be able to load nrrd files.")
    message(STATUS "${Teem_DIR_MESSAGE}")
  endif(Teem_FIND_REQUIRED)
endif(NOT Teem_FOUND)
