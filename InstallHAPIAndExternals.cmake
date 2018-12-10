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
# "lib" - Libraries should be installed.
# "bin" - Binaries should be installed.
# EXCLUDE_MAIN if true then the main features (HAPI) feature is excluded.
# EXCLUDE_EXTERNAL if false then the externals are excluded.
# Output variables are:
# HAPI_INCLUDE_FILES_INSTALL - Contains a list of include files that
# was used when the checked HAPI version was built.
# HAPI_INCLUDE_DIRECTORIES_INSTALL - Contains a list of directories that
# contains files used when the checked HAPI version was built.
# HAPI_LIBRARIES_INSTALL - Contains a list of libraries that
# was used when the checked HAPI version was built.
# HAPI_BINARIES_INSTALL - Contains a list of binaries that
# the built HAPI version needs.
if( COMMAND cmake_policy )
  if( POLICY CMP0026 )
    cmake_policy( SET CMP0026 NEW )
  endif()
  if( POLICY CMP0054 )
    cmake_policy( SET CMP0054 NEW )
  endif()
endif()

if( NOT DEFINED EXCLUDE_MAIN )
  set( EXCLUDE_MAIN OFF )
endif()

if( NOT DEFINED EXCLUDE_EXTERNAL )
  set( EXCLUDE_EXTERNAL OFF )
endif()

include( InstallH3DUtilAndExternals )
if( NOT h3d_release_only_warning )
  set( h3d_release_only_warning TRUE )
  message( "NOTE: Packing will only be done properly in Release build, not RelWithDebInfo, MinSizeRel or Debug" )
endif()

if( NOT DEFINED HAPI_INCLUDE_DIRS )
  set( HAPI_INCLUDE_DIRS "" CACHE PATH "Path to HAPI/include." )
endif()

include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES H3D_EXTERNAL_ROOT
                                              OLD_VARIABLE_NAMES EXTERNAL_ROOT
                                              DOC_STRINGS "Path to External directory that comes with H3D." )

if( WIN32 )
  if( NOT DEFINED H3D_EXTERNAL_ROOT )
    set( external_root_default "" )
    if( NOT "$ENV{H3D_EXTERNAL_ROOT}" STREQUAL  "" )
      set( external_root_default "$ENV{H3D_EXTERNAL_ROOT}" )
    endif()
    set( H3D_EXTERNAL_ROOT "${external_root_default}" CACHE PATH "Path to External directory that comes with H3D." )
    createCacheVariablesMarkedAsDeprecated( NEW_VARIABLE_NAMES H3D_EXTERNAL_ROOT
                                            OLD_VARIABLE_NAMES EXTERNAL_ROOT )
  endif()
endif()

if( NOT DEFINED HAPI_CMAKE_INSTALL_PREFIX )
  set( hapi_cmake_install_prefix_default "" )
  if( TARGET HAPI )
    set( hapi_cmake_install_prefix_default ${CMAKE_INSTALL_PREFIX} )
  elseif( NOT "${H3D_ROOT_CMAKE_PATH}" STREQUAL  "" )
    set( hapi_cmake_install_prefix_default "${H3D_ROOT_CMAKE_PATH}/.." )
  endif()
  set( HAPI_CMAKE_INSTALL_PREFIX ${hapi_cmake_install_prefix_default} CACHE PATH "Set this to the CMAKE_INSTALL_PREFIX directory used when installing HAPI. It is assumed that HAPI is installed in bin32/bin64 and lib32/lib64." )
  mark_as_advanced( HAPI_CMAKE_INSTALL_PREFIX )
endif()

set( HAPI_INCLUDE_FILES_INSTALL "" CACHE INTERNAL "List of External include files used by this compiled version of HAPI." )
set( HAPI_INCLUDE_DIRECTORIES_INSTALL "" CACHE INTERNAL "List of External include directories used by this compiled version of HAPI." )
set( HAPI_LIBRARIES_INSTALL "" CACHE INTERNAL "List of External libraries used by this compiled version of HAPI." )
set( HAPI_BINARIES_INSTALL "" CACHE INTERNAL "List of External binaries used by this compiled version of HAPI." )

getDefaultH3DOutputDirectoryName( default_bin_install default_lib_install )

set( hapi_external_bin "${H3D_EXTERNAL_ROOT}/${default_bin_install}" )
set( hapi_external_lib "${H3D_EXTERNAL_ROOT}/${default_lib_install}" )

if( HAPI_INCLUDE_DIRS AND H3D_EXTERNAL_ROOT )
  set( externals_to_look_for )
  if( MSVC )
    set( h3d_msvc_version 6 )
    set( temp_msvc_version 1299 )
    while( ${MSVC_VERSION} GREATER ${temp_msvc_version} )
      math( EXPR h3d_msvc_version "${h3d_msvc_version} + 1" )
      math( EXPR temp_msvc_version "${temp_msvc_version} + 100" )
    endwhile()

    if( ${h3d_msvc_version} GREATER 12 ) # MSVC skipped 13 in their numbering system.
      math( EXPR h3d_msvc_version "${h3d_msvc_version} + 1" )
    endif()
    if( ( ${h3d_msvc_version} GREATER 14 ) OR ( ${MSVC_VERSION} GREATER 1900 ) )
      # MSVC vs 2015 has number 1900 and vs 2017 has number 1910. So this is a guess on upcoming vs versions.
      math( EXPR h3d_msvc_version "${h3d_msvc_version} + 1" )
    endif()

    if( NOT EXCLUDE_EXTERNAL )
      # When the first item for an external entry is only "#define" then it will always be included.
      set( externals_to_look_for "#define HAVE_OPENHAPTICS" )
      if( NOT TARGET HAPI )
        set( externals_to_look_for ${externals_to_look_for}
                                 "include" "../OpenHapticsRenderer/include/HAPI" )
      endif()
      set( externals_to_look_for ${externals_to_look_for}
                                 "lib" "OpenHapticsRenderer"
                                 "bin" "OpenHapticsRenderer"
                                 "warning" "NOTE: HAPI compiled with OpenHaptics support. If OpenHaptics is not distributed together with the package then test that the application starts on a system without OpenHaptics."

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
                                 "warning" "NOTE: HAPI compiled with Novint Falcon support. If Novint Falcon dlls is not distributed together with the package then test that the application starts on a system without Novint Falcon dlls."

                                 "#define HAVE_NIFALCONAPI"
                                 "warning" "NOTE: HAPI compiled with NiFalcon api support. If NiFalcon dlls is not distributed together with the package then test that the application starts on a system without NiFalcon dlls"

                                 "#define NIFALCONAPI_LIBUSB"
                                 "warning" "NOTE: HAPI compiled with NiFalcon api LIBUSB support. If NiFalcon dlls ( if there are any ) is not distributed together with the package then test that the application starts on a system without NiFalcon dlls"

                                 "#define NIFALCONAPI_LIBFTD2XX"
                                 "warning" "NOTE: HAPI compiled with NiFalcon api LIBFTD2XX api support. If NiFalcon dlls ( if there are any ) is not distributed together with the package then test that the application starts on a system without NiFalcon dlls"

                                 "#define NIFALCONAPI_LIBFTDI"
                                 "warning" "NOTE: HAPI compiled with NiFalcon api LIBFTDI support. If NiFalcon dlls ( if there are any ) is not distributed together with the package then test that the application starts on a system without NiFalcon dlls"

                                 "#define HAVE_FPARSER"
                                 "include" "fparser"
                                 "lib" "fparser"
                                 "bin" "fparser"

                                 "#define HAVE_HAPTIK_LIBRARY"
                                 "warning" "NOTE: HAPI compiled with HAPTIK library support. If HAPTIK dlls( if there are any ) is not distributed together with the package then test that the application starts on a system without HAPTIK dlls"

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
                                 "bin" "glew32" "freeglut" )
    endif()
    if( NOT EXCLUDE_MAIN )
      set( externals_to_look_for ${externals_to_look_for}
                                 "#define"
                                 "include" "HAPI"
                                 "lib" "HAPI"
                                 "bin" "HAPI" )
    endif()
  endif()

  list( LENGTH FEATURES_TO_INSTALL features_to_install_length )
  math( EXPR features_to_install_length "${features_to_install_length} - 1" )
  set( features_to_install_truncated "" )
  foreach( loop_var RANGE 0 ${features_to_install_length} 2 )
    list( GET FEATURES_TO_INSTALL ${loop_var} one_feature )
    list( APPEND features_to_install_truncated ${one_feature} )
  endforeach()

  set( include_dirs_to_check ${H3D_EXTERNAL_ROOT}/include ${HAPI_INCLUDE_DIRS} )
  set( add_external FALSE )
  set( current_checked_feature "" )
  foreach( hapi_include_dir_tmp ${HAPI_INCLUDE_DIRS} )
    if( EXISTS ${hapi_include_dir_tmp}/HAPI/HAPI.h )
      foreach( feature_to_look_for ${externals_to_look_for} )
        if( feature_to_look_for MATCHES "#define" )
          set( add_external FALSE )
          set( regex_to_find ${feature_to_look_for} )
          file( STRINGS ${hapi_include_dir_tmp}/HAPI/HAPI.h list_of_defines REGEX ${regex_to_find} )
          list( LENGTH list_of_defines list_of_defines_length )
          if( list_of_defines_length )
            set( add_external TRUE )
          endif()
        elseif( add_external )
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
            set( found_include_path FALSE )
            foreach( include_dir_to_check ${include_dirs_to_check} )
              if( EXISTS ${include_dir_to_check}/${feature_to_look_for} )
                set( found_include_path TRUE )
                set( HAPI_INCLUDE_DIRECTORIES_INSTALL ${HAPI_INCLUDE_DIRECTORIES_INSTALL} ${include_dir_to_check}/${feature_to_look_for} )
              elseif( EXISTS ${include_dir_to_check}/${feature_to_look_for}.h )
                set( found_include_path TRUE )
                set( HAPI_INCLUDE_FILES_INSTALL ${HAPI_INCLUDE_FILES_INSTALL} ${include_dir_to_check}/${feature_to_look_for}.h )
              endif()
            endforeach()
            if( NOT found_include_path )
              message( "Include directory or file ${feature_to_look_for} not found. Searched using CMake variable H3D_EXTERNAL_ROOT and HAPI_INCLUDE_DIR." )
            endif()
          elseif( current_checked_feature STREQUAL "lib" )
            if( EXISTS ${hapi_external_lib}/${feature_to_look_for}.lib )
              set( HAPI_LIBRARIES_INSTALL ${HAPI_LIBRARIES_INSTALL} ${hapi_external_lib}/${feature_to_look_for}.lib )
            elseif( EXISTS ${hapi_external_lib}/static/${feature_to_look_for}.lib )
              set( HAPI_LIBRARIES_INSTALL ${HAPI_LIBRARIES_INSTALL} ${hapi_external_lib}/static/${feature_to_look_for}.lib )
            elseif( TARGET ${feature_to_look_for} )
              if( CMAKE_VERSION VERSION_LESS 3.0.0 )
                get_target_property( hapi_release_filename_path ${feature_to_look_for} LOCATION_RELEASE )
                get_filename_component( hapi_release_filename_path ${hapi_release_filename_path} PATH )
                set( HAPI_LIBRARIES_INSTALL ${HAPI_LIBRARIES_INSTALL} ${hapi_release_filename_path}/${feature_to_look_for}_vc${h3d_msvc_version}.lib )
              else()
                set( HAPI_LIBRARIES_INSTALL ${HAPI_LIBRARIES_INSTALL} $<TARGET_LINKER_FILE:${feature_to_look_for}> )
              endif()
            elseif( HAPI_CMAKE_INSTALL_PREFIX )
              set( dirs_to_test ${HAPI_CMAKE_INSTALL_PREFIX}/${default_lib_install}
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
              message( "Library file ${feature_to_look_for}.lib not found. Searched using CMake variable H3D_EXTERNAL_ROOT and HAPI_CMAKE_INSTALL_PREFIX." )
            endif()
          elseif( current_checked_feature STREQUAL "bin" )
            if( EXISTS ${hapi_external_bin}/${feature_to_look_for}.dll )
              set( HAPI_BINARIES_INSTALL ${HAPI_BINARIES_INSTALL} ${hapi_external_bin}/${feature_to_look_for}.dll )
            elseif( TARGET ${feature_to_look_for} )
              if( CMAKE_VERSION VERSION_LESS 3.0.0 )
                get_target_property( hapi_release_filename ${feature_to_look_for} LOCATION_RELEASE )
                set( HAPI_BINARIES_INSTALL ${HAPI_BINARIES_INSTALL} ${hapi_release_filename} )
              else()
                set( HAPI_BINARIES_INSTALL ${HAPI_BINARIES_INSTALL} $<TARGET_FILE:${feature_to_look_for}> )
              endif()
            elseif( HAPI_CMAKE_INSTALL_PREFIX )
              set( dirs_to_test ${HAPI_CMAKE_INSTALL_PREFIX}/${default_bin_install}
                                ${HAPI_CMAKE_INSTALL_PREFIX}/bin )
              foreach( dir_to_test ${dirs_to_test} )
                if( EXISTS ${dir_to_test}/${feature_to_look_for}_vc${h3d_msvc_version}.dll )
                  set( HAPI_BINARIES_INSTALL ${HAPI_BINARIES_INSTALL} ${dir_to_test}/${feature_to_look_for}_vc${h3d_msvc_version}.dll )
                  break()
                endif()
              endforeach()
            else()
              message( "Binary file ${feature_to_look_for}.dll not found. Searched using CMake variable H3D_EXTERNAL_ROOT and HAPI_CMAKE_INSTALL_PREFIX." )
            endif()
          elseif( current_checked_feature STREQUAL "warning" )
            message( ${feature_to_look_for} )
          endif()
        endif()
      endforeach()
    endif()
  endforeach()

  set( install_include FALSE )
  set( install_lib FALSE )
  set( install_bin FALSE )
  foreach( feature_to_install ${FEATURES_TO_INSTALL} )
    if( NOT install_include AND feature_to_install STREQUAL "include" )
      set( install_include TRUE )
    elseif( NOT install_lib AND feature_to_install STREQUAL "lib" )
      set( install_lib TRUE )
    elseif( NOT install_bin AND feature_to_install STREQUAL "bin" )
      set( install_bin TRUE )
    elseif( install_include )
      set( install_include FALSE )
      if( HAPI_INCLUDE_DIRECTORIES_INSTALL )
        foreach( ext_dir ${HAPI_INCLUDE_DIRECTORIES_INSTALL} )
          set( include_file_path_last_part "" )
          foreach( include_dir_to_check ${include_dirs_to_check} )
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
          foreach( include_dir_to_check ${include_dirs_to_check} )
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
    elseif( install_lib )
      set( install_lib FALSE )
      if( HAPI_LIBRARIES_INSTALL )
        foreach( ext_lib ${HAPI_LIBRARIES_INSTALL} )
          install( FILES ${ext_lib}
                   DESTINATION ${feature_to_install} )
        endforeach()
      endif()
    elseif( install_bin )
      set( install_bin FALSE )
      if( HAPI_BINARIES_INSTALL )
        foreach( ext_bin ${HAPI_BINARIES_INSTALL} )
          install( FILES ${ext_bin}
                   DESTINATION ${feature_to_install} )
        endforeach()
      endif()
    endif()
  endforeach()
endif()