# This file detects H3DUtil libraries/include/binaries and the
# external libraries/includes/binaries a particular
# H3DUtil source is built with and installs that.
# It requires that H3DUTIL_INCLUDE_DIR is set to H3DUtil/include of
# the build that should be checked.
# H3DUtil_CMAKE_INSTALL_PREFIX must be set to the CMAKE_INSTALL_PREFIX
# used when installing H3DUtil ( basically the directory above the directory
# in which H3DUtil binaries and libraries are installed ).
# EXTERNAL_ROOT should be set to the External directory that comes with
# H3D.
# FEATURES_TO_INSTALL should be set to a list of pairs.  The first
# item in each pair should be a specific word. The second item in the
# pair should be the directory to install into. The predefined words are:
# "include" - Include directories should be installed.
# "lib" - Release libraries should be installed.
# "bin" - Debug binaries should be installed.
# Output variables are:
# H3DUTIL_INCLUDE_FILES_INSTALL - Contains a list of include files that
# was used when the checked H3DUTIL version was built.
# H3DUTIL_INCLUDE_DIRECTORIES_INSTALL - Contains a list of directories that
# contains files used when the checked H3DUTIL version was built.
# H3DUTIL_LIBRARIES_INSTALL - Contains a list of libraries that
# was used when the checked H3DUTIL version was built.
# H3DUTIL_BINARIES_INSTALL - Contains a list of binaries that
# the built H3DUTIL version needs.
# TODO, IMPLEMENT FOR OTHER THAN WINDOWS if IT MAKES SENSE TO DO THAT.
# IMPLEMENT for other than MSVC10.
# GET INCLUDE_DIR AND LIBS FROM FIND_MODULES used by H3DUTIL?
# IMPLEMENT to HANDLE debug libs/bins and configure to include them or not.

if( NOT h3d_release_only_warning )
  set( h3d_release_only_warning TRUE )
  message( "NOTE: Packing will only be done properly in Release build, not RelWithDebInfo, MinSizeRel or Debug" )
endif()

if( NOT DEFINED H3DUTIL_INCLUDE_DIR )
  set( H3DUTIL_INCLUDE_DIR "" CACHE BOOL "Path to H3DUtil/include." )
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

if( NOT DEFINED H3DUtil_CMAKE_INSTALL_PREFIX )
  set( H3DUtil_CMAKE_INSTALL_PREFIX_DEFAULT "" )
  if( TARGET H3DUtil )
    set( H3DUtil_CMAKE_INSTALL_PREFIX_DEFAULT ${CMAKE_INSTALL_PREFIX} )
  elseif( NOT "${H3D_ROOT_CMAKE_PATH}" STREQUAL  "" )
    set( H3DUtil_CMAKE_INSTALL_PREFIX_DEFAULT "${H3D_ROOT_CMAKE_PATH}/.." )
  endif()
  set( H3DUtil_CMAKE_INSTALL_PREFIX ${H3DUtil_CMAKE_INSTALL_PREFIX_DEFAULT} CACHE PATH "Set this to the CMAKE_INSTALL_PREFIX directory used when installing H3DUtil. It is assumed that H3DUtil is installed in bin32/bin64 and lib32/lib64." )
  mark_as_advanced( H3DUtil_CMAKE_INSTALL_PREFIX )
endif()

set( H3DUTIL_INCLUDE_FILES_INSTALL "" CACHE INTERNAL "List of External include files used by this compiled version of H3DUtil." )
set( H3DUTIL_INCLUDE_DIRECTORIES_INSTALL "" CACHE INTERNAL "List of External include directories used by this compiled version of H3DUtil." )
set( H3DUTIL_LIBRARIES_INSTALL "" CACHE INTERNAL "List of External libraries used by this compiled version of H3DUtil." )
set( H3DUTIL_BINARIES_INSTALL "" CACHE INTERNAL "List of External binaries used by this compiled version of H3DUtil." )


set( H3DUtil_bin "bin32" )
set( H3DUtil_lib "lib32" )
if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set( H3DUtil_bin "bin64" )
  set( H3DUtil_lib "lib64" )
endif()
set( H3DUTIL_EXTERNAL_BIN "${EXTERNAL_ROOT}/${H3DUtil_bin}" )
set( H3DUTIL_EXTERNAL_LIB "${EXTERNAL_ROOT}/${H3DUtil_lib}" )

if( H3DUTIL_INCLUDE_DIR AND EXTERNAL_ROOT )
  set( externals_to_look_for "" )
  if( MSVC )
    set( H3D_MSVC_VERSION 6 )
    set( TEMP_MSVC_VERSION 1299 )
    while( ${MSVC_VERSION} GREATER ${TEMP_MSVC_VERSION} )
      math( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
      math( EXPR TEMP_MSVC_VERSION "${TEMP_MSVC_VERSION} + 100" )
    endwhile()
  
    ## TODO: Somehow check if TEEM is compiled against BZPI2, PNG and/or ZLIB, probably have to use find modules.
    # When the first item for an external entry is only "#define" then it will always be included.
    set( externals_to_look_for "#define HAVE_ZLIB"
                               "include" "zlib"
                               "lib" "zlib"
                               "bin" "zlib1"
                               
                               "#define HAVE_FREEIMAGE"
                               "include" "FreeImage"
                               "lib" "FreeImage"
                               "bin" "FreeImage"
                               
                               "#define HAVE_OPENEXR"
                               "include" "OpenEXR"
                               "lib" "IlmImf" "IlmThread" "Imath" "Half" "Iex"
                               "bin" "IlmImf" "IlmThread" "Imath" "Half" "Iex"
                               
                               "#define HAVE_TEEM"
                               "include" "teem" )
    if( Teem_BZIP2 )
      set( externals_to_look_for ${externals_to_look_for} "Bzip2" )
    endif()
    
    set( externals_to_look_for ${externals_to_look_for}
                               "lib" "teem" )
    if( Teem_BZIP2 )
      set( externals_to_look_for ${externals_to_look_for} "libbz2" )
    endif()
    
    set( externals_to_look_for ${externals_to_look_for}
                               "bin" "teem" )
    if( Teem_BZIP2 )
      set( externals_to_look_for ${externals_to_look_for} "libbz2" )
    endif()
    
    set( externals_to_look_for ${externals_to_look_for}                               
                               "#define"
                               "include" "pthread" "H3DUtil"
                               "lib" "pthreadVC2" "H3DUtil"
                               "bin" "pthreadVC2" "H3DUtil"
                               
                               "#define HAVE_DCMTK"
                               "include" "dcmtk"
                               "lib" )
    # It seems like we do not distribute oflog at the moment even though it is searched for.
    #set( teem_libraries "ofstd" "oflog" "dcmjpeg" "ijg8" "ijg12" "ijg16" "dcmdata" "dcmimgle" "dcmimage" )
    set( teem_libraries "ofstd" "dcmjpeg" "ijg8" "ijg12" "ijg16" "dcmdata" "dcmimgle" "dcmimage" )
    #foreach( post_fix "" "_d" )
    foreach( post_fix "" )
      foreach( teem_library ${teem_libraries} )
        set( externals_to_look_for ${externals_to_look_for} "${teem_library}_vc${H3D_MSVC_VERSION}${post_fix}" )
      endforeach()
    endforeach()
  endif()
  
  list( LENGTH FEATURES_TO_INSTALL FEATURES_TO_INSTALL_LENGTH )
  math( EXPR FEATURES_TO_INSTALL_LENGTH "${FEATURES_TO_INSTALL_LENGTH} - 1" )
  set( FEATURES_TO_INSTALL_TRUNCATED "" )
  foreach( loop_var RANGE 0 ${FEATURES_TO_INSTALL_LENGTH} 2 )
    list( GET FEATURES_TO_INSTALL ${loop_var} one_feature )
    list( APPEND FEATURES_TO_INSTALL_TRUNCATED ${one_feature} )
  endforeach()
  
  set( INCLUDE_DIRS_TO_CHECK ${EXTERNAL_ROOT}/include ${H3DUTIL_INCLUDE_DIR} )
  set( ADD_EXTERNAL FALSE )
  set( CURRENT_CHECKED_FEATURE "" )
  foreach( H3DUTIL_INCLUDE_DIR_TMP ${H3DUTIL_INCLUDE_DIR} )
    if( EXISTS ${H3DUTIL_INCLUDE_DIR_TMP}/H3DUtil/H3DUtil.h )
      foreach( feature_to_look_for ${externals_to_look_for} )
        if( feature_to_look_for MATCHES "#define" )
          set( ADD_EXTERNAL FALSE )
          set( regex_to_find ${feature_to_look_for} )
          file( STRINGS ${H3DUTIL_INCLUDE_DIR_TMP}/H3DUtil/H3DUtil.h list_of_defines REGEX ${regex_to_find} )
          list( LENGTH list_of_defines list_of_defines_length )
          if( list_of_defines_length )
            set( ADD_EXTERNAL TRUE )
          endif()
        elseif( ADD_EXTERNAL )
          if( feature_to_look_for STREQUAL "include" OR
              feature_to_look_for STREQUAL "lib" OR
              feature_to_look_for STREQUAL "bin" )
            list( FIND FEATURES_TO_INSTALL_TRUNCATED ${feature_to_look_for} feature_found )
            if( ${feature_found} EQUAL -1 )
              set( CURRENT_CHECKED_FEATURE "feature_not_desired" )
            else()
              set( CURRENT_CHECKED_FEATURE ${feature_to_look_for} )
            endif()
          elseif( feature_to_look_for STREQUAL "warning" )
            set( CURRENT_CHECKED_FEATURE ${feature_to_look_for} )
          elseif( CURRENT_CHECKED_FEATURE STREQUAL "include" )
            set( FOUND_INCLUDE_PATH FALSE )
            foreach( include_dir_to_check ${INCLUDE_DIRS_TO_CHECK} )
              if( EXISTS ${include_dir_to_check}/${feature_to_look_for} )
                set( FOUND_INCLUDE_PATH TRUE )
                set( H3DUTIL_INCLUDE_DIRECTORIES_INSTALL ${H3DUTIL_INCLUDE_DIRECTORIES_INSTALL} ${include_dir_to_check}/${feature_to_look_for} )
              elseif( EXISTS ${include_dir_to_check}/${feature_to_look_for}.h )
                set( FOUND_INCLUDE_PATH TRUE )
                set( H3DUTIL_INCLUDE_FILES_INSTALL ${H3DUTIL_INCLUDE_FILES_INSTALL} ${include_dir_to_check}/${feature_to_look_for}.h )
              endif()
            endforeach()
            if( NOT FOUND_INCLUDE_PATH )
              message( "Include directory or file ${feature_to_look_for} not found. Searched using CMake variable EXTERNAL_ROOT and H3DUTIL_INCLUDE_DIR." )
            endif()
          elseif( CURRENT_CHECKED_FEATURE STREQUAL "lib" )
            if( EXISTS ${H3DUTIL_EXTERNAL_LIB}/${feature_to_look_for}.lib )
              set( H3DUTIL_LIBRARIES_INSTALL ${H3DUTIL_LIBRARIES_INSTALL} ${H3DUTIL_EXTERNAL_LIB}/${feature_to_look_for}.lib )
            elseif( EXISTS ${H3DUTIL_EXTERNAL_LIB}/static/${feature_to_look_for}.lib )
              set( H3DUTIL_LIBRARIES_INSTALL ${H3DUTIL_LIBRARIES_INSTALL} ${H3DUTIL_EXTERNAL_LIB}/static/${feature_to_look_for}.lib )
            elseif( TARGET ${feature_to_look_for} )
              get_target_property( h3dutil_release_filename_path ${feature_to_look_for} LOCATION_RELEASE )
              get_filename_component( h3dutil_release_filename_path ${h3dutil_release_filename_path} PATH )
              set( H3DUTIL_LIBRARIES_INSTALL ${H3DUTIL_LIBRARIES_INSTALL} ${h3dutil_release_filename_path}/${feature_to_look_for}_vc${H3D_MSVC_VERSION}.lib )
            elseif( H3DUtil_CMAKE_INSTALL_PREFIX )
              set( dirs_to_test ${H3DUtil_CMAKE_INSTALL_PREFIX}/${H3DUtil_lib}
                                ${H3DUtil_CMAKE_INSTALL_PREFIX}/lib )
              if( dirs_to_test )
                foreach( dir_to_test ${dirs_to_test} )
                  if( EXISTS ${dir_to_test}/${feature_to_look_for}_vc${H3D_MSVC_VERSION}.lib )
                    set( H3DUTIL_LIBRARIES_INSTALL ${H3DUTIL_LIBRARIES_INSTALL} ${dir_to_test}/${feature_to_look_for}_vc${H3D_MSVC_VERSION}.lib )
                    break()
                  endif()
                endforeach()
              endif()
            else()
              message( "Library file ${feature_to_look_for}.lib not found.  Searched using CMake variable EXTERNAL_ROOT and H3DUtil_CMAKE_INSTALL_PREFIX." )
            endif()
          elseif( CURRENT_CHECKED_FEATURE STREQUAL "bin" )
            if( EXISTS ${H3DUTIL_EXTERNAL_BIN}/${feature_to_look_for}.dll )
              set( H3DUTIL_BINARIES_INSTALL ${H3DUTIL_BINARIES_INSTALL} ${H3DUTIL_EXTERNAL_BIN}/${feature_to_look_for}.dll )
            elseif( TARGET ${feature_to_look_for} )
              get_target_property( h3dutil_release_filename ${feature_to_look_for} LOCATION_RELEASE )
              set( H3DUTIL_BINARIES_INSTALL ${H3DUTIL_BINARIES_INSTALL} ${h3dutil_release_filename} )
            elseif( H3DUtil_CMAKE_INSTALL_PREFIX )
              set( dirs_to_test ${H3DUtil_CMAKE_INSTALL_PREFIX}/${H3DUtil_bin}
                                ${H3DUtil_CMAKE_INSTALL_PREFIX}/bin )
              foreach( dir_to_test ${dirs_to_test} )
                if( EXISTS ${dir_to_test}/${feature_to_look_for}_vc${H3D_MSVC_VERSION}.dll )
                  set( H3DUTIL_BINARIES_INSTALL ${H3DUTIL_BINARIES_INSTALL} ${dir_to_test}/${feature_to_look_for}_vc${H3D_MSVC_VERSION}.dll )
                  break()
                endif()
              endforeach()
            else()
              message( "Binary file ${feature_to_look_for}.dll not found. Searched using CMake variable EXTERNAL_ROOT and H3DUtil_CMAKE_INSTALL_PREFIX." )
            endif()
          elseif( CURRENT_CHECKED_FEATURE STREQUAL "warning" )
            message( STATUS ${feature_to_look_for} )
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
      if( H3DUTIL_INCLUDE_DIRECTORIES_INSTALL )
        foreach( ext_dir ${H3DUTIL_INCLUDE_DIRECTORIES_INSTALL} )
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

      if( H3DUTIL_INCLUDE_FILES_INSTALL )
        foreach( ext_include_file ${H3DUTIL_INCLUDE_FILES_INSTALL} )
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
      if( H3DUTIL_LIBRARIES_INSTALL )
        foreach( ext_lib ${H3DUTIL_LIBRARIES_INSTALL} )
          install( FILES ${ext_lib}
                   DESTINATION ${feature_to_install} )
        endforeach()
      endif()
    elseif( INSTALL_BIN )
      set( INSTALL_BIN FALSE )
      if( H3DUTIL_BINARIES_INSTALL )
        foreach( ext_bin ${H3DUTIL_BINARIES_INSTALL} )
          install( FILES ${ext_bin}
                   DESTINATION ${feature_to_install} )
        endforeach()
      endif()
    endif()
  endforeach()
endif()