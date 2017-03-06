# Contains common H3D functions that are used a bit here and there.

set( H3D_MSVC_VERSION 6 )
if( MSVC )
  set( temp_msvc_version 1299 )
  while( ${MSVC_VERSION} GREATER ${temp_msvc_version} )
    math( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
    math( EXPR temp_msvc_version "${temp_msvc_version} + 100" )
  endwhile()

  if( ${H3D_MSVC_VERSION} GREATER 12 ) # MSVC skipped 13 in their numbering system.
    math( EXPR H3D_MSVC_VERSION "${H3D_MSVC_VERSION} + 1" )
  endif()
endif()

# the_target Will contain search path for the include directories.
# target_base_name Must be the base name for the target.
# Optional argument can be given which will be set to the postfix appended to the name.
function( setH3DMSVCOutputName the_target target_base_name )
  if( MSVC )
    # change the name depending on compiler to be able to tell them apart
    # since they are not compatible with each other. 
    # the_target can not link incrementally on vc8 for some reason. We shut of incremental linking for
    # all visual studio versions.
    set_target_properties( ${the_target} PROPERTIES OUTPUT_NAME ${target_base_name}_vc${H3D_MSVC_VERSION} )
    if( ARGC GREATER 2 )
      set( ${ARGV2} _vc${H3D_MSVC_VERSION} PARENT_SCOPE )
    endif()
  endif()
endfunction()

# compile_flags_container Compile flags will be added here.
function( addCommonH3DMSVCCompileFlags compile_flags_container )
  if( MSVC )
    # Treat wchar_t as built in type for all visual studio versions.
    # This is default for every version above 7 (so far) but we still set it for all.
    set( compile_flags_container_internal "/Zc:wchar_t" )

    if( MSVC80 )
      # This might be useful for visual studio 2005 users that often recompile the api.
      if( NOT DEFINED USE_VC8_MP_FLAG )
        set( USE_VC8_MP_FLAG "NO" CACHE BOOL "In visual studio 8 the MP flag exists but is not documented. Maybe it is unsafe to use. If you want to use it then set this flag to yes." )
      endif()

      if( USE_VC8_MP_FLAG )
        set( compile_flags_container_internal "${compile_flags_container_internal} /MP" )
      endif()
    endif()

    if( ${MSVC_VERSION} GREATER 1399 )
      # Remove compiler warnings about deprecation for visual studio versions 8 and above.
      set( compile_flags_container_internal "${compile_flags_container_internal} -D_CRT_SECURE_NO_DEPRECATE" )
    endif()

    if( ${MSVC_VERSION} GREATER 1499 )
      # Build using several threads for visual studio versions 9 and above.
      set( compile_flags_container_internal "${compile_flags_container_internal} /MP" )
    endif()
    set( ${compile_flags_container} "${${compile_flags_container}} ${compile_flags_container_internal}" PARENT_SCOPE )
  endif()
endfunction()

# goes through a list of libraries and adds them to be delayloaded
function( addDelayLoadFlags libraries_list link_flags_container )
  if( MSVC )
    set( link_flags_container_internal "" )
    foreach( lib_path ${${libraries_list}} )
      get_filename_component( lib_name ${lib_path} NAME_WE )
      set( link_flags_container_internal "${link_flags_container_internal} /DELAYLOAD:\"${lib_name}.dll\"" )
    endforeach()
    set( ${link_flags_container} "${${link_flags_container}} ${link_flags_container_internal}" PARENT_SCOPE )
  endif()
endfunction()

function( addDelayLoadFlagsFromNames dll_names_list link_flags_container )
  if( MSVC )
    set( link_flags_container_internal "" )
    foreach( dll_name ${${dll_names_list}} )
      set( link_flags_container_internal "${link_flags_container_internal} /DELAYLOAD:\"${dll_name}.dll\"" )
    endforeach()
    set( ${link_flags_container} "${${link_flags_container}} ${link_flags_container_internal}" PARENT_SCOPE )
  endif()
endfunction()