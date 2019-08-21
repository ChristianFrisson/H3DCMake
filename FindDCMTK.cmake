# - find DCMTK libraries
#
#  DCMTK_INCLUDE_DIRS  - Directories to include to use DCMTK
#  DCMTK_LIBRARIES     - Files to link against to use DCMTK
#  DCMTK_FOUND         - If false, don't try to use DCMTK
#  DCMTK_DIR           - Optional source directory for DCMTK
#
# DCMTK_DIR can be used to make it simpler to find the various include
# directories and compiled libraries if you've just compiled it in the
# source tree. Just set it to the root of the tree where you extracted
# the source.
#
# Written for VXL by Amitha Perera.
#
# Updates from SenseGraphics to make this module less recognizable.
#
# The following features are deprecated and the COMPONENTS feature of find_package should be used instead.
# DCMTK_lib_names (deprecated) - Use this to list which DCMTK libraries to include. Default values are:
# dcmjpeg ofstd oflog dcmimage dcmdata dcmimgle
# DCMTK_lib_ijg_names (deprecated) - Use this to list which DCMTK ijg libraries to include. Default values are
# ijg8 ijg12 ijg16

set( DCMTK_DIR "" CACHE PATH "Set this to the root of the installed dcmtk files to find include files and libraries." )
mark_as_advanced( DCMTK_DIR )

include( H3DCommonFindModuleFunctions )
set( msvc_before_vs2010 OFF )
if( MSVC )
  if( ${MSVC_VERSION} LESS 1600 )
    set( msvc_before_vs2010 ON )
  else()
    set( check_if_h3d_external_matches_vs_version ON )
  endif()
endif()

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )

set( dcmtk_library_postfix "" )
if( msvc_before_vs2010 )
  include( H3DUtilityFunctions )
  getMSVCPostFix( dcmtk_library_postfix )
endif()

if( NOT WIN32 )
  set( DCMTK_HAVE_CONFIG_H "NO" CACHE BOOL "On some systems the compile flag -DHAVE_CONFIG_H needs to be defined because of DCMTK. If DCMTK headers are causing problem turn this flag on." )
  if( DCMTK_HAVE_CONFIG_H )
    set( CMAKE_CXX_FLAGS "-DHAVE_CONFIG_H" )
  endif()
endif()

find_path( DCMTK_config_INCLUDE_DIR NAMES dcmtk/config/osconfig.h
           PATHS ${DCMTK_DIR}/config/include
                 ${DCMTK_DIR}/include
                 ${module_include_search_paths}
                 ${module_file_path}/../../dcmtk/include
                 /usr/local/dicom/include
           DOC "Path in which the file dcmtk/config/osconfig.h is located."
           NO_SYSTEM_ENVIRONMENT_PATH )
mark_as_advanced( DCMTK_config_INCLUDE_DIR )

set( DCMTK_IS_VERSION360 FALSE ) # Do not make this one into lower case due to it being used as a cmakedefine.
if( EXISTS ${DCMTK_config_INCLUDE_DIR}/dcmtk/config/osconfig.h )
  file( STRINGS ${DCMTK_config_INCLUDE_DIR}/dcmtk/config/osconfig.h list_of_defines REGEX "3.6.0" )
  list( LENGTH list_of_defines list_of_defines_length )
  if( list_of_defines_length )
    set( DCMTK_IS_VERSION360 TRUE )
  endif()
endif()

if( DCMTK_lib_names OR DCMTK_lib_ijg_names )
  message( AUTHOR_WARNING "The setting DCMTK_lib_names and DCMTK_lib_ijg_names are deprecated. Use the COMPONENTS feature of find_package instead." )
endif()

set( dcmtk_lib_names        dcmjpeg ofstd oflog dcmimage dcmdata dcmimgle ijg8 ijg12 ijg16 )
set( dcmtk_lib_names_no_ijg dcmjpeg ofstd oflog dcmimage dcmdata dcmimgle )
if( DCMTK_FIND_COMPONENTS )
  set( dcmtk_lib_names ${DCMTK_FIND_COMPONENTS} )
  set( dcmtk_lib_names_no_ijg )
  foreach( lib_name ${DCMTK_FIND_COMPONENTS} )
    string( FIND ${lib_name} "ijg" ijg_string )
    if( ijg_string EQUAL -1 )
      set( dcmtk_lib_names_no_ijg ${dcmtk_lib_names_no_ijg} ${lib_name} )
    endif()
  endforeach()
elseif( DCMTK_lib_names OR DCMTK_lib_ijg_names )
  set( dcmtk_lib_names ${DCMTK_lib_names} ${DCMTK_lib_ijg_names} )
  set( dcmtk_lib_names_no_ijg ${DCMTK_lib_names} )
endif()

set( required_vars DCMTK_config_INCLUDE_DIR )
foreach( dcmtk_lib_name ${dcmtk_lib_names_no_ijg} )
  find_path( DCMTK_${dcmtk_lib_name}_INCLUDE_DIR NAMES dcmtk/${dcmtk_lib_name}
           PATHS ${DCMTK_DIR}/${dcmtk_lib_name}/include
                 ${DCMTK_DIR}/include/${dcmtk_lib_name}
                 ${DCMTK_DIR}/include
                 ${module_include_search_paths}
                 ${module_file_path}/../../dcmtk/include
                 /usr/local/dicom/include
           DOC "Path to where dcmtk/${dcmtk_lib_name} is located."
           NO_SYSTEM_ENVIRONMENT_PATH )
  mark_as_advanced( DCMTK_${dcmtk_lib_name}_INCLUDE_DIR )
  list( APPEND required_vars DCMTK_${dcmtk_lib_name}_INCLUDE_DIR )
endforeach()

foreach( dcmtk_lib_name ${dcmtk_lib_names} )
  find_library( DCMTK_${dcmtk_lib_name}_LIBRARY "${dcmtk_lib_name}${dcmtk_library_postfix}"
                PATHS ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc
                      ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc/Release
                      ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc/Debug
                      ${DCMTK_DIR}/${dcmtk_lib_name}/Release
                      ${DCMTK_DIR}/${dcmtk_lib_name}/Debug
                      ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_name}/libsrc
                      ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_name}/libsrc/Release
                      ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_name}/libsrc/Debug
                      ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_name}/Release
                      ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_name}/Debug
                      ${DCMTK_DIR}/lib
                      ${module_lib_search_paths}
                      ${module_file_path}/../../dcmtk/lib
                      /usr/local/dicom/lib
                DOC "Path to ${dcmtk_lib_name}${dcmtk_library_postfix} library."
                NO_SYSTEM_ENVIRONMENT_PATH )
  mark_as_advanced( DCMTK_${dcmtk_lib_name}_LIBRARY )
  list( APPEND required_vars DCMTK_${dcmtk_lib_name}_LIBRARY )

  if( WIN32 AND NOT msvc_before_vs2010 )
    # Visual Studio versions later than 2008 needs debug versions to compile in debug
    find_library( DCMTK_${dcmtk_lib_name}_DEBUG_LIBRARY "${dcmtk_lib_name}${dcmtk_library_postfix}_d"
                  PATHS ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc
                        ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc/Release
                        ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc/Debug
                        ${DCMTK_DIR}/${dcmtk_lib_name}/Release
                        ${DCMTK_DIR}/${dcmtk_lib_name}/Debug
                        ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_name}/libsrc
                        ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_name}/libsrc/Release
                        ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_name}/libsrc/Debug
                        ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_name}/Release
                        ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_name}/Debug
                        ${DCMTK_DIR}/lib
                        ${module_lib_search_paths}
                        ${module_file_path}/../../dcmtk/lib
                        /usr/local/dicom/lib
                  DOC "Path to ${dcmtk_lib_name}${dcmtk_library_postfix}_d library."
                  NO_SYSTEM_ENVIRONMENT_PATH )
    mark_as_advanced( DCMTK_${dcmtk_lib_name}_DEBUG_LIBRARY )
    list( APPEND required_vars DCMTK_${dcmtk_lib_name}_DEBUG_LIBRARY )
  endif()
endforeach()

# Extra libs to link against.
if( WIN32 )
  set( required_libs ${required_libs} optimized iphlpapi.lib debug iphlpapi.lib )
endif()


set( if_tiff_needed_then_tiff_found_variable )
set( tiff_needed NO )
if( DCMTK_config_INCLUDE_DIR )
  set( dcmtk_config_filename "dummy" )
  if( WIN32 )
    set( dcmtk_config_filename "cfwin32" )
  else()
    set( dcmtk_config_filename "cfunix" )
  endif()

  set( dcmtk_config_file ${DCMTK_config_INCLUDE_DIR}/dcmtk/config/${dcmtk_config_filename}.h )
  if( NOT EXISTS ${dcmtk_config_file} )
    if( EXISTS ${DCMTK_config_INCLUDE_DIR}/dcmtk/config/osconfig.h )
      set( dcmtk_config_file ${DCMTK_config_INCLUDE_DIR}/dcmtk/config/osconfig.h )
    else()
      set( dcmtk_config_file "" )
    endif()
  endif()
  if( dcmtk_config_file )
    set( regex_to_find "#define[ ]+WITH_LIBTIFF" )
    file( STRINGS ${dcmtk_config_file} list_of_defines REGEX ${regex_to_find} )
    list( LENGTH list_of_defines list_of_defines_length )
    if( list_of_defines_length )
      # Dicom is compiled with tiff support. Find libtiff as well.
      find_package( TIFF )
      set( if_tiff_needed_then_tiff_found_variable TIFF_FOUND )
      set( tiff_needed YES )
    endif()
  endif()
endif()

checkIfModuleFound( DCMTK
                    REQUIRED_VARS ${required_vars} ${if_tiff_needed_then_tiff_found_variable} )

set( DCMTK_LIBRARIES )
set( DCMTK_INCLUDE_DIRS )
if( DCMTK_FOUND )
  foreach( dcmtk_lib_name ${dcmtk_lib_names_no_ijg} )
    set( DCMTK_INCLUDE_DIRS ${DCMTK_INCLUDE_DIRS} ${DCMTK_${dcmtk_lib_name}_INCLUDE_DIR} )
  endforeach()

  if( WIN32 AND NOT msvc_before_vs2010 )
    # MSVC after version 10(2010) needs debug libraries since it cannot compile with
    # the release versions
    foreach( dcmtk_lib_name ${dcmtk_lib_names} )
      set( DCMTK_LIBRARIES ${DCMTK_LIBRARIES} optimized ${DCMTK_${dcmtk_lib_name}_LIBRARY} debug ${DCMTK_${dcmtk_lib_name}_DEBUG_LIBRARY} )
    endforeach()
  else()
    foreach( dcmtk_lib_name ${dcmtk_lib_names} )
      set( DCMTK_LIBRARIES ${DCMTK_LIBRARIES} ${DCMTK_${dcmtk_lib_name}_LIBRARY} )
    endforeach()
  endif()

  if( WIN32 )
    set( DCMTK_LIBRARIES ${DCMTK_LIBRARIES} netapi32 ws2_32 )
  endif()

  if( TIFF_FOUND )
    set( DCMTK_INCLUDE_DIRS ${DCMTK_INCLUDE_DIRS} ${TIFF_INCLUDE_DIR} )
    set( DCMTK_LIBRARIES ${DCMTK_LIBRARIES} ${TIFF_LIBRARIES} )
  endif()
else()
  if( tiff_needed OR DCMTK_FIND_COMPONENTS )
    # DCMTKs internal module does not take into account dependency with tiff for some reason.
    # therefore we do not call the internal function if our system detected that tiff is needed.
    include( FindPackageHandleStandardArgs )
    # handle the QUIETLY and REQUIRED arguments and set DCTMK_FOUND to TRUE
    # if all listed variables are TRUE
    find_package_handle_standard_args( DCTMK DEFAULT_MSG
                                       ${required_vars} ${if_tiff_needed_then_tiff_found_variable} )
  else()
    checkCMakeInternalModule( DCMTK )  # Will call CMakes internal find module for this feature.
  endif()
endif()

# Backwards compatibility values set here.
set( DCMTK_INCLUDE_DIR ${DCMTK_INCLUDE_DIRS} )