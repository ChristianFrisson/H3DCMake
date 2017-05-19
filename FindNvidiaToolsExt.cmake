# - Find the NVIDIA Tool Extensions Toolkit
#
#  NvidiaToolsExt_INCLUDE_DIRS -  where to find cg.h, etc.
#  NvidiaToolsExt_LIBRARIES    - List of libraries when using NVIDIA CG Toolkit.
#  NvidiaToolsExt_FOUND        - True if the NVIDIA CG Toolkit is found.
#
# NVIDIA Tool Ext Toolkit (NVTX) is part of NSight profiling tool:
#   https://developer.nvidia.com/nvidia-nsight-visual-studio-edition
#
# Tested with v4.0.0
include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES NvidiaToolsExt_INCLUDE_DIR NvidiaToolsExt_LIBRARY
                                              OLD_VARIABLE_NAMES NVIDIATX_INCLUDE_DIR NVIDIATX_LIBRARY
                                              DOC_STRINGS "Path in which the file nvToolsExt.h and nvToolsExt.h are located."
                                                          "Path to nvToolsExt library." )

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

# Look for the header file
find_path( NvidiaToolsExt_INCLUDE_DIR NAMES nvToolsExt.h
           PATHS "$ENV{ProgramW6432}/NVIDIA Corporation/NvToolsExt/include"
                 "$ENV{PROGRAMFILES}/NVIDIA Corporation/NvToolsExt/include"
           DOC "Path in which the file nvToolsExt.h and nvToolsExt.h are located." )

# Look for the library nvToolsExt
if( CMAKE_CL_64 )
  find_library( NvidiaToolsExt_LIBRARY NAMES nvToolsExt64_1
                PATHS "$ENV{ProgramW6432}/NVIDIA Corporation/NvToolsExt/lib/x64"
                      "$ENV{PROGRAMFILES}/NVIDIA Corporation/NvToolsExt/lib/x64"
                DOC "Path to nvToolsExt library." )
else()
  find_library( NvidiaToolsExt_LIBRARY NAMES nvToolsExt32_1
                PATHS "$ENV{ProgramW6432}/NVIDIA Corporation/NvToolsExt/lib/Win32"
                      "$ENV{PROGRAMFILES}/NVIDIA Corporation/NvToolsExt/lib/Win32"
                DOC "Path to nvToolsExt library." )
endif()
mark_as_advanced( NvidiaToolsExt_LIBRARY )
mark_as_advanced( NvidiaToolsExt_INCLUDE_DIR )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set NvidiaToolsExt_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( NvidiaToolsExt DEFAULT_MSG
                                   NvidiaToolsExt_LIBRARY NvidiaToolsExt_INCLUDE_DIR )

set( NvidiaToolsExt_LIBRARIES ${NvidiaToolsExt_LIBRARY} )
set( NvidiaToolsExt_INCLUDE_DIRS ${NvidiaToolsExt_INCLUDE_DIR} )

# Kept for backward compatibility.
set( NVIDIATX_INCLUDE_DIR ${NvidiaToolsExt_INCLUDE_DIRS} )
set( NVIDIATX_LIBRARIES ${NvidiaToolsExt_LIBRARIES} )
set( NvidiaToolsExt_FOUND ${NVIDIATOOLSEXT_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.
set( NVIDIATX_FOUND ${NvidiaToolsExt_FOUND} )