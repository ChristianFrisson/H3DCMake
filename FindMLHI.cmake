# - Find MLHI
# Find the MLHI library
#
#  MLHI_INCLUDE_DIR -  where to find MLHI/ml_api.h
#  MLHI_LIBRARIES    - List of libraries when using MLHI
#  MLHI_FOUND        - True if MLHI found

# Look for the header file.
find_path(MLHI_INCLUDE_DIR NAMES MLHI/ml_api.h
                                PATHS /usr/local/include/
                                DOC "Path in which the file MLHI/ml_api.h is located." )
mark_as_advanced(MLHI_INCLUDE_DIR)

# Look for the library.
find_library(MLHI_LIBRARY NAMES mlhi_api_linux
                        PATHS /usr/local/lib/
                        DOC "Path to MLHI library." )
mark_as_advanced(MLHI_LIBRARY)

# Copy the results to the output variables.
if(MLHI_INCLUDE_DIR AND MLHI_LIBRARY)
  set(MLHI_FOUND 1)
  set(MLHI_LIBRARIES ${MLHI_LIBRARY} )
  set(MLHI_INCLUDE_DIR ${MLHI_INCLUDE_DIR})
else(MLHI_INCLUDE_DIR AND MLHI_LIBRARY)
  set(MLHI_FOUND 0)
  set(MLHI_LIBRARIES)
  set(MLHI_INCLUDE_DIR)
endif(MLHI_INCLUDE_DIR  AND MLHI_LIBRARY)

# Report the results.
if(NOT MLHI_FOUND)
  set(MLHI_DIR_MESSAGE
    "The MLHI API was not found. Make sure to set MLHI_LIBRARY and MLHI_INCLUDE_DIR. If you do not have the MLHI library you will not be able to use the MLHI devices.")
  if(MLHI_FIND_REQUIRED)
    message(FATAL_ERROR "${MLHI_DIR_MESSAGE}")
  elseif(NOT MLHI_FIND_QUIETLY)
    message(STATUS "${MLHI_DIR_MESSAGE}")
  endif(MLHI_FIND_REQUIRED)
endif(NOT MLHI_FOUND)
