# - Find the NVIDIA Tool Extensions Toolkit
#
#  NVIDIATX_INCLUDE_DIR -  where to find cg.h, etc.
#  NVIDIATX_LIBRARIES    - List of libraries when using NVIDIA CG Toolkit.
#  NVIDIATX_FOUND        - True if the NVIDIA CG Toolkit is found.
#
# NVIDIA Tool Ext Toolkit (NVTX) is part of NSight profiling tool:
#   https://developer.nvidia.com/nvidia-nsight-visual-studio-edition
#
# Tested with v4.0.0 

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

# Look for the header file
find_path( NVIDIATX_INCLUDE_DIR NAMES nvToolsExt.h
           PATHS "$ENV{ProgramW6432}/NVIDIA Corporation/NvToolsExt/include"
                 "$ENV{PROGRAMFILES}/NVIDIA Corporation/NvToolsExt/include"
           DOC "Path in which the file nvToolsExt.h and nvToolsExt.h are located." )

# Look for the library nvToolsExt
if( CMAKE_CL_64 )
  find_library( NVIDIATX_LIBRARY NAMES nvToolsExt64_1
                PATHS "$ENV{ProgramW6432}/NVIDIA Corporation/NvToolsExt/lib/x64"
                      "$ENV{PROGRAMFILES}/NVIDIA Corporation/NvToolsExt/lib/x64"
                DOC "Path to nvToolsExt library." )
else()
  find_library( NVIDIATX_LIBRARY NAMES nvToolsExt32_1
                PATHS "$ENV{ProgramW6432}/NVIDIA Corporation/NvToolsExt/lib/Win32"
                      "$ENV{PROGRAMFILES}/NVIDIA Corporation/NvToolsExt/lib/Win32"
                DOC "Path to nvToolsExt library." )
endif()
mark_as_advanced( NVIDIATX_LIBRARY )
mark_as_advanced( NVIDIATX_INCLUDE_DIR )

# Copy the results to the output variables.
if( NVIDIATX_INCLUDE_DIR AND NVIDIATX_LIBRARY )
  set( NVIDIATX_FOUND 1 )
  set( NVIDIATX_LIBRARIES ${NVIDIATX_LIBRARY} )
  set( NVIDIATX_INCLUDE_DIR ${NVIDIATX_INCLUDE_DIR} )
else()
  set( NVIDIATX_FOUND 0 )
  set( NVIDIATX_LIBRARIES )
  set( NVIDIATX_INCLUDE_DIR )
endif()

# Report the results.
if( NOT NVIDIATX_FOUND )
  set( NVIDIATX_DIR_MESSAGE
       "NVIDIAs CG Toolkit was not found. Make sure NVIDIATX_LIBRARY and NVIDIATX_INCLUDE_DIR are set." )
  if( NVIDIATX_FIND_REQUIRED )
    message( FATAL_ERROR "${NVIDIATX_DIR_MESSAGE}" )
  elseif( NOT NVIDIATX_FIND_QUIETLY )
    message( STATUS "${NVIDIATX_DIR_MESSAGE}" )
  endif()
endif()
