# - Find Chai3D
# Find the native Chai3D headers and libraries.
#
#  Chai3D_INCLUDE_DIR -  where to find Chai3D headers
#  Chai3D_LIBRARIES    - List of libraries when using Chai3D.
#  Chai3D_FOUND        - True if Chai3D found.
if( WIN32 )
  set( chai3d_library_name chai3d_complete )
  if( MSVC70 OR MSVC71 )
    set( chai3d_library_name chai3d_complete_vc7 )
  elseif( MSVC80 )
    set( chai3d_library_name chai3d_complete_vc8 )
  elseif( MSVC90 )
    set( chai3d_library_name chai3d_complete_vc9 )
  elseif( MSVC10 )
    set( chai3d_library_name chai3d_complete_vc10 )
  endif()
else()

endif()

include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES Chai3D_INCLUDE_DIR Chai3D_LIBRARY_RELEASE Chai3D_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES CHAI3D_INCLUDE_DIR CHAI3D_LIBRARY CHAI3D_DEBUG_LIBRARY
                                              DOC_STRINGS "Path to include files for chai3d. The path is to where chai3d.h ( cWorld.h for chai3d versions earlier than 2.0 ) is located."
                                                          "Path to chai3d library (possible names also include ${chai3d_library_name}, chai3d-release and chai3d_linux)"
                                                          "Path to ${chai3d_library_name}_d or chai3d-debug library." )

set( search_for_chai3d 1 )

if( MSVC )
  include( testIfVCExpress )
  testIfVCExpress()
  if( NOT CMake_HAVE_MFC )
    set( search_for_chai3d 0 )
  endif()
endif()

if( search_for_chai3d )
  include( H3DCommonFindModuleFunctions )
  get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "chai3d/include" "static" )
  # Look for the header file.
  find_path( Chai3D_INCLUDE_DIR NAMES chai3d.h cWorld.h
                                PATHS ${module_include_search_paths}
                                DOC "Path to include files for chai3d. The path is to where chai3d.h ( cWorld.h for chai3d versions earlier than 2.0 ) is located." )

  find_library( Chai3D_LIBRARY_RELEASE NAMES ${chai3d_library_name} chai3d-release chai3d_linux chai3d
                                       PATHS ${module_lib_search_paths}
                                       DOC "Path to chai3d library (possible names also include ${chai3d_library_name}, chai3d-release and chai3d_linux)" )

  # Look for the library.
  find_library( Chai3D_LIBRARY_DEBUG NAMES ${chai3d_library_name}_d chai3d-debug
                                     PATHS ${module_lib_search_paths}
                                     DOC "Path to ${chai3d_library_name}_d or chai3d-debug library." )
else()
  set( Chai3D_INCLUDE_DIR "" CACHE PATH "Path to include files for chai3d. The path is to where chai3d.h ( cWorld.h for chai3d versions earlier than 2.0 ) is located." )
  set( Chai3D_LIBRARY_RELEASE "" CACHE FILEPATH "Path to chai3d library file." )
  set( Chai3D_LIBRARY_DEBUG "" CACHE FILEPATH "Path to chai3d debug library file." )
endif()

mark_as_advanced( Chai3D_INCLUDE_DIR Chai3D_LIBRARY_RELEASE Chai3D_LIBRARY_DEBUG )

include( SelectLibraryConfigurations )
select_library_configurations( Chai3D )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set Chai3D_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( Chai3D DEFAULT_MSG
                                   Chai3D_INCLUDE_DIR Chai3D_LIBRARY )

set( Chai3D_LIBRARIES ${Chai3D_LIBRARY} )
set( Chai3D_INCLUDE_DIRS ${Chai3D_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( CHAI3D_INCLUDE_DIR ${Chai3D_INCLUDE_DIRS} )
set( CHAI3D_LIBRARIES ${Chai3D_LIBRARIES} )
set( Chai3D_FOUND ${CHAI3D_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.

# Additional message on MSVC
if( Chai3D_FOUND AND MSVC )
  if( NOT Chai3D_LIBRARY_RELEASE )
    message( WARNING "Chai3D release library not found. Release build might not work properly. To get rid of this warning set Chai3D_LIBRARY_RELEASE." )
  endif()
  if( NOT Chai3D_LIBRARY_DEBUG )
    message( WARNING "Chai3D debug library not found. Debug build might not work properly. To get rid of this warning set Chai3D_LIBRARY_DEBUG." )
  endif()
endif()

if( Chai3D_FOUND )
  # The way we get the version number might be unreliable since the version
  # number is not updated in every file for previous releases of chai3d.
  # Note that this might also break in the future if chai3d changes their
  # version handling, then FindChai3D.cmake needs to be updated.
  set( Chai3D_VERSION "1.0" )
  set( chai3d_header_to_check ${Chai3D_INCLUDE_DIR}/cWorld.h )
  if( NOT EXISTS ${chai3d_header_to_check} )
    set( chai3d_header_to_check ${Chai3D_INCLUDE_DIR}/chai3d.h )
  endif()
  if( EXISTS ${chai3d_header_to_check} )
    file( STRINGS ${chai3d_header_to_check} chai3d_versions REGEX "\\version[ ]*[0-9][.][0-9][.]*[0-9]*" )
    foreach( line ${chai3d_versions} )
      # Only get the two first numbers in order to use it for comparasion in c++.
      string( REGEX MATCH "[0-9][.][0-9][.]*[0-9]*" Chai3D_VERSION ${line} )
    endforeach()
  endif()

  if( MSVC AND search_for_chai3d )
    set( Chai3D_LIBRARIES ${Chai3D_LIBRARIES} optimized "atls.lib" debug "atlsd.lib" )
  endif()

  # Backwards compatibility values set here.
  set( CHAI3D_VERSION ${Chai3D_VERSION} )
endif()