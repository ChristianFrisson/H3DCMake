# - Find ODE
# Find the native ODE headers and libraries.
#
#  ODE_INCLUDE_DIR -  where to find ode.h, etc.
#  ODE_LIBRARIES    - List of libraries when using ODE.
#  ODE_FOUND        - True if ODE found.
#  ODE_FLAGS        - Flags needed for ode to build 

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )

# Look for the header file.
find_path( ODE_INCLUDE_DIR NAMES ode/ode.h
           PATHS /usr/local/include
                 ${module_include_search_paths} )

mark_as_advanced(ODE_INCLUDE_DIR)

# Look for the library.
if(WIN32)
  find_library( ODE_DOUBLE_LIBRARY NAMES ode_double
                PATHS ${module_lib_search_paths} )
  find_library( ODE_SINGLE_LIBRARY NAMES ode_single
                PATHS ${module_lib_search_paths} )
  if(ODE_DOUBLE_LIBRARY)
    set( ODE_LIBRARY ${ODE_DOUBLE_LIBRARY} )
    set( ODE_FLAGS -DdDOUBLE )
  else(ODE_DOUBLE_LIBRARY)
    set( ODE_LIBRARY ${ODE_SINGLE_LIBRARY} )
    set( ODE_FLAGS -DdSINGLE )
  endif(ODE_DOUBLE_LIBRARY)

  mark_as_advanced(ODE_DOUBLE_LIBRARY)
  mark_as_advanced(ODE_SINGLE_LIBRARY)
  mark_as_advanced(ODE_FLAGS)

else(WIN32)
  find_library( ODE_LIBRARY NAMES ode )

# use the ode-config program to set the defines necessary. E.g. -DdSINGLE or -DdDOUBLE
# depending on how ode was built.
  find_program(ODE_CONFIG_EXECUTABLE ode-config
               PATHS /usr/local/bin
                     /opt/local/bin )
  message( STATUS ${ODE_CONFIG_EXECUTABLE} )
  if( ODE_CONFIG_EXECUTABLE )
     EXECUTE_PROCESS(
        COMMAND sh "${ODE_CONFIG_EXECUTABLE}" --cflags
        OUTPUT_VARIABLE ODE_CFLAGS
        RESULT_VARIABLE RET
        ERROR_QUIET
        )

     if( RET EQUAL 0 )
       string(REGEX REPLACE "\n" "" ODE_CFLAGS "${ODE_CFLAGS}")       
       set( ODE_FLAGS ${ODE_CFLAGS} )
     endif( RET EQUAL 0 )
  endif( ODE_CONFIG_EXECUTABLE )
endif(WIN32)

mark_as_advanced(ODE_LIBRARY)

# Copy the results to the output variables.
if(ODE_INCLUDE_DIR AND ODE_LIBRARY AND ( WIN32 OR ODE_CONFIG_EXECUTABLE ))
  set(ODE_FOUND 1)
  set(ODE_LIBRARIES ${ODE_LIBRARY})
  set(ODE_INCLUDE_DIR ${ODE_INCLUDE_DIR})
else(ODE_INCLUDE_DIR AND ODE_LIBRARY)
  set(ODE_FOUND 0)
  set(ODE_LIBRARIES)
  set(ODE_INCLUDE_DIR)
endif(ODE_INCLUDE_DIR AND ODE_LIBRARY AND ( WIN32 OR ODE_CONFIG_EXECUTABLE ))

# Report the results.
if(NOT ODE_FOUND)
  set(ODE_DIR_MESSAGE
    "ODE was not found. Make sure ODE_LIBRARY and ODE_INCLUDE_DIR are set.")
  if(ODE_FIND_REQUIRED)
    message(FATAL_ERROR "${ODE_DIR_MESSAGE}")
  elseif(NOT ODE_FIND_QUIETLY)
    message(STATUS "${ODE_DIR_MESSAGE}")
  endif(ODE_FIND_REQUIRED)
endif(NOT ODE_FOUND)
