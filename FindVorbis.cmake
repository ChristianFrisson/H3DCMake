# - Find VORBIS
# Find the native VORBIS headers and libraries.
#
#  VORBIS_INCLUDE_DIR -  where to find VORBIS.h, etc.
#  VORBIS_LIBRARIES    - List of libraries when using VORBIS.
#  VORBIS_FOUND        - True if VORBIS found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )

# Look for the header file.
find_path( VORBIS_INCLUDE_DIR NAMES vorbis/vorbisfile.h
                              PATHS ${module_include_search_paths}
                              DOC "Path in which the file vorbis/vorbisfile.h is located." )
mark_as_advanced( VORBIS_INCLUDE_DIR )

find_path( VORBIS_OGG_INCLUDE_DIR NAMES ogg/ogg.h
                                  PATHS ${module_include_search_paths}
                                  DOC "Path in which the file ogg/ogg.h is located." )
mark_as_advanced( VORBIS_OGG_INCLUDE_DIR )

# Look for the library.
find_library( VORBIS_VORBISFILE_LIBRARY NAMES libvorbisfile vorbisfile
                                        PATHS ${module_lib_search_paths}
                                        DOC "Path to vorbisfile library." )
mark_as_advanced( VORBIS_VORBISFILE_LIBRARY )

find_library( VORBIS_LIBRARY NAMES libvorbis vorbis
                             PATHS ${module_lib_search_paths}
                             DOC "Path to vorbis library." )
mark_as_advanced( VORBIS_LIBRARY )

find_library( VORBIS_OGG_LIBRARY NAMES libogg ogg 
                                 PATHS ${module_lib_search_paths}
                                 DOC "Path to ogg library." )
mark_as_advanced( VORBIS_OGG_LIBRARY )

if( WIN32 AND PREFER_STATIC_LIBRARIES )
  set( module_include_search_paths "" )
  set( module_lib_search_paths "" )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )
  find_library( VORBIS_VORBISFILE_STATIC_LIBRARY NAMES libvorbisfile_static vorbisfile_static
                                         PATHS ${module_lib_search_paths}
                                         DOC "Path to vorbisfile static library." )
  mark_as_advanced( VORBIS_VORBISFILE_STATIC_LIBRARY )
  
  find_library( VORBIS_OGG_STATIC_LIBRARY NAMES libogg_static ogg_static
                                         PATHS ${module_lib_search_paths}
                                         DOC "Path to ogg static library." )
  mark_as_advanced( VORBIS_OGG_STATIC_LIBRARY )
endif()

if( VORBIS_LIBRARY AND VORBIS_OGG_LIBRARY AND VORBIS_VORBISFILE_LIBRARY )
  set( VORBIS_LIBRARIES_FOUND 1 )
endif()

if( PREFER_STATIC_LIBRARIES AND VORBIS_VORBISFILE_STATIC_LIBRARY AND VORBIS_OGG_STATIC_LIBRARY )
  set( VORBIS_LIBRARIES_FOUND 1 )
  set( VORBIS_STATIC_LIBRARIES_FOUND 1 )
endif()

# Copy the results to the output variables.
if( VORBIS_INCLUDE_DIR AND VORBIS_OGG_INCLUDE_DIR AND VORBIS_LIBRARIES_FOUND )
  set( VORBIS_FOUND 1 )
  if( VORBIS_STATIC_LIBRARIES_FOUND )
    set( VORBIS_LIBRARIES ${VORBIS_VORBISFILE_STATIC_LIBRARY} ${VORBIS_OGG_STATIC_LIBRARY} )
  else()
    set( VORBIS_LIBRARIES ${VORBIS_VORBISFILE_LIBRARY} ${VORBIS_LIBRARY} ${VORBIS_OGG_LIBRARY} )
  endif()
  set( VORBIS_INCLUDE_DIR ${VORBIS_INCLUDE_DIR} ${VORBIS_OGG_INCLUDE_DIR} )
else()
  set( VORBIS_FOUND 0 )
  set( VORBIS_LIBRARIES )
  set( VORBIS_INCLUDE_DIR )
endif()

# Report the results.
if( NOT VORBIS_FOUND )
  set( VORBIS_DIR_MESSAGE
       "VORBIS was not found. Make sure cmake cache variables with prefix VORBIS are set "
       "to the locations of include and lib files for vorbis and ogg. If you do not have the library you will not be able to use ogg files as sound." )
  if( Vorbis_FIND_REQUIRED )
    message( FATAL_ERROR "${VORBIS_DIR_MESSAGE}" )
  elseif( NOT Vorbis_FIND_QUIETLY )
    message( STATUS "${VORBIS_DIR_MESSAGE}" )
  endif()
endif()
