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
# DCMTK_lib_names - Use this to list which DCMTK libraries to include. Default values are:
# dcmjpeg ofstd oflog dcmimage dcmdata dcmimgle
# DCMTK_lib_ijg_names - Use this to list which DCMTK ijg libraries to include. Default values are
# ijg8 ijg12 ijg16
# TODO: replace this with the COMPONENT feature of find_package.

set( DCMTK_DIR "" CACHE PATH "Set this to the root of the installed dcmtk files to find include files and libraries." )
mark_as_advanced( DCMTK_DIR )

include( H3DExternalSearchPath )
set( MSVC_BEFORE_VS2010 OFF )
if( MSVC )
  if( ${MSVC_VERSION} LESS 1600 )
    set( MSVC_BEFORE_VS2010 ON )
  else()
    set( check_if_h3d_external_matches_vs_version ON )
  endif()
endif()

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )

set( dcmtk_library_postfix "" )
if( MSVC_BEFORE_VS2010 )
  set( H3D_MSVC_VERSION 6 )
  set( temp_msvc_version 1299 )
  while( ${MSVC_VERSION} GREATER ${temp_msvc_version} )
    math( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
    math( EXPR temp_msvc_version "${temp_msvc_version} + 100" )
  endwhile()
  set( dcmtk_library_postfix "_vc${H3D_MSVC_VERSION}" )
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

set( DCMTK_lib_names_internal dcmjpeg ofstd oflog dcmimage dcmdata dcmimgle )
if( DCMTK_lib_names )
  set( DCMTK_lib_names_internal ${DCMTK_lib_names} )
endif()

set( DCMTK_lib_ijg_names_internal ijg8 ijg12 ijg16 )
if( DCMTK_lib_ijg_names )
  set( DCMTK_lib_ijg_names_internal ${DCMTK_lib_ijg_names} )
endif()

set( required_vars DCMTK_config_INCLUDE_DIR )
foreach( dcmtk_lib_name ${DCMTK_lib_names_internal} )
  find_path( DCMTK_${dcmtk_lib_name}_INCLUDE_DIR NAMES dcmtk/${dcmtk_lib_name}
           PATHS ${DCMTK_DIR}/${dcmtk_lib_name}/include
                 ${DCMTK_DIR}/include/${dcmtk_lib_name}
                 ${DCMTK_DIR}/include
                 ${module_include_search_paths}
                 ${module_file_path}/../../dcmtk/include
                 /usr/local/dicom/include
           DOC "Path to dcmtk/${dcmtk_lib_name} is located."
           NO_SYSTEM_ENVIRONMENT_PATH )
  mark_as_advanced( DCMTK_${dcmtk_lib_name}_INCLUDE_DIR )

  find_library( DCMTK_${dcmtk_lib_name}_LIBRARY "${dcmtk_lib_name}${dcmtk_library_postfix}"
                PATHS ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc
                      ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc/Release
                      ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc/Debug
                      ${DCMTK_DIR}/${dcmtk_lib_name}/Release
                      ${DCMTK_DIR}/${dcmtk_lib_name}/Debug
                      ${DCMTK_DIR}/lib
                      ${module_lib_search_paths}
                      ${module_file_path}/../../dcmtk/lib
                      /usr/local/dicom/lib
                DOC "Path to ${dcmtk_lib_name}${dcmtk_library_postfix} library."
                NO_SYSTEM_ENVIRONMENT_PATH )
  mark_as_advanced( DCMTK_${dcmtk_lib_name}_LIBRARY )
  list( APPEND required_vars DCMTK_${dcmtk_lib_name}_INCLUDE_DIR DCMTK_${dcmtk_lib_name}_LIBRARY )

  if( WIN32 AND NOT MSVC_BEFORE_VS2010 )
    # Visual Studio versions later than 2008 needs debug versions to compile in debug
    find_library( DCMTK_${dcmtk_lib_name}_DEBUG_LIBRARY "${dcmtk_lib_name}${dcmtk_library_postfix}_d"
                  PATHS ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc
                        ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc/Release
                        ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc/Debug
                        ${DCMTK_DIR}/${dcmtk_lib_name}/Release
                        ${DCMTK_DIR}/${dcmtk_lib_name}/Debug
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

foreach( dcmtk_lib_ijg_name ${DCMTK_lib_ijg_names_internal} )
  find_library( DCMTK_${dcmtk_lib_ijg_name}_LIBRARY ${dcmtk_lib_ijg_name}${dcmtk_library_postfix}
              PATHS ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/libsrc
                    ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/libsrc/Release
                    ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/libsrc/Debug
                    ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/Release
                    ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/Debug
                    ${DCMTK_DIR}/lib
                    ${module_lib_search_paths}
                    ${module_file_path}/../../dcmtk/lib
                    /usr/local/dicom/lib
              DOC "Path to ${dcmtk_lib_ijg_name}${dcmtk_library_postfix} library."
              NO_SYSTEM_ENVIRONMENT_PATH )
  mark_as_advanced( DCMTK_${dcmtk_lib_ijg_name}_LIBRARY )
  list( APPEND required_vars DCMTK_${dcmtk_lib_ijg_name}_LIBRARY )

  if( WIN32 AND NOT MSVC_BEFORE_VS2010 )
    find_library( DCMTK_${dcmtk_lib_ijg_name}_DEBUG_LIBRARY ${dcmtk_lib_ijg_name}${dcmtk_library_postfix}_d
                  PATHS ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/libsrc
                        ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/libsrc/Release
                        ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/libsrc/Debug
                        ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/Release
                        ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/Debug
                        ${DCMTK_DIR}/lib
                        ${module_lib_search_paths}
                        ${module_file_path}/../../dcmtk/lib
                        /usr/local/dicom/lib
                  DOC "Path to ${dcmtk_lib_ijg_name}${dcmtk_library_postfix}_d library."
                  NO_SYSTEM_ENVIRONMENT_PATH )
    mark_as_advanced( DCMTK_${dcmtk_lib_ijg_name}_DEBUG_LIBRARY )
    list( APPEND required_vars DCMTK_${dcmtk_lib_ijg_name}_DEBUG_LIBRARY )
  endif()
endforeach()

set( if_tiff_needed_then_tiff_found_variable )
set( tiff_needed NO )
if( DCMTK_config_INCLUDE_DIR )
  set( DCMTK_Config_file_name "dummy" )
  if( WIN32 )
    set( DCMTK_Config_file_name "cfwin32" )
  else()
    set( DCMTK_Config_file_name "cfunix" )
  endif()

  set( DCMTK_Config_file ${DCMTK_config_INCLUDE_DIR}/dcmtk/config/${DCMTK_Config_file_name}.h )
  if( NOT EXISTS ${DCMTK_Config_file} )
    if( EXISTS ${DCMTK_config_INCLUDE_DIR}/dcmtk/config/osconfig.h )
      set( DCMTK_Config_file ${DCMTK_config_INCLUDE_DIR}/dcmtk/config/osconfig.h )
    else()
      set( DCMTK_Config_file "" )
    endif()
  endif()
  if( DCMTK_Config_file )
    set( regex_to_find "#define[ ]+WITH_LIBTIFF" )
    file( STRINGS ${DCMTK_Config_file} list_of_defines REGEX ${regex_to_find} )
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
  foreach( dcmtk_lib_name ${DCMTK_lib_names_internal} )
    set( DCMTK_INCLUDE_DIRS ${DCMTK_INCLUDE_DIRS} ${DCMTK_${dcmtk_lib_name}_INCLUDE_DIR} )
  endforeach()

  if( WIN32 AND NOT MSVC_BEFORE_VS2010 )
    # MSVC after version 10(2010) needs debug libraries since it cannot compile with
    # the release versions
    foreach( dcmtk_lib_name ${DCMTK_lib_names_internal} )
      set( DCMTK_LIBRARIES ${DCMTK_LIBRARIES} optimized ${DCMTK_${dcmtk_lib_name}_LIBRARY} debug ${DCMTK_${dcmtk_lib_name}_DEBUG_LIBRARY} )
    endforeach()
    foreach( DCMTK_lib_ijg_name ${DCMTK_lib_ijg_names_internal} )
      set( DCMTK_LIBRARIES ${DCMTK_LIBRARIES} optimized ${DCMTK_${DCMTK_lib_ijg_name}_LIBRARY} debug ${DCMTK_${DCMTK_lib_ijg_name}_DEBUG_LIBRARY} )
    endforeach()
  else()
    foreach( dcmtk_lib_name ${DCMTK_lib_names_internal} )
      set( DCMTK_LIBRARIES ${DCMTK_LIBRARIES} ${DCMTK_${dcmtk_lib_name}_LIBRARY} )
    endforeach()
    foreach( DCMTK_lib_ijg_name ${DCMTK_lib_ijg_names_internal} )
      set( DCMTK_LIBRARIES ${DCMTK_LIBRARIES} ${DCMTK_${DCMTK_lib_ijg_name}_LIBRARY} )
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
  if( tiff_needed )
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