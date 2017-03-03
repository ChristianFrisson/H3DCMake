# - find DCMTK libraries
#
#  DCMTK_INCLUDE_DIRS   - Directories to include to use DCMTK
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

set( DCMTK_LIBRARY_POSTFIX "" )
if( MSVC_BEFORE_VS2010 )
  set( H3D_MSVC_VERSION 6 )
  set( TEMP_MSVC_VERSION 1299 )
  while( ${MSVC_VERSION} GREATER ${TEMP_MSVC_VERSION} )
    math( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
    math( EXPR TEMP_MSVC_VERSION "${TEMP_MSVC_VERSION} + 100" )
  endwhile()
  set( DCMTK_LIBRARY_POSTFIX "_vc${H3D_MSVC_VERSION}" )
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
           DOC "Path in which the file dcmtk/config/osconfig.h is located." )
mark_as_advanced( DCMTK_config_INCLUDE_DIR )

set( DCMTK_IS_VERSION360 FALSE )
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

foreach( dcmtk_lib_name ${DCMTK_lib_names_internal} )
  find_path( DCMTK_${dcmtk_lib_name}_INCLUDE_DIR NAMES dcmtk/${dcmtk_lib_name}
           PATHS ${DCMTK_DIR}/${dcmtk_lib_name}/include 
                 ${DCMTK_DIR}/include/${dcmtk_lib_name}
                 ${DCMTK_DIR}/include
                 ${module_include_search_paths}
                 ${module_file_path}/../../dcmtk/include
                 /usr/local/dicom/include
           DOC "Path to dcmtk/${dcmtk_lib_name} is located." )
  mark_as_advanced( DCMTK_${dcmtk_lib_name}_INCLUDE_DIR )

  find_library( DCMTK_${dcmtk_lib_name}_LIBRARY "${dcmtk_lib_name}${DCMTK_LIBRARY_POSTFIX}"
                PATHS ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc
                      ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc/Release
                      ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc/Debug
                      ${DCMTK_DIR}/${dcmtk_lib_name}/Release
                      ${DCMTK_DIR}/${dcmtk_lib_name}/Debug
                      ${DCMTK_DIR}/lib
                      ${module_lib_search_paths}
                      ${module_file_path}/../../dcmtk/lib
                      /usr/local/dicom/lib
                DOC "Path to ${dcmtk_lib_name}${DCMTK_LIBRARY_POSTFIX} library." )
  mark_as_advanced( DCMTK_${dcmtk_lib_name}_LIBRARY )
  
  if( WIN32 AND NOT MSVC_BEFORE_VS2010 )
    # Visual Studio versions later than 2008 needs debug versions to compile in debug
    find_library( DCMTK_${dcmtk_lib_name}_DEBUG_LIBRARY "${dcmtk_lib_name}${DCMTK_LIBRARY_POSTFIX}_d"
                  PATHS ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc
                        ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc/Release
                        ${DCMTK_DIR}/${dcmtk_lib_name}/libsrc/Debug
                        ${DCMTK_DIR}/${dcmtk_lib_name}/Release
                        ${DCMTK_DIR}/${dcmtk_lib_name}/Debug
                        ${DCMTK_DIR}/lib
                        ${module_lib_search_paths}
                        ${module_file_path}/../../dcmtk/lib
                        /usr/local/dicom/lib
                  DOC "Path to ${dcmtk_lib_name}${DCMTK_LIBRARY_POSTFIX}_d library." )
    mark_as_advanced( DCMTK_${dcmtk_lib_name}_DEBUG_LIBRARY )
  endif()
endforeach()

foreach( dcmtk_lib_ijg_name ${DCMTK_lib_ijg_names_internal} )
  find_library( DCMTK_${dcmtk_lib_ijg_name}_LIBRARY ${dcmtk_lib_ijg_name}${DCMTK_LIBRARY_POSTFIX}
              PATHS ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/libsrc
                    ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/libsrc/Release
                    ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/libsrc/Debug
                    ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/Release
                    ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/Debug
                    ${DCMTK_DIR}/lib
                    ${module_lib_search_paths}
                    ${module_file_path}/../../dcmtk/lib
                    /usr/local/dicom/lib
              DOC "Path to ${dcmtk_lib_ijg_name}${DCMTK_LIBRARY_POSTFIX} library." )
  mark_as_advanced( DCMTK_${dcmtk_lib_ijg_name}_LIBRARY )
  
  if( WIN32 AND NOT MSVC_BEFORE_VS2010 )
    find_library( DCMTK_${dcmtk_lib_ijg_name}_DEBUG_LIBRARY ${dcmtk_lib_ijg_name}${DCMTK_LIBRARY_POSTFIX}_d
                  PATHS ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/libsrc
                        ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/libsrc/Release
                        ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/libsrc/Debug
                        ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/Release
                        ${DCMTK_DIR}/dcmjpeg/lib${dcmtk_lib_ijg_name}/Debug
                        ${DCMTK_DIR}/lib
                        ${module_lib_search_paths}
                        ${module_file_path}/../../dcmtk/lib
                        /usr/local/dicom/lib
                  DOC "Path to ${dcmtk_lib_ijg_name}${DCMTK_LIBRARY_POSTFIX}_d library." )
    mark_as_advanced( DCMTK_${dcmtk_lib_ijg_name}_DEBUG_LIBRARY )
  endif()
endforeach()

set( HAVE_INCLUDE_DIRS ON )
set( HAVE_RELEASE_LIBS ON )
set( HAVE_DEBUG_LIBS ON )

# check that we have all include dirs, release libs and debug libs.
foreach( dcmtk_lib_name ${DCMTK_lib_names_internal} )
  if( NOT DCMTK_${dcmtk_lib_name}_INCLUDE_DIR )
    set( HAVE_INCLUDE_DIRS OFF )
  endif()
  if( NOT DCMTK_${dcmtk_lib_name}_LIBRARY )
    set( HAVE_RELEASE_LIBS OFF )
  endif()
  if( NOT DCMTK_${dcmtk_lib_name}_DEBUG_LIBRARY )
    set( HAVE_DEBUG_LIBS OFF )
  endif()
endforeach()

foreach( dcmtk_lib_ijg_name ${DCMTK_lib_ijg_names_internal} )
  if( NOT DCMTK_${dcmtk_lib_ijg_name}_LIBRARY )
    set( HAVE_RELEASE_LIBS OFF )
  endif()
  if( NOT DCMTK_${dcmtk_lib_ijg_name}_DEBUG_LIBRARY )
    set( HAVE_DEBUG_LIBS OFF )
  endif()
endforeach()

set( HAVE_TIFF_OR_NO_TIFF_NEEDED 1 )
if( HAVE_INCLUDE_DIRS AND HAVE_RELEASE_LIBS )
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
      if( NOT TIFF_FOUND )
        set( HAVE_TIFF_OR_NO_TIFF_NEEDED 0 )
      endif()
    endif()
  endif()
endif()

set( DCMTK_INCLUDE_DIRS "" )
set( DCMTK_LIBRARIES "" )
set( DCMTK_FOUND "NO" )
if( HAVE_INCLUDE_DIRS AND HAVE_RELEASE_LIBS AND HAVE_TIFF_OR_NO_TIFF_NEEDED )
  set( DCMTK_FOUND "YES" )
  
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
    
    if( WIN32 AND NOT MSVC_BEFORE_VS2010 )
      message( STATUS "DCMTK debug libraries not found. Debug compilation might not work with DCMTK." )
    endif()

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

endif()

# Report the results.
if( NOT DCMTK_FOUND )
  set( DCMTK_DIR_MESSAGE
       "DCMTK was not found. Make sure all cmake variables with prefix DCMTK_ set, see each one for description." )
  if( NOT HAVE_TIFF_OR_NO_TIFF_NEEDED )
    set( DCMTK_DIR_MESSAGE "${DCMTK_DIR_MESSAGE} Also make sure that TIFF is found." )
  endif()
  if( DCMTK_FIND_REQUIRED )
    set( DCMTK_DIR_MESSAGE
       "${DCMTK_DIR_MESSAGE} You need the Dicom Toolkit libraries and headers to compile." )
    message( FATAL_ERROR "${DCMTK_DIR_MESSAGE}" )
  elseif( NOT DCMTK_FIND_QUIETLY )
    set( DCMTK_DIR_MESSAGE
       "${DCMTK_DIR_MESSAGE} If you do not have the Dicom Toolkit libraries and headers you will not be able to load dicom images." )
    message( STATUS "${DCMTK_DIR_MESSAGE}" )
  endif()
endif()

# Backwards compatibility values set here.
set( DCMTK_INCLUDE_DIR ${DCMTK_INCLUDE_DIRS} )