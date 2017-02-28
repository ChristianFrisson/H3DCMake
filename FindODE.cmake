# - Find ODE
# Find the native ODE headers and libraries.
#
#  ODE_INCLUDE_DIRS -  where to find ode.h, etc.
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

mark_as_advanced( ODE_INCLUDE_DIR )

# Look for the library.
if( WIN32 )
  find_library( ODE_DOUBLE_LIBRARY NAMES ode_double
                PATHS ${module_lib_search_paths} )
  find_library( ODE_SINGLE_LIBRARY NAMES ode_single
                PATHS ${module_lib_search_paths} )
  if( ODE_DOUBLE_LIBRARY )
    set( ODE_LIBRARY ${ODE_DOUBLE_LIBRARY} )
    set( ODE_FLAGS -DdDOUBLE )
  else()
    set( ODE_LIBRARY ${ODE_SINGLE_LIBRARY} )
    set( ODE_FLAGS -DdSINGLE )
  endif()

  mark_as_advanced( ODE_DOUBLE_LIBRARY )
  mark_as_advanced( ODE_SINGLE_LIBRARY )
  mark_as_advanced( ODE_FLAGS )

else()
  find_library( ODE_LIBRARY NAMES ode )

# use the ode-config program to set the defines necessary. E.g. -DdSINGLE or -DdDOUBLE
# depending on how ode was built.
  find_program(ODE_CONFIG_EXECUTABLE ode-config
               PATHS /usr/local/bin
                     /opt/local/bin )
  message( STATUS ${ODE_CONFIG_EXECUTABLE} )
  if( ODE_CONFIG_EXECUTABLE )
     execute_process(
        COMMAND sh "${ODE_CONFIG_EXECUTABLE}" --cflags
        OUTPUT_VARIABLE ODE_CFLAGS
        RESULT_VARIABLE RET
        ERROR_QUIET )

     if( RET EQUAL 0 )
       string(REGEX REPLACE "\n" "" ODE_CFLAGS "${ODE_CFLAGS}" )
       set( ODE_FLAGS ${ODE_CFLAGS} )
     endif()
  endif()
endif()

mark_as_advanced( ODE_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set ODE_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( ODE DEFAULT_MSG
                                   ODE_LIBRARY ODE_INCLUDE_DIR )

set( ODE_LIBRARIES ${ODE_LIBRARY} )
set( ODE_INCLUDE_DIRS ${ODE_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( ODE_INCLUDE_DIR ${ODE_INCLUDE_DIRS} )
