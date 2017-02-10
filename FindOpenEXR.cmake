# - Find OpenEXR
# Finds OpenEXR libraries from ILM for handling HRD / float image formats
#
#  OpenEXR_INCLUDE_DIR -  where to find OpenEXR headers
#  OpenEXR_LIBRARIES    - List of libraries when using OpenEXR.
#  OpenEXR_FOUND        - True if OpenEXR found.


#OpenEXR requires zlib.
find_package(H3DZLIB)

set( OpenEXRIncludeSearchPath "" )
set( OpenEXRLibrarySearchPath "" )
include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
set( check_if_h3d_external_matches_vs_version ON )
getExternalSearchPathsH3D( OpenEXRIncludeSearchPath OpenEXRLibrarySearchPath ${module_file_path} )

# Look for the header file.
find_path( OpenEXR_INCLUDE_DIR NAMES OpenEXR/Iex.h
           PATHS ${OpenEXRIncludeSearchPath}
           DOC "Path in which the file OpenEXR/Iex.h is located." )

# Look for the library.
find_library( OpenEXR_LIBRARY_IMF NAMES IlmImf 
              PATHS ${OpenEXRLibrarySearchPath}
              DOC "Path to IlmImf library." )

find_library( OpenEXR_LIBRARY_THREAD NAMES IlmThread 
              PATHS ${OpenEXRLibrarySearchPath}
              DOC "Path to IlmThread library." )

find_library( OpenEXR_LIBRARY_MATH NAMES Imath 
              PATHS ${OpenEXRLibrarySearchPath}
              DOC "Path to Imath library." )

find_library( OpenEXR_LIBRARY_HALF NAMES Half 
              PATHS ${OpenEXRLibrarySearchPath}
              DOC "Path to Half library." )

find_library( OpenEXR_LIBRARY_EX NAMES Iex 
              PATHS ${OpenEXRLibrarySearchPath}
              DOC "Path to Iex library." )

if( WIN32 )
  find_library( OpenEXR_DEBUG_LIBRARY_IMF NAMES IlmImf_d 
                PATHS ${OpenEXRLibrarySearchPath}
                DOC "Path to IlmImf library." )

  find_library( OpenEXR_DEBUG_LIBRARY_THREAD NAMES IlmThread_d
                PATHS ${OpenEXRLibrarySearchPath}
                DOC "Path to IlmThread library." )

  find_library( OpenEXR_DEBUG_LIBRARY_MATH NAMES Imath_d
                PATHS ${OpenEXRLibrarySearchPath}
                DOC "Path to Imath library." )

  find_library( OpenEXR_DEBUG_LIBRARY_HALF NAMES Half_d
                PATHS ${OpenEXRLibrarySearchPath}
                DOC "Path to Half library." )

  find_library( OpenEXR_DEBUG_LIBRARY_EX NAMES Iex_d
                PATHS ${OpenEXRLibrarySearchPath}
                DOC "Path to Iex library." )
  mark_as_advanced(OpenEXR_DEBUG_LIBRARY_IMF OpenEXR_DEBUG_LIBRARY_THREAD OpenEXR_DEBUG_LIBRARY_MATH OpenEXR_DEBUG_LIBRARY_HALF OpenEXR_DEBUG_LIBRARY_EX )
endif()

if(ZLIB_FOUND AND OpenEXR_INCLUDE_DIR AND OpenEXR_LIBRARY_IMF AND OpenEXR_LIBRARY_THREAD AND OpenEXR_LIBRARY_MATH AND OpenEXR_LIBRARY_HALF AND OpenEXR_LIBRARY_EX)
  set(OpenEXR_FOUND 1)
  if( OpenEXR_DEBUG_LIBRARY_IMF AND OpenEXR_DEBUG_LIBRARY_THREAD AND OpenEXR_DEBUG_LIBRARY_MATH AND OpenEXR_DEBUG_LIBRARY_HALF AND OpenEXR_DEBUG_LIBRARY_EX )
    set(OpenEXR_LIBRARIES optimized ${OpenEXR_LIBRARY_IMF} debug ${OpenEXR_DEBUG_LIBRARY_IMF}
                          optimized ${OpenEXR_LIBRARY_THREAD} debug ${OpenEXR_DEBUG_LIBRARY_THREAD}
                          optimized ${OpenEXR_LIBRARY_MATH} debug ${OpenEXR_DEBUG_LIBRARY_MATH}
                          optimized ${OpenEXR_LIBRARY_HALF} debug ${OpenEXR_DEBUG_LIBRARY_HALF}
                          optimized ${OpenEXR_LIBRARY_EX} debug ${OpenEXR_DEBUG_LIBRARY_EX})
  else()
    set(OpenEXR_LIBRARIES ${OpenEXR_LIBRARY_IMF} ${OpenEXR_LIBRARY_THREAD} ${OpenEXR_LIBRARY_MATH} ${OpenEXR_LIBRARY_HALF} ${OpenEXR_LIBRARY_EX})
  endif()
  if( WIN32 )
    set( OpenEXR_INCLUDE_DIR ${OpenEXR_INCLUDE_DIR} ${ZLIB_INCLUDE_DIR} )
  else()
    set( OpenEXR_INCLUDE_DIR ${OpenEXR_INCLUDE_DIR}/OpenEXR ${OpenEXR_INCLUDE_DIR} ${ZLIB_INCLUDE_DIR} ) # The linux OpenEXR headers seems to not have "OpenEXR" in its include paths.
  endif()
  set( OpenEXR_LIBRARIES ${OpenEXR_LIBRARIES} ${ZLIB_LIBRARIES} )
  if (WIN32)
    ADD_DEFINITIONS(-DOPENEXR_DLL)
  endif()
endif()

# Report the results.
if(NOT OpenEXR_FOUND)
  message(STATUS "OpenEXR was not found. Handling OpenEXR images will not be supported. OpenEXR also requires zlib.")
endif()

mark_as_advanced(OpenEXR_INCLUDE_DIR OpenEXR_LIBRARY_IMF OpenEXR_LIBRARY_THREAD OpenEXR_LIBRARY_MATH OpenEXR_LIBRARY_HALF OpenEXR_LIBRARY_EX )
