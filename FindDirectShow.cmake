# - Find DirectShow, windows only
#
#  DirectShow_INCLUDE_DIRS - Where to find streams.h.
#  DirectShow_LIBRARIES    - List of libraries when using DirectShow.
#  DirectShow_FOUND        - True if DirectShow is found.

include( testIfVCExpress )
testIfVCExpress()

include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES DirectShow_INCLUDE_DIR_STREAMS_H DirectShow_INCLUDE_DIR_DDRAW_H DirectShow_INCLUDE_DIR_INTSAFE_H DirectShow_LIBRARY
                                              DOC_STRINGS "Path in which the file streams.h is located."
                                                          "Path in which the file ddraw.h is located."
                                                          "Path in which the file intsafe.h is located."
                                                          "Path to strmbase library." )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "DirectShow/BaseClasses" "static" )

if( CMake_HAVE_MFC AND NOT MSVC14 )
  # Look for the header file.
  set( directshow_extra_dir )
  if( MSVC70 OR MSVC71 )
    set( directshow_extra_dir $ENV{VS71COMNTOOLS}../../Vc7/PlatformSDK/Include )
  elseif( MSVC80 )
    set( directshow_extra_dir $ENV{VS80COMNTOOLS}../../VC/PlatformSDK/Include )
  elseif( MSVC90 )
    set( directshow_extra_dir $ENV{VS90COMNTOOLS}../../VC/PlatformSDK/Include )
  elseif( MSVC10 )
    set( directshow_extra_dir $ENV{VS100COMNTOOLS}../../VC/PlatformSDK/Include )
  endif()

  get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

  find_path( DirectShow_INCLUDE_DIR_STREAMS_H NAMES streams.h
             PATHS ${module_include_search_paths}
             DOC "Path in which the file streams.h is located." )
  mark_as_advanced( DirectShow_INCLUDE_DIR_STREAMS_H )

  find_path( DirectShow_INCLUDE_DIR_DDRAW_H NAMES ddraw.h
             PATHS $ENV{DXSDK_DIR}/include
                   ${directshow_extra_dir}
                   "C:/Program Files (x86)/Microsoft SDKs/Windows/v7.0A/Include"
                   "C:/Program Files/Microsoft SDKs/Windows/v7.0A/Include"
                   "C:/Program Files (x86)/Microsoft SDKs/Windows/v7.0/Include"
                   "C:/Program Files/Microsoft SDKs/Windows/v7.0/Include"
             DOC "Path in which the file ddraw.h is located." )
  mark_as_advanced( DirectShow_INCLUDE_DIR_DDRAW_H )

  find_path( DirectShow_INCLUDE_DIR_INTSAFE_H NAMES intsafe.h
             PATHS $ENV{DXSDK_DIR}/include
                   ${directshow_extra_dir}
                   "C:/Program Files (x86)/Microsoft SDKs/Windows/v7.0A/Include"
                   "C:/Program Files/Microsoft SDKs/Windows/v7.0A/Include"
                   "C:/Program Files (x86)/Microsoft SDKs/Windows/v7.0/Include"
                   "C:/Program Files/Microsoft SDKs/Windows/v7.0/Include"
              DOC "Path in which the file intsafe.h is located." )
  mark_as_advanced( DirectShow_INCLUDE_DIR_INTSAFE_H )

  find_library( DirectShow_LIBRARY NAMES strmbase
                PATHS ${module_lib_search_paths}
                DOC "Path to strmbase library." )
  mark_as_advanced( DirectShow_LIBRARY )

endif()

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set DirectShow_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( DirectShow DEFAULT_MSG
                                   DirectShow_LIBRARY DirectShow_INCLUDE_DIR_STREAMS_H DirectShow_INCLUDE_DIR_DDRAW_H DirectShow_INCLUDE_DIR_INTSAFE_H )

set( DirectShow_LIBRARIES ${DirectShow_LIBRARY} )
set( DirectShow_INCLUDE_DIRS ${DirectShow_INCLUDE_DIR_STREAMS_H} ${DirectShow_INCLUDE_DIR_DDRAW_H} )

# Backwards compatibility values set here.
set( DIRECTSHOW_INCLUDE_DIR ${DirectShow_INCLUDE_DIRS} )
set( DIRECTSHOW_LIBRARIES ${DirectShow_LIBRARIES} )
set( DirectShow_FOUND ${DIRECTSHOW_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.