# - Find FalconAPI
# Find the native FALCONAPI headers and libraries.
#
#  FALCONAPI_INCLUDE_DIR -  where to find hdl.h, etc.
#  FALCONAPI_LIBRARIES    - List of libraries when using FalconAPI.
#  FALCONAPI_FOUND        - True if FalconAPI found.

set( program_files_path "" )
if( CMAKE_CL_64 )
  set( program_files_path "$ENV{ProgramW6432}" )
else( CMAKE_CL_64 )
  set( program_files_path "$ENV{ProgramFiles}" )
endif( CMAKE_CL_64 )

set( FALCON_INCLUDE_SEARCH_PATH "" )
set( FALCON_LIB_SEARCH_PATH "" )
if( WIN32 )
  if( NOT CMAKE_CL_64 )
    set( FALCON_INCLUDE_SEARCH_PATH $ENV{NOVINT_FALCON_SUPPORT}/include
                                    ${program_files_path}/Novint/Falcon/HDAL/include
                                    ${program_files_path}/Novint/HDAL_SDK_2.1.3/include
                                    $ENV{NOVINT_DEVICE_SUPPORT}/include )
    set( FALCON_LIB_SEARCH_PATH $ENV{NOVINT_FALCON_SUPPORT}/lib
                                ${program_files_path}/Novint/Falcon/HDAL/lib
                                ${program_files_path}/Novint/HDAL_SDK_2.1.3/lib
                                $ENV{NOVINT_DEVICE_SUPPORT}/lib )
  endif( NOT CMAKE_CL_64 )
endif( WIN32 )

# Look for the header file.
find_path(FALCONAPI_INCLUDE_DIR NAMES hdl/hdl.h 
                                PATHS ${FALCON_INCLUDE_SEARCH_PATH}
                                DOC "Path in which the file hdl/hdl.h is located. File is part of HDAL SDK." )

mark_as_advanced(FALCONAPI_INCLUDE_DIR)

# Look for the library.
find_library(FALCONAPI_HDL_LIBRARY NAMES hdl 
                        PATHS ${FALCON_LIB_SEARCH_PATH}
                        DOC "Path to hdl library. Library is part of HDAL SDK." )
mark_as_advanced(FALCONAPI_HDL_LIBRARY)

# Copy the results to the output variables.
if(FALCONAPI_INCLUDE_DIR AND FALCONAPI_HDL_LIBRARY)
  set(FALCONAPI_FOUND 1)
  set(FALCONAPI_LIBRARIES ${FALCONAPI_HDL_LIBRARY} )
  set(FALCONAPI_INCLUDE_DIR ${FALCONAPI_INCLUDE_DIR})
else(FALCONAPI_INCLUDE_DIR AND FALCONAPI_HDL_LIBRARY)
  set(FALCONAPI_FOUND 0)
  set(FALCONAPI_LIBRARIES)
  set(FALCONAPI_INCLUDE_DIR)
endif(FALCONAPI_INCLUDE_DIR  AND FALCONAPI_HDL_LIBRARY)

# Report the results.
if(NOT FALCONAPI_FOUND)
  set(FALCONAPI_DIR_MESSAGE
    "The Novint Falcon API(HDAL SDK) was not found. Make sure to set FALCONAPI_HDL_LIBRARY and FALCONAPI_INCLUDE_DIR. If you do not have it you will not be able to use the Novint Falcon Haptics device.")
  if( CMAKE_CL_64 )
    set( FALCONAPI_DIR_MESSAGE "${FALCONAPI_DIR_MESSAGE} NOVINT HAS NOT RELEASED A 64 BIT VERSION OF HDAL SDK YET." )
  endif( CMAKE_CL_64 )
  if(FalconAPI_FIND_REQUIRED)
    message(FATAL_ERROR "${FALCONAPI_DIR_MESSAGE}")
  elseif(NOT FalconAPI_FIND_QUIETLY)
    message(STATUS "${FALCONAPI_DIR_MESSAGE}")
  endif(FalconAPI_FIND_REQUIRED)
endif(NOT FALCONAPI_FOUND)
