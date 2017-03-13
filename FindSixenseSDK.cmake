# - Find SixenseSDK
# Find the native SixenseSDK headers and libraries.
#
#  SixenseSDK_INCLUDE_DIRS - Where to find sixense.h, etc.
#  SixenseSDK_LIBRARIES    - List of libraries when using SixenseSDK.
#  SixenseSDK_FOUND        - True if SixenseSDK found.

include( H3DExternalSearchPath )

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES SixenseSDK_INCLUDE_DIR SixenseSDK_LIBRARY
                                              OLD_VARIABLE_NAMES SIXENSE_INCLUDE_DIR SIXENSE_LIBRARY
                                              DOC_STRINGS "Path in which the file sixense.h is located. Required to use the HydraSensor."
                                                          "Path to sixense library. Required to use the HydraSensor." )

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )

if( CMAKE_CL_64 )
  set( sdk_lib "x64" )
  set( PROGRAMFILES_X86 "ProgramFiles(x86)" ) # Needed because ( and ) are disallowed characters in cmake 3.1.0, see policy cmp0053
  set( steam_path "$ENV{${PROGRAMFILES_X86}}/Steam/SteamApps/common/Sixense SDK/SixenseSDK" )
else()
  set( sdk_lib "win32" )
  set( steam_path "$ENV{ProgramFiles}/Steam/SteamApps/common/Sixense SDK/SixenseSDK" )
endif()

set( SIXENSE_INSTALL_DIR "" CACHE PATH "Path to external Sixense SDK installation" )

# Look for the header file.
find_path( SixenseSDK_INCLUDE_DIR NAMES sixense.h
                               PATHS ${SIXENSE_INSTALL_DIR}/include
                                     ${module_include_search_paths}
         ${steam_path}/include
         $ENV{SIXENSE_SDK_PATH}/include 
                           DOC "Path in which the file sixense.h is located. Required to use the HydraSensor." )
mark_as_advanced( SixenseSDK_INCLUDE_DIR )

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
find_library( SixenseSDK_LIBRARY NAMES sixense sixense_${sdk_lib}
                              PATHS ${SIXENSE_INSTALL_DIR}/lib/${sdk_lib}/${VS_DIR}/release_dll
                                    ${module_lib_search_paths}
                                    ${steam_path}/lib/${sdk_lib}/${VS_DIR}/release_dll
                                    $ENV{SIXENSE_SDK_PATH}/lib/${sdk_lib}/${VS_DIR}/release_dll
                              DOC "Path to sixense library. Required to use the HydraSensor." )
mark_as_advanced( SixenseSDK_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set SixenseSDK_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( SixenseSDK DEFAULT_MSG
                                   SixenseSDK_LIBRARY SixenseSDK_INCLUDE_DIR )

set( SixenseSDK_LIBRARIES ${SixenseSDK_LIBRARY} )
set( SixenseSDK_INCLUDE_DIRS ${SixenseSDK_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( SIXENSE_INCLUDE_DIR ${SixenseSDK_INCLUDE_DIRS} )
set( SIXENSE_LIBRARIES ${SixenseSDK_LIBRARIES} )
set( SixenseSDK_FOUND ${SIXENSESDK_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.
set( SIXENSE_FOUND ${SixenseSDK_FOUND} )