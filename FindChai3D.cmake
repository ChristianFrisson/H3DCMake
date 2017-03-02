# - Find Chai3D
# Find the native CHAI3D headers and libraries.
#
#  CHAI3D_INCLUDE_DIR -  where to find Chai3D headers
#  CHAI3D_LIBRARIES    - List of libraries when using Chai3D.
#  CHAI3D_FOUND        - True if Chai3D found.

set( SEARCH_FOR_CHAI3D 1 )

if( MSVC )
  include( testIfVCExpress )
  testIfVCExpress()
  if( NOT CMake_HAVE_MFC )
    set( SEARCH_FOR_CHAI3D 0 )
  endif()
endif()

if( SEARCH_FOR_CHAI3D )
  include( H3DExternalSearchPath )
  get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "chai3d/include" "static" )
  # Look for the header file.
  find_path( CHAI3D_INCLUDE_DIR NAMES chai3d.h cWorld.h
                                PATHS ${module_include_search_paths}
                                DOC "Path in which the file chai3d.h ( cWorld.h for chai3d versions earlier than 2.0 ) is located." )

  # Look for the library.
  if( WIN32 )
    set( CHAI3D_LIBRARY_NAME chai3d_complete )
    if( MSVC70 OR MSVC71 )
      set( CHAI3D_LIBRARY_NAME chai3d_complete_vc7 )
    elseif( MSVC80 )
      set( CHAI3D_LIBRARY_NAME chai3d_complete_vc8 )
    elseif( MSVC90 )
      set( CHAI3D_LIBRARY_NAME chai3d_complete_vc9 )
    elseif( MSVC10 )             
      set( CHAI3D_LIBRARY_NAME chai3d_complete_vc10 )
    endif()

    find_library( CHAI3D_LIBRARY NAMES ${CHAI3D_LIBRARY_NAME} chai3d-release
                                 PATHS ${module_lib_search_paths}
                                 DOC "Path to ${CHAI3D_LIBRARY_NAME} library." )
    if( MSVC80 OR MSVC90 OR MSVC10 )
      find_library( CHAI3D_DEBUG_LIBRARY NAMES ${CHAI3D_LIBRARY_NAME}_d chai3d-debug
                                         PATHS ${module_lib_search_paths}
                                         DOC "Path to ${CHAI3D_LIBRARY_NAME}_d library." )
    endif()
    mark_as_advanced( CHAI3D_DEBUG_LIBRARY )
  else()
    find_library( CHAI3D_LIBRARY NAMES chai3d_linux chai3d
                  DOC "Path to chai3d_linux ( or chai3d ) library." )
  endif()
else()
  set( CHAI3D_INCLUDE_DIR "" CACHE PATH "Path to include files for chai3d. The path is to where chai3d.h ( cWorld.h for chai3d versions earlier than 2.0 ) is located." )
  set( CHAI3D_LIBRARY "" CACHE FILEPATH "Path to chai3d library file." )
endif()

mark_as_advanced( CHAI3D_INCLUDE_DIR )
mark_as_advanced( CHAI3D_LIBRARY )

set( CHAI3D_LIBRARIES_FOUND 0 )
if( MSVC80 OR MSVC90 OR MSVC10 )
  if( CHAI3D_LIBRARY OR CHAI3D_DEBUG_LIBRARY )
    set( CHAI3D_LIBRARIES_FOUND 1 )
  endif()
elseif( CHAI3D_LIBRARY )
  set( CHAI3D_LIBRARIES_FOUND 1 )
endif()

# Copy the results to the output variables.
if( CHAI3D_INCLUDE_DIR AND CHAI3D_LIBRARIES_FOUND )
  
  # The way we get the version number might be unreliable since the version
  # number is not updated in every file for previous releases of chai3d.
  # Note that this might also break in the future if chai3d changes their
  # version handling, then FindChai3D.cmake needs to be updated.
  set( CHAI3D_VERSION "1.0" )
  set( CHAI3D_FILE ${CHAI3D_INCLUDE_DIR}/cWorld.h )
  if( NOT EXISTS ${CHAI3D_FILE} )
    set( CHAI3D_FILE ${CHAI3D_INCLUDE_DIR}/chai3d.h )
  endif()
  if( EXISTS ${CHAI3D_FILE} )
    file( STRINGS ${CHAI3D_FILE} chai3d_versions REGEX "\\version[ ]*[0-9][.][0-9][.]*[0-9]*" )
    foreach( line ${chai3d_versions} )
      # Only get the two first numbers in order to use it for comparasion in c++.
      string( REGEX MATCH "[0-9][.][0-9][.]*[0-9]*" CHAI3D_VERSION ${line} )
    endforeach()
  endif()
  set( CHAI3D_FOUND 1 )
  
  if( MSVC80 OR MSVC90 OR MSVC10 )
    if( CHAI3D_LIBRARY )
      set( CHAI3D_LIBRARIES optimized ${CHAI3D_LIBRARY} )
    else()
      set( CHAI3D_LIBRARIES optimized ${CHAI3D_LIBRARY_NAME} )
      message( STATUS "Chai3D release libraries not found. Release build might not work." )
    endif()

    if( CHAI3D_DEBUG_LIBRARY )
      set( CHAI3D_LIBRARIES ${CHAI3D_LIBRARIES} debug ${CHAI3D_DEBUG_LIBRARY} )
    else()
      set( CHAI3D_LIBRARIES ${CHAI3D_LIBRARIES} debug ${CHAI3D_LIBRARY_NAME}_d )
      message( STATUS "Chai3D debug libraries not found. Debug build might not work." )
    endif()
  else()
    set( CHAI3D_LIBRARIES ${CHAI3D_LIBRARY} )
  endif()
  
  if( MSVC AND SEARCH_FOR_CHAI3D )
    set( CHAI3D_LIBRARIES ${CHAI3D_LIBRARIES} optimized "atls.lib" debug "atlsd.lib" )
  endif()
  set( CHAI3D_INCLUDE_DIR ${CHAI3D_INCLUDE_DIR} )
else()
  set( CHAI3D_FOUND 0 )
  set( CHAI3D_LIBRARIES )
  set( CHAI3D_INCLUDE_DIR )
endif()

# Report the results.
if( NOT CHAI3D_FOUND )
  set( CHAI3D_DIR_MESSAGE
       "CHAI3D was not found. Make sure to set CHAI3D_LIBRARY" )
  if( MSVC80 OR MSVC90 OR MSVC10 )
    set( CHAI3D_DIR_MESSAGE
         "${CHAI3D_DIR_MESSAGE}, CHAI3D_DEBUG_LIBRARY" )
  endif()
  set( CHAI3D_DIR_MESSAGE
       "${CHAI3D_DIR_MESSAGE} and CHAI3D_INCLUDE_DIR. If you do not have chai3d you will not be able to use the Chai3DRenderer." )
  if( Chai3D_FIND_REQUIRED )
    message( FATAL_ERROR "${CHAI3D_DIR_MESSAGE}" )
  elseif( NOT Chai3D_FIND_QUIETLY )
    message( STATUS "${CHAI3D_DIR_MESSAGE}" )
  endif()
endif()
