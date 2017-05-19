# - Find FalconAPI
# Find the native FalconAPI headers and libraries.
#
#  FalconAPI_INCLUDE_DIRS -  where to find hdl.h, etc.
#  FalconAPI_LIBRARIES    - List of libraries when using FalconAPI.
#  FalconAPI_FOUND        - True if FalconAPI found.

include( H3DUtilityFunctions )

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES FalconAPI_INCLUDE_DIR FalconAPI_hdl_LIBRARY
                                              OLD_VARIABLE_NAMES FALCONAPI_INCLUDE_DIR FALCONAPI_HDL_LIBRARY
                                              DOC_STRINGS "Path in which the file hdl/hdl.h is located. File is part of HDAL SDK. Needed to support the Novint Falcon Haptics device."
                                                          "Path to hdl library. Library is part of HDAL SDK. Needed to support the Novint Falcon Haptics device." )

set( program_files_path "" )
if( CMAKE_CL_64 )
  set( program_files_path "$ENV{ProgramW6432}" )
else()
  set( program_files_path "$ENV{ProgramFiles}" )
endif()

set( falcon_include_search_path "" )
set( falcon_lib_search_path "" )
if( WIN32 )
  if( NOT CMAKE_CL_64 )
    set( falcon_include_search_path $ENV{NOVINT_FALCON_SUPPORT}/include
                                    ${program_files_path}/Novint/Falcon/HDAL/include
                                    ${program_files_path}/Novint/HDAL_SDK_2.1.3/include
                                    $ENV{NOVINT_DEVICE_SUPPORT}/include )
    set( falcon_lib_search_path $ENV{NOVINT_FALCON_SUPPORT}/lib
                                ${program_files_path}/Novint/Falcon/HDAL/lib
                                ${program_files_path}/Novint/HDAL_SDK_2.1.3/lib
                                $ENV{NOVINT_DEVICE_SUPPORT}/lib )
  endif()
endif()

# Look for the header file.
find_path( FalconAPI_INCLUDE_DIR NAMES hdl/hdl.h
                                 PATHS ${falcon_include_search_path}
                                 DOC "Path in which the file hdl/hdl.h is located. File is part of HDAL SDK. Needed to support the Novint Falcon Haptics device." )

mark_as_advanced( FalconAPI_INCLUDE_DIR )

# Look for the library.
find_library( FalconAPI_hdl_LIBRARY NAMES hdl
                                    PATHS ${falcon_lib_search_path}
                                    DOC "Path to hdl library. Library is part of HDAL SDK. Needed to support the Novint Falcon Haptics device." )
mark_as_advanced( FalconAPI_hdl_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set FalconAPI_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( FalconAPI DEFAULT_MSG
                                   FalconAPI_hdl_LIBRARY FalconAPI_INCLUDE_DIR )

set( FalconAPI_LIBRARIES ${FalconAPI_hdl_LIBRARY} )
set( FalconAPI_INCLUDE_DIRS ${FalconAPI_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( FALCONAPI_INCLUDE_DIR ${FalconAPI_INCLUDE_DIRS} )
set( FALCONAPI_LIBRARIES ${FalconAPI_LIBRARIES} )
set( FalconAPI_FOUND ${FALCONAPI_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.

if( CMAKE_CL_64 AND ( NOT FalconAPI_FIND_QUITELY ) AND ( NOT FalconAPI_FOUND ) )
  set( FalconAPI_DIR_MESSAGE "${FalconAPI_DIR_MESSAGE} NOVINT HAS NOT RELEASED A 64 BIT VERSION OF HDAL SDK YET." )
endif()