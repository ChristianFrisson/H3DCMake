# - Find sofa helper library
# Find the sofahelper headers and libraries.
# This module can get sofahelper from two places
# when SOFA_DELAY_FIND_LIBS is set, it depends on SOFA_INSTALL_DIR to locate library
# when SOFA_DELAY_FIND_LIBS is not set, it search the h3d external folder to get the precompiled sofahelper library.
#  SofaHelper_INCLUDE_DIRS -  where to find helper.h, AdvancedTimer.h etc.
#  SofaHelper_LIBRARIES    - List of libraries when using sofa helper component.
#  SofaHelper_FOUND        - True if sofa helper found.
#  SOFA_DELAY_FIND_LIBS    - If defined then rely on predefined SOFA_INSTALL_DIR to locate the sofahelper library
#                            otherwise rely on predefined sofahelper library predefined in h3d external folder
# 

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "sofahelper" "sofahelper/framework" )

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES SofaHelper_INCLUDE_DIR SofaHelper_LIBRARY_RELEASE SofaHelper_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES SOFAHELPER_INCLUDE_DIR SOFAHELPER_LIBRARY SOFAHELPER_DEBUG_LIBRARY
                                              DOC_STRINGS "Path in which the file AdvancedTimer.h is located."
                                                          "Path to SofaHelper${SOFA_LIBRARY_POSTFIX} library."
                                                          "Path to SofaHelper_d2${SOFA_LIBRARY_POSTFIX} library." )

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
find_path( SofaHelper_INCLUDE_DIR NAMES   sofa/helper/AdvancedTimer.h
                                  PATHS   ${SOFA_INSTALL_DIR}/framework
                                          ${module_include_search_paths}
                                  NO_DEFAULT_PATH 
                                  DOC     "Path in which the file AdvancedTimer.h is located." )
                                    
mark_as_advanced( SofaHelper_INCLUDE_DIR )

# Look for the library.

if( SOFA_DELAY_FIND_LIBS )
  # Assume it will be build before it is used by this project
  if( WIN32 )
    set( SofaHelper_LIBRARY_RELEASE ${SOFA_INSTALL_DIR}/lib/SofaHelper${SOFA_LIBRARY_POSTFIX}.lib CACHE FILE "Sofa helper library" )
    set( SofaHelper_LIBRARY_DEBUG ${SOFA_INSTALL_DIR}/lib/SofaHelper${SOFA_LIBRARY_POSTFIX}_d.lib CACHE FILE "Sofa helper debug library" )
  elseif( APPLE )
    set( SofaHelper_LIBRARY_RELEASE ${SOFA_INSTALL_DIR}/lib/libSofaHelper${SOFA_LIBRARY_POSTFIX}.dylib CACHE FILE "Sofa helper library" )
    set( SofaHelper_LIBRARY_DEBUG ${SOFA_INSTALL_DIR}/lib/libSofaHelper${SOFA_LIBRARY_POSTFIX}d.dylib CACHE FILE "Sofa helper debug library" )
  elseif( UNIX )
    set( SofaHelper_LIBRARY_RELEASE ${SOFA_INSTALL_DIR}/lib/libSofaHelper${SOFA_LIBRARY_POSTFIX}.so CACHE FILE "Sofa helper library" )
    set( SofaHelper_LIBRARY_DEBUG ${SOFA_INSTALL_DIR}/lib/libSofaHelper${SOFA_LIBRARY_POSTFIX}d.so CACHE FILE "Sofa helper debug library" )
  endif()
  mark_as_advanced( SofaHelper_LIBRARY_RELEASE )
  mark_as_advanced( SofaHelper_LIBRARY_DEBUG )
else()
  # use precompiled lib to work
  find_library( SofaHelper_LIBRARY_RELEASE   NAMES   SofaHelper2${SOFA_LIBRARY_POSTFIX}
                                     PATHS   ${SOFA_INSTALL_DIR}/lib
                                             ${module_lib_search_paths}
                                     DOC     "Path to SofaHelper${SOFA_LIBRARY_POSTFIX} library." )
  mark_as_advanced( SofaHelper_LIBRARY_RELEASE )
  find_library( SofaHelper_LIBRARY_DEBUG NAMES   SofaHelper_d2${SOFA_LIBRARY_POSTFIX}
                                         PATHS   ${SOFA_INSTALL_DIR}/lib
                                                 ${module_lib_search_paths}
                                         DOC     "Path to SofaHelper_d2${SOFA_LIBRARY_POSTFIX} library." )

  mark_as_advanced( SofaHelper_LIBRARY_DEBUG )
endif()

include( SelectLibraryConfigurations )
select_library_configurations( SofaHelper )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set SofaHelper_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( SofaHelper DEFAULT_MSG
                                   SofaHelper_LIBRARY SofaHelper_INCLUDE_DIR )

if( SofaHelper_FOUND AND MSVC )
  if( NOT SofaHelper_LIBRARY_RELEASE )
    message( WARNING "SofaHelper release library not found. Release build might not work properly. To get rid of this warning set SofaHelper_LIBRARY_RELEASE." )
  endif()
  if( NOT SofaHelper_LIBRARY_DEBUG )
    message( WARNING "SofaHelper debug library not found. Debug build might not work properly. To get rid of this warning set SofaHelper_LIBRARY_DEBUG." )
  endif()
endif()

# Backwards compatibility values set here.
set( SOFAHELPER_INCLUDE_DIR ${SofaHelper_INCLUDE_DIRS} )
set( SOFAHELPER_LIBRARIES ${SofaHelper_LIBRARIES} )
set( SofaHelper_FOUND ${SOFAHELPER_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.