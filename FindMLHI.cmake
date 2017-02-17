# - Find MLHI
# Find the MLHI library
#
#  MLHI_INCLUDE_DIRS - Where to find MLHI/ml_api.h
#  MLHI_LIBRARIES    - List of libraries when using MLHI
#  MLHI_FOUND        - True if MLHI found

# Look for the header file.
find_path( MLHI_INCLUDE_DIR NAMES MLHI/ml_api.h
                            PATHS /usr/local/include/
                            DOC "Path in which the file MLHI/ml_api.h is located. Needed to support the MLHI devices." )
mark_as_advanced( MLHI_INCLUDE_DIR )

# Look for the library.
find_library( MLHI_LIBRARY NAMES mlhi_api_linux
                           PATHS /usr/local/lib/
                           DOC "Path to MLHI library. Needed to support the MLHI devices." )
mark_as_advanced( MLHI_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set MLHI_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( MLHI DEFAULT_MSG
                                   MLHI_LIBRARY MLHI_INCLUDE_DIR )

set( MLHI_LIBRARIES ${MLHI_LIBRARY} )
set( MLHI_INCLUDE_DIRS ${MLHI_INCLUDE_DIR} )