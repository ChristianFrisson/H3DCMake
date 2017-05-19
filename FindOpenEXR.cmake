# - Find OpenEXR
# Finds OpenEXR libraries from ILM for handling HRD / float image formats
#
#  OpenEXR_INCLUDE_DIRS -  where to find OpenEXR headers
#  OpenEXR_LIBRARIES    - List of libraries when using OpenEXR.
#  OpenEXR_FOUND        - True if OpenEXR found.

include( H3DUtilityFunctions )
set( open_exr_partial_var_names IMF THREAD MATH HALF EX )
set( open_exr_var_names )
set( open_exr_var_names_debug )
set( open_exr_old_var_names )
set( open_exr_old_var_names_debug )
foreach( _var_name ${open_exr_partial_var_names} )
  list( APPEND open_exr_old_var_names OpenEXR_LIBRARY_${_var_name} )
  list( APPEND open_exr_old_var_names_debug OpenEXR_DEBUG_LIBRARY_${_var_name} )
endforeach()

set( open_exr_lib_names IlmImf IlmThread Imath Half Iex )
set( doc_strings )
set( doc_strings_debug )
foreach( _lib_name ${open_exr_lib_names} )
  list( APPEND open_exr_var_names OpenEXR_${_lib_name}_LIBRARY_RELEASE )
  list( APPEND open_exr_var_names_debug OpenEXR_${_lib_name}_LIBRARY_DEBUG )
  list( APPEND doc_strings "Path to ${_lib_name} library." )
  list( APPEND doc_strings_debug "Path to ${_lib_name}_d library." )
endforeach()

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES ${open_exr_var_names} ${open_exr_var_names_debug}
                                              OLD_VARIABLE_NAMES ${open_exr_old_var_names} ${open_exr_old_var_names_debug}
                                              DOC_STRINGS ${doc_strings} ${doc_strings_debug} )

include( H3DCommonFindModuleFunctions )
set( openexr_include_search_path "" )
set( openexr_library_search_path "" )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
set( check_if_h3d_external_matches_vs_version ON )
getExternalSearchPathsH3D( openexr_include_search_path openexr_library_search_path ${module_file_path} )

# Look for the header file.
find_path( OpenEXR_INCLUDE_DIR NAMES OpenEXR/Iex.h
           PATHS ${openexr_include_search_path}
           DOC "Path in which the file OpenEXR/Iex.h is located." )

set( i 0 )
foreach( _var_name ${open_exr_var_names} )
  list( GET doc_strings ${i} _doc_string )
  list( GET open_exr_lib_names ${i} _lib_name )
  # Look for the library.
  find_library( ${_var_name} NAMES ${_lib_name}
                PATHS ${openexr_library_search_path}
                DOC ${_doc_string} )
  math( EXPR i "${i} + 1" )
  mark_as_advanced( ${_var_name} )
endforeach()

# OpenEXR requires zlib.
find_package( ZLIB )
set( openexr_required_lib_vars ${open_exr_var_names} )
if( WIN32 )
  set( i 0 )
  foreach( _var_name ${open_exr_var_names_debug} )
    list( GET doc_strings_debug ${i} _doc_string )
    list( GET open_exr_lib_names ${i} _lib_name )
    # Look for the library.
    find_library( ${_var_name} NAMES ${_lib_name}_d
                  PATHS ${openexr_library_search_path}
                  DOC ${_doc_string} )
    math( EXPR i "${i} + 1" )
    mark_as_advanced( ${_var_name} )
  endforeach()

  set( openexr_required_lib_vars ${openexr_required_lib_vars} ${open_exr_var_names_debug} )
endif()

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set OpenEXR_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( OpenEXR DEFAULT_MSG
                                   OpenEXR_INCLUDE_DIR ${openexr_required_lib_vars} ZLIB_FOUND )

set( OpenEXR_LIBRARIES )
foreach( _lib_var ${openexr_required_lib_vars} )
  set( OpenEXR_LIBRARIES ${OpenEXR_LIBRARIES} ${${_lib_var}} )
endforeach()
set( OpenEXR_LIBRARIES ${OpenEXR_LIBRARIES} ${ZLIB_LIBRARIES} )
set( OpenEXR_INCLUDE_DIRS ${OpenEXR_INCLUDE_DIR}/OpenEXR ${OpenEXR_INCLUDE_DIR} ${ZLIB_INCLUDE_DIRS} )

# Backwards compatibility values set here.
set( OpenEXR_INCLUDE_DIR ${OpenEXR_INCLUDE_DIRS} )
set( OpenEXR_FOUND ${OPENEXR_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.

if( OpenEXR_FOUND AND WIN32 )
  add_definitions( -DOPENEXR_DLL )
endif()