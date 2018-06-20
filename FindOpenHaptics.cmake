# - Find OpenHaptics
# Find the native OpenHaptics headers and libraries.
#
#  OpenHaptics_INCLUDE_DIRS - Where to find OpenHaptics.h, etc.
#  OpenHaptics_LIBRARIES    - List of libraries when using OpenHaptics.
#  OpenHaptics_FOUND        - True if OpenHaptics found.

include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES OpenHaptics_INCLUDE_DIR OpenHaptics_HL_LIBRARY OpenHaptics_HD_LIBRARY
                                              DOC_STRINGS "Path in which the files HL/hl.h, HD/hd.h and HDU/hdu.h are located. Comes with OpenHaptics installation, needed for PhantomDevice to work."
                                                          "Path to hl library. Comes with OpenHaptics installation, needed for PhantomDevice to work."
                                                          "Path to hd library. Comes with OpenHaptics installation, needed for PhantomDevice to work." )

set( program_files_path "" )
if( CMAKE_CL_64 )
  set( lib "x64" )
  set( program_files_path "$ENV{ProgramW6432}" )
else()
  set( lib "win32" )
  set( program_files_path "$ENV{ProgramFiles}" )
endif()

# Look for the header file.
find_path( OpenHaptics_INCLUDE_DIR NAMES HL/hl.h HD/hd.h HDU/hdu.h
                                   PATHS $ENV{3DTOUCH_BASE}/include
                                         $ENV{OH_SDK_BASE}/include
                                         "${program_files_path}/SensAble/3DTouch/include"
                                   DOC "Path in which the files HL/hl.h, HD/hd.h and HDU/hdu.h are located. Comes with OpenHaptics installation, needed for PhantomDevice to work." )
mark_as_advanced( OpenHaptics_INCLUDE_DIR )

set( openhaptics_library_directories $ENV{3DTOUCH_BASE}/lib        # OpenHaptics 2.0
                              $ENV{3DTOUCH_BASE}/lib/${lib}  # OpenHaptics 3.0
                              $ENV{OH_SDK_BASE}/lib        # OpenHaptics 2.0
                              $ENV{OH_SDK_BASE}/lib/${lib}  # OpenHaptics 3.0
                              $ENV{OH_SDK_BASE}/lib/${lib}/Release
                              $ENV{OH_SDK_BASE}/lib/${lib}/ReleaseAcademicEdition
                              "${program_files_path}/SensAble/3DTouch/lib"        # OpenHaptics 2.0
                              "${program_files_path}/SensAble/3DTouch/lib/${lib}" # OpenHaptics 3.0
                              "/usr/lib64" )

# Look for the library.
find_library( OpenHaptics_HL_LIBRARY NAMES HL
                        PATHS ${openhaptics_library_directories}
                        DOC "Path to hl library. Comes with OpenHaptics installation, needed for PhantomDevice to work." )

mark_as_advanced( OpenHaptics_HL_LIBRARY )

find_library( OpenHaptics_HD_LIBRARY NAMES HD
                        PATHS ${openhaptics_library_directories}
                        DOC "Path to hd library. Comes with OpenHaptics installation, needed for PhantomDevice to work." )
mark_as_advanced( OpenHaptics_HD_LIBRARY )

find_library( OpenHaptics_HDU_LIBRARY NAMES HDU
                         PATHS  $ENV{3DTOUCH_BASE}/utilities/lib        # OpenHaptics 2.0
                                $ENV{3DTOUCH_BASE}/utilities/lib/${lib}/Release  # OpenHaptics 3.0
                                $ENV{OH_SDK_BASE}/utilities/lib        # OpenHaptics 2.0
                                $ENV{OH_SDK_BASE}/utilities/lib/${lib}/Release  # OpenHaptics 3.0
                                "${program_files_path}/SensAble/3DTouch/utilities/lib"        # OpenHaptics 2.0
                                "${program_files_path}/SensAble/3DTouch/utilities/lib/${lib}/Release"  # OpenHaptics 3.0
                                "/usr/lib64"
                         DOC "Path to hdu library. Comes with OpenHaptics installation, needed for PhantomDevice to work." )
mark_as_advanced( OpenHaptics_HDU_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set OpenHaptics_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( OpenHaptics DEFAULT_MSG
                                   OpenHaptics_HL_LIBRARY OpenHaptics_HD_LIBRARY OpenHaptics_HDU_LIBRARY OpenHaptics_INCLUDE_DIR )

set( OpenHaptics_LIBRARIES ${OpenHaptics_HL_LIBRARY} ${OpenHaptics_HD_LIBRARY} ${OpenHaptics_HDU_LIBRARY} )
set( OpenHaptics_INCLUDE_DIRS ${OpenHaptics_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( OPENHAPTICS_INCLUDE_DIR ${OpenHaptics_INCLUDE_DIRS} )
set( OPENHAPTICS_LIBRARIES ${OpenHaptics_LIBRARIES} )
set( OpenHaptics_FOUND ${OPENHAPTICS_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.