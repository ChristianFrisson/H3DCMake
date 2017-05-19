# - Find wxWidgets
# Find the native wxWidgets headers and libraries.
#
#  wxWidgets_INCLUDE_DIRS - Where to find WxWidgets headers
#  wxWidgets_LIBRARIES    - List of libraries when using WxWidgets.
#  wxWidgets_FOUND        - True if WxWidgets found.
#
# The following features are deprecated and the COMPONENTS feature of find_package should be used instead.
# wxWidgets_USE_LIBS (deprecated) - Can be used to specify which libs to search for.

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

set( wxwidgets_library_search_paths "" )
set( wxwidgets_include_search_paths "" )
if( MSVC11 )
  getExternalSearchPathsH3D( wxwidgets_include_search_paths wxwidgets_library_search_paths ${module_file_path} "vc11" )
else()
  getExternalSearchPathsH3D( wxwidgets_include_search_paths wxwidgets_library_search_paths ${module_file_path} "static" )
endif()

# Look for the header file.
find_path( wxWidgets_INCLUDE_DIR NAMES wx/wx.h
                                 PATHS ${wxwidgets_include_search_paths}
                                 DOC "Path in which the file wx/wx.h is located." )
mark_as_advanced( wxWidgets_INCLUDE_DIR )

if( wxWidgets_USE_LIBS )
  message( AUTHOR_WARNING "The setting wxWidgets_USE_LIBS is deprecated. Use the COMPONENTS feature of find_package instead." )
endif()

if( wxWidgets_FIND_COMPONENTS )
  set( wxlibs ${wxWidgets_FIND_COMPONENTS} )
else()
  if( wxWidgets_USE_LIBS )
    set( wxlibs ${wxWidgets_USE_LIBS} )
  else()
    set( wxlibs core adv aui html media xrc gl qa richtext )
  endif()
endif()

set( wxWidgets_Win_DEBUG_LIBS "YES" CACHE BOOL "If set to YES debug libraries will be included." )
mark_as_advanced( wxWidgets_Win_DEBUG_LIBS )
if( wxWidgets_Win_DEBUG_LIBS )
  set( _dbg "d" )
else()
  set( _dbg "" )
endif()

set( required_lib_vars )
foreach( wxlib ${wxlibs} )
  find_library( wxWidgets_${wxlib}_LIBRARY
                NAMES
                    wxmsw30u_${wxlib}
                    wxbase30u_${wxlib}
                    wxmsw29u_${wxlib}
                    wxbase29u_${wxlib}
                    wxmsw28${_UCD}_${wxlib}
                    wx${wxlib}
                    PATHS ${wxwidgets_library_search_paths}
                    DOC "Path to wx ${wxlib} library." )
  mark_as_advanced( wxWidgets_${wxlib}_LIBRARY )
  set( required_lib_vars ${required_lib_vars} wxWidgets_${wxlib}_LIBRARY )

  if( wxWidgets_Win_DEBUG_LIBS )
    # The _dbg variable is not used for 2.8 since the libraries that used to be in External worked for both debug and release.
    find_library( wxWidgets_${wxlib}${_dbg}_LIBRARY
                  NAMES
                  wxmsw30u${_dbg}_${wxlib}
                  wxbase30u${_dbg}_${wxlib}
                  wxmsw29u${_dbg}_${wxlib}
                  wxbase29u${_dbg}_${wxlib}
                  wxmsw28${_UCD}_${wxlib}
                  wx${wxlib}${_dbg}
                  PATHS ${wxwidgets_library_search_paths}
                  DOC "Path to wx ${wxlib}d library." )
    mark_as_advanced( wxWidgets_${wxlib}${_dbg}_LIBRARY )
    set( required_lib_vars ${required_lib_vars} wxWidgets_${wxlib}${_dbg}_LIBRARY )
  endif()
endforeach()


find_library( wxWidgets_base_LIBRARY NAMES wxbase30u wxbase29u wxbase28
                                     PATHS ${wxwidgets_library_search_paths}
                                     DOC "Path to wx base library." )
mark_as_advanced( wxWidgets_base_LIBRARY )
set( required_lib_vars ${required_lib_vars} wxWidgets_base_LIBRARY )

if( wxWidgets_Win_DEBUG_LIBS )
  # The _dbg variable is not used for 2.8 since the libraries that used to be in External worked for both debug and release.
  find_library( wxWidgets_base${_dbg}_LIBRARY NAMES wxbase30u${_dbg} wxbase29u${_dbg} wxbase28
                      PATHS ${wxwidgets_library_search_paths}
                      DOC "Path to wx base library." )
  mark_as_advanced( wxWidgets_base${_dbg}_LIBRARY )
  set( required_lib_vars ${required_lib_vars} wxWidgets_base${_dbg}_LIBRARY )
endif()

checkIfModuleFound( wxWidgets
                    REQUIRED_VARS wxWidgets_INCLUDE_DIR ${required_lib_vars} )

if( wxWidgets_FOUND )
  set( wxWidgets_INCLUDE_DIRS ${wxWidgets_INCLUDE_DIR} )
  set( wxWidgets_LIBRARIES comctl32 Rpcrt4 optimized ${wxWidgets_base_LIBRARY} )
  if( wxWidgets_Win_DEBUG_LIBS )
    set( wxWidgets_LIBRARIES ${wxWidgets_LIBRARIES} debug ${wxWidgets_base${_dbg}_LIBRARY} )
  endif()
  foreach( wxlib ${wxlibs} )
    set( wxWidgets_LIBRARIES ${wxWidgets_LIBRARIES} optimized ${wxWidgets_${wxlib}_LIBRARY} )
    if( wxWidgets_Win_DEBUG_LIBS )
      set( wxWidgets_LIBRARIES ${wxWidgets_LIBRARIES} debug ${wxWidgets_${wxlib}${_dbg}_LIBRARY} )
    endif()
  endforeach()
else()
  checkCMakeInternalModule( wxWidgets )  # Will call CMakes internal find module for this feature.
endif()

# Backwards compatibility values set here.
set( wxWidgets_INCLUDE_DIR ${wxWidgets_INCLUDE_DIRS} )