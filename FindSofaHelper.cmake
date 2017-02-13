# - Find sofa helper library
# Find the sofahelper headers and libraries.
# This module can get sofahelper from two places
# when SOFA_DELAY_FIND_LIBS is set, it depends on SOFA_INSTALL_DIR to locate library
# when SOFA_DELAY_FIND_LIBS is not set, it search the h3d external folder to get the precompiled sofahelper library.
#  SOFAHELPER_INCLUDE_DIR  -  where to find helper.h, AdvancedTimer.h etc.
#  SOFAHELPER_LIBRARIES    - List of libraries when using sofa helper component.
#  SOFAHELPER_FOUND        - True if sofa helper found.
#  SOFA_DELAY_FIND_LIBS    - If defined then rely on predefined SOFA_INSTALL_DIR to locate the sofahelper library
#                            otherwise rely on predefined sofahelper library predefined in h3d external folder
# 

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "sofahelper" "sofahelper/framework" )

if( WIN32 )
set( SOFA_LIBRARY_POSTFIX "" )
endif()

if( NOT SOFA_DELAY_FIND_LIBS )
  if( H3D_USE_DEPENDENCIES_ONLY AND WIN32 )
    set( SOFA_INSTALL_DIR "${EXTERNAL_INCLUDE_DIR}/sofahelper" CACHE PATH "Path to root of SOFA helper" )
  else()
    if( DEFINED ENV{SOFA_ROOT} )
      set( SOFA_INSTALL_DIR "$ENV{SOFA_ROOT}" CACHE PATH "Path to root of SOFA installation" )
    else()
      if( DEFINED ENV{H3D_EXTERNAL_ROOT} )
        set( SOFA_INSTALL_DIR "$ENV{H3D_EXTERNAL_ROOT}/include/sofahelper" CACHE PATH "Path to root of SOFA helper" )
      else()
        if( DEFINED ENV{H3D_ROOT} )
          set( SOFA_INSTALL_DIR "$ENV{H3D_ROOT}/../External/include/sofahelper" CACHE PATH "Path to root of SOFA helper" )
        else( DEFINED ENV{H3D_ROOT} )
          set( SOFA_INSTALL_DIR "NOTFOUND" CACHE PATH "Path to root of SOFA installation" )
        endif( DEFINED ENV{H3D_ROOT} )
      endif()
    endif()
  endif()
else()
  if( NOT SOFA_INSTALL_DIR )
    message( SEND_ERROR "SOFA_DELAY_FIND_LIBS is defined, but no SOFA_INSTALL_DIR is set" )
  endif()
  message( STATUS "SOFA_DELAY_FIND_LIBS is defined, use locally build sofa helper instead" )
endif()

# Look for the header file.
find_path( SOFAHELPER_INCLUDE_DIR NAMES   sofa/helper/AdvancedTimer.h
                                  PATHS   ${SOFA_INSTALL_DIR}/framework
                                          ${module_include_search_paths}
                                  NO_DEFAULT_PATH 
                                  DOC     "Path in which the file AdvancedTimer.h is located." )
                                    
mark_as_advanced( SOFAHELPER_INCLUDE_DIR )

# Look for the library.

if( SOFA_DELAY_FIND_LIBS )
  # Assume it will be build before it is used by this project
  if( WIN32 )
    set( SOFAHELPER_LIBRARY ${SOFA_INSTALL_DIR}/lib/SofaHelper${SOFA_LIBRARY_POSTFIX}.lib CACHE FILE "Sofa helper library" )
    set( SOFAHELPER_DEBUG_LIBRARY ${SOFA_INSTALL_DIR}/lib/SofaHelper${SOFA_LIBRARY_POSTFIX}_d.lib CACHE FILE "Sofa helper debug library" )
  elseif( APPLE )
    set( SOFAHELPER_LIBRARY ${SOFA_INSTALL_DIR}/lib/libSofaHelper${SOFA_LIBRARY_POSTFIX}.dylib CACHE FILE "Sofa helper library" )
    set( SOFAHELPER_DEBUG_LIBRARY ${SOFA_INSTALL_DIR}/lib/libSofaHelper${SOFA_LIBRARY_POSTFIX}d.dylib CACHE FILE "Sofa helper debug library" )
  elseif( UNIX )
    set( SOFAHELPER_LIBRARY ${SOFA_INSTALL_DIR}/lib/libSofaHelper${SOFA_LIBRARY_POSTFIX}.so CACHE FILE "Sofa helper library" )
    set( SOFAHELPER_DEBUG_LIBRARY ${SOFA_INSTALL_DIR}/lib/libSofaHelper${SOFA_LIBRARY_POSTFIX}d.so CACHE FILE "Sofa helper debug library" )
  endif()
  mark_as_advanced( SOFAHELPER_LIBRARY )
  mark_as_advanced( SOFAHELPER_DEBUG_LIBRARY )
else()
  # use precompiled lib to work
find_library( SOFAHELPER_LIBRARY   NAMES   SofaHelper2${SOFA_LIBRARY_POSTFIX}
                                   PATHS   ${SOFA_INSTALL_DIR}/lib
                                           ${module_lib_search_paths}
                                   DOC     "Path to SofaHelper${SOFA_LIBRARY_POSTFIX} library." )
mark_as_advanced( SOFAHELPER_LIBRARY )
find_library( SOFAHELPER_DEBUG_LIBRARY NAMES   SofaHelper_d2${SOFA_LIBRARY_POSTFIX}
                                       PATHS   ${SOFA_INSTALL_DIR}/lib
                                               ${module_lib_search_paths}
                                       DOC     "Path to SofaHelper_d2${SOFA_LIBRARY_POSTFIX} library." )

mark_as_advanced( SOFAHELPER_DEBUG_LIBRARY )
endif()



# Copy the results to the output variables.
if( SOFAHELPER_INCLUDE_DIR AND SOFAHELPER_LIBRARY )
  set( SOFAHELPER_FOUND 1 )
  set( SOFAHELPER_INCLUDE_DIR ${SOFAHELPER_INCLUDE_DIR} )
  if( SOFAHELPER_DEBUG_LIBRARY )
    set( SOFAHELPER_LIBRARIES 
         optimized   ${SOFAHELPER_LIBRARY}
         debug       ${SOFAHELPER_DEBUG_LIBRARY})
  else()
    message( STATUS "Sofa helper debug library is not found. Debug compilation might not work with sofa heler." )
    set( SOFAHELPER_LIBRARIES ${SOFAHELPER_LIBRARY} )
  endif()
else()
  set( SOFAHELPER_FOUND 0 )
  set( SOFAHELPER_LIBRARIES )
  set( SOFAHELPER_INCLUDE_DIR )
endif()

# Report the results.
if( NOT SOFAHELPER_FOUND )
  set( SOFAHELPER_DIR_MESSAGE
       "Sofa helper component not found. Make sure SOFAHELPER_LIBRARY and SOFAHELPER_INCLUDE_DIR are set . Currently, it is only supported on windows. " )
  if( SOFAHELPER_FIND_REQUIRED )
    set( SOFAHELPER_DIR_MESSAGE
         "${SOFAHELPER_DIR_MESSAGE} Sofa helper component is required to build." )
    message( FALTAL_ERROR "${SOFAHELPER_DIR_MESSAGE}" )
  elseif( NOT SOFAHELPER_FIND_QUIETLY )
    set( SOFAHELPER_DIR_MESSAGE
         "${SOFAHELPER_DIR_MESSAGE} Timer profiling will be disabled without Sofa helper component" )
  endif()
endif()
