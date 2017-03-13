# - Find VirtualHand SDK
# Find the native VirtualHand headers and libraries.
#
#  VirtualHand_INCLUDE_DIRS - Where to find headers, etc.
#  VirtualHand_LIBRARIES    - List of libraries when using VirtualHand.
#  VirtualHand_FOUND        - True if VirtualHand found.

set( vti_registry_file_path "" )
if( NOT "$ENV{VTI_REGISTRY_FILE}" STREQUAL  "" )
  get_filename_component( vti_registry_file_path "$ENV{VTI_REGISTRY_FILE}" PATH )
endif()

# Look for the header file.
find_path( VirtualHand_INCLUDE_DIR NAMES vhandtk/vht.h
           PATHS ${vti_registry_file_path}/../../Development/include
                  C:/Program/Immersion Corporation/VirtualHand/Development/include
                  "C:/Program Files/Immersion Corporation/VirtualHand/Development/include"
           DOC "Path in which the file vhandtk/vht.h is located." )
mark_as_advanced( VirtualHand_INCLUDE_DIR )

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

mark_as_advanced( VirtualHand_Device_LIBRARY )
mark_as_advanced( VirtualHand_Core_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set VirtualHand_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( VirtualHand DEFAULT_MSG
                                   VirtualHand_Device_LIBRARY VirtualHand_Core_LIBRARY VirtualHand_INCLUDE_DIR )

set( VirtualHand_LIBRARIES ${VirtualHand_Device_LIBRARY} ${VirtualHand_Core_LIBRARY} )
set( VirtualHand_INCLUDE_DIRS ${VirtualHand_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( VirtualHand_INCLUDE_DIR ${VirtualHand_INCLUDE_DIRS} )
set( VirtualHand_FOUND ${VIRTUALHAND_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.