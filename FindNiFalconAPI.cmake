# - Find NiFalconAPI
# Find the native NiFalconAPI headers and libraries.
#
#  NiFalconAPI_INCLUDE_DIRS - Where to find include files.
#  NiFalconAPI_LIBRARIES    - List of libraries when using NiFalconAPI.
#  NiFalconAPI_FOUND        - True if NiFalconAPI found.

include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES NiFalconAPI_INCLUDE_DIR NiFalconAPI_comm_ftdi_LIBRARY NiFalconAPI_comm_usb_LIBRARY NiFalconAPI_comm_ftd2xx_LIBRARY NiFalconAPI_ftd2xx_LIBRARY
                                              OLD_VARIABLE_NAMES NIFALCONAPI_INCLUDE_DIR NIFALCONAPI_COMM_FTDI_LIBRARY NIFALCONAPI_COMM_USB_LIBRARY NIFALCONAPI_COMM_FTD2XX_LIBRARY NIFALCONAPI_LIBFTD2XX_LIBRARY
                                              DOC_STRINGS "Path in which the files falcon/comm/FalconCommLibFTDI.h, falcon/firmware/FalconFirmwareNovintSDK.h, falcon/kinematic/FalconKinematicStamper.h, falcon/util/FalconFirmwareBinaryNvent.h, falcon/core/FalconDevice.h are located."
                                                          "Path to nifalcon_comm_libftdi library."
                                                          "Path to nifalcon_comm_libusb library."
                                                          "Path to nifalcon_comm_ftd2xx library."
                                                          "Path to ftd2xx library." )
# Look for the header file.
find_path( NiFalconAPI_INCLUDE_DIR
           NAMES
           falcon/comm/FalconCommLibFTDI.h
           falcon/firmware/FalconFirmwareNovintSDK.h
           falcon/kinematic/FalconKinematicStamper.h
           falcon/util/FalconFirmwareBinaryNvent.h
           falcon/core/FalconDevice.h
           PATHS $ENV{FALCON_SUPPORT}/include
           "/Program Files/NiFalcon/include"
           $ENV{NOVINT_DEVICE_SUPPORT}/include
           DOC "Path in which the files falcon/comm/FalconCommLibFTDI.h, falcon/firmware/FalconFirmwareNovintSDK.h, falcon/kinematic/FalconKinematicStamper.h, falcon/util/FalconFirmwareBinaryNvent.h, falcon/core/FalconDevice.h are located." )
mark_as_advanced( NiFalconAPI_INCLUDE_DIR )

# Look for the ftdi library.
find_library( NiFalconAPI_comm_ftdi_LIBRARY
              NAMES nifalcon_comm_libftdi
              PATHS $ENV{FALCON_SUPPORT}/lib
                    "/Program Files/NiFalcon/lib"
                    $ENV{NOVINT_DEVICE_SUPPORT}/lib
              DOC "Path to nifalcon_comm_libftdi library." )
mark_as_advanced( NiFalconAPI_comm_ftdi_LIBRARY )

# Look for the usb library.
find_library( NiFalconAPI_comm_usb_LIBRARY
              NAMES nifalcon_comm_libusb
              PATHS $ENV{FALCON_SUPPORT}/lib
                    "/Program Files/NiFalcon/lib"
                    $ENV{NOVINT_DEVICE_SUPPORT}/lib
              DOC "Path to nifalcon_comm_libusb library." )
mark_as_advanced( NiFalconAPI_comm_usb_LIBRARY )

# Look for the ftd2xx library.
find_library( NiFalconAPI_comm_ftd2xx_LIBRARY
              NAMES nifalcon_comm_ftd2xx
              PATHS $ENV{FALCON_SUPPORT}/lib
                    "/Program Files/NiFalcon/lib"
                    $ENV{NOVINT_DEVICE_SUPPORT}/lib
              DOC "Path to nifalcon_comm_ftd2xx library." )
mark_as_advanced( NiFalconAPI_comm_ftd2xx_LIBRARY )

if( WIN32 )
  if( NOT DEFINED NiFalconAPI_ftd2xx_LIBRARY )
    set( NiFalconAPI_ftd2xx_LIBRARY NiFalconAPI_ftd2xx_LIBRARY-NOTFOUND CACHE FILEPATH "Path to ftd2xx library." )
    mark_as_advanced( NiFalconAPI_ftd2xx_LIBRARY )
  endif()
endif()

# comm libraries, preferred order usb, ftdi, ftd2xx
if( NiFalconAPI_comm_usb_LIBRARY )
  option( NiFalconAPI_LIBUSB
          "Use libusb for communication with Falcon device"
          ON )
  set( have_set_option 1 )
endif()

if( NiFalconAPI_comm_ftdi_LIBRARY )
  if( DEFINED have_set_option )
    option( NiFalconAPI_LIBFTDI
           "Use libftdi for communication with Falcon device"
           OFF )
  else()
    option( NiFalconAPI_LIBFTDI
           "Use libftdi for communication with Falcon device"
           ON )
  endif()
endif()

if( NiFalconAPI_comm_ftd2xx_LIBRARY )
  if( DEFINED have_set_option )
    option( NiFalconAPI_LIBFTD2XX
            "Use libftd2xx for communication with Falcon device"
            OFF )
  else()
    option( NiFalconAPI_LIBFTD2XX
           "Use libftd2xx for communication with Falcon device"
         ON )
  endif()
endif()

set( required_comm_lib_vars NiFalconAPI_comm_usb_LIBRARY )
if( NOT NiFalconAPI_LIBUSB )
  if( NiFalconAPI_LIBFTDI )
    set( required_comm_lib_vars NiFalconAPI_comm_ftdi_LIBRARY )
  elseif( NiFalconAPI_LIBFTD2XX )
    set( required_comm_lib_vars NiFalconAPI_comm_ftd2xx_LIBRARY )
    if( WIN32 )
      set( required_comm_lib_vars ${required_comm_lib_vars} NiFalconAPI_ftd2xx_LIBRARY )
    endif()
  endif()
endif()

# Look for the nifalcon_cpp library.
find_library( NiFalconAPI_LIBRARY
              NAMES nifalcon
              PATHS $ENV{FALCON_SUPPORT}/lib
              "/Program Files/NiFalcon/lib"
              $ENV{NOVINT_DEVICE_SUPPORT}/lib
              DOC "Path to nifalcon library." )
mark_as_advanced( NiFalconAPI_LIBRARY )

set( Boost_USE_MULTITHREADED ON )
set( Boost_USE_STATIC_LIBS ON )
if( WIN32 )
  if( NOT DEFINED NiFalconAPI_BOOST_ROOT )
    set( NiFalconAPI_BOOST_ROOT "" CACHE PATH
     "Set this variable to boost root folder if it is desired to compile with support for NiFalcon and boost could not be found." )
    mark_as_advanced( NiFalconAPI_BOOST_ROOT )
  endif()
  if( EXISTS ${NiFalconAPI_BOOST_ROOT} )
    set( BOOST_ROOT ${NiFalconAPI_BOOST_ROOT} )
  endif()
endif()

if( NiFalconAPI_INCLUDE_DIR AND NiFalconAPI_LIBRARY )
  set( search_for_Boost ON )
  foreach( comm_lib_var ${required_comm_lib_vars} )
    if( NOT ${comm_lib_var} )
      set( search_for_Boost OFF )
    endif()
  endforeach()
  if( search_for_Boost )
    find_package( Boost COMPONENTS program_options thread )
  endif()
endif()

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set NiFalconAPI_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( NiFalconAPI DEFAULT_MSG
                                   NiFalconAPI_INCLUDE_DIR NiFalconAPI_LIBRARY ${required_comm_lib_vars} Boost_FOUND )

set( NiFalconAPI_LIBRARIES ${NiFalconAPI_LIBRARY} )
foreach( comm_lib_var ${required_comm_lib_vars} )
  set( NiFalconAPI_LIBRARIES ${NiFalconAPI_LIBRARIES} ${comm_lib_var} )
endforeach()
set( NiFalconAPI_INCLUDE_DIRS ${NiFalconAPI_INCLUDE_DIR} ${Boost_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( NIFALCONAPI_INCLUDE_DIR ${NiFalconAPI_INCLUDE_DIRS} )
set( NIFALCONAPI_LIBRARIES ${NiFalconAPI_LIBRARIES} )
set( NiFalconAPI_FOUND ${NIFALCONAPI_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.