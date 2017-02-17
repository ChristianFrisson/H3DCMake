# - Find DHD
# Find the native DHD headers and libraries.
#
#  DHD_INCLUDE_DIRS -  where to find DHD headers
#  DHD_LIBRARIES    - List of libraries when using DHD.
#  DHD_FOUND        - True if DHD found.
#  DHD_DRD_SUPPORT  - True if DRD header/library was actually found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "DHD-API" )

# Look for the header file.
find_path( DHD_INCLUDE_DIR NAMES dhdc.h 
                           PATHS ${module_include_search_paths}
                           DOC "Path in which the file dhdc.h is located." )
mark_as_advanced( DHD_INCLUDE_DIR )

find_path( DHD_DRD_INCLUDE_DIR NAMES drdc.h 
                               PATHS ${module_include_search_paths}
                               DOC "Path in which the file drdc.h is located, not needed if DHD_INCLUDE_DIR and DHD_LIBRARY is set." )
mark_as_advanced( DHD_DRD_INCLUDE_DIR )

# Look for the library.
if( WIN32 )
  find_library( DHD_LIBRARY NAMES dhdms dhdms64
                            PATHS ${module_lib_search_paths}
                            DOC "Path to dhdms library." )
  find_library( DHD_DRD_LIBRARY NAMES drdms drdms64
                                PATHS ${module_lib_search_paths}
                                DOC "Path to drdms library, not needed if DHD_INCLUDE_DIR and DHD_LIBRARY is set." )
else()
  find_library( DHD_LIBRARY NAMES dhd
                            PATHS ${module_lib_search_paths}
                            DOC "Path to dhd library." )
  find_library( DHD_DRD_LIBRARY NAMES drdms drdms64
                                PATHS ${module_lib_search_paths}
                                DOC "Path to drd library, not needed if DHD_INCLUDE_DIR and DHD_LIBRARY is set." )

  if( APPLE )
    find_library( DHD_IOKIT_LIBRARY NAMES IOKit
                  DOC "Path to IOKit library." )
    find_library( DHD_COREFOUNDATION_LIBRARY NAMES CoreFoundation
                  DOC "Path to CoreFoundation library." )
    mark_as_advanced( DHD_IOKIT_LIBRARY )
    mark_as_advanced( DHD_COREFOUNDATION_LIBRARY )
  else()
    if( UNIX )
      find_library( DHD_USB_LIBRARY NAMES usb
                    DOC "Path to usb library." )
      find_library( DHD_PCISCAN_LIBRARY NAMES pciscan 
                    DOC "Path to pciscan library." )
      mark_as_advanced( DHD_USB_LIBRARY )
      mark_as_advanced( DHD_PCISCAN_LIBRARY )
    endif()
  endif()
endif()
mark_as_advanced( DHD_LIBRARY )
mark_as_advanced( DHD_DRD_LIBRARY )

if( DHD_DRD_INCLUDE_DIR AND DHD_DRD_LIBRARY )
  set( DHD_DRD_FOUND ON )
else()
  set( DHD_DRD_FOUND OFF )
endif()


# Copy the results to the output variables.
if( ( DHD_INCLUDE_DIR AND DHD_LIBRARY ) OR DHD_DRD_FOUND )
  set( DHD_FOUND 1 )
  if( DHD_DRD_FOUND )
    set( DHD_LIBRARIES ${DHD_DRD_LIBRARY} )
    set( DHD_INCLUDE_DIRS ${DHD_DRD_INCLUDE_DIR} )
  else()
    set( DHD_LIBRARIES ${DHD_LIBRARY} )
    set( DHD_INCLUDE_DIRS ${DHD_INCLUDE_DIR} )
  endif()
  if( APPLE )
    if( DHD_IOKIT_LIBRARY AND DHD_COREFOUNDATION_LIBRARY )
        set( DHD_LIBRARIES ${DHD_LIBRARIES} ${DHD_IOKIT_LIBRARY} ${DHD_COREFOUNDATION_LIBRARY} )
      else()
        set( DHD_FOUND 0 )
        set( DHD_LIBRARIES )
        set( DHD_INCLUDE_DIRS )
      endif()
  else()
    if( UNIX )
      if( DHD_USB_LIBRARY AND DHD_PCISCAN_LIBRARY )
        set( DHD_LIBRARIES ${DHD_LIBRARIES} ${DHD_USB_LIBRARY} ${DHD_PCISCAN_LIBRARY} )
      else()
        set( DHD_FOUND 0 )
        set( DHD_LIBRARIES )
        set( DHD_INCLUDE_DIRS )
      endif()
    endif()
  endif()
else()
  set( DHD_FOUND 0 )
  set( DHD_LIBRARIES )
  set( DHD_INCLUDE_DIRS )
endif()
# Report the results.
if( NOT DHD_FOUND )
  set( DHD_DIR_MESSAGE
       "DHD was not found. Make sure to set DHD_LIBRARY" )
  if( UNIX )
     set( DHD_DIR_MESSAGE
          "${DHD_DIR_MESSAGE}, DHD_USB_LIBRARY, DHD_PCISCAN_LIBRARY" )
  endif()
  set( DHD_DIR_MESSAGE
       "${DHD_DIR_MESSAGE} and DHD_INCLUDE_DIR. If you do not have DHD library you will not be able to use the Omega or Delta haptics devices from ForceDimension." )
  if( DHD_FIND_REQUIRED )
    message( FATAL_ERROR "${DHD_DIR_MESSAGE}" )
  elseif( NOT DHD_FIND_QUIETLY )
    message( STATUS "${DHD_DIR_MESSAGE}" )
  endif()
endif()
