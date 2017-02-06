# This file detects H3DUtil libraries/include/binaries and the
# external libraries/includes/binaries a particular
# H3DUtil source is built with and installs that.
# It requires that H3DUTIL_INCLUDE_DIR is set to H3DUtil/include of
# the build that should be checked.
# H3DUtil_CMAKE_INSTALL_PREFIX must be set to the CMAKE_INSTALL_PREFIX
# used when installing H3DUtil (basically the directory above the directory
# in which H3DUtil binaries and libraries are installed.
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
# TODO, IMPLEMENT FOR OTHER THAN WINDOWS IF IT MAKES SENSE TO DO THAT.
# IMPLEMENT for other than MSVC10.
# GET INCLUDE_DIR AND LIBS FROM FIND_MODULES used by H3DUTIL?
# IMPLEMENT to HANDLE debug libs/bins and configure to include them or not.

IF( NOT h3d_release_only_warning )
  SET( h3d_release_only_warning TRUE )
  MESSAGE( "NOTE: Packing will only be done properly in Release build, not RelWithDebInfo, MinSizeRel or Debug" )
ENDIF( NOT h3d_release_only_warning )

IF( NOT DEFINED H3DUTIL_INCLUDE_DIR )
  SET( H3DUTIL_INCLUDE_DIR "" CACHE BOOL "Path to H3DUtil/include." )
ENDIF( NOT DEFINED H3DUTIL_INCLUDE_DIR )

IF( WIN32 )
  IF( NOT DEFINED EXTERNAL_ROOT )
    SET( EXTERNAL_ROOT_DEFAULT "" )
    IF( NOT "$ENV{H3D_EXTERNAL_ROOT}" STREQUAL  "" )
      SET( EXTERNAL_ROOT_DEFAULT "$ENV{H3D_EXTERNAL_ROOT}" )
    ENDIF( NOT "$ENV{H3D_EXTERNAL_ROOT}" STREQUAL  "" )
    SET( EXTERNAL_ROOT "${EXTERNAL_ROOT_DEFAULT}" CACHE PATH "Path to External directory that comes with H3D." )
  ENDIF( NOT DEFINED EXTERNAL_ROOT )
ENDIF( WIN32 )

IF( NOT DEFINED H3DUtil_CMAKE_INSTALL_PREFIX )
  SET( H3DUtil_CMAKE_INSTALL_PREFIX_DEFAULT "" )
  IF( TARGET H3DUtil )
    SET( H3DUtil_CMAKE_INSTALL_PREFIX_DEFAULT ${CMAKE_INSTALL_PREFIX} )
  ELSEIF( NOT "${H3D_ROOT_CMAKE_PATH}" STREQUAL  "" )
    SET( H3DUtil_CMAKE_INSTALL_PREFIX_DEFAULT "${H3D_ROOT_CMAKE_PATH}/.." )
  ENDIF( TARGET H3DUtil )
  SET( H3DUtil_CMAKE_INSTALL_PREFIX ${H3DUtil_CMAKE_INSTALL_PREFIX_DEFAULT} CACHE PATH "Set this to the CMAKE_INSTALL_PREFIX directory used when installing H3DUtil. It is assumed that H3DUtil is installed in bin32/bin64 and lib32/lib64." )
  MARK_AS_ADVANCED(H3DUtil_CMAKE_INSTALL_PREFIX)
ENDIF( NOT DEFINED H3DUtil_CMAKE_INSTALL_PREFIX )

SET( H3DUTIL_INCLUDE_FILES_INSTALL "" CACHE INTERNAL "List of External include files used by this compiled version of H3DUtil." )
SET( H3DUTIL_INCLUDE_DIRECTORIES_INSTALL "" CACHE INTERNAL "List of External include directories used by this compiled version of H3DUtil." )
SET( H3DUTIL_LIBRARIES_INSTALL "" CACHE INTERNAL "List of External libraries used by this compiled version of H3DUtil." )
SET( H3DUTIL_BINARIES_INSTALL "" CACHE INTERNAL "List of External binaries used by this compiled version of H3DUtil." )


SET( H3DUtil_bin "bin32" )
SET( H3DUtil_lib "lib32" )
IF( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  SET( H3DUtil_bin "bin64" )
  SET( H3DUtil_lib "lib64" )
ENDIF( CMAKE_SIZEOF_VOID_P EQUAL 8 )
SET( H3DUTIL_EXTERNAL_BIN "${EXTERNAL_ROOT}/${H3DUtil_bin}" )
SET( H3DUTIL_EXTERNAL_LIB "${EXTERNAL_ROOT}/${H3DUtil_lib}" )

IF( H3DUTIL_INCLUDE_DIR AND EXTERNAL_ROOT )
  set( externals_to_look_for "" )
  IF( MSVC )
    SET( H3D_MSVC_VERSION 6 )
    SET( TEMP_MSVC_VERSION 1299 )
    WHILE( ${MSVC_VERSION} GREATER ${TEMP_MSVC_VERSION} )
      MATH( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
      MATH( EXPR TEMP_MSVC_VERSION "${TEMP_MSVC_VERSION} + 100" )
    ENDWHILE( ${MSVC_VERSION} GREATER ${TEMP_MSVC_VERSION} )
  
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
    IF( Teem_BZIP2 )
      set( externals_to_look_for ${externals_to_look_for} "Bzip2" )
    ENDIF( Teem_BZIP2 )
    
    set( externals_to_look_for ${externals_to_look_for}
                               "lib" "teem" )
    IF( Teem_BZIP2 )
      set( externals_to_look_for ${externals_to_look_for} "libbz2" )
    ENDIF( Teem_BZIP2 )
    
    set( externals_to_look_for ${externals_to_look_for}
                               "bin" "teem" )
    IF( Teem_BZIP2 )
      set( externals_to_look_for ${externals_to_look_for} "libbz2" )
    ENDIF( Teem_BZIP2 )
    
    set( externals_to_look_for ${externals_to_look_for}                               
                               "#define"
                               "include" "pthread" "H3DUtil"
                               "lib" "pthreadVC2" "H3DUtil"
                               "bin" "pthreadVC2" "H3DUtil"
                               
                               "#define HAVE_DCMTK"
                               "include" "dcmtk"
                               "lib")
    # It seems like we do not distribute oflog at the moment even though it is searched for.
    #set( teem_libraries "ofstd" "oflog" "dcmjpeg" "ijg8" "ijg12" "ijg16" "dcmdata" "dcmimgle" "dcmimage" )
    set( teem_libraries "ofstd" "dcmjpeg" "ijg8" "ijg12" "ijg16" "dcmdata" "dcmimgle" "dcmimage" )
    #foreach( post_fix "" "_d" )
    foreach( post_fix "" )
      foreach( teem_library ${teem_libraries} )
        set( externals_to_look_for ${externals_to_look_for} "${teem_library}_vc${H3D_MSVC_VERSION}${post_fix}" )
      endforeach( teem_library)
    endforeach( post_fix)
  ENDIF( MSVC )
  
  list( LENGTH FEATURES_TO_INSTALL FEATURES_TO_INSTALL_LENGTH )
  math( EXPR FEATURES_TO_INSTALL_LENGTH "${FEATURES_TO_INSTALL_LENGTH} - 1" )
  set( FEATURES_TO_INSTALL_TRUNCATED "")
  foreach( loop_var RANGE 0 ${FEATURES_TO_INSTALL_LENGTH} 2 )
    list( GET FEATURES_TO_INSTALL ${loop_var} one_feature )
    list( APPEND FEATURES_TO_INSTALL_TRUNCATED ${one_feature} )
  endforeach(loop_var)
  
  SET( INCLUDE_DIRS_TO_CHECK ${EXTERNAL_ROOT}/include ${H3DUTIL_INCLUDE_DIR} )
  SET( ADD_EXTERNAL FALSE )
  SET( CURRENT_CHECKED_FEATURE "" )
  foreach( H3DUTIL_INCLUDE_DIR_TMP ${H3DUTIL_INCLUDE_DIR} )
    IF( EXISTS ${H3DUTIL_INCLUDE_DIR_TMP}/H3DUtil/H3DUtil.h )
      foreach( feature_to_look_for ${externals_to_look_for} )
        IF( feature_to_look_for MATCHES "#define" )
          SET( ADD_EXTERNAL FALSE )
          SET( regex_to_find ${feature_to_look_for} )
          FILE( STRINGS ${H3DUTIL_INCLUDE_DIR_TMP}/H3DUtil/H3DUtil.h list_of_defines REGEX ${regex_to_find} )
          LIST( LENGTH list_of_defines list_of_defines_length )
          IF( list_of_defines_length )
            SET( ADD_EXTERNAL TRUE )
          ENDIF( list_of_defines_length )
        ELSEIF( ADD_EXTERNAL )
          IF( feature_to_look_for STREQUAL "include" OR
              feature_to_look_for STREQUAL "lib" OR
              feature_to_look_for STREQUAL "bin" )
            LIST( FIND FEATURES_TO_INSTALL_TRUNCATED ${feature_to_look_for} feature_found )
            IF( ${feature_found} EQUAL -1 )
              SET( CURRENT_CHECKED_FEATURE "feature_not_desired" )
            ELSE( ${feature_found} EQUAL -1 )
              SET( CURRENT_CHECKED_FEATURE ${feature_to_look_for} )
            ENDIF( ${feature_found} EQUAL -1 )
          ELSEIF( feature_to_look_for STREQUAL "warning" )
            SET( CURRENT_CHECKED_FEATURE ${feature_to_look_for} )
          ELSEIF( CURRENT_CHECKED_FEATURE STREQUAL "include" )
            SET( FOUND_INCLUDE_PATH FALSE )
            foreach( include_dir_to_check ${INCLUDE_DIRS_TO_CHECK} )
              IF( EXISTS ${include_dir_to_check}/${feature_to_look_for} )
                SET( FOUND_INCLUDE_PATH TRUE )
                SET( H3DUTIL_INCLUDE_DIRECTORIES_INSTALL ${H3DUTIL_INCLUDE_DIRECTORIES_INSTALL} ${include_dir_to_check}/${feature_to_look_for} )
              ELSEIF( EXISTS ${include_dir_to_check}/${feature_to_look_for}.h )
                SET( FOUND_INCLUDE_PATH TRUE )
                SET( H3DUTIL_INCLUDE_FILES_INSTALL ${H3DUTIL_INCLUDE_FILES_INSTALL} ${include_dir_to_check}/${feature_to_look_for}.h )
              ENDIF( EXISTS ${include_dir_to_check}/${feature_to_look_for} )
            endforeach( include_dir_to_check )
            IF( NOT FOUND_INCLUDE_PATH )
              MESSAGE( "Include directory or file ${feature_to_look_for} not found. Searched using CMake variable EXTERNAL_ROOT and H3DUTIL_INCLUDE_DIR." )
            ENDIF( NOT FOUND_INCLUDE_PATH )
          ELSEIF( CURRENT_CHECKED_FEATURE STREQUAL "lib" )
            IF( EXISTS ${H3DUTIL_EXTERNAL_LIB}/${feature_to_look_for}.lib )
              SET( H3DUTIL_LIBRARIES_INSTALL ${H3DUTIL_LIBRARIES_INSTALL} ${H3DUTIL_EXTERNAL_LIB}/${feature_to_look_for}.lib )
            ELSEIF( EXISTS ${H3DUTIL_EXTERNAL_LIB}/static/${feature_to_look_for}.lib )
              SET( H3DUTIL_LIBRARIES_INSTALL ${H3DUTIL_LIBRARIES_INSTALL} ${H3DUTIL_EXTERNAL_LIB}/static/${feature_to_look_for}.lib )
            ELSEIF( TARGET ${feature_to_look_for} )
              get_target_property( h3dutil_release_filename_path ${feature_to_look_for} LOCATION_RELEASE )
              get_filename_component( h3dutil_release_filename_path ${h3dutil_release_filename_path} PATH )
              SET( H3DUTIL_LIBRARIES_INSTALL ${H3DUTIL_LIBRARIES_INSTALL} ${h3dutil_release_filename_path}/${feature_to_look_for}_vc${H3D_MSVC_VERSION}.lib )
            ELSEIF( H3DUtil_CMAKE_INSTALL_PREFIX )
              set( dirs_to_test ${H3DUtil_CMAKE_INSTALL_PREFIX}/${H3DUtil_lib}
                                ${H3DUtil_CMAKE_INSTALL_PREFIX}/lib )
              IF( dirs_to_test )
                foreach( dir_to_test ${dirs_to_test} )
                  IF( EXISTS ${dir_to_test}/${feature_to_look_for}_vc${H3D_MSVC_VERSION}.lib )
                    SET( H3DUTIL_LIBRARIES_INSTALL ${H3DUTIL_LIBRARIES_INSTALL} ${dir_to_test}/${feature_to_look_for}_vc${H3D_MSVC_VERSION}.lib )
                    break()
                  ENDIF( EXISTS ${dir_to_test}/${feature_to_look_for}_vc${H3D_MSVC_VERSION}.lib )
                endforeach( dir_to_test )
              ENDIF( dirs_to_test )
            ELSE( EXISTS ${H3DUTIL_EXTERNAL_LIB}/${feature_to_look_for}.lib )
              MESSAGE( "Library file ${feature_to_look_for}.lib not found.  Searched using CMake variable EXTERNAL_ROOT and H3DUtil_CMAKE_INSTALL_PREFIX." )
            ENDIF( EXISTS ${H3DUTIL_EXTERNAL_LIB}/${feature_to_look_for}.lib )
          ELSEIF( CURRENT_CHECKED_FEATURE STREQUAL "bin" )
            IF( EXISTS ${H3DUTIL_EXTERNAL_BIN}/${feature_to_look_for}.dll )
              SET( H3DUTIL_BINARIES_INSTALL ${H3DUTIL_BINARIES_INSTALL} ${H3DUTIL_EXTERNAL_BIN}/${feature_to_look_for}.dll )
            ELSEIF( TARGET ${feature_to_look_for} )
              get_target_property( h3dutil_release_filename ${feature_to_look_for} LOCATION_RELEASE )
              SET( H3DUTIL_BINARIES_INSTALL ${H3DUTIL_BINARIES_INSTALL} ${h3dutil_release_filename} )
            ELSEIF( H3DUtil_CMAKE_INSTALL_PREFIX )
              set( dirs_to_test ${H3DUtil_CMAKE_INSTALL_PREFIX}/${H3DUtil_bin}
                                ${H3DUtil_CMAKE_INSTALL_PREFIX}/bin )
              foreach( dir_to_test ${dirs_to_test} )
                IF( EXISTS ${dir_to_test}/${feature_to_look_for}_vc${H3D_MSVC_VERSION}.dll )
                  SET( H3DUTIL_BINARIES_INSTALL ${H3DUTIL_BINARIES_INSTALL} ${dir_to_test}/${feature_to_look_for}_vc${H3D_MSVC_VERSION}.dll )
                  break()
                ENDIF( EXISTS ${dir_to_test}/${feature_to_look_for}_vc${H3D_MSVC_VERSION}.dll )
              endforeach( dir_to_test )
            ELSE( EXISTS ${H3DUTIL_EXTERNAL_BIN}/${feature_to_look_for}.dll )
              MESSAGE( "Binary file ${feature_to_look_for}.dll not found. Searched using CMake variable EXTERNAL_ROOT and H3DUtil_CMAKE_INSTALL_PREFIX." )
            ENDIF( EXISTS ${H3DUTIL_EXTERNAL_BIN}/${feature_to_look_for}.dll )
          ELSEIF( CURRENT_CHECKED_FEATURE STREQUAL "warning" )
            MESSAGE( STATUS ${feature_to_look_for} )
          ENDIF() 
        ENDIF( feature_to_look_for MATCHES "#define" )
      endforeach( feature_to_look_for)
    ENDIF( EXISTS ${H3DUTIL_INCLUDE_DIR_TMP}/H3DUtil/H3DUtil.h )
  endforeach( H3DUTIL_INCLUDE_DIR_TMP )

  SET( INSTALL_INCLUDE FALSE )
  SET( INSTALL_LIB FALSE )
  SET( INSTALL_BIN FALSE )
  foreach( feature_to_install ${FEATURES_TO_INSTALL} )
    IF( NOT INSTALL_INCLUDE AND feature_to_install STREQUAL "include" )
      SET( INSTALL_INCLUDE TRUE )
    ELSEIF( NOT INSTALL_LIB AND feature_to_install STREQUAL "lib" )
      SET( INSTALL_LIB TRUE )
    ELSEIF( NOT INSTALL_BIN AND feature_to_install STREQUAL "bin" )
      SET( INSTALL_BIN TRUE )
    ELSEIF( INSTALL_INCLUDE )
      SET( INSTALL_INCLUDE FALSE )
      IF( H3DUTIL_INCLUDE_DIRECTORIES_INSTALL )
        foreach( ext_dir ${H3DUTIL_INCLUDE_DIRECTORIES_INSTALL} )
          SET( include_file_path_last_part "" )
          foreach( include_dir_to_check ${INCLUDE_DIRS_TO_CHECK} )
            get_filename_component( include_file_path ${ext_dir} PATH )
            string( LENGTH ${include_file_path} include_length )
            string( LENGTH ${include_dir_to_check} include_dir_to_check_length )
            IF( ${include_length} GREATER ${include_dir_to_check_length} )
              string( SUBSTRING ${include_file_path} 0 ${include_dir_to_check_length} include_file_path_first_part )
              IF( ${include_file_path_first_part} STREQUAL ${include_dir_to_check} )
                string( SUBSTRING ${include_file_path} ${include_dir_to_check_length} -1 include_file_path_last_part )
                break()
              ENDIF( ${include_file_path_first_part} STREQUAL ${include_dir_to_check} )
            ENDIF( ${include_length} GREATER ${include_dir_to_check_length} )
          endforeach( include_dir_to_check )
          INSTALL( DIRECTORY ${ext_dir}
                   DESTINATION ${feature_to_install}${include_file_path_last_part}
                   REGEX "(/.svn)|(/CVS)" EXCLUDE )
        endforeach( ext_dir )
      ENDIF( H3DUTIL_INCLUDE_DIRECTORIES_INSTALL )

      IF( H3DUTIL_INCLUDE_FILES_INSTALL )
        foreach( ext_include_file ${H3DUTIL_INCLUDE_FILES_INSTALL} )
          SET( include_file_path_last_part "" )
          foreach( include_dir_to_check ${INCLUDE_DIRS_TO_CHECK} )
            get_filename_component( include_file_path ${ext_include_file} PATH )
            string( LENGTH ${include_file_path} include_length )
            string( LENGTH ${include_dir_to_check} include_dir_to_check_length )
            IF( ${include_length} GREATER ${include_dir_to_check_length} )
              string( SUBSTRING ${include_file_path} 0 ${include_dir_to_check_length} include_file_path_first_part )
              IF( ${include_file_path_first_part} STREQUAL ${include_dir_to_check} )
                string( SUBSTRING ${include_file_path} ${include_dir_to_check_length} -1 include_file_path_last_part )
                break()
              ENDIF( ${include_file_path_first_part} STREQUAL ${include_dir_to_check} )
            ENDIF( ${include_length} GREATER ${include_dir_to_check_length} )
          endforeach( include_dir_to_check )
          INSTALL( FILES ${ext_include_file}
                   DESTINATION ${feature_to_install}${include_file_path_last_part} )
        endforeach( ext_include_file )
      ENDIF( H3DUTIL_INCLUDE_FILES_INSTALL )
    ELSEIF( INSTALL_LIB )
      SET( INSTALL_LIB FALSE )
      IF( H3DUTIL_LIBRARIES_INSTALL )
        foreach( ext_lib ${H3DUTIL_LIBRARIES_INSTALL} )
          INSTALL( FILES ${ext_lib}
                   DESTINATION ${feature_to_install} )
        endforeach( ext_lib )
      ENDIF( H3DUTIL_LIBRARIES_INSTALL )
    ELSEIF( INSTALL_BIN )
      SET( INSTALL_BIN FALSE )
      IF( H3DUTIL_BINARIES_INSTALL )
        foreach( ext_bin ${H3DUTIL_BINARIES_INSTALL} )
          INSTALL( FILES ${ext_bin}
                   DESTINATION ${feature_to_install} )
        endforeach( ext_bin )
      ENDIF( H3DUTIL_BINARIES_INSTALL )
    ENDIF( NOT INSTALL_INCLUDE AND feature_to_install STREQUAL "include" )
  endforeach( feature_to_install )
ENDIF( H3DUTIL_INCLUDE_DIR AND EXTERNAL_ROOT)