# This file detects HAPI libraries/include/binaries and the
# external libraries/includes/binaries a particular
# HAPI source is built with and installs that.
# It requires that HAPI_INCLUDE_DIR is set to HAPI/include of
# the build that should be checked.
# HAPI_CMAKE_INSTALL_PREFIX must be set to the CMAKE_INSTALL_PREFIX
# used when installing HAPI ( basically the directory above the directory
# in which HAPI binaries and libraries are installed ).
# EXTERNAL_ROOT should be set to the External directory that comes with
# H3D.
# FEATURES_TO_INSTALL should be set to a list of pairs.  The first
# item in each pair should be a specific word. The second item in the
# pair should be the directory to install into. The predefined words are:
# "include" - Include directories should be installed.
# "lib" - Release libraries should be installed.
# "bin" - Debug binaries should be installed.
# Output variables are:
# HAPI_INCLUDE_FILES_INSTALL - Contains a list of include files that
# was used when the checked HAPI version was built.
# HAPI_INCLUDE_DIRECTORIES_INSTALL - Contains a list of directories that
# contains files used when the checked HAPI version was built.
# HAPI_LIBRARIES_INSTALL - Contains a list of libraries that
# was used when the checked HAPI version was built.
# HAPI_BINARIES_INSTALL - Contains a list of binaries that
# the built HAPI version needs.
# TODO, IMPLEMENT FOR OTHER THAN WINDOWS if IT MAKES SENSE TO DO THAT.
# IMPLEMENT for other than MSVC10.
# GET INCLUDE_DIR AND LIBS FROM FIND_MODULES used by HAPI?
# IMPLEMENT to HANDLE debug libs/bins and configure to include them or not.

include( InstallH3DUtilAndExternals )
if( NOT h3d_release_only_warning )
  set( h3d_release_only_warning TRUE )
  message( "NOTE: Packing will only be done properly in Release build, not RelWithDebInfo, MinSizeRel or Debug" )
endif()

if( NOT DEFINED HAPI_INCLUDE_DIR )
  set( HAPI_INCLUDE_DIR "" CACHE BOOL "Path to HAPI/include." )
endif()

if( WIN32 )
  if( NOT DEFINED EXTERNAL_ROOT )
    set( EXTERNAL_ROOT_DEFAULT "" )
    if( NOT "$ENV{H3D_EXTERNAL_ROOT}" STREQUAL  "" )
      set( EXTERNAL_ROOT_DEFAULT "$ENV{H3D_EXTERNAL_ROOT}" )
    endif()
    set( EXTERNAL_ROOT "${EXTERNAL_ROOT_DEFAULT}" CACHE PATH "Path to External directory that comes with H3D." )
  endif()
endif()

if( NOT DEFINED HAPI_CMAKE_INSTALL_PREFIX )
  set( HAPI_CMAKE_INSTALL_PREFIX_DEFAULT "" )
  if( TARGET HAPI )
    set( HAPI_CMAKE_INSTALL_PREFIX_DEFAULT ${CMAKE_INSTALL_PREFIX} )
  elseif( NOT "${H3D_ROOT_CMAKE_PATH}" STREQUAL  "" )
    set( HAPI_CMAKE_INSTALL_PREFIX_DEFAULT "${H3D_ROOT_CMAKE_PATH}/.." )
  endif()
  set( HAPI_CMAKE_INSTALL_PREFIX ${HAPI_CMAKE_INSTALL_PREFIX_DEFAULT} CACHE PATH "Set this to the CMAKE_INSTALL_PREFIX directory used when installing HAPI. It is assumed that HAPI is installed in bin32/bin64 and lib32/lib64." )
  mark_as_advanced( HAPI_CMAKE_INSTALL_PREFIX )
endif()

set( HAPI_INCLUDE_FILES_INSTALL "" CACHE INTERNAL "List of External include files used by this compiled version of HAPI." )
set( HAPI_INCLUDE_DIRECTORIES_INSTALL "" CACHE INTERNAL "List of External include directories used by this compiled version of HAPI." )
set( HAPI_LIBRARIES_INSTALL "" CACHE INTERNAL "List of External libraries used by this compiled version of HAPI." )
set( HAPI_BINARIES_INSTALL "" CACHE INTERNAL "List of External binaries used by this compiled version of HAPI." )

set( HAPI_bin "bin32" )
set( HAPI_lib "lib32" )
if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set( HAPI_bin "bin64" )
  set( HAPI_lib "lib64" )
endif()
set( HAPI_EXTERNAL_BIN "${EXTERNAL_ROOT}/${HAPI_bin}" )
set( HAPI_EXTERNAL_LIB "${EXTERNAL_ROOT}/${HAPI_lib}" )

if( HAPI_INCLUDE_DIR AND EXTERNAL_ROOT )
  set( externals_to_look_for "" )
  if( MSVC )
    set( h3d_msvc_version 6 )
    set( temp_msvc_version 1299 )
    while( ${MSVC_VERSION} GREATER ${temp_msvc_version} )
      math( EXPR h3d_msvc_version "${h3d_msvc_version} + 1" )
      math( EXPR temp_msvc_version "${temp_msvc_version} + 100" )
    endwhile()

    ## TODO: Somehow check if TEEM is compiled against BZPI2, PNG and/or ZLIB, probably have to use find modules.
    # When the first item for an external entry is only "#define" then it will always be included.
    set( externals_to_look_for "#define HAVE_OPENHAPTICS" )
    if( NOT TARGET HAPI )
      set( externals_to_look_for ${externals_to_look_for}
                               "include" "../OpenHapticsRenderer/include/HAPI" )
    endif()
    set( externals_to_look_for ${externals_to_look_for}
                               "lib" "OpenHapticsRenderer"
                               "bin" "OpenHapticsRenderer"
                               "warning" "NOTE: HAPI compiled with OpenHaptics support. Test that application starts on system without OpenHaptics before distributing package if you do not distribute it yourself."

                               "#define HAVE_CHAI3D" )
    if( NOT TARGET HAPI )
      set( externals_to_look_for ${externals_to_look_for}
                               "include" "../Chai3DRenderer/include/HAPI" )
    endif()
    set( externals_to_look_for ${externals_to_look_for}
                               "include" "chai3d"
                               "lib" "chai3d_complete_vc${h3d_msvc_version}" "Chai3DRenderer"
                               "bin" "Chai3DRenderer"

                               "#define HAVE_ENTACTAPI"
                               "include" "EntactAPI"
                               "lib" "EntactAPI"
                               "bin" "EntactAPI"

                               "#define HAVE_DHDAPI"
                               "include" "DHD-API"
                               "lib" "dhdms"

                               "#define HAVE_VIRTUOSEAPI"
                               "include" "virtuoseAPI"
                               "lib" "virtuoseDLL"

                               "#define HAVE_FALCONAPI"
                               "warning" "NOTE: HAPI compiled with Novint Falcon support. Test that application starts on system without Novint Falcon dlls before distributing package if you do not distribute it yourself."

                               "#define HAVE_NIFALCONAPI"
                               "warning" "NOTE: HAPI compiled with NiFalcon api support. Test that application starts on system without NiFalcon dlls ( if there are any ) before distributing package if you do not distribute it yourself."

                               "#define NIFALCONAPI_LIBUSB"
                               "warning" "NOTE: HAPI compiled with NiFalcon api LIBUSB support. Test that application starts on system without NiFalcon dlls ( if there are any ) before distributing package if you do not distribute it yourself."

                               "#define NIFALCONAPI_LIBFTD2XX"
                               "warning" "NOTE: HAPI compiled with NiFalcon api LIBFTD2XX api support. Test that application starts on system without NiFalcon dlls ( if there are any ) before distributing package if you do not distribute it yourself."

                               "#define NIFALCONAPI_LIBFTDI"
                               "warning" "NOTE: HAPI compiled with NiFalcon api LIBFTDI support. Test that application starts on system without NiFalcon dlls ( if there are any ) before distributing package if you do not distribute it yourself."

                               "#define HAVE_FPARSER"
                               "include" "fparser"
                               "lib" "fparser"
                               "bin" "fparser"

                               "#define HAVE_HAPTIK_LIBRARY"
                               "warning" "NOTE: HAPI compiled with HAPTIK library support. Test that application starts on system without HAPTIK dlls ( if there are any ) before distributing package if you do not distribute it yourself."

                               "#define HAVE_SIMBALLMEDICAL_API"
                               "include" "Simball"
                               "lib" "SimballMedicalHID"
                               "bin" "SimballMedicalHID"

                               "#define HAVE_HAPTIC_MASTER_API"
                               "bin" "HapticAPI" "HapticMasterDriver"

                               "#define HAVE_QUANSERAPI"

                               "#define HAVE_MLHI"

                               "#define HAVE_OPENGL"
                               "include" "GL/freeglut" "GL/freeglut" "GL/freeglut_ext" "GL/freeglut_std" "GL/glew" "GL/glext" "GL/glut" "GL/wglew"
                               "lib" "glew32" "freeglut"
                               "bin" "glew32" "freeglut"

                               "#define"
                               "include" "HAPI"
                               "lib" "HAPI"
                               "bin" "HAPI" )
  endif()

  list( LENGTH FEATURES_TO_INSTALL FEATURES_TO_INSTALL_LENGTH )
  math( EXPR FEATURES_TO_INSTALL_LENGTH "${FEATURES_TO_INSTALL_LENGTH} - 1" )
  set( features_to_install_truncated "" )
  foreach( loop_var RANGE 0 ${FEATURES_TO_INSTALL_LENGTH} 2 )
    list( GET FEATURES_TO_INSTALL ${loop_var} one_feature )
    list( APPEND features_to_install_truncated ${one_feature} )
  endforeach()

  set( INCLUDE_DIRS_TO_CHECK ${EXTERNAL_ROOT}/include ${HAPI_INCLUDE_DIR} )
  set( ADD_EXTERNAL FALSE )
  set( current_checked_feature "" )
  foreach( HAPI_INCLUDE_DIR_TMP ${HAPI_INCLUDE_DIR} )
    if( EXISTS ${HAPI_INCLUDE_DIR_TMP}/HAPI/HAPI.h )
      foreach( feature_to_look_for ${externals_to_look_for} )
        if( feature_to_look_for MATCHES "#define" )
          set( ADD_EXTERNAL FALSE )
          set( regex_to_find ${feature_to_look_for} )
          file( STRINGS ${HAPI_INCLUDE_DIR_TMP}/HAPI/HAPI.h list_of_defines REGEX ${regex_to_find} )
          list( LENGTH list_of_defines list_of_defines_length )
          if( list_of_defines_length )
            set( ADD_EXTERNAL TRUE )
          endif()
        elseif( ADD_EXTERNAL )
          if( feature_to_look_for STREQUAL "include" OR
              feature_to_look_for STREQUAL "lib" OR
              feature_to_look_for STREQUAL "bin" )
            list( FIND features_to_install_truncated ${feature_to_look_for} feature_found )
            if( ${feature_found} EQUAL -1 )
              set( current_checked_feature "feature_not_desired" )
            else()
              set( current_checked_feature ${feature_to_look_for} )
            endif()
          elseif( feature_to_look_for STREQUAL "warning" )
            set( current_checked_feature ${feature_to_look_for} )
          elseif( current_checked_feature STREQUAL "include" )
            set( FOUND_INCLUDE_PATH FALSE )
            foreach( include_dir_to_check ${INCLUDE_DIRS_TO_CHECK} )
              if( EXISTS ${include_dir_to_check}/${feature_to_look_for} )
                set( FOUND_INCLUDE_PATH TRUE )
                set( HAPI_INCLUDE_DIRECTORIES_INSTALL ${HAPI_INCLUDE_DIRECTORIES_INSTALL} ${include_dir_to_check}/${feature_to_look_for} )
              elseif( EXISTS ${include_dir_to_check}/${feature_to_look_for}.h )
                set( FOUND_INCLUDE_PATH TRUE )
                set( HAPI_INCLUDE_FILES_INSTALL ${HAPI_INCLUDE_FILES_INSTALL} ${include_dir_to_check}/${feature_to_look_for}.h )
              endif()
            endforeach()
            if( NOT FOUND_INCLUDE_PATH )
              message( "Include directory or file ${feature_to_look_for} not found. Searched using CMake variable EXTERNAL_ROOT and HAPI_INCLUDE_DIR." )
            endif()
          elseif( current_checked_feature STREQUAL "lib" )
            if( EXISTS ${HAPI_EXTERNAL_LIB}/${feature_to_look_for}.lib )
              set( HAPI_LIBRARIES_INSTALL ${HAPI_LIBRARIES_INSTALL} ${HAPI_EXTERNAL_LIB}/${feature_to_look_for}.lib )
            elseif( EXISTS ${HAPI_EXTERNAL_LIB}/static/${feature_to_look_for}.lib )
              set( HAPI_LIBRARIES_INSTALL ${HAPI_LIBRARIES_INSTALL} ${HAPI_EXTERNAL_LIB}/static/${feature_to_look_for}.lib )
            elseif( TARGET ${feature_to_look_for} )
              get_target_property( hapi_release_filename_path ${feature_to_look_for} LOCATION_RELEASE )
              get_filename_component( hapi_release_filename_path ${hapi_release_filename_path} PATH )
              set( HAPI_LIBRARIES_INSTALL ${HAPI_LIBRARIES_INSTALL} ${hapi_release_filename_path}/${feature_to_look_for}_vc${h3d_msvc_version}.lib )
            elseif( HAPI_CMAKE_INSTALL_PREFIX )
              set( dirs_to_test ${HAPI_CMAKE_INSTALL_PREFIX}/${HAPI_lib}
                                ${HAPI_CMAKE_INSTALL_PREFIX}/lib )
              if( dirs_to_test )
                foreach( dir_to_test ${dirs_to_test} )
                  if( EXISTS ${dir_to_test}/${feature_to_look_for}_vc${h3d_msvc_version}.lib )
                    set( HAPI_LIBRARIES_INSTALL ${HAPI_LIBRARIES_INSTALL} ${dir_to_test}/${feature_to_look_for}_vc${h3d_msvc_version}.lib )
                    break()
                  endif()
                endforeach()
              endif()
            else()
              message( "Library file ${feature_to_look_for}.lib not found. Searched using CMake variable EXTERNAL_ROOT and HAPI_CMAKE_INSTALL_PREFIX." )
            endif()
          elseif( current_checked_feature STREQUAL "bin" )
            if( EXISTS ${HAPI_EXTERNAL_BIN}/${feature_to_look_for}.dll )
              set( HAPI_BINARIES_INSTALL ${HAPI_BINARIES_INSTALL} ${HAPI_EXTERNAL_BIN}/${feature_to_look_for}.dll )
            elseif( TARGET ${feature_to_look_for} )
              get_target_property( hapi_release_filename ${feature_to_look_for} LOCATION_RELEASE )
              set( HAPI_BINARIES_INSTALL ${HAPI_BINARIES_INSTALL} ${hapi_release_filename} )
            elseif( HAPI_CMAKE_INSTALL_PREFIX )
              set( dirs_to_test ${HAPI_CMAKE_INSTALL_PREFIX}/${HAPI_bin}
                                ${HAPI_CMAKE_INSTALL_PREFIX}/bin )
              foreach( dir_to_test ${dirs_to_test} )
                if( EXISTS ${dir_to_test}/${feature_to_look_for}_vc${h3d_msvc_version}.dll )
                  set( HAPI_BINARIES_INSTALL ${HAPI_BINARIES_INSTALL} ${dir_to_test}/${feature_to_look_for}_vc${h3d_msvc_version}.dll )
                  break()
                endif()
              endforeach()
            else()
              message( "Binary file ${feature_to_look_for}.dll not found. Searched using CMake variable EXTERNAL_ROOT and HAPI_CMAKE_INSTALL_PREFIX." )
            endif()
          elseif( current_checked_feature STREQUAL "warning" )
            message( ${feature_to_look_for} )
          endif()
        endif()
      endforeach()
    endif()
  endforeach()

  set( INSTALL_INCLUDE FALSE )
  set( INSTALL_LIB FALSE )
  set( INSTALL_BIN FALSE )
  foreach( feature_to_install ${FEATURES_TO_INSTALL} )
    if( NOT INSTALL_INCLUDE AND feature_to_install STREQUAL "include" )
      set( INSTALL_INCLUDE TRUE )
    elseif( NOT INSTALL_LIB AND feature_to_install STREQUAL "lib" )
      set( INSTALL_LIB TRUE )
    elseif( NOT INSTALL_BIN AND feature_to_install STREQUAL "bin" )
      set( INSTALL_BIN TRUE )
    elseif( INSTALL_INCLUDE )
      set( INSTALL_INCLUDE FALSE )
      if( HAPI_INCLUDE_DIRECTORIES_INSTALL )
        foreach( ext_dir ${HAPI_INCLUDE_DIRECTORIES_INSTALL} )
          set( include_file_path_last_part "" )
          foreach( include_dir_to_check ${INCLUDE_DIRS_TO_CHECK} )
            get_filename_component( include_file_path ${ext_dir} PATH )
            string( LENGTH ${include_file_path} include_length )
            string( LENGTH ${include_dir_to_check} include_dir_to_check_length )
            if( ${include_length} GREATER ${include_dir_to_check_length} )
              string( SUBSTRING ${include_file_path} 0 ${include_dir_to_check_length} include_file_path_first_part )
              if( ${include_file_path_first_part} STREQUAL ${include_dir_to_check} )
                string( SUBSTRING ${include_file_path} ${include_dir_to_check_length} -1 include_file_path_last_part )
                break()
              endif()
            endif()
          endforeach()
          install( DIRECTORY ${ext_dir}
                   DESTINATION ${feature_to_install}${include_file_path_last_part}
                   REGEX "(/.svn)|(/CVS)" EXCLUDE )
        endforeach()
      endif()

      if( HAPI_INCLUDE_FILES_INSTALL )
        foreach( ext_include_file ${HAPI_INCLUDE_FILES_INSTALL} )
          set( include_file_path_last_part "" )
          foreach( include_dir_to_check ${INCLUDE_DIRS_TO_CHECK} )
            get_filename_component( include_file_path ${ext_include_file} PATH )
            string( LENGTH ${include_file_path} include_length )
            string( LENGTH ${include_dir_to_check} include_dir_to_check_length )
            if( ${include_length} GREATER ${include_dir_to_check_length} )
              string( SUBSTRING ${include_file_path} 0 ${include_dir_to_check_length} include_file_path_first_part )
              if( ${include_file_path_first_part} STREQUAL ${include_dir_to_check} )
                string( SUBSTRING ${include_file_path} ${include_dir_to_check_length} -1 include_file_path_last_part )
                break()
              endif()
            endif()
          endforeach()
          install( FILES ${ext_include_file}
                   DESTINATION ${feature_to_install}${include_file_path_last_part} )
        endforeach()
      endif()
    elseif( INSTALL_LIB )
      set( INSTALL_LIB FALSE )
      if( HAPI_LIBRARIES_INSTALL )
        foreach( ext_lib ${HAPI_LIBRARIES_INSTALL} )
          install( FILES ${ext_lib}
                   DESTINATION ${feature_to_install} )
        endforeach()
      endif()
    elseif( INSTALL_BIN )
      set( INSTALL_BIN FALSE )
      if( HAPI_BINARIES_INSTALL )
        foreach( ext_bin ${HAPI_BINARIES_INSTALL} )
          install( FILES ${ext_bin}
                   DESTINATION ${feature_to_install} )
        endforeach()
      endif()
    endif()
  endforeach()
endif()