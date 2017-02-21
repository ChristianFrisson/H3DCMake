# - Find FFmpeg
# Find the native FFmpeg headers and libraries.
#
#  FFMPEG_INCLUDE_DIR -  where to find avcodec.h, etc.
#  FFMPEG_LIBRARIES    - List of libraries when using FFmpeg.
#  FFMPEG_FOUND        - True if FFmpeg found.


if( WIN32 OR APPLE )
  message( FATAL_ERROR "FindFFmpeg not yet ready for Windows and Mac! Please contribute" )
endif()


# Try to use pkgconfig
#include(FindPkgConfig)
# pkg-config is disabled for now since it does not seem to find
# the directories we want always. 
# explicitly set the PKG_CONFIG_FOUND to be False as it can be set to be
# True by other module before FindFFmpeg module
set( PKG_CONFIG_FOUND False )
if( PKG_CONFIG_FOUND )
  PKG_CHECK_MODULES(FFMPEGMODULES libavcodec libavformat libswscale)
else()
  include( H3DExternalSearchPath )
  get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "ffmpeg/include" )

  # Look for the header file.
  find_path( FFMPEG_AVCODEC_INCLUDE_DIR NAMES avcodec.h
                                        PATHS /usr/local/include/libavcodec
                                              /usr/include/libavcodec
                                              /usr/local/include/ffmpeg
                                              /usr/include/ffmpeg
                                              /usr/local/include/${CMAKE_LIBRARY_ARCHITECTURE}/libavcodec
                                              /usr/include/${CMAKE_LIBRARY_ARCHITECTURE}/libavcodec
                                              ${module_include_search_paths}
                                        DOC "Path in which the file avcodec.h is located." )
  mark_as_advanced( FFMPEG_AVCODEC_INCLUDE_DIR )

  find_path( FFMPEG_AVFORMAT_INCLUDE_DIR NAMES avformat.h
                                               PATHS /usr/local/include/libavformat
                                                     /usr/include/libavformat
                                                     /usr/local/include/ffmpeg
                                                     /usr/include/ffmpeg
                                                     /usr/include/ffmpeg
                                                     /usr/local/include/${CMAKE_LIBRARY_ARCHITECTURE}/libavformat
                                                     /usr/include/${CMAKE_LIBRARY_ARCHITECTURE}/libavformat
                                                     ${module_include_search_paths}
                                               DOC "Path in which the file avformat.h is located." )
  mark_as_advanced( FFMPEG_AVFORMAT_INCLUDE_DIR )

  find_path( FFMPEG_SWSCALE_INCLUDE_DIR NAMES swscale.h
                                        PATHS /usr/local/include/libswscale
                                              /usr/include/libswscale
                                              /usr/local/include/ffmpeg
                                              /usr/include/ffmpeg
                                              /usr/include/libavformat
                                              /usr/local/include/${CMAKE_LIBRARY_ARCHITECTURE}/libswscale
                                              /usr/include/${CMAKE_LIBRARY_ARCHITECTURE}/libswscale
                                              ${module_include_search_paths}
                                        DOC "Path in which the file swscale.h is located." )
  mark_as_advanced( FFMPEG_SWSCALE_INCLUDE_DIR )

  # Look for the libraries.
  find_library( FFMPEG_AVCODEC_LIBRARY NAMES avcodec 
                                       PATHS ${module_lib_search_paths}
                                       DOC "Path to avcodec library." )
  mark_as_advanced( FFMPEG_AVCODEC_LIBRARY )

  find_library( FFMPEG_AVFORMAT_LIBRARY NAMES avformat
                                        PATHS ${module_lib_search_paths}
                                        DOC "Path to avformat library." )
  mark_as_advanced( FFMPEG_AVFORMAT_LIBRARY )

  find_library( FFMPEG_SWSCALE_LIBRARY NAMES swscale 
                                       PATHS ${module_lib_search_paths}
                                       DOC "Path to swscale library." )
  mark_as_advanced( FFMPEG_SWSCALE_LIBRARY )

  if( FFMPEG_AVCODEC_INCLUDE_DIR AND FFMPEG_AVFORMAT_INCLUDE_DIR AND FFMPEG_SWSCALE_INCLUDE_DIR AND
      FFMPEG_AVCODEC_LIBRARY AND FFMPEG_AVFORMAT_LIBRARY AND FFMPEG_SWSCALE_LIBRARY )
    set( FFMPEGMODULES_FOUND 1 )
    set( FFMPEGMODULES_LIBRARIES ${FFMPEG_AVCODEC_LIBRARY} ${FFMPEG_AVFORMAT_LIBRARY} ${FFMPEG_SWSCALE_LIBRARY} )
    set( FFMPEGMODULES_INCLUDE_DIRS ${FFMPEG_AVCODEC_INCLUDE_DIR} ${FFMPEG_AVFORMAT_INCLUDE_DIR} ${FFMPEG_SWSCALE_INCLUDE_DIR} )
  endif()



endif()

# Copy the results to the output variables.
if( FFMPEGMODULES_FOUND )
  set( FFMPEG_FOUND 1 )
  set( FFMPEG_LIBRARIES ${FFMPEGMODULES_LIBRARIES} )
  set( FFMPEG_INCLUDE_DIRS ${FFMPEGMODULES_INCLUDE_DIRS} )
else()
  set( FFMPEG_FOUND 0 )
  set( FFMPEG_LIBRARIES )
  set( FFMPEG_INCLUDE_DIRS )
endif()

mark_as_advanced( FFMPEG_LIBRARIES )
mark_as_advanced( FFMPEG_INCLUDE_DIRS )

# Report the results.
if( NOT FFMPEG_FOUND )
  set( FFMPEG_DIR_MESSAGE
       "FFmpeg was not found. Make sure cmake variables with prefix FFMPEG set to the directories containing the include and lib files for ffmpeg. If you do not have the library you will not be able to use video textures under linux." )
  if( NOT FFMPEG_FIND_QUIETLY )
    message( STATUS "${FFMPEG_DIR_MESSAGE}" )
  else()
    if( FFMPEG_FIND_REQUIRED )
      message( FATAL_ERROR "${FFMPEG_DIR_MESSAGE}" )
    endif()
  endif()
endif()
