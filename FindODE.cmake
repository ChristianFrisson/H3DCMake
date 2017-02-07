# - Find ODE
# Find the native ODE headers and libraries.
#
#  ODE_INCLUDE_DIR -  where to find ode.h, etc.
#  ODE_LIBRARIES    - List of libraries when using ODE.
#  ODE_FOUND        - True if ODE found.
#  ODE_FLAGS        - Flags needed for ode to build 

include( H3DExternalSearchPath )
GET_FILENAME_COMPONENT( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
get_external_search_paths_h3d( module_include_search_paths module_lib_search_paths ${module_file_path} )

# Look for the header file.
FIND_PATH( ODE_INCLUDE_DIR NAMES ode/ode.h
           PATHS /usr/local/include
                 ${module_include_search_paths} )

MARK_AS_ADVANCED(ODE_INCLUDE_DIR)

# Look for the library.
IF(WIN32)
  FIND_LIBRARY( ODE_DOUBLE_LIBRARY NAMES ode_double
                PATHS ${module_lib_search_paths} )
  FIND_LIBRARY( ODE_SINGLE_LIBRARY NAMES ode_single
                PATHS ${module_lib_search_paths} )
  IF(ODE_DOUBLE_LIBRARY)
    SET( ODE_LIBRARY ${ODE_DOUBLE_LIBRARY} )
    SET( ODE_FLAGS -DdDOUBLE )
  ELSE(ODE_DOUBLE_LIBRARY)
    SET( ODE_LIBRARY ${ODE_SINGLE_LIBRARY} )
    SET( ODE_FLAGS -DdSINGLE )
  ENDIF(ODE_DOUBLE_LIBRARY)

  MARK_AS_ADVANCED(ODE_DOUBLE_LIBRARY)
  MARK_AS_ADVANCED(ODE_SINGLE_LIBRARY)
  MARK_AS_ADVANCED(ODE_FLAGS)

ELSE(WIN32)
  FIND_LIBRARY( ODE_LIBRARY NAMES ode )

# use the ode-config program to set the defines necessary. E.g. -DdSINGLE or -DdDOUBLE
# depending on how ode was built.
  FIND_PROGRAM(ODE_CONFIG_EXECUTABLE ode-config
               PATHS /usr/local/bin
                     /opt/local/bin )
  MESSAGE( STATUS ${ODE_CONFIG_EXECUTABLE} )
  IF( ODE_CONFIG_EXECUTABLE )
     EXECUTE_PROCESS(
        COMMAND sh "${ODE_CONFIG_EXECUTABLE}" --cflags
        OUTPUT_VARIABLE ODE_CFLAGS
        RESULT_VARIABLE RET
        ERROR_QUIET
        )

     IF( RET EQUAL 0 )
       STRING(REGEX REPLACE "\n" "" ODE_CFLAGS "${ODE_CFLAGS}")       
       SET( ODE_FLAGS ${ODE_CFLAGS} )
     ENDIF( RET EQUAL 0 )
  ENDIF( ODE_CONFIG_EXECUTABLE )
ENDIF(WIN32)

MARK_AS_ADVANCED(ODE_LIBRARY)

# Copy the results to the output variables.
IF(ODE_INCLUDE_DIR AND ODE_LIBRARY AND ( WIN32 OR ODE_CONFIG_EXECUTABLE ))
  SET(ODE_FOUND 1)
  SET(ODE_LIBRARIES ${ODE_LIBRARY})
  SET(ODE_INCLUDE_DIR ${ODE_INCLUDE_DIR})
ELSE(ODE_INCLUDE_DIR AND ODE_LIBRARY)
  SET(ODE_FOUND 0)
  SET(ODE_LIBRARIES)
  SET(ODE_INCLUDE_DIR)
ENDIF(ODE_INCLUDE_DIR AND ODE_LIBRARY AND ( WIN32 OR ODE_CONFIG_EXECUTABLE ))

# Report the results.
IF(NOT ODE_FOUND)
  SET(ODE_DIR_MESSAGE
    "ODE was not found. Make sure ODE_LIBRARY and ODE_INCLUDE_DIR are set.")
  IF(ODE_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR "${ODE_DIR_MESSAGE}")
  ELSEIF(NOT ODE_FIND_QUIETLY)
    MESSAGE(STATUS "${ODE_DIR_MESSAGE}")
  ENDIF(ODE_FIND_REQUIRED)
ENDIF(NOT ODE_FOUND)
