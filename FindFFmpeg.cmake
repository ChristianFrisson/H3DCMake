# - Find FFmpeg
# Find the native FFmpeg headers and libraries.
#
#  FFmpeg_INCLUDE_DIRS - Where to find avcodec.h, etc.
#  FFmpeg_LIBRARIES    - List of libraries when using FFmpeg.
#  FFmpeg_FOUND        - True if FFmpeg found.

include( H3DUtilityFunctions )

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES FFmpeg_AVCODEC_INCLUDE_DIR
                                                                 FFmpeg_AVFORMAT_INCLUDE_DIR
                                                                 FFmpeg_SWSCALE_INCLUDE_DIR
                                                                 FFmpeg_AVCODEC_LIBRARY
                                                                 FFmpeg_AVFORMAT_LIBRARY
                                                                 FFmpeg_SWSCALE_LIBRARY
                                              DOC_STRINGS "Path in which the file avcodec.h is located."
                                                          "Path in which the file avformat.h is located."
                                                          "Path in which the file swscale.h is located."
                                                          "Path to avcodec library."
                                                          "Path to avformat library."
                                                          "Path to swscale library." )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "ffmpeg/include" )

# Look for the header file.
find_path( FFmpeg_AVCODEC_INCLUDE_DIR NAMES avcodec.h
                                      PATHS /usr/local/include/libavcodec
                                            /usr/include/libavcodec
                                            /usr/local/include/ffmpeg
                                            /usr/include/ffmpeg
                                            /usr/local/include/${CMAKE_LIBRARY_ARCHITECTURE}/libavcodec
                                            /usr/include/${CMAKE_LIBRARY_ARCHITECTURE}/libavcodec
                                            ${module_include_search_paths}
                                      DOC "Path in which the file avcodec.h is located." )
mark_as_advanced( FFmpeg_AVCODEC_INCLUDE_DIR )

find_path( FFmpeg_AVFORMAT_INCLUDE_DIR NAMES avformat.h
                                             PATHS /usr/local/include/libavformat
                                                   /usr/include/libavformat
                                                   /usr/local/include/ffmpeg
                                                   /usr/include/ffmpeg
                                                   /usr/include/ffmpeg
                                                   /usr/local/include/${CMAKE_LIBRARY_ARCHITECTURE}/libavformat
                                                   /usr/include/${CMAKE_LIBRARY_ARCHITECTURE}/libavformat
                                                   ${module_include_search_paths}
                                             DOC "Path in which the file avformat.h is located." )
mark_as_advanced( FFmpeg_AVFORMAT_INCLUDE_DIR )

find_path( FFmpeg_SWSCALE_INCLUDE_DIR NAMES swscale.h
                                      PATHS /usr/local/include/libswscale
                                            /usr/include/libswscale
                                            /usr/local/include/ffmpeg
                                            /usr/include/ffmpeg
                                            /usr/include/libavformat
                                            /usr/local/include/${CMAKE_LIBRARY_ARCHITECTURE}/libswscale
                                            /usr/include/${CMAKE_LIBRARY_ARCHITECTURE}/libswscale
                                            ${module_include_search_paths}
                                      DOC "Path in which the file swscale.h is located." )
mark_as_advanced( FFmpeg_SWSCALE_INCLUDE_DIR )

# Look for the libraries.
find_library( FFmpeg_AVCODEC_LIBRARY NAMES avcodec
                                     PATHS ${module_lib_search_paths}
                                     DOC "Path to avcodec library." )
mark_as_advanced( FFmpeg_AVCODEC_LIBRARY )

find_library( FFmpeg_AVFORMAT_LIBRARY NAMES avformat
                                      PATHS ${module_lib_search_paths}
                                      DOC "Path to avformat library." )
mark_as_advanced( FFmpeg_AVFORMAT_LIBRARY )

find_library( FFmpeg_SWSCALE_LIBRARY NAMES swscale
                                     PATHS ${module_lib_search_paths}
                                     DOC "Path to swscale library." )
mark_as_advanced( FFmpeg_SWSCALE_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set FFmpeg_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( FFmpeg DEFAULT_MSG
                                   FFmpeg_AVCODEC_INCLUDE_DIR FFmpeg_AVFORMAT_INCLUDE_DIR FFmpeg_SWSCALE_INCLUDE_DIR
                                   FFmpeg_AVCODEC_LIBRARY FFmpeg_AVFORMAT_LIBRARY FFmpeg_SWSCALE_LIBRARY )

set( FFmpeg_LIBRARIES ${FFmpeg_AVCODEC_LIBRARY} ${FFmpeg_AVFORMAT_LIBRARY} ${FFmpeg_SWSCALE_LIBRARY} )
set( FFmpeg_INCLUDE_DIRS ${FFmpeg_AVCODEC_INCLUDE_DIR} ${FFmpeg_AVFORMAT_INCLUDE_DIR} ${FFmpeg_SWSCALE_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( FFMPEG_INCLUDE_DIR ${FFmpeg_INCLUDE_DIRS} )
set( FFMPEG_INCLUDE_DIRS ${FFmpeg_INCLUDE_DIRS} )
set( FFMPEG_LIBRARIES ${FFmpeg_LIBRARIES} )
set( FFmpeg_FOUND ${FFMPEG_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.
