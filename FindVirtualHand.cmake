# - Find VirtualHand SDK
# Find the native VirtualHand headers and libraries.
#
#  VirtualHand_INCLUDE_DIR -  where to find headers, etc.
#  VirtualHand_LIBRARIES    - List of libraries when using VirtualHand.
#  VirtualHand_FOUND        - True if VirtualHand found.

set( vti_registry_file_path "" )
if( NOT "$ENV{VTI_REGISTRY_FILE}" STREQUAL  "" )
  get_filename_component(vti_registry_file_path "$ENV{VTI_REGISTRY_FILE}" PATH )
endif( NOT "$ENV{VTI_REGISTRY_FILE}" STREQUAL  "" )

# Look for the header file.
find_path( VirtualHand_INCLUDE_DIR NAMES vhandtk/vht.h
           PATHS ${vti_registry_file_path}/../../Development/include
                  C:/Program/Immersion Corporation/VirtualHand/Development/include
                  "C:/Program Files/Immersion Corporation/VirtualHand/Development/include"
           DOC "Path in which the file vhandtk/vht.h is located." )
mark_as_advanced(VirtualHand_INCLUDE_DIR)

# Look for the library.

find_library( VirtualHand_Device_LIBRARY NAMES VirtualHandDevice
              PATHS ${vti_registry_file_path}/../../Development/lib/winnt_386
                    C:/Program/Immersion Corporation/VirtualHand/Development/lib/winnt_386
                    "C:/Program Files/Immersion Corporation/VirtualHand/Development/lib/winnt_386"
              DOC "Path to VirtualHandDevice library." )

find_library( VirtualHand_Core_LIBRARY NAMES VirtualHandCore
              PATHS ${vti_registry_file_path}/../../Development/lib/winnt_386
                    C:/Program/Immersion Corporation/VirtualHand/Development/lib/winnt_386
                    "C:/Program Files/Immersion Corporation/VirtualHand/Development/lib/winnt_386"
              DOC "Path to VirtualHandCore library." )

mark_as_advanced(VirtualHand_Device_LIBRARY)
mark_as_advanced(VirtualHand_Core_LIBRARY)

# Copy the results to the output variables.
if(VirtualHand_INCLUDE_DIR AND VirtualHand_Device_LIBRARY AND VirtualHand_Core_LIBRARY)
  set(VirtualHand_FOUND 1)
  set(VirtualHand_INCLUDE_DIR ${VirtualHand_INCLUDE_DIR} )
  set(VirtualHand_LIBRARIES ${VirtualHand_Device_LIBRARY} ${VirtualHand_Core_LIBRARY})
else(VirtualHand_INCLUDE_DIR AND VirtualHand_Device_LIBRARY AND VirtualHand_Core_LIBRARY)
  set(VirtualHand_FOUND 0)
  set(VirtualHand_LIBRARIES)
  set(VirtualHand_INCLUDE_DIR)
endif(VirtualHand_INCLUDE_DIR AND VirtualHand_Device_LIBRARY AND VirtualHand_Core_LIBRARY)

# Report the results.
if(NOT VirtualHand_FOUND)
  set(VirtualHand_DIR_MESSAGE
    "VirtualHand was not found. Make sure VirtualHand_Device_LIBRARY, VirtualHand_Core_LIBRARY and VirtualHand_INCLUDE_DIR are set.")
  if(VirtualHand_FIND_REQUIRED)
    message(FATAL_ERROR "${VirtualHand_DIR_MESSAGE}")
  elseif(NOT VirtualHand_FIND_QUIETLY)
    message(STATUS "${VirtualHand_DIR_MESSAGE}")
  endif(VirtualHand_FIND_REQUIRED)
endif(NOT VirtualHand_FOUND)
