# - Find Vorbis
# Find the native Vorbis headers and libraries.
#
#  Vorbis_INCLUDE_DIRS - Where to find vorbisfile.h, etc.
#  Vorbis_LIBRARIES    - List of libraries when using Vorbis.
#  Vorbis_FOUND        - True if Vorbis found.

include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES Vorbis_INCLUDE_DIR Vorbis_ogg_INCLUDE_DIR Vorbis_vorbisfile_LIBRARY Vorbis_LIBRARY Vorbis_ogg_LIBRARY Vorbis_vorbisfile_STATIC_LIBRARY Vorbis_ogg_STATIC_LIBRARY
                                              OLD_VARIABLE_NAMES VORBIS_INCLUDE_DIR VORBIS_OGG_INCLUDE_DIR VORBIS_VORBISFILE_LIBRARY VORBIS_LIBRARY VORBIS_OGG_LIBRARY VORBIS_VORBISFILE_STATIC_LIBRARY VORBIS_OGG_STATIC_LIBRARY
                                              DOC_STRINGS "Path in which the file vorbis/vorbisfile.h is located."
                                                          "Path in which the file ogg/ogg.h is located."
                                                          "Path to vorbisfile library. Needed to support vorbis and ogg sound files."
                                                          "Path to vorbis library. Needed to support vorbis and ogg sound files."
                                                          "Path to ogg library. Needed to support vorbis and ogg sound files."
                                                          "Path to vorbisfile static library. Needed to support vorbis and ogg sound files."
                                                          "Path to ogg static library. Needed to support vorbis and ogg sound files." )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )

# Look for the header file.
find_path( Vorbis_INCLUDE_DIR NAMES vorbis/vorbisfile.h
                              PATHS ${module_include_search_paths}
                              DOC "Path in which the file vorbis/vorbisfile.h is located." )
mark_as_advanced( Vorbis_INCLUDE_DIR )

find_path( Vorbis_ogg_INCLUDE_DIR NAMES ogg/ogg.h
                                  PATHS ${module_include_search_paths}
                                  DOC "Path in which the file ogg/ogg.h is located." )
mark_as_advanced( Vorbis_ogg_INCLUDE_DIR )

# Look for the library.
find_library( Vorbis_vorbisfile_LIBRARY NAMES libvorbisfile vorbisfile
                                        PATHS ${module_lib_search_paths}
                                        DOC "Path to vorbisfile library. Needed to support vorbis and ogg sound files." )
mark_as_advanced( Vorbis_vorbisfile_LIBRARY )

find_library( Vorbis_LIBRARY NAMES libvorbis vorbis
                             PATHS ${module_lib_search_paths}
                             DOC "Path to vorbis library. Needed to support vorbis and ogg sound files." )
mark_as_advanced( Vorbis_LIBRARY )

find_library( Vorbis_ogg_LIBRARY NAMES libogg ogg 
                                 PATHS ${module_lib_search_paths}
                                 DOC "Path to ogg library. Needed to support vorbis and ogg sound files." )
mark_as_advanced( Vorbis_ogg_LIBRARY )

if( WIN32 AND H3D_PREFER_STATIC_LIBRARIES )
  set( module_include_search_paths "" )
  set( module_lib_search_paths "" )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )
  find_library( Vorbis_vorbisfile_STATIC_LIBRARY NAMES libvorbisfile_static vorbisfile_static
                                         PATHS ${module_lib_search_paths}
                                         DOC "Path to vorbisfile static library. Needed to support vorbis and ogg sound files." )
  mark_as_advanced( Vorbis_vorbisfile_STATIC_LIBRARY )
  
  find_library( Vorbis_ogg_STATIC_LIBRARY NAMES libogg_static ogg_static
                                         PATHS ${module_lib_search_paths}
                                         DOC "Path to ogg static library. Needed to support vorbis and ogg sound files." )
  mark_as_advanced( Vorbis_ogg_STATIC_LIBRARY )
endif()

include( FindPackageHandleStandardArgs )
set( vorbis_staticlib 0 )
# handle the QUIETLY and REQUIRED arguments and set Vorbis_FOUND to TRUE
# if all listed variables are TRUE
if( WIN32 AND H3D_PREFER_STATIC_LIBRARIES )
  find_package_handle_standard_args( Vorbis DEFAULT_MSG
                                     Vorbis_vorbisfile_STATIC_LIBRARY Vorbis_ogg_STATIC_LIBRARY Vorbis_INCLUDE_DIR )
  set( Vorbis_LIBRARIES ${Vorbis_STATIC_LIBRARY} )
  set( vorbis_staticlib ${VORBIS_FOUND} ) # VORBIS_FOUND is set by find_package_handle_standard_args and should be up to date here. Upper case due to CMake 2.8 support
endif()

if( NOT vorbis_staticlib ) # This goes a bit against the standard, the reason is that if static libraries are desired the normal ones are only fallback.
  find_package_handle_standard_args( Vorbis DEFAULT_MSG
                                     Vorbis_vorbisfile_LIBRARY Vorbis_LIBRARY Vorbis_ogg_LIBRARY Vorbis_INCLUDE_DIR )
  set( Vorbis_LIBRARIES ${Vorbis_vorbisfile_LIBRARY} ${Vorbis_LIBRARY} ${Vorbis_ogg_LIBRARY} )
endif()

set( Vorbis_INCLUDE_DIRS ${Vorbis_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( VORBIS_INCLUDE_DIR ${Vorbis_INCLUDE_DIRS} )
set( VORBIS_LIBRARIES ${Vorbis_LIBRARIES} )
set( Vorbis_FOUND ${VORBIS_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.