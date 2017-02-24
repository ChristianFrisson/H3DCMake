# - Find FREETYPE
# Find the native FREETYPE headers and libraries.
#
#  FREETYPE_FOUND        - True if FREETYPE found.
#  FREETYPE_INCLUDE_DIRS - Where to find FREETYPE.h, etc.
#  FREETYPE_LIBRARIES    - List of libraries when using FREETYPE.

include( H3DExternalSearchPath )

checkCMakeInternalModule( Freetype ) # Will call CMakes internal find module for this feature.
if( ( DEFINED FREETYPE_FOUND ) AND FREETYPE_FOUND )
  return()
endif()

find_program(FREETYPE_CONFIG_EXECUTABLE freetype-config
      ONLY_CMAKE_FIND_ROOT_PATH
      DOC "Path to freetype_config executable. Used to find freetype, not used on a standard Windows installation of H3DAPI." )
mark_as_advanced( FREETYPE_CONFIG_EXECUTABLE )

if( FREETYPE_CONFIG_EXECUTABLE )

  # run the freetype-config program to get cflags
  EXECUTE_PROCESS(
        COMMAND sh "${FREETYPE_CONFIG_EXECUTABLE}" --cflags
        OUTPUT_VARIABLE FREETYPE_CFLAGS
        RESULT_VARIABLE RET
        ERROR_QUIET )

  if( RET EQUAL 0 )
    if( ${CMAKE_MAJOR_VERSION} EQUAL 2 AND ${CMAKE_MINOR_VERSION} EQUAL 6 )
      string(STRIP "${FREETYPE_CFLAGS}" FREETYPE_CFLAGS)
    endif()
    SEPARATE_ARGUMENTS(FREETYPE_CFLAGS)

    # parse definitions from cxxflags; drop -D* from CFLAGS
    string(REGEX REPLACE "-D[^;]+;" ""
           FREETYPE_CFLAGS "${FREETYPE_CFLAGS}" )

    # parse include dirs from cxxflags; drop -I prefix
    string(REGEX MATCHALL "-I[^;]+"
           FREETYPE_INCLUDE_DIR_ft2build "${FREETYPE_CFLAGS}" )
    string(REGEX REPLACE "-I[^;]+;" ""
           FREETYPE_CFLAGS "${FREETYPE_CFLAGS}" )
    string(REPLACE "-I" ""
           FREETYPE_INCLUDE_DIR_ft2build "${FREETYPE_INCLUDE_DIR_ft2build}" )
    string(REPLACE "\n" ""
           FREETYPE_INCLUDE_DIR_ft2build "${FREETYPE_INCLUDE_DIR_ft2build}" )
    set( FREETYPE_INCLUDE_DIR_ft2build "${FREETYPE_INCLUDE_DIR_ft2build}" )

  endif()

endif()

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "freetype/include" "static" )

if( NOT FREETYPE_INCLUDE_DIR_ft2build )
  # Look for the header file.
  find_path( FREETYPE_INCLUDE_DIR_ft2build NAMES freetype/freetype.h
                                           PATHS ${module_include_search_paths}
                                           DOC "Path in which the file freetype/freetype.h is located." )
  mark_as_advanced( FREETYPE_INCLUDE_DIR_ft2build )
endif()

# Look for the library.
find_library( FREETYPE_LIBRARY NAMES freetype freetype2311 freetype2312MT freetype2312 freetype235
                               PATHS ${module_lib_search_paths}
                               DOC "Path to freetype library." )
mark_as_advanced( FREETYPE_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set FREETYPE_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( FREETYPE DEFAULT_MSG
                                   FREETYPE_LIBRARY FREETYPE_INCLUDE_DIR_ft2build )

set( FREETYPE_LIBRARIES ${FREETYPE_LIBRARY} )
set( FREETYPE_INCLUDE_DIRS ${FREETYPE_INCLUDE_DIR_ft2build} )

# Backwards compatibility values set here.
set( FREETYPE_INCLUDE_DIR ${FREETYPE_INCLUDE_DIRS} )