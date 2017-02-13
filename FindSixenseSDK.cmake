# - Find SIXENSE
# Find the native SIXENSE headers and libraries.
#
#  SIXENSE_INCLUDE_DIR -  where to find SIXENSE.h, etc.
#  SIXENSE_LIBRARIES    - List of libraries when using SIXENSE.
#  SIXENSE_FOUND        - True if SIXENSE found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )

if( CMAKE_CL_64 )
  set( LIB "win64" )
  set( SDK_LIB "x64" )
  set( PROGRAMFILES_X86 "ProgramFiles(x86)" ) # Needed because ( and ) are disallowed characters in cmake 3.1.0, see policy cmp0053
  set( steam_path "$ENV{${PROGRAMFILES_X86}}/Steam/SteamApps/common/Sixense SDK/SixenseSDK" )
else()
  set( LIB "lib32" )
  set( SDK_LIB "win32" )
  set( steam_path "$ENV{ProgramFiles}/Steam/SteamApps/common/Sixense SDK/SixenseSDK" )
endif()

set( SIXENSE_INSTALL_DIR "" CACHE PATH "Path to external Sixense SDK installation" )

# Look for the header file.
find_path( SIXENSE_INCLUDE_DIR NAMES sixense.h
                               PATHS ${SIXENSE_INSTALL_DIR}/include
                                     ${module_include_search_paths}
         ${steam_path}/include
         $ENV{SIXENSE_SDK_PATH}/include 
                           DOC "Path in which the file sixense.h is located." )
mark_as_advanced( SIXENSE_INCLUDE_DIR )

set( VS_DIR "" )
if( MSVC )
  if( ${MSVC_VERSION} EQUAL 1600 )
    set( VS_DIR "VS2010" )
  endif()
  if( ${MSVC_VERSION} EQUAL 1800 )
    set( VS_DIR "VS2013" )
  endif()
  if( ${MSVC_VERSION} EQUAL 1900 )
    set( VS_DIR "VS2015" )
  endif()
endif()

# Look for the library.
find_library( SIXENSE_LIBRARY NAMES sixense sixense_${SDK_LIB}
                              PATHS ${SIXENSE_INSTALL_DIR}/lib/${SDK_LIB}/${VS_DIR}/release_dll
                                    ${module_lib_search_paths}
                                    ${steam_path}/lib/${SDK_LIB}/${VS_DIR}/release_dll
                                    $ENV{SIXENSE_SDK_PATH}/lib/${SDK_LIB}/${VS_DIR}/release_dll
                              DOC "Path to sixense library." )
mark_as_advanced( SIXENSE_LIBRARY )

# Copy the results to the output variables.
if( SIXENSE_INCLUDE_DIR AND SIXENSE_LIBRARY )
  set( SIXENSE_FOUND 1 )
  set( SIXENSE_LIBRARIES ${SIXENSE_LIBRARY} )
  set( SIXENSE_INCLUDE_DIR ${SIXENSE_INCLUDE_DIR} )
else()
  set( SIXENSE_FOUND 0 )
  set( SIXENSE_LIBRARIES )
  set( SIXENSE_INCLUDE_DIR )
endif()

# Report the results.
if( NOT SIXENSE_FOUND )
  set( SIXENSE_DIR_MESSAGE
       "SIXENSE was not found. Make sure SIXENSE_LIBRARY and SIXENSE_INCLUDE_DIR are set to where you have your sixense sdk header and lib files. If you do not have the library you will not be able to use the HydraSensor." )
  if( SIXENSE_FIND_REQUIRED )
      message( FATAL_ERROR "${SIXENSE_DIR_MESSAGE}" )
  elseif( NOT SIXENSE_FIND_QUIETLY )
    message( STATUS "${SIXENSE_DIR_MESSAGE}" )
  endif()
endif()
