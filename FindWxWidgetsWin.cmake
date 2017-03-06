# - Find wxWidgets
# Find the native wxWidgets headers and libraries.
#
#  wxWidgets_INCLUDE_DIR -  where to find WxWidgets headers
#  wxWidgets_LIBRARIES    - List of libraries when using WxWidgets.
#  wxWidgets_FOUND        - True if WxWidgets found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

set( wxwidgets_library_search_paths "" )
set( wxwidgets_include_search_paths "" )
if( MSVC11 )
  getExternalSearchPathsH3D( wxwidgets_include_search_paths wxwidgets_library_search_paths ${module_file_path} "vc11" )
else()
  getExternalSearchPathsH3D( wxwidgets_include_search_paths wxwidgets_library_search_paths ${module_file_path} "chai3d/include" "static" )
endif()



# Look for the header file.
find_path( wxWidgets_INCLUDE_DIR NAMES wx/wx.h
                                 PATHS ${wxwidgets_include_search_paths}
                                 DOC "Path in which the file wx/wx.h is located." )
mark_as_advanced( wxWidgets_INCLUDE_DIR )

if( wxWidgets_USE_LIBS )
  set( wxlibs ${wxWidgets_USE_LIBS} )
else()
  set( wxlibs core adv aui html media xrc gl qa richtext )
endif()

set( wxWidgets_Win_DEBUG_LIBS "YES" CACHE BOOL "If set to YES debug libraries will be included." )
mark_as_advanced( wxWidgets_Win_DEBUG_LIBS )
if( wxWidgets_Win_DEBUG_LIBS )
  set( _dbg "d" )
else()
  set( _dbg "" )
endif()
foreach( WXLIB ${wxlibs} )
      find_library( wxWidgets_${WXLIB}_LIBRARY
                    NAMES
                    wxmsw30u_${WXLIB}
                    wxbase30u_${WXLIB}
                    wxmsw29u_${WXLIB}
                    wxbase29u_${WXLIB}
                    wxmsw28${_UCD}_${WXLIB}
                    wx${WXLIB}
                    PATHS ${wxwidgets_library_search_paths}
                    DOC "Path to wx ${WXLIB} library." )
        mark_as_advanced( wxWidgets_${WXLIB}_LIBRARY )
  if( wxWidgets_Win_DEBUG_LIBS )
      # The _dbg variable is not used for 2.8 since the libraries in External works for both debug and release.
      find_library( wxWidgets_${WXLIB}${_dbg}_LIBRARY
                    NAMES
                    wxmsw30u${_dbg}_${WXLIB}
                    wxbase30u${_dbg}_${WXLIB}
                    wxmsw29u${_dbg}_${WXLIB}
                    wxbase29u${_dbg}_${WXLIB}
                    wxmsw28${_UCD}_${WXLIB}
                    wx${WXLIB}${_dbg}
                    PATHS ${wxwidgets_library_search_paths}
                    DOC "Path to wx ${WXLIB}d library." )
      mark_as_advanced( wxWidgets_${WXLIB}${_dbg}_LIBRARY )
  endif()
endforeach()


find_library( wxWidgets_base_LIBRARY NAMES wxbase30u wxbase29u wxbase28
                                     PATHS ${wxwidgets_library_search_paths}
                                     DOC "Path to wx base library." )
mark_as_advanced( wxWidgets_base_LIBRARY )

if( wxWidgets_Win_DEBUG_LIBS )
  # The _dbg variable is not used for 2.8 since the libraries in External works for both debug and release.
  find_library( wxWidgets_base${_dbg}_LIBRARY NAMES wxbase30u${_dbg} wxbase29u${_dbg} wxbase28
                      PATHS ${wxwidgets_library_search_paths}
                      DOC "Path to wx base library." )
  mark_as_advanced( wxWidgets_base${_dbg}_LIBRARY )
endif()

if( wxWidgets_base_LIBRARY )
  set( wxWidgets_FOUND 1 )
else()
  set( wxWidgets_FOUND 0 )
endif()

foreach( WXLIB ${wxlibs} )
  if( NOT wxWidgets_${WXLIB}_LIBRARY )
    set( wxWidgets_FOUND 0 )
  endif()
  if( wxWidgets_Win_DEBUG_LIBS )
    if( NOT wxWidgets_${WXLIB}${_dbg}_LIBRARY )
      set( wxWidgets_FOUND 0 )
    endif()
  endif()
endforeach()

# Copy the results to the output variables.
if( wxWidgets_INCLUDE_DIR AND wxWidgets_base_LIBRARY AND wxWidgets_FOUND )
  set( wxWidgets_FOUND 1 )
  set( wxWidgets_LIBRARIES comctl32 Rpcrt4 optimized  ${wxWidgets_base_LIBRARY} debug  ${wxWidgets_base${_dbg}_LIBRARY} )
  foreach( WXLIB ${wxlibs} )
    set( wxWidgets_LIBRARIES ${wxWidgets_LIBRARIES} optimized ${wxWidgets_${WXLIB}_LIBRARY} debug ${wxWidgets_${WXLIB}${_dbg}_LIBRARY} )
  endforeach()
  set( wxWidgets_INCLUDE_DIR ${wxWidgets_INCLUDE_DIR} )
else()
  set( wxWidgets_FOUND 0 )
  set( wxWidgets_LIBRARIES )
  set( wxWidgets_INCLUDE_DIR )
endif()

# Report the results.
if( NOT wxWidgets_FOUND )
  set( wxWidgets_DIR_MESSAGE
       "WxWidgets was not found. Make sure wxWidgets_core_LIBRARY, wxWidgets_base_LIBRARY" )
   set( wxWidgets_DIR_MESSAGE "${wxWidgets_DIR_MESSAGE} and wxWidgets_INCLUDE_DIR are set and other requested libs are set." )
  if( wxWidgets_FIND_REQUIRED )
      message( FATAL_ERROR "${wxWidgets_DIR_MESSAGE}" )
  elseif( NOT wxWidgets_FIND_QUIETLY )
    message( STATUS "${wxWidgets_DIR_MESSAGE}" )
  endif()
endif()
