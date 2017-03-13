# - Find HAPI
# Find the native HAPI headers and libraries.
# Output:
#  HAPI_INCLUDE_DIR -  where to find HAPI.h, etc.
#  HAPI_LIBRARIES    - List of libraries when using HAPI.
#  HAPI_FOUND        - True if HAPI found.
#
# Input
# HAPI_REQUIRED_RENDERERS - Set to a list of names of supported external renderers.
# Allowed values are "OpenHapticsRenderer" and "Chai3DRenderer". Only used
# if HAPI_DECIDES_RENDERER_SUPPORT is 1.
# HAPI_DECIDES_RENDERER_SUPPORT - If 1 HAPI decides which renderers are supported
# by checking HAPI.h (if found). If 0 the HAPI_REQUIRED_RENDERERS list is used.
# Note that external dependencies of the renderers are also required if a renderer is
# desired for support. For example, setting a dependency on OpenHapticsRenderer means
# that SensAbles OpenHaptics libraries must exist on the system for HAPI to be found
# properly. If a library do not use any of the external renderers then simply leave
# HAPI_DECIDES_RENDERER_SUPPORT at its default value (not existing or 0).
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

# Look for the header file.
find_path( HAPI_INCLUDE_DIR NAMES HAPI/HAPI.h HAPI/HAPI.cmake
                            PATHS $ENV{H3D_ROOT}/../HAPI/include
                                  ../../HAPI/include
                                  ${module_file_path}/../../../HAPI/include
                                  ${module_file_path}/../../include
                                  ../../../support/H3D/HAPI/include
                                  ${module_file_path}/../../../../support/H3D/HAPI/include
                            DOC "Path in which the file HAPI/HAPI.h is located." )
mark_as_advanced( HAPI_INCLUDE_DIR )

# Look for the library.
set( HAPI_LIBRARY_SUFFIX "" )
if( MSVC )
  set( h3d_msvc_version 6 )
  set( temp_msvc_version 1299 )
  while( ${MSVC_VERSION} GREATER ${temp_msvc_version} )
    math( EXPR h3d_msvc_version "${h3d_msvc_version} + 1" )
    # Increments one more time if MSVC version is 13 as it doesn't exist
    if( ${h3d_msvc_version} EQUAL 13 )
      math( EXPR h3d_msvc_version "${h3d_msvc_version} + 1" )
    endif()
    math( EXPR temp_msvc_version "${temp_msvc_version} + 100" )
  endwhile()
  set( HAPI_LIBRARY_SUFFIX "_vc${h3d_msvc_version}" )
  set( HAPI_NAME "HAPI${HAPI_LIBRARY_SUFFIX}" )
else()
  set( HAPI_NAME hapi )
endif()

set( default_lib_install "lib" )
if( WIN32 )
  set( default_lib_install "lib32" )
  if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    set( default_lib_install "lib64" )
  endif()
endif()

find_library( HAPI_LIBRARY NAMES ${HAPI_NAME}
                           PATHS $ENV{H3D_ROOT}/../${default_lib_install}
                                 ../../${default_lib_install}
                                 ${module_file_path}/../../../${default_lib_install}
                                 $ENV{H3D_ROOT}/../../../${default_lib_install}
                                 $ENV{H3D_ROOT}/../../${default_lib_install}
                                 ../../../support/H3D/${default_lib_install}
                                 ${module_file_path}/../../../../support/H3D/${default_lib_install}
                                 ../../../${default_lib_install}
                                 ${module_file_path}/../../../../${default_lib_install}
                           DOC "Path to ${HAPI_NAME} library." )

find_library( HAPI_DEBUG_LIBRARY NAMES ${HAPI_NAME}_d
              PATHS $ENV{H3D_ROOT}/../${default_lib_install}
                    ../../${default_lib_install}
                    ${module_file_path}/../../../${default_lib_install}
                    $ENV{H3D_ROOT}/../../../${default_lib_install}
                    $ENV{H3D_ROOT}/../../${default_lib_install}
                    ../../../support/H3D/${default_lib_install}
                    ${module_file_path}/../../../../support/H3D/${default_lib_install}
                    ../../../${default_lib_install}
                    ${module_file_path}/../../../../${default_lib_install}
                    DOC "Path to ${HAPI_NAME}_d library." )
mark_as_advanced( HAPI_LIBRARY )
mark_as_advanced( HAPI_DEBUG_LIBRARY )

set( HAPI_REQUIRED_RENDERERS_FOUND 1 )
set( HAPI_RENDERERS_INCLUDE_DIR "" )
set( HAPI_RENDERERS_LIBRARIES "" )
set( HAPI_OPENHAPTICS_SUPPORT 0 )
set( HAPI_CHAI3D_SUPPORT 0 )

if( HAPI_LIBRARY OR HAPI_DEBUG_LIBRARY )
  set( HAVE_HAPI_LIBRARY 1 )
else()
  set( HAVE_HAPI_LIBRARY 0 )
endif()

if( HAVE_HAPI_LIBRARY AND HAPI_INCLUDE_DIR )
  foreach( HAPI_INCLUDE_DIR_TMP ${HAPI_INCLUDE_DIR} )
    if( EXISTS ${HAPI_INCLUDE_DIR_TMP}/HAPI/HAPI.h )
      set( regex_to_find "#define HAVE_OPENHAPTICS" )
      file( STRINGS ${HAPI_INCLUDE_DIR_TMP}/HAPI/HAPI.h list_of_defines REGEX ${regex_to_find} )
      list( LENGTH list_of_defines list_of_defines_length )
      if( list_of_defines_length )
        set( HAPI_OPENHAPTICS_SUPPORT 1 )
      endif()
    
      set( regex_to_find "#define HAVE_CHAI3D" )
      file( STRINGS ${HAPI_INCLUDE_DIR_TMP}/HAPI/HAPI.h list_of_defines REGEX ${regex_to_find} )
      list( LENGTH list_of_defines list_of_defines_length )
      if( list_of_defines_length )
        set( HAPI_CHAI3D_SUPPORT 1 )
      endif()
    endif()
  endforeach()

    
  if( HAPI_DECIDES_RENDERER_SUPPORT AND NOT HAPI_REQUIRED_RENDERERS )
    if( HAPI_OPENHAPTICS_SUPPORT )
      set( HAPI_REQUIRED_RENDERERS "OpenHapticsRenderer" )
    endif()
    if( HAPI_CHAI3D_SUPPORT )
      set( HAPI_REQUIRED_RENDERERS ${HAPI_REQUIRED_RENDERERS} "Chai3DRenderer" )
    endif()
  endif()

  foreach( renderer_name ${HAPI_REQUIRED_RENDERERS} )
    if( ( ${renderer_name} STREQUAL "OpenHapticsRenderer" ) AND NOT HAPI_OPENHAPTICS_SUPPORT )
      set( HAPI_COMPILED_WITH_SUPPORT_MESSAGE "The found version of HAPI is not compiled with support for OpenHapticsRenderer" )
      if( HAPI_FIND_REQUIRED )
        message( FATAL_ERROR "${HAPI_COMPILED_WITH_SUPPORT_MESSAGE}" )
      elseif( NOT HAPI_FIND_QUIETLY )
        message( STATUS "${HAPI_COMPILED_WITH_SUPPORT_MESSAGE}" )
      endif()
    endif()
    
    
    if( ( ${renderer_name} STREQUAL "Chai3DRenderer" ) AND NOT HAPI_CHAI3D_SUPPORT )
      set( HAPI_COMPILED_WITH_SUPPORT_MESSAGE "The found version of HAPI is not compiled with support for Chai3DRenderer" )
      if( HAPI_FIND_REQUIRED )
        message( FATAL_ERROR "${HAPI_COMPILED_WITH_SUPPORT_MESSAGE}" )
      elseif( NOT HAPI_FIND_QUIETLY )
        message( STATUS "${HAPI_COMPILED_WITH_SUPPORT_MESSAGE}" )
      endif()
    endif()
    
    find_path( HAPI_${renderer_name}_INCLUDE_DIR NAMES HAPI/${renderer_name}.h 
                                                 PATHS $ENV{H3D_ROOT}/../HAPI/${renderer_name}/include
                                                       ../../HAPI/${renderer_name}/include
                                                       ${module_file_path}/../../../HAPI/${renderer_name}/include
                                                       ${HAPI_INCLUDE_DIR}/../${renderer_name}/include
                                                 DOC "Path in which the file HAPI/${renderer_name}.h is located." )
    mark_as_advanced( HAPI_${renderer_name}_INCLUDE_DIR )

    if( WIN32 )  
      find_library( HAPI_${renderer_name}_LIBRARY NAMES ${renderer_name}${HAPI_LIBRARY_SUFFIX}
                                                  PATHS $ENV{H3D_ROOT}/../${default_lib_install}
                                                        ../../${default_lib_install}
                                                        ${module_file_path}/../../../${default_lib_install}
                                                  DOC "Path to ${renderer_name}${HAPI_LIBRARY_SUFFIX} library." )

      find_library( HAPI_${renderer_name}_DEBUG_LIBRARY NAMES ${renderer_name}${HAPI_LIBRARY_SUFFIX}_d
                   PATHS $ENV{H3D_ROOT}/../${default_lib_install}
                          ../../${default_lib_install}
                          ${module_file_path}/../../../${default_lib_install}
                          DOC "Path to ${renderer_name}${HAPI_LIBRARY_SUFFIX}_d library." )
      mark_as_advanced( HAPI_${renderer_name}_LIBRARY )
      mark_as_advanced( HAPI_${renderer_name}_DEBUG_LIBRARY )
    endif()
    
    if( HAPI_${renderer_name}_INCLUDE_DIR AND ( HAPI_${renderer_name}_LIBRARY OR ${HAPI_${renderer_name}_DEBUG_LIBRARY} ) )  
      set( HAPI_RENDERERS_INCLUDE_DIR ${HAPI_RENDERERS_INCLUDE_DIR} ${HAPI_${renderer_name}_INCLUDE_DIR} )
      if( WIN32 )    
        if( HAPI_${renderer_name}_LIBRARY )
          set( HAPI_RENDERERS_LIBRARIES ${HAPI_RENDERERS_LIBRARIES} optimized ${HAPI_${renderer_name}_LIBRARY} )
        else()
          set( HAPI_RENDERERS_LIBRARIES ${HAPI_RENDERERS_LIBRARIES} optimized ${renderer_name}${HAPI_LIBRARY_SUFFIX} )
          message( STATUS "HAPI ${renderer_name} release libraries not found. Release build might not work." )
        endif()
          
        if( HAPI_${renderer_name}_DEBUG_LIBRARY )
          set( HAPI_RENDERERS_LIBRARIES ${HAPI_RENDERERS_LIBRARIES} debug ${HAPI_${renderer_name}_DEBUG_LIBRARY} )
        else()
          set( HAPI_RENDERERS_LIBRARIES ${HAPI_RENDERERS_LIBRARIES} debug ${renderer_name}${HAPI_LIBRARY_SUFFIX}_d )
          message( STATUS "HAPI ${renderer_name} debug libraries not found. Debug build might not work." )
        endif()
      endif()
      
      if( ( ${renderer_name} STREQUAL "OpenHapticsRenderer" ) )
        # OpenHapticsRenderer library is found. Check for OpenHaptics on the system. It must exist for the library
        # using HAPI since it is assumed that the library using HAPI will include OpenHapticsRenderer.h.
        find_package( OpenHaptics REQUIRED )
        if( OpenHaptics_FOUND )
          set( HAPI_RENDERERS_INCLUDE_DIR ${HAPI_RENDERERS_INCLUDE_DIR} ${OpenHaptics_INCLUDE_DIRS} )
          set( HAPI_RENDERERS_LIBRARIES ${HAPI_RENDERERS_LIBRARIES} ${OpenHaptics_LIBRARIES} )
        endif()
      endif()
      
      if( ( ${renderer_name} STREQUAL "Chai3DRenderer" ) )
        # Chai3DRenderer library is found. Check for chai3d on the system. It must exist for the library
        # using HAPI since it is assumed that the library using HAPI will include Chai3DRenderer.h.
        find_package( Chai3D REQUIRED )
        if( CHAI3D_FOUND )
          set( HAPI_RENDERERS_INCLUDE_DIR ${HAPI_RENDERERS_INCLUDE_DIR} ${CHAI3D_INCLUDE_DIR} )
          set( HAPI_RENDERERS_LIBRARIES ${HAPI_RENDERERS_LIBRARIES} ${CHAI3D_LIBRARIES} )
        endif()
      endif()
    else()
      set( HAPI_REQUIRED_RENDERERS_FOUND 0 )
    endif()
  endforeach()
endif()

# Copy the results to the output variables.
if( HAPI_INCLUDE_DIR AND HAVE_HAPI_LIBRARY AND HAPI_REQUIRED_RENDERERS_FOUND )
  set( HAPI_FOUND 1 )
  if( HAPI_LIBRARY )
    set( HAPI_LIBRARIES ${HAPI_LIBRARIES} optimized ${HAPI_LIBRARY} )
  else()
    set( HAPI_LIBRARIES ${HAPI_LIBRARIES} optimized ${HAPI_NAME} )
    message( STATUS "HAPI release libraries not found. Release build might not work." )
  endif()

  if( HAPI_DEBUG_LIBRARY )
    set( HAPI_LIBRARIES ${HAPI_LIBRARIES} debug ${HAPI_DEBUG_LIBRARY} )
  else()
    set( HAPI_LIBRARIES ${HAPI_LIBRARIES} debug ${HAPI_NAME}_d )
    message( STATUS "HAPI debug libraries not found. Debug build might not work." )
  endif()
  
  set( HAPI_INCLUDE_DIR ${HAPI_INCLUDE_DIR} ${HAPI_RENDERERS_INCLUDE_DIR} )
  set( HAPI_LIBRARIES ${HAPI_LIBRARIES} ${HAPI_RENDERERS_LIBRARIES} )
else()
  set( HAPI_FOUND 0 )
  set( HAPI_LIBRARIES )
  set( HAPI_INCLUDE_DIR )
endif()

# Report the results.
if( NOT HAPI_FOUND )
  set( HAPI_DIR_MESSAGE
       "HAPI was not found. Make sure HAPI_LIBRARY ( and/or HAPI_DEBUG_LIBRARY ) and HAPI_INCLUDE_DIR" )
  foreach( renderer_name ${HAPI_REQUIRED_RENDERERS} )
    set( HAPI_DIR_MESSAGE "${HAPI_DIR_MESSAGE} and HAPI_${renderer_name}_INCLUDE_DIR" )
    if( WIN32 )
      set( HAPI_DIR_MESSAGE "${HAPI_DIR_MESSAGE} and HAPI_${renderer_name}_LIBRARY ( and/or HAPI_${renderer_name}_DEBUG_LIBRARY )" )
    endif()
  endforeach()
  set( HAPI_DIR_MESSAGE "${HAPI_DIR_MESSAGE} are set." )
  if( HAPI_FIND_REQUIRED )
    message( FATAL_ERROR "${HAPI_DIR_MESSAGE}" )
  elseif( NOT HAPI_FIND_QUIETLY )
    message( STATUS "${HAPI_DIR_MESSAGE}" )
  endif()
endif()
