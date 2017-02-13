# - Find PHYSX3
# Find the native PHYSX3 headers and libraries.
#
#  PHYSX3_INCLUDE_DIR -  where to find the include files of PHYSX3
#  PHYSX3_LIBRARIES    - List of libraries when using PHYSX3.
#  PHYSX3_FOUND        - True if PHYSX3 found.
#  PHYSX3_FLAGS        - Flags needed for physx to build 

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "physx3" )

if( CMAKE_CL_64 )
  set( LIB "64" )
  set( ARCH "x64" )
else()
  set( LIB "32" )
  set( ARCH "x86" )
endif()

if( NOT DEFINED PHYSX3_INSTALL_DIR )
  set( PHYSX3_INSTALL_DIR "" CACHE PATH "Path to external PhysX 3 installation" )
endif()
mark_as_advanced( PHYSX3_INSTALL_DIR )

# Look for the header file.
find_path( PHYSX3_INCLUDE_DIR NAMES PxPhysics.h
           PATHS /usr/local/include
                 ${PHYSX3_INSTALL_DIR}/Include
                 ${PHYSX3_INSTALL_DIR}/include/PhysX3
                 ${module_include_search_paths} )

mark_as_advanced( PHYSX3_INCLUDE_DIR )

set( PHYSX3_LIBS_FOUND 1 )
set( PHYSX3_LIBS_DEBUG_FOUND 1 )


# Decide which libraires to add
if( NOT DEFINED PHYSX3_LIBS )

  set( PHYSX3_LIBS 
      "PxTask"
      "PhysX3Common"
      "PhysX3Extensions"
      "PhysX3"
      "PhysX3Vehicle"
      "PhysX3Cooking"
      "PhysX3CharacterKinematic"
      "PhysXProfileSDK"
      "PhysXVisualDebuggerSDK" )

  if( UNIX )
    set( PHYSX3_LIBS ${PHYSX3_LIBS}
      "PvdRuntime"
      "LowLevel"
      "LowLevelCloth"
      "SceneQuery"
      "SimulationController" )
  endif()
  
endif()


set( PHYSX3_LIB_TYPE "CHECKED" CACHE STRING "PhysX library type" )
SET_PROPERTY( CACHE PHYSX3_LIB_TYPE PROPERTY STRINGS RELEASE CHECKED PROFILE )
if( ${PHYSX3_LIB_TYPE} STREQUAL RELEASE )
  set( PHYSX3_LIB_TYPE_SUFFIX "" )
else()
  set( PHYSX3_LIB_TYPE_SUFFIX ${PHYSX3_LIB_TYPE} )
endif()


# Look for the libraries.
foreach( PHYSX3_LIB ${PHYSX3_LIBS})
  string(TOUPPER ${PHYSX3_LIB} _upper_lib_name)
  set( LIB_NAME PHYSX3_${_upper_lib_name}_LIBRARY )
  set( LIB_DEBUG_NAME PHYSX3_${_upper_lib_name}_DEBUG_LIBRARY )
  # unset libraries so that they are always looked for. This is because we want it to automatically
  # update if the PHYSX3_LIB_TYPE is changed.
  UNSET( ${LIB_NAME} CACHE)

  # FIND RELEASE LIBS
  find_library( ${LIB_NAME}
                NAMES ${PHYSX3_LIB}${PHYSX3_LIB_TYPE_SUFFIX}_${ARCH} ${PHYSX3_LIB}${PHYSX3_LIB_TYPE_SUFFIX}
                PATHS ${PHYSX3_INSTALL_DIR}/Lib/win${LIB}
                      ${PHYSX3_INSTALL_DIR}/Lib/vc10win${LIB}
                      ${PHYSX3_INSTALL_DIR}/Lib/linux${LIB}
                      ${PHYSX3_INSTALL_DIR}/lib${LIB}
                      ${module_lib_search_paths} )
  mark_as_advanced( ${LIB_NAME} )
                      
  if( ${LIB_NAME} )
    if( UNIX )
      # To avoid undefined symbols at runtime we need to include the entire static library in our shared library
      set( PHYSX3_${_upper_lib_name}_LIBRARY -Wl,-whole-archive ${PHYSX3_${_upper_lib_name}_LIBRARY} -Wl,-no-whole-archive )
    endif()
    set( PHYSX3_LIBS_PATHS ${PHYSX3_LIBS_PATHS} optimized ${${LIB_NAME}} )
  else()
    set( PHYSX3_LIBS_FOUND 0 )
    set( PHYSX3_LIBS_NOTFOUND ${PHYSX3_LIBS_NOTFOUND} ${PHYSX3_LIB} ) 
  endif()

  #FIND DEBUG LIBS
  find_library( ${LIB_DEBUG_NAME}
                NAMES ${PHYSX3_LIB}DEBUG_${ARCH} ${PHYSX3_LIB}DEBUG
                PATHS ${PHYSX3_INSTALL_DIR}/Lib/win${LIB}
                      ${PHYSX3_INSTALL_DIR}/Lib/vc10win${LIB}
                      ${PHYSX3_INSTALL_DIR}/Lib/linux${LIB}
                      ${PHYSX3_INSTALL_DIR}/lib${LIB}
                      ${module_lib_search_paths} )
  mark_as_advanced( ${LIB_DEBUG_NAME} )
                      
  if( ${LIB_DEBUG_NAME} )
    if( UNIX )
      # To avoid undefined symbols at runtime we need to include the entire static library in our shared library
      set( PHYSX3_${_upper_lib_name}_LIBRARY -Wl,-whole-archive ${PHYSX3_${_upper_lib_name}_LIBRARY} -Wl,-no-whole-archive )
    endif()
    set( PHYSX3_LIBS_DEBUG_PATHS ${PHYSX3_LIBS_DEBUG_PATHS} debug ${${LIB_DEBUG_NAME}} )
  else()
    set( PHYSX3_DEBUG_LIBS_FOUND 0 )
    set( PHYSX3_DEBUG_LIBS_NOTFOUND ${PHYSX3_DEBUG_LIBS_NOTFOUND} ${PHYSX3_LIB} ) 
  endif()
endforeach()
                      
mark_as_advanced( PHYSX3_LIBS )

# Copy the results to the output variables.
if( PHYSX3_INCLUDE_DIR AND
     PHYSX3_LIBS_FOUND AND
     PHYSX3_LIBS_DEBUG_FOUND )
  set( PHYSX3_FOUND 1 )
  set( PHYSX3_LIBRARIES ${PHYSX3_LIBS_PATHS} ${PHYSX3_LIBS_DEBUG_PATHS} )
  set( PHYSX3_INCLUDE_DIR ${PHYSX3_INCLUDE_DIR} )
else()
  set( PHYSX3_FOUND 0 )
  set( PHYSX3_LIBRARIES )
  set( PHYSX3_INCLUDE_DIR )
endif()

# Report the results.
if( NOT PHYSX3_FOUND )
  set( PHYSX3_DIR_MESSAGE
       "PHYSX3 was not found. Set PHYSX3_INSTALL_DIR to the root directory of the 
installation containing the 'include' and 'lib' folders." )
  if( PHYSX3_FIND_REQUIRED )
    message( FATAL_ERROR "${PHYSX3_DIR_MESSAGE}" )
  elseif( NOT PHYSX3_FIND_QUIETLY )
    message( STATUS "${PHYSX3_DIR_MESSAGE}" )
  endif()
endif()
