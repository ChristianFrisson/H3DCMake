# - Find DirectShow, windows only
#
#  DIRECTSHOW_INCLUDE_DIR -  where to find streams.h.
#  DIRECTSHOW_LIBRARIES    - List of libraries when using DirectShow.
#  DIRECTSHOW_FOUND        - True if DirectShow is found.

include( testIfVCExpress )
testIfVCExpress()

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "DirectShow/BaseClasses" "static" )

if( CMake_HAVE_MFC AND NOT MSVC14 )
  # Look for the header file.
  set( DIRECTSHOW_EXTRA_DIR )
  if( MSVC70 OR MSVC71 )
    set( DIRECTSHOW_EXTRA_DIR $ENV{VS71COMNTOOLS}../../Vc7/PlatformSDK/Include )
  elseif( MSVC80 )
    set( DIRECTSHOW_EXTRA_DIR $ENV{VS80COMNTOOLS}../../VC/PlatformSDK/Include )
  elseif( MSVC90 )
    set( DIRECTSHOW_EXTRA_DIR $ENV{VS90COMNTOOLS}../../VC/PlatformSDK/Include )
  elseif( MSVC10 )
    set( DIRECTSHOW_EXTRA_DIR $ENV{VS100COMNTOOLS}../../VC/PlatformSDK/Include )
  endif()

  get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

  find_path( DIRECTSHOW_INCLUDE_DIR_STREAMS_H NAMES streams.h
             PATHS ${module_include_search_paths}
             DOC "Path in which the file streams.h is located." )
  mark_as_advanced( DIRECTSHOW_INCLUDE_DIR_STREAMS_H )

  find_path( DIRECTSHOW_INCLUDE_DIR_DDRAW_H NAMES ddraw.h
             PATHS $ENV{DXSDK_DIR}/include
                   ${DIRECTSHOW_EXTRA_DIR}
                   "C:/Program Files (x86)/Microsoft SDKs/Windows/v7.0A/Include"
                   "C:/Program Files/Microsoft SDKs/Windows/v7.0A/Include"
                   "C:/Program Files (x86)/Microsoft SDKs/Windows/v7.0/Include"
                   "C:/Program Files/Microsoft SDKs/Windows/v7.0/Include"

             DOC "Path in which the file ddraw.h is located." )
  mark_as_advanced( DIRECTSHOW_INCLUDE_DIR_DDRAW_H )

  find_path( DIRECTSHOW_INCLUDE_DIR_INTSAFE_H NAMES intsafe.h
             PATHS $ENV{DXSDK_DIR}/include
                   ${DIRECTSHOW_EXTRA_DIR}
                   "C:/Program Files (x86)/Microsoft SDKs/Windows/v7.0A/Include"
                   "C:/Program Files/Microsoft SDKs/Windows/v7.0A/Include"
                   "C:/Program Files (x86)/Microsoft SDKs/Windows/v7.0/Include"
                   "C:/Program Files/Microsoft SDKs/Windows/v7.0/Include"
   
              DOC "Path in which the file intsafe.h is located." )
  mark_as_advanced( DIRECTSHOW_INCLUDE_DIR_INTSAFE_H )

  find_library( DIRECTSHOW_LIBRARY NAMES strmbase
                PATHS ${module_lib_search_paths}
                DOC "Path to strmbase library." )
  mark_as_advanced( DIRECTSHOW_LIBRARY )

  # Copy the results to the output variables.
  if( DIRECTSHOW_INCLUDE_DIR_STREAMS_H AND DIRECTSHOW_INCLUDE_DIR_INTSAFE_H AND DIRECTSHOW_INCLUDE_DIR_DDRAW_H AND DIRECTSHOW_LIBRARY )
    set( DIRECTSHOW_FOUND 1 )
    set( DIRECTSHOW_LIBRARIES ${DIRECTSHOW_LIBRARY} )
    set( DIRECTSHOW_INCLUDE_DIR ${DIRECTSHOW_INCLUDE_DIR_STREAMS_H} ${DIRECTSHOW_INCLUDE_DIR_DDRAW_H} )
  else()
    set( DIRECTSHOW_FOUND 0 )
    set( DIRECTSHOW_LIBRARIES )
    set( DIRECTSHOW_INCLUDE_DIR )
  endif()

endif()

# Report the results.
if( NOT DIRECTSHOW_FOUND )
  set( DIRECTSHOW_DIR_MESSAGE
       "Directshow was not found. Set DIRECTSHOW_INCLUDE_DIR_STREAMS_H, DIRECTSHOW_INCLUDE_DIR_INTSAFE_H, DIRECTSHOW_INCLUDE_DIR_DDRAW_H and DIRECTSHOW_LIBRARY to enable Directshow (DSHOW) support." )
  if( DirectShow_FIND_REQUIRED )
    message( FATAL_ERROR "${DIRECTSHOW_DIR_MESSAGE}" )
  elseif( NOT DirectShow_FIND_QUIETLY )
    message( STATUS "${DIRECTSHOW_DIR_MESSAGE}" )
  endif()
endif()
