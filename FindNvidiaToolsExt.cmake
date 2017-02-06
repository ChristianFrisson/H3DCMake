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

GET_FILENAME_COMPONENT(module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

# Look for the header file
FIND_PATH( NVIDIATX_INCLUDE_DIR NAMES nvToolsExt.h
           PATHS "$ENV{ProgramW6432}/NVIDIA Corporation/NvToolsExt/include"
                 "$ENV{PROGRAMFILES}/NVIDIA Corporation/NvToolsExt/include"
           DOC "Path in which the file nvToolsExt.h and nvToolsExt.h are located." )

# Look for the library nvToolsExt
IF( CMAKE_CL_64 )
  FIND_LIBRARY( NVIDIATX_LIBRARY NAMES nvToolsExt64_1
                PATHS "$ENV{ProgramW6432}/NVIDIA Corporation/NvToolsExt/lib/x64"
                      "$ENV{PROGRAMFILES}/NVIDIA Corporation/NvToolsExt/lib/x64"
                DOC "Path to nvToolsExt library." )
ELSE( CMAKE_CL_64 )
  FIND_LIBRARY( NVIDIATX_LIBRARY NAMES nvToolsExt32_1
                PATHS "$ENV{ProgramW6432}/NVIDIA Corporation/NvToolsExt/lib/Win32"
                      "$ENV{PROGRAMFILES}/NVIDIA Corporation/NvToolsExt/lib/Win32"
                DOC "Path to nvToolsExt library." )
ENDIF( CMAKE_CL_64 )
MARK_AS_ADVANCED(NVIDIATX_LIBRARY)
MARK_AS_ADVANCED(NVIDIATX_INCLUDE_DIR)

# Copy the results to the output variables.
IF(NVIDIATX_INCLUDE_DIR AND NVIDIATX_LIBRARY)
  SET(NVIDIATX_FOUND 1)
  SET(NVIDIATX_LIBRARIES ${NVIDIATX_LIBRARY})
  SET(NVIDIATX_INCLUDE_DIR ${NVIDIATX_INCLUDE_DIR})
ELSE(NVIDIATX_INCLUDE_DIR AND NVIDIATX_LIBRARY)
  SET(NVIDIATX_FOUND 0)
  SET(NVIDIATX_LIBRARIES)
  SET(NVIDIATX_INCLUDE_DIR)
ENDIF(NVIDIATX_INCLUDE_DIR AND NVIDIATX_LIBRARY)

# Report the results.
IF(NOT NVIDIATX_FOUND)
  SET(NVIDIATX_DIR_MESSAGE
    "NVIDIAs CG Toolkit was not found. Make sure NVIDIATX_LIBRARY and NVIDIATX_INCLUDE_DIR are set.")
  IF(NVIDIATX_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR "${NVIDIATX_DIR_MESSAGE}")
  ELSEIF(NOT NVIDIATX_FIND_QUIETLY)
    MESSAGE(STATUS "${NVIDIATX_DIR_MESSAGE}")
  ENDIF(NVIDIATX_FIND_REQUIRED)
ENDIF(NOT NVIDIATX_FOUND)
