# - Find SimballMedical
# Find the native SimballMedical headers and libraries.
#
#  SIMBALLMEDICAL_INCLUDE_DIR -  where to find SimballMedicalHID.h, etc.
#  SIMBALLMEDICAL_LIBRARIES    - List of libraries when using SimballMedical.
#  SIMBALLMEDICAL_FOUND        - True if SimballMedical found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )

# Look for the header file.
find_path(SIMBALLMEDICAL_INCLUDE_DIR NAMES Simball/SimballMedicalHID.h
                                PATHS ${module_include_search_paths}
                                DOC "Path in which the file Simball/SimballMedicalHID.h is located." )
mark_as_advanced(SIMBALLMEDICAL_INCLUDE_DIR)

# Look for the library.
find_library(SIMBALLMEDICAL_LIBRARY NAMES SimballMedicalHID 
                        PATHS ${module_lib_search_paths}
                        DOC "Path to SimballMedicalHID library." )
mark_as_advanced(SIMBALLMEDICAL_LIBRARY)

# Copy the results to the output variables.
if(SIMBALLMEDICAL_INCLUDE_DIR AND SIMBALLMEDICAL_LIBRARY)
  set(SIMBALLMEDICAL_FOUND 1)
  set(SIMBALLMEDICAL_LIBRARIES ${SIMBALLMEDICAL_LIBRARY} )
  set(SIMBALLMEDICAL_INCLUDE_DIR ${SIMBALLMEDICAL_INCLUDE_DIR})
else(SIMBALLMEDICAL_INCLUDE_DIR AND SIMBALLMEDICAL_LIBRARY)
  set(SIMBALLMEDICAL_FOUND 0)
  set(SIMBALLMEDICAL_LIBRARIES)
  set(SIMBALLMEDICAL_INCLUDE_DIR)
endif(SIMBALLMEDICAL_INCLUDE_DIR  AND SIMBALLMEDICAL_LIBRARY)

# Report the results.
if(NOT SIMBALLMEDICAL_FOUND)
  set(SIMBALLMEDICAL_DIR_MESSAGE
    "The SimballMedical API was not found. Make sure to set SIMBALLMEDICAL_LIBRARY and SIMBALLMEDICAL_INCLUDE_DIR. If you do not have the SimballMedicalHID library you will not be able to use the Simball device.")
  if(SimballMedical_FIND_REQUIRED)
    message(FATAL_ERROR "${SIMBALLMEDICAL_DIR_MESSAGE}")
  elseif(NOT SimballMedical_FIND_QUIETLY)
    message(STATUS "${SIMBALLMEDICAL_DIR_MESSAGE}")
  endif(SimballMedical_FIND_REQUIRED)
endif(NOT SIMBALLMEDICAL_FOUND)
