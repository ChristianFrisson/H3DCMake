# This file detects H3DAPI libraries/include/binaries and the
# external libraries/includes/binaries a particular
# H3DAPI source is built with and installs that.
# It requires that H3DUTIL_INCLUDE_DIR is set to H3DAPI/include of
# the build that should be checked.
# H3DAPI_CMAKE_INSTALL_PREFIX must be set to the CMAKE_INSTALL_PREFIX
# used when installing H3DAPI ( basically the directory above the directory
# in which H3DAPI binaries and libraries are installed ).
# EXTERNAL_ROOT should be set to the External directory that comes with
# H3D.
# FEATURES_TO_INSTALL should be set to a list of pairs.  The first
# item in each pair should be a specific word. The second item in the
# pair should be the directory to install into. The predefined words are:
# "include" - Include directories should be installed.
# "lib" - Libraries should be installed.
# "bin" - Binaries should be installed.
# EXCLUDE_MAIN if true then the main features (H3DAPI) feature is excluded.
# EXCLUDE_EXTERNAL if false then the externals are excluded.
# Output variables are:
# H3DAPI_INCLUDE_FILES_INSTALL - Contains a list of include files that
# was used when the checked H3DAPI version was built.
# H3DAPI_INCLUDE_DIRECTORIES_INSTALL - Contains a list of directories that
# contains files used when the checked H3DAPI version was built.
# H3DAPI_LIBRARIES_INSTALL - Contains a list of libraries that
# was used when the checked H3DAPI version was built.
# H3DAPI_BINARIES_INSTALL - Contains a list of binaries that
# the built H3DAPI version needs.
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

include( InstallHAPIAndExternals )
if( NOT h3d_release_only_warning )
  set( h3d_release_only_warning TRUE )
  message( "NOTE: Packing will only be done properly in Release build, not RelWithDebInfo, MinSizeRel or Debug" )
endif()

if( NOT DEFINED H3DAPI_INCLUDE_DIRS )
  set( H3DAPI_INCLUDE_DIRS "" CACHE PATH "Path to H3DAPI/include. Used to detect externals to install for H3DAPI." )
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

if( NOT DEFINED H3DAPI_CMAKE_INSTALL_PREFIX )
  set( h3dapi_cmake_install_prefix_default "" )
  if( TARGET H3DAPI )
    set( h3dapi_cmake_install_prefix_default ${CMAKE_INSTALL_PREFIX} )
  elseif( NOT "${H3D_ROOT_CMAKE_PATH}" STREQUAL  "" )
    set( h3dapi_cmake_install_prefix_default "${H3D_ROOT_CMAKE_PATH}/.." )
  endif()
  set( H3DAPI_CMAKE_INSTALL_PREFIX ${h3dapi_cmake_install_prefix_default} CACHE PATH "Set this to the CMAKE_INSTALL_PREFIX directory used when installing H3DAPI. It is assumed that H3DAPI is installed in bin32/bin64 and lib32/lib64." )
  mark_as_advanced( H3DAPI_CMAKE_INSTALL_PREFIX )
endif()

set( H3DAPI_INCLUDE_FILES_INSTALL "" CACHE INTERNAL "List of External include files used by this compiled version of H3DAPI." )
set( H3DAPI_INCLUDE_DIRECTORIES_INSTALL "" CACHE INTERNAL "List of External include directories used by this compiled version of H3DAPI." )
set( H3DAPI_LIBRARIES_INSTALL "" CACHE INTERNAL "List of External libraries used by this compiled version of H3DAPI." )
set( H3DAPI_BINARIES_INSTALL "" CACHE INTERNAL "List of External binaries used by this compiled version of H3DAPI." )
set( H3DAPI_NSIS_EXTRA_INSTALL_COMMANDS "\\n" CACHE INTERNAL "Extra install commands for installing with nsis." )
set( H3DAPI_NSIS_EXTRA_UNINSTALL_COMMANDS "\\n" CACHE INTERNAL "Extra uninstall commands for installing with nsi." )

getDefaultH3DOutputDirectoryName( default_bin_install default_lib_install )
set( h3dapi_external_bin "${H3D_EXTERNAL_ROOT}/${default_bin_install}" )
set( h3dapi_external_lib "${H3D_EXTERNAL_ROOT}/${default_lib_install}" )

if( H3DAPI_INCLUDE_DIRS AND H3D_EXTERNAL_ROOT )
  set( externals_to_look_for )
  if( MSVC )
    set( h3d_msvc_version 6 )
    set( temp_msvc_version 1299 )
    while( ${MSVC_VERSION} GREATER ${temp_msvc_version} )
      math( EXPR h3d_msvc_version "${h3d_msvc_version} + 1" )
      math( EXPR temp_msvc_version "${temp_msvc_version} + 100" )
    endwhile()

    if( NOT EXCLUDE_EXTERNAL )
      # Install OpenAL.
      set( OpenAlInstallExe "" CACHE FILEPATH "Needs to be set to add openal installation to the package." )
      mark_as_advanced( OpenAlInstallExe )
      if( OpenAlInstallExe )
        get_filename_component( openal_file_name ${OpenAlInstallExe} NAME )
        string( REPLACE "/" "\\\\" openal_install_exe_tmp ${OpenAlInstallExe} )
        set( openal_install_command_1 " Code to install OPENAL\\n  File \\\"${openal_install_exe_tmp}\\\"\\n" )
        set( openal_install_command_2 " Wait a bit for system to unlock file.\\n  Sleep 1000\\n"
                                      " Delete install file\\n  Delete \\\"$INSTDIR\\\\${openal_file_name}\\\"\\n" )
        set( h3doal_nsis_extra_install_commands ${openal_install_command_1}
                                                " Execute install file\\n  ExecWait '\\\"$INSTDIR\\\\${openal_file_name}\\\" /s'\\n"
                                                ${openal_install_command_2} )
        if( CMAKE_SIZEOF_VOID_P EQUAL 8 ) # check if the system is 64 bit
          set( h3doal_nsis_extra_uninstall_commands "A comment\\n \\\${If} \\\${RunningX64}\\n"
                                                    "A comment\\n   SetRegView 32\\n"
                                                    "A comment\\n \\\${EndIf}\\n" )
        endif()
        set( h3doal_nsis_extra_uninstall_commands ${h3doal_nsis_extra_uninstall_commands}
                                                  " Get OpenAL uninstall registry string\\n  ReadRegStr $0 HKLM SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Uninstall\\\\OpenAL \\\"UninstallString\\\"\\n"
                                                  " Check if OpenAL is installed\\n  StrCmp $0 \\\"\\\" uninstall_openal_no 0\\n"
                                                  " Check if uninstall OpenAL \\n  MessageBox MB_YESNO \\\"Do you want to uninstall OpenAL? It is recommended if no other applications use it.\\\" IDYES uninstall_openal_yes IDNO uninstall_openal_no\\n"
                                                  " A comment \\n  uninstall_openal_yes:\\n"
                                                  ${openal_install_command_1}
                                                  " Execute install file\\n  ExecWait '\\\"$INSTDIR\\\\${openal_file_name}\\\" /u /s'\\n"
                                                  ${openal_install_command_2}
                                                  " A comment \\n  uninstall_openal_no:\\n\\n" )
        if( CMAKE_SIZEOF_VOID_P EQUAL 8 ) # check if the system is 64 bit
          set( h3doal_nsis_extra_uninstall_commands ${h3doal_nsis_extra_uninstall_commands}
                                                    "A comment\\n \\\${If} \\\${RunningX64}\\n"
                                                    "A comment\\n   SetRegView 64\\n"
                                                    "A comment\\n \\\${EndIf}\\n" )
        endif()
      endif()

      # Install python if not already installed
      set( PythonInstallMSI "" CACHE FILEPATH "Needs to be set to add python installation to the package." )
      mark_as_advanced( PythonInstallMSI )
      if( PythonInstallMSI )
        string( REGEX MATCH 2\\.[456789] CPACK_PYTHON_VERSION ${PythonInstallMSI} )
        string( REGEX REPLACE \\. "" CPACK_PYTHON_VERSION_NO_DOT ${CPACK_PYTHON_VERSION} )
        get_filename_component( python_file_name ${PythonInstallMSI} NAME )
        string( REPLACE "/" "\\\\" python_install_msi_tmp ${PythonInstallMSI} )
        set( python_install_command_1 " Code to install Python\\n  ReadRegStr $0 HKLM SOFTWARE\\\\Python\\\\PythonCore\\\\${CPACK_PYTHON_VERSION}\\\\InstallPath \\\"\\\"\\n" )
        set( python_install_command_2 " Extract python installer\\n  File \\\"${python_install_msi_tmp}\\\"\\n" )
        set( python_install_command_3 " Wait a bit for system to unlock file.\\n  Sleep 1000\\n"
                                      " Delete python installer\\n  Delete \\\"$INSTDIR\\\\${python_file_name}\\\"\\n\\n" )

        set( h3dpython_nsis_extra_uninstall_commands ${python_install_command_1}
                                                     " Check if python is installed\\n  StrCmp $0 \\\"\\\" uninstall_python_no 0\\n"
                                                     " Check if uninstall python \\n  MessageBox MB_YESNO \\\"Do you want to uninstall python? It is recommended if no other applications use python ${CPACK_PYTHON_VERSION}.\\\" IDYES uninstall_python_yes IDNO uninstall_python_no\\n"
                                                     " A comment \\n  uninstall_python_yes:\\n"
                                                     ${python_install_command_2}
                                                     " Execute python installer, wait for completion\\n  ExecWait '\\\"msiexec\\\" /x \\\"$INSTDIR\\\\${python_file_name}\\\" /qn'\\n"
                                                     ${python_install_command_3}
                                                     " A comment \\n  uninstall_python_no:\\n" )
        set( h3dpython_nsis_extra_install_commands ${python_install_command_1}
                                                   " Check if python is installed\\n  StrCmp $0 \\\"\\\" 0 install_python_no\\n"
                                                   ${python_install_command_2}
                                                   "A comment \\n  ClearErrors\\n"
                                                   "Check if python install path is free \\n  GetFullPathName $0 C:\\\\Python${CPACK_PYTHON_VERSION_NO_DOT}\\n"
                                                   "If errors then path was not found, i.e. empty\\n  IfErrors 0 python_install_not_hidden \\n"
                                                   "A comment \\n    ClearErrors\\n"
                                                   " Execute python installer silent, wait for completion\\n  ExecWait '\\\"msiexec\\\" /i \\\"$INSTDIR\\\\${python_file_name}\\\" /qn ALLUSERS=1'\\n"
                                                   "A comment \\n Goto python_end_install\\n"
                                                   "A comment \\n python_install_not_hidden:\\n"
                                                   " Execute python installer, wait for completion\\n  ExecWait '\\\"msiexec\\\" /i \\\"$INSTDIR\\\\${python_file_name}\\\"'\\n"
                                                   " A comment \\n  python_end_install:\\n"
                                                   ${python_install_command_3}
                                                   "A comment \\n  install_python_no:\\n" )
      endif()

      # Extra install commands will be set to install python and OpenAL
      set( redist_versions 8 9 10 14 15 )
      foreach( redist_version ${redist_versions} )
        # Add cache variable vc${redist_version}_redist which should be set to the install file
        # for microsoft visual studio redistributables, they can be found in the
        # installation folder for each visual studio installation.
        if( NOT DEFINED vc${redist_version}_redist )
          set( vc${redist_version}_redist CACHE FILEPATH "Set this to the exe installing microsoft visual studio redistributable for visual studio ${redist_version}" )
          mark_as_advanced( vc${redist_version} )
        endif()
        if( vc${redist_version}_redist )
          string( REPLACE "/" "\\\\" Temp_vc${redist_version}_redist ${vc${redist_version}_redist} )
          get_filename_component( VC${redist_version}_FILE_NAME ${vc${redist_version}_redist} NAME )
          set( ms_redist_install_command_1 " Set output Path\\n  SetOutPath \\\"$INSTDIR\\\\vc${redist_version}\\\"\\n"
                                           " Code to install Visual studio redistributable\\n  File \\\"${Temp_vc${redist_version}_redist}\\\"\\n" )
          set( h3dvs_nsis_extra_install_commands ${ms_redist_install_command_1} )
          set( h3dvs_nsis_extra_uninstall_commands " Check if uninstall vc redist \\n  MessageBox MB_YESNO \\\"Do you want to uninstall Visual studio ${redist_version} redistributable? It is recommended if no other applications use it.\\\" IDYES uninstall_vcredist_yes IDNO uninstall_vcredist_no\\n"
                                                   " A comment \\n  uninstall_vcredist_yes:\\n"
                                                   ${ms_redist_install_command_1} )
          if( ${redist_version} LESS 9 )
            set( h3dvs_nsis_extra_install_commands ${h3dvs_nsis_extra_install_commands}
                                                   " Execute silent and wait\\n  ExecWait '\\\"$INSTDIR\\\\vc${redist_version}\\\\${VC${redist_version}_FILE_NAME}\\\" /q:a /norestart /c:\\\"msiexec /i vcredist.msi /qn\\\"'\\n" )
            set( h3dvs_nsis_extra_uninstall_commands ${h3dvs_nsis_extra_uninstall_commands}
                                                   " Execute silent and wait\\n  ExecWait '\\\"$INSTDIR\\\\vc${redist_version}\\\\${VC${redist_version}_FILE_NAME}\\\" /q:a /norestart /c:\\\"msiexec /x vcredist.msi /qn\\\"'\\n" )
          elseif( ${redist_version} LESS 14 )
            set( h3dvs_nsis_extra_install_commands ${h3dvs_nsis_extra_install_commands}
                                                   " Execute silent and wait\\n  ExecWait '\\\"$INSTDIR\\\\vc${redist_version}\\\\${VC${redist_version}_FILE_NAME}\\\" /q /norestart '\\n" )
            set( h3dvs_nsis_extra_uninstall_commands ${h3dvs_nsis_extra_uninstall_commands}
                                                   " Execute silent and wait\\n  ExecWait '\\\"$INSTDIR\\\\vc${redist_version}\\\\${VC${redist_version}_FILE_NAME}\\\" /q /uninstall '\\n" )
          else()
            set( h3dvs_nsis_extra_install_commands ${h3dvs_nsis_extra_install_commands}
                                                   " Execute silent and wait\\n  ExecWait '\\\"$INSTDIR\\\\vc${redist_version}\\\\${VC${redist_version}_FILE_NAME}\\\" /install /quiet /norestart '\\n" )
            set( h3dvs_nsis_extra_uninstall_commands ${h3dvs_nsis_extra_uninstall_commands}
                                                   " Execute silent and wait\\n  ExecWait '\\\"$INSTDIR\\\\vc${redist_version}\\\\${VC${redist_version}_FILE_NAME}\\\" /uninstall /quiet /norestart '\\n" )
          endif()
          set( ms_redist_install_command_2 " Wait a bit for system to unlock file.\\n  Sleep 1000\\n"
                                           " Delete file\\n  Delete \\\"$INSTDIR\\\\vc${redist_version}\\\\${VC${redist_version}_FILE_NAME}\\\"\\n"
                                           " Reset output Path\\n  SetOutPath \\\"$INSTDIR\\\"\\n"
                                           " Remove folder\\n  RMDir /r \\\"$INSTDIR\\\\vc${redist_version}\\\"\\n\\n" )
          set( h3dvs_nsis_extra_install_commands ${h3dvs_nsis_extra_install_commands}
                                                 ${ms_redist_install_command_2} )
          set( h3dvs_nsis_extra_uninstall_commands ${h3dvs_nsis_extra_uninstall_commands}
                                                   ${ms_redist_install_command_2}
                                                   " A comment \\n  uninstall_vcredist_no:\\n\\n" )
        endif()
      endforeach()

      # When the first item for an external entry is only "#define" then it will always be included.
      set( externals_to_look_for "#define HAVE_XERCES"
                                 "include" "xercesc"
                                 "lib" "xerces-c_3"
                                 "bin" "xerces-c_3_2"

                                 "#define HAVE_OPENAL"
                                 "include" "AL"
                                 "lib" "OpenAL32"
                                 "nsisextrainstall" ${h3doal_nsis_extra_install_commands}
                                 "nsisextrauninstall" ${h3doal_nsis_extra_uninstall_commands}

                                 "#define HAVE_LIBVORBIS"
                                 "include" "vorbis" "ogg"
                                 "lib" "libvorbis" "libogg" "libvorbisfile"
                                 "bin" "libvorbis" "libogg" "libvorbisfile"

                                 "#define HAVE_LIBAUDIOFILE"
                                 "include" "libaudiofile"
                                 "lib" "audiofile"
                                 "bin" "audiofile"

                                 "#define HAVE_CG"
                                 "include" "Cg"
                                 "lib" "cgGL" "cg"
                                 "bin" "cg" "cgGL"

                                 "#define HAVE_LIBOVR"
                                 "include" "libovr"
                                 "lib" "LibOVR"

                                 "#define HAVE_FTGL"
                                 "include" "FTGL"
                                 "lib" "ftgl"
                                 "bin" "ftgl"

                                 "#define HAVE_FTGL"
                                 "include" "FTGL"
                                 "lib" "ftgl"
                                 "bin" "ftgl"

                                 "#define HAVE_FREETYPE"
                                 "include" "freetype"
                                 "lib" "freetype"

                                 "#define HAVE_FONTCONFIG"
                                 "warning" "NOTE: H3DAPI compiled with font config support. Make sure font config features are included."

                                 "#define HAVE_3DXWARE"
                                 "warning" "NOTE: H3DAPI compiled with 3DXWare support. If 3DConnection drivers is not distributed together with the package then test that the application starts on a system without 3DConnection drivers installed"

                                 "#define HAVE_PYTHON"
                                 "nsisextrainstall" ${h3dpython_nsis_extra_install_commands}
                                 "nsisextrauninstall" ${h3dpython_nsis_extra_uninstall_commands}

                                 "#define HAVE_LIBCURL"
                                 "include" "curl"
                                 "lib" "libcurl"
                                 "bin" "libcurl"

                                 "#define HAVE_SPIDERMONKEY"
                                 "include" "js"
                                 "lib" "js32"
                                 "bin" "js32"

                                 "#define HAVE_DSHOW"
                                 "include" "DirectShow"
                                 "lib" "strmbase"

                                 "#define HAVE_FFMPEG"
                                 "warning" "NOTE: H3DAPI compiled with ffmpeg support. Make sure ffmpeg features are included."

                                 "#define HAVE_VIRTUAL_HAND_SDK"
                                 "warning" "NOTE: H3DAPI compiled with Virtual Hand support. If Virtual hand is not distributed together with the package then test that the application starts on a system without Virtual hand installed"

                                 "#define"
                                 "include" "GL/freeglut" "GL/freeglut" "GL/freeglut_ext" "GL/freeglut_std" "GL/glew" "GL/glext" "GL/glut" "GL/wglew" "H3D"
                                 "lib" "glew32" "freeglut"
                                 "bin" "glew32" "freeglut"
                                 "nsisextrainstall" ${h3dvs_nsis_extra_install_commands}
                                 "nsisextrauninstall" ${h3dvs_nsis_extra_uninstall_commands} )
    endif()
    if( NOT EXCLUDE_MAIN )
      set( externals_to_look_for ${externals_to_look_for}
                                 "#define"
                                 "include" "H3D"
                                 "lib" "H3DAPI"
                                 "bin" "H3DAPI" )
    endif()
  endif()

  list( LENGTH FEATURES_TO_INSTALL features_to_install_length )
  math( EXPR features_to_install_length "${features_to_install_length} - 1" )
  set( features_to_install_truncated "" )
  foreach( loop_var RANGE 0 ${features_to_install_length} 2 )
    list( GET FEATURES_TO_INSTALL ${loop_var} one_feature )
    list( APPEND features_to_install_truncated ${one_feature} )
  endforeach()

  set( include_dirs_to_check ${H3D_EXTERNAL_ROOT}/include ${H3DAPI_INCLUDE_DIRS} )
  set( add_external FALSE )
  set( current_checked_feature "" )
  foreach( h3dapi_include_dir_tmp ${H3DAPI_INCLUDE_DIRS} )
    if( EXISTS ${h3dapi_include_dir_tmp}/H3D/H3DApi.h )
      foreach( feature_to_look_for ${externals_to_look_for} )
        if( feature_to_look_for MATCHES "#define" )
          set( add_external FALSE )
          set( regex_to_find ${feature_to_look_for} )
          file( STRINGS ${h3dapi_include_dir_tmp}/H3D/H3DApi.h list_of_defines REGEX ${regex_to_find} )
          list( LENGTH list_of_defines list_of_defines_length )
          if( list_of_defines_length )
            set( add_external TRUE )
          endif()
        elseif( add_external )
          if( feature_to_look_for STREQUAL "include" OR
              feature_to_look_for STREQUAL "lib" OR
              feature_to_look_for STREQUAL "bin" OR
              feature_to_look_for STREQUAL "nsisextrainstall" OR
              feature_to_look_for STREQUAL "nsisextrauninstall" )
            set( external_to_look_for_tmp ${feature_to_look_for} )
            if( feature_to_look_for STREQUAL "nsisextrainstall" OR
                feature_to_look_for STREQUAL "nsisextrauninstall" )
              set( external_to_look_for_tmp "bin" )
            endif()
            list( FIND features_to_install_truncated ${external_to_look_for_tmp} feature_found )
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
                set( H3DAPI_INCLUDE_DIRECTORIES_INSTALL ${H3DAPI_INCLUDE_DIRECTORIES_INSTALL} ${include_dir_to_check}/${feature_to_look_for} )
              elseif( EXISTS ${include_dir_to_check}/${feature_to_look_for}.h )
                set( found_include_path TRUE )
                set( H3DAPI_INCLUDE_FILES_INSTALL ${H3DAPI_INCLUDE_FILES_INSTALL} ${include_dir_to_check}/${feature_to_look_for}.h )
              endif()
            endforeach()
            if( NOT found_include_path )
              message( "Include directory or file ${feature_to_look_for} not found. Searched using CMake variable H3D_EXTERNAL_ROOT and H3DAPI_INCLUDE_DIR." )
            endif()
          elseif( current_checked_feature STREQUAL "lib" )
            if( EXISTS ${h3dapi_external_lib}/${feature_to_look_for}.lib )
              set( H3DAPI_LIBRARIES_INSTALL ${H3DAPI_LIBRARIES_INSTALL} ${h3dapi_external_lib}/${feature_to_look_for}.lib )
            elseif( EXISTS ${h3dapi_external_lib}/static/${feature_to_look_for}.lib )
              set( H3DAPI_LIBRARIES_INSTALL ${H3DAPI_LIBRARIES_INSTALL} ${h3dapi_external_lib}/static/${feature_to_look_for}.lib )
            elseif( TARGET ${feature_to_look_for} )
              if( CMAKE_VERSION VERSION_LESS 3.0.0 )
                get_target_property( h3dapi_release_filename_path ${feature_to_look_for} LOCATION_RELEASE )
                get_filename_component( h3dapi_release_filename_path ${h3dapi_release_filename_path} PATH )
                set( H3DAPI_LIBRARIES_INSTALL ${H3DAPI_LIBRARIES_INSTALL} ${h3dapi_release_filename_path}/${feature_to_look_for}_vc${h3d_msvc_version}.lib )
              else()
                set( H3DAPI_LIBRARIES_INSTALL ${H3DAPI_LIBRARIES_INSTALL} $<TARGET_LINKER_FILE:${feature_to_look_for}> )
              endif()
            elseif( H3DAPI_CMAKE_INSTALL_PREFIX )
              set( dirs_to_test ${H3DAPI_CMAKE_INSTALL_PREFIX}/${default_lib_install}
                                ${H3DAPI_CMAKE_INSTALL_PREFIX}/lib )
              if( dirs_to_test )
                foreach( dir_to_test ${dirs_to_test} )
                  if( EXISTS ${dir_to_test}/${feature_to_look_for}_vc${h3d_msvc_version}.lib )
                    set( H3DAPI_LIBRARIES_INSTALL ${H3DAPI_LIBRARIES_INSTALL} ${dir_to_test}/${feature_to_look_for}_vc${h3d_msvc_version}.lib )
                    break()
                  endif()
                endforeach()
              endif()
            else()
              message( "Library file ${feature_to_look_for}.lib not found. Searched using CMake variable H3D_EXTERNAL_ROOT and H3DAPI_CMAKE_INSTALL_PREFIX." )
            endif()
          elseif( current_checked_feature STREQUAL "bin" )
            if( EXISTS ${h3dapi_external_bin}/${feature_to_look_for}.dll )
              set( H3DAPI_BINARIES_INSTALL ${H3DAPI_BINARIES_INSTALL} ${h3dapi_external_bin}/${feature_to_look_for}.dll )
            elseif( TARGET ${feature_to_look_for} )
              if( CMAKE_VERSION VERSION_LESS 3.0.0 )
                get_target_property( h3dapi_release_filename ${feature_to_look_for} LOCATION_RELEASE )
                set( H3DAPI_BINARIES_INSTALL ${H3DAPI_BINARIES_INSTALL} ${h3dapi_release_filename} )
              else()
                set( H3DAPI_BINARIES_INSTALL ${H3DAPI_BINARIES_INSTALL} $<TARGET_FILE:${feature_to_look_for}> )
              endif()
            elseif( H3DAPI_CMAKE_INSTALL_PREFIX )
              set( dirs_to_test ${H3DAPI_CMAKE_INSTALL_PREFIX}/${default_bin_install}
                                ${H3DAPI_CMAKE_INSTALL_PREFIX}/bin )
              foreach( dir_to_test ${dirs_to_test} )
                if( EXISTS ${dir_to_test}/${feature_to_look_for}_vc${h3d_msvc_version}.dll )
                  set( H3DAPI_BINARIES_INSTALL ${H3DAPI_BINARIES_INSTALL} ${dir_to_test}/${feature_to_look_for}_vc${h3d_msvc_version}.dll )
                  break()
                endif()
              endforeach()
            else()
              message( "Binary file ${feature_to_look_for}.dll not found. Searched using CMake variable H3D_EXTERNAL_ROOT and H3DAPI_CMAKE_INSTALL_PREFIX." )
            endif()
          elseif( current_checked_feature STREQUAL "warning" )
            message( ${feature_to_look_for} )
          elseif( current_checked_feature STREQUAL "nsisextrainstall" )
            set( H3DAPI_NSIS_EXTRA_INSTALL_COMMANDS ${H3DAPI_NSIS_EXTRA_INSTALL_COMMANDS} ${feature_to_look_for} )
          elseif( current_checked_feature STREQUAL "nsisextrauninstall" )
            set( H3DAPI_NSIS_EXTRA_UNINSTALL_COMMANDS ${H3DAPI_NSIS_EXTRA_UNINSTALL_COMMANDS} ${feature_to_look_for} )
          endif()
        endif()
      endforeach()
      break()
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
      if( H3DAPI_INCLUDE_DIRECTORIES_INSTALL )
        foreach( ext_dir ${H3DAPI_INCLUDE_DIRECTORIES_INSTALL} )
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
                   DESTINATION ${feature_to_install}
                   REGEX "(/.svn)|(/CVS)" EXCLUDE )
        endforeach()
      endif()

      if( H3DAPI_INCLUDE_FILES_INSTALL )
        foreach( ext_include_file ${H3DAPI_INCLUDE_FILES_INSTALL} )
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
      if( H3DAPI_LIBRARIES_INSTALL )
        foreach( ext_lib ${H3DAPI_LIBRARIES_INSTALL} )
          install( FILES ${ext_lib}
                   DESTINATION ${feature_to_install} )
        endforeach()
      endif()
    elseif( install_bin )
      set( install_bin FALSE )
      if( H3DAPI_BINARIES_INSTALL )
        foreach( ext_bin ${H3DAPI_BINARIES_INSTALL} )
          install( FILES ${ext_bin}
                   DESTINATION ${feature_to_install} )
        endforeach()
      endif()
      if( H3DAPI_NSIS_EXTRA_INSTALL_COMMANDS )
        set( CPACK_NSIS_EXTRA_INSTALL_COMMANDS ${CPACK_NSIS_EXTRA_INSTALL_COMMANDS} ${H3DAPI_NSIS_EXTRA_INSTALL_COMMANDS} )
      endif()
      if( H3DAPI_NSIS_EXTRA_UNINSTALL_COMMANDS )
        set( CPACK_NSIS_EXTRA_UNINSTALL_COMMANDS ${CPACK_NSIS_EXTRA_UNINSTALL_COMMANDS} ${H3DAPI_NSIS_EXTRA_UNINSTALL_COMMANDS} )
      endif()
    endif()
  endforeach()
endif()