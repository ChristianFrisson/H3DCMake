if( WIN32 )
  cmake_minimum_required( VERSION 2.6.0 )
  # Macro used to set include directories on windows.
  macro( stripAndAddLibraryDirectories )
    foreach( temp_list_item ${ARGV} )
      string( REGEX REPLACE  "[/]([^/])*\\.lib$" "" temp_link_dir ${temp_list_item} )
      string( COMPARE NOTEQUAL ${temp_list_item} ${temp_link_dir} link_string_not_equal )
      if( ${link_string_not_equal} )
        link_directories( ${temp_link_dir} )
      endif()
    endforeach()
  endmacro()

  # Kept for backward compatibility. It prints a warning then calls the new macro named stripAndAddLibraryDirectories.
  macro( STRIP_AND_ADD_LIBRARY_DIRECTORIES )
    message( AUTHOR_WARNING "STRIP_AND_ADD_LIBRARY_DIRECTORIES is deprecated. Use stripAndAddLibraryDirectories instead." )
    stripAndAddLibraryDirectories( ${ARGV} )
  endmacro()
endif()
