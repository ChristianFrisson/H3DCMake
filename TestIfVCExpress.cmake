# Macro to check if MFC exists. Would like to check if ATL exists but this will have to do for now.
# Can be seen as a way of detecting whether an express version of visual studio is used or not.
macro( testIfVCExpress )
  if( MSVC )
    if( CMake_HAVE_MFC MATCHES "^CMake_HAVE_MFC$" )
      set( CHECK_INCLUDE_FILE_VAR "afxwin.h" )
      configure_file( ${CMAKE_ROOT}/Modules/CheckIncludeFile.cxx.in
        ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/CheckIncludeFile.cxx )
      message( STATUS "Looking for MFC" )
      try_compile( CMake_HAVE_MFC
        ${CMAKE_BINARY_DIR}
        ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/CheckIncludeFile.cxx
        CMAKE_FLAGS
        -DCMAKE_MFC_FLAG:STRING=2
        -DCOMPILE_DEFINITIONS:STRING=-D_AFXDLL
        OUTPUT_VARIABLE OUTPUT )
      if( CMake_HAVE_MFC )
        message( STATUS "Looking for MFC - found" )
        set( CMake_HAVE_MFC 1 CACHE INTERNAL "Have MFC?" )
        file( APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
          "Determining if MFC exists passed with the following output:\n"
          "${OUTPUT}\n\n" )
      else()
        message( STATUS "Looking for MFC - not found" )
        set( CMake_HAVE_MFC 0 CACHE INTERNAL "Have MFC?" )
        file( APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
          "Determining if MFC exists failed with the following output:\n"
          "${OUTPUT}\n\n" )
      endif()
    endif()
  endif()
endmacro()
