# - Find FREETYPE
# Find the native FREETYPE headers and libraries.
#
#  FREETYPE_FOUND        - True if FREETYPE found.
#  FREETYPE_INCLUDE_DIRS -  where to find FREETYPE.h, etc.
#  FREETYPE_LIBRARIES    - List of libraries when using FREETYPE.

find_program(FREETYPE_CONFIG_EXECUTABLE freetype-config
      ONLY_CMAKE_FIND_ROOT_PATH
      DOC "Path to freetype_config executable. Used to find freetype, not used on a standard Windows installation of H3DAPI." )
mark_as_advanced( FREETYPE_CONFIG_EXECUTABLE )

if( H3DFreetype_FIND_REQUIRED )
  if( WIN32 )
    find_package(Freetype QUIET REQUIRED)
  else()
    find_package(Freetype REQUIRED)
  endif()
else()
  if( WIN32 )
    find_package(Freetype QUIET)
  else()
    find_package(Freetype)
  endif()
endif()

if( NOT FREETYPE_FOUND )

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

  include( H3DExternalSearchPath )
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

  # Copy the results to the output variables.
  if( FREETYPE_INCLUDE_DIR_ft2build AND FREETYPE_LIBRARY )
    set( FREETYPE_FOUND 1 )
    set( FREETYPE_LIBRARIES ${FREETYPE_LIBRARY} )
    set( FREETYPE_INCLUDE_DIRS ${FREETYPE_INCLUDE_DIR_ft2build} )
  else()
    set( FREETYPE_FOUND 0 )
    set( FREETYPE_LIBRARIES )
    set( FREETYPE_INCLUDE_DIRS )
  endif()
endif()

# Report the results.
if( NOT FREETYPE_FOUND )
  set( FREETYPE_DIR_MESSAGE
       "FREETYPE was not found. Make sure FREETYPE_-named variables are set to the include directories and library files required." )
  if( FreeType_FIND_REQUIRED )
    message( FATAL_ERROR "${FREETYPE_DIR_MESSAGE}" )
  elseif( NOT FreeType_FIND_QUIETLY )
    message( STATUS "${FREETYPE_DIR_MESSAGE}" )
  endif()
endif()
