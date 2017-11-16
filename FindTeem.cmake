# - Find TEEM
# Find the native TEEM headers and libraries.
#
#  Teem_INCLUDE_DIRS - Where to find Teem.h, etc.
#  Teem_LIBRARIES    - List of libraries when using Teem.
#  Teem_FOUND        - True if Teem found.
if( NOT WIN32 )
  set( Teem_NO_LIBRARY_DEPENDS "YES" )
endif()

# This module starts with calling CMakes internal find module, which does not exist but
# a config file is found on some systems. If that config file is used (Teem_USE_FILE)
# then this version is used instead.
include( H3DCommonFindModuleFunctions )
set( teem_find_quietly_old ${Teem_FIND_QUIETLY} )
set( teem_find_required_old ${Teem_FIND_REQUIRED} )
set( Teem_FIND_QUIETLY TRUE )
set( Teem_FIND_REQUIRED FALSE )
checkCMakeInternalModule( Teem ) # Will call CMakes internal find module for this feature.
set( Teem_FIND_QUIETLY ${teem_find_quietly_old} )
set( Teem_FIND_REQUIRED ${teem_find_required_old} )

if( Teem_FOUND AND Teem_USE_FILE )
  # We do not use Teem_USE_FILE simply because it uses link_directories which is
  # discouraged nowadays. So we use the TeemConfig.cmake definitions to create
  # Teem_LIBRARIES and Teem_INCLUDE_DIRS. If Teem_USE_FILE is ever updated we can
  # check the Teem_VERSION* cmake variables to update this module.
  # include( ${Teem_USE_FILE} ) should be the normal way to do this.
  # On ubuntu artful Teem_USE_FILE also does not work due to using deprecated cmake functionality that sets up a target that does not build.
  # On windows Teem_USE_FILE does not work at all due to it not handling Release and Debug
  # sub directories.
  set( Teem_INCLUDE_DIR ${Teem_INCLUDE_DIRS} )
  # Do we need to loop here? In that case beware of optimized and debug keywords.
  if( EXISTS "${Teem_LIBRARY_DIRS}/lib${Teem_LIBRARIES}.so" )
    set( Teem_LIBRARIES "${Teem_LIBRARY_DIRS}/lib${Teem_LIBRARIES}.so" )
  elseif( EXISTS "${Teem_LIBRARY_DIRS}/lib${Teem_LIBRARIES}.dylib" )
    set( Teem_LIBRARIES "${Teem_LIBRARY_DIRS}/lib${Teem_LIBRARIES}.dylib" )
  elseif( EXISTS "/usr/lib/lib${Teem_LIBRARIES}.so" )
    set( Teem_LIBRARIES "/usr/lib/lib${Teem_LIBRARIES}.so" )
  else()
    # The library version is now assumed to be in a default location so we can actually use the UseFile.
    include( ${Teem_USE_FILE} )
  endif()
else()
  set( Teem_PNG "NO" CACHE BOOL "If teem is built with png support then this variable should be set to ON." )
  if( WIN32 )
    set( Teem_BZIP2 "YES" CACHE BOOL "If teem is built with bz2 support then this variable should be set to ON." )
    set( Teem_ZLIB "YES" CACHE BOOL "If teem is built with zlib support then this variable should be set to ON." )
  else()
    set( Teem_BZIP2 "NO" CACHE BOOL "If teem is built with bz2 support then this variable should be set to ON." )
    set( Teem_ZLIB "NO" CACHE BOOL "If teem is built with zlib support then this variable should be set to ON." )
  endif()

  mark_as_advanced( Teem_BZIP2 )
  mark_as_advanced( Teem_PNG )
  mark_as_advanced( Teem_ZLIB )

  get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "teem" )

  # Look for the header file.
  find_path( Teem_INCLUDE_DIR NAMES teem/nrrd.h
                              PATHS /usr/local/include
                                    ${module_include_search_paths}
                              DOC "Path in which the file teem/nrrd.h is located."
                              NO_SYSTEM_ENVIRONMENT_PATH )
  mark_as_advanced( Teem_INCLUDE_DIR )

  # Look for the library.
  find_library( Teem_LIBRARY NAMES teem
                             PATHS /usr/local/lib
                                   ${module_lib_search_paths}
                             DOC "Path to teem library."
                             NO_SYSTEM_ENVIRONMENT_PATH )
  mark_as_advanced( Teem_LIBRARY )

  set( teem_external_libraries )
  set( quiet_required_args )
  if( Teem_FIND_QUIETLY )
    set( quiet_required_args QUIET )
  endif()
  if( Teem_FIND_REQUIRED )
    set( quiet_required_args ${quiet_required_args} REQUIRED )
  endif()

  if( Teem_ZLIB )
    find_package( ZLIB ${quiet_required_args} )
    set( teem_external_libraries ${teem_external_libraries} ZLIB_LIBRARIES )
  endif()

  if( Teem_PNG )
    find_package( PNG ${quiet_required_args} )
    set( teem_external_libraries ${teem_external_libraries} PNG_LIBRARIES )
  endif()

  if( Teem_BZIP2 )
    find_package( BZip2 ${quiet_required_args} )
    set( teem_external_libraries ${teem_external_libraries} BZIP2_LIBRARIES )
  endif()

  find_package_handle_standard_args( Teem DEFAULT_MSG
                                     Teem_LIBRARY Teem_INCLUDE_DIR ${teem_external_libraries} )

  set( Teem_INCLUDE_DIRS ${Teem_INCLUDE_DIR} )
  set( Teem_LIBRARIES ${Teem_LIBRARY} )
  foreach( external_lib ${teem_external_libraries} )
    set( Teem_LIBRARIES ${Teem_LIBRARIES} ${${external_lib}} )
  endforeach()

  if( AIR_LIBRARY )
    set( Teem_LIBRARIES ${Teem_LIBRARIES} ${AIR_LIBRARY} )
  endif()
  if( BIFF_LIBRARY )
    set( Teem_LIBRARIES ${Teem_LIBRARIES} ${BIFF_LIBRARY} )
  endif()

  # Backwards compatibility values set here.
  set( Teem_INCLUDE_DIR ${Teem_INCLUDE_DIRS} )
  set( Teem_FOUND ${TEEM_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.
endif()
