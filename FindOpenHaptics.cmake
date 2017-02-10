# - Find OpenHaptics
# Find the native OPENHAPTICS headers and libraries.
#
#  OPENHAPTICS_INCLUDE_DIR -  where to find OpenHaptics.h, etc.
#  OPENHAPTICS_LIBRARIES    - List of libraries when using OpenHaptics.
#  OPENHAPTICS_FOUND        - True if OpenHaptics found.

set( program_files_path "" )
if( CMAKE_CL_64 )
  set( LIB "x64" )
  set( program_files_path "$ENV{ProgramW6432}" )
else( CMAKE_CL_64 )
  set( LIB "win32" )
  set( program_files_path "$ENV{ProgramFiles}" )
endif( CMAKE_CL_64 )

# Look for the header file.
find_path(OPENHAPTICS_INCLUDE_DIR NAMES HL/hl.h HD/hd.h HDU/hdu.h
                                  PATHS $ENV{3DTOUCH_BASE}/include
                                        $ENV{OH_SDK_BASE}/include
                                        "${program_files_path}/SensAble/3DTouch/include"
                                  DOC "Path in which the files HL/hl.h, HD/hd.h and HDU/hdu.h are located." )
mark_as_advanced(OPENHAPTICS_INCLUDE_DIR)

set( OPENHAPTICS_LIBRARY_DIRECTORIES $ENV{3DTOUCH_BASE}/lib        # OpenHaptics 2.0
                              $ENV{3DTOUCH_BASE}/lib/${LIB}  # OpenHaptics 3.0
                              $ENV{OH_SDK_BASE}/lib        # OpenHaptics 2.0
                              $ENV{OH_SDK_BASE}/lib/${LIB}  # OpenHaptics 3.0
                              $ENV{OH_SDK_BASE}/lib/${LIB}/Release
                              $ENV{OH_SDK_BASE}/lib/${LIB}/ReleaseAcademicEdition
                              "${program_files_path}/SensAble/3DTouch/lib"        # OpenHaptics 2.0
                              "${program_files_path}/SensAble/3DTouch/lib/${LIB}" # OpenHaptics 3.0
                              "/usr/lib64" )

# TODO: Add conditional checking for x64 system
# Look for the library.
find_library(OPENHAPTICS_HL_LIBRARY NAMES HL
                        PATHS ${OPENHAPTICS_LIBRARY_DIRECTORIES}
                        DOC "Path to hl library." )

mark_as_advanced(OPENHAPTICS_HL_LIBRARY)

find_library(OPENHAPTICS_HD_LIBRARY NAMES HD
                        PATHS ${OPENHAPTICS_LIBRARY_DIRECTORIES}
                        DOC "Path to hd library." )
mark_as_advanced(OPENHAPTICS_HD_LIBRARY)

find_library(OPENHAPTICS_HDU_LIBRARY NAMES HDU
                         PATHS  $ENV{3DTOUCH_BASE}/utilities/lib        # OpenHaptics 2.0
                                $ENV{3DTOUCH_BASE}/utilities/lib/${LIB}/Release  # OpenHaptics 3.0
                                $ENV{OH_SDK_BASE}/utilities/lib        # OpenHaptics 2.0
                                $ENV{OH_SDK_BASE}/utilities/lib/${LIB}/Release  # OpenHaptics 3.0
                                "${program_files_path}/SensAble/3DTouch/utilities/lib"        # OpenHaptics 2.0
                                "${program_files_path}/SensAble/3DTouch/utilities/lib/${LIB}/Release"  # OpenHaptics 3.0
                                "/usr/lib64"
                         DOC "Path to hdu library." )
mark_as_advanced(OPENHAPTICS_HDU_LIBRARY)

# Copy the results to the output variables.
if(OPENHAPTICS_INCLUDE_DIR AND OPENHAPTICS_HD_LIBRARY AND OPENHAPTICS_HL_LIBRARY AND OPENHAPTICS_HDU_LIBRARY)
  set(OPENHAPTICS_FOUND 1)
  set(OPENHAPTICS_LIBRARIES ${OPENHAPTICS_HD_LIBRARY} ${OPENHAPTICS_HL_LIBRARY} ${OPENHAPTICS_HDU_LIBRARY})
  set(OPENHAPTICS_INCLUDE_DIR ${OPENHAPTICS_INCLUDE_DIR})
else(OPENHAPTICS_INCLUDE_DIR AND OPENHAPTICS_HD_LIBRARY AND OPENHAPTICS_HL_LIBRARY AND OPENHAPTICS_HDU_LIBRARY)
  set(OPENHAPTICS_FOUND 0)
  set(OPENHAPTICS_LIBRARIES)
  set(OPENHAPTICS_INCLUDE_DIR)
endif(OPENHAPTICS_INCLUDE_DIR  AND OPENHAPTICS_HD_LIBRARY AND OPENHAPTICS_HL_LIBRARY AND OPENHAPTICS_HDU_LIBRARY)

# Report the results.
if(NOT OPENHAPTICS_FOUND)
  set(OPENHAPTICS_DIR_MESSAGE
    "OPENHAPTICS [hapi] was not found. Make sure to set OPENHAPTICS_HL_LIBRARY, OPENHAPTICS_HD_LIBRARY, OPENHAPTICS_HDU_LIBRARY and OPENHAPTICS_INCLUDE_DIR. If you do not have it you will not be able to use haptics devices from SensAble Technologies such as the Phantom.")
  if(OpenHaptics_FIND_REQUIRED)
    message(FATAL_ERROR "${OPENHAPTICS_DIR_MESSAGE}")
  elseif(NOT OpenHaptics_FIND_QUIETLY)
    message(STATUS "${OPENHAPTICS_DIR_MESSAGE}")
  endif(OpenHaptics_FIND_REQUIRED)
endif(NOT OPENHAPTICS_FOUND)
