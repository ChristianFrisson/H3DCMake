# - Find NiFalconAPI
# Find the native NIFALCONAPI headers and libraries.
#
#  NIFALCONAPI_INCLUDE_DIR -  where to find hdl.h, etc.
#  NIFALCONAPI_LIBRARIES    - List of libraries when using NiFalconAPI.
#  NIFALCONAPI_FOUND        - True if NiFalconAPI found.


# Look for the header file.
find_path( NIFALCONAPI_INCLUDE_DIR
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
mark_as_advanced( NIFALCONAPI_INCLUDE_DIR )

# Look for the ftdi library.
find_library( NIFALCONAPI_COMM_FTDI_LIBRARY
              NAMES nifalcon_comm_libftdi
              PATHS $ENV{FALCON_SUPPORT}/lib
                    "/Program Files/NiFalcon/lib"
                    $ENV{NOVINT_DEVICE_SUPPORT}/lib
              DOC "Path to nifalcon_comm_libftdi library." )
mark_as_advanced( NIFALCONAPI_COMM_FTDI_LIBRARY )

# Look for the usb library.
find_library( NIFALCONAPI_COMM_USB_LIBRARY
              NAMES nifalcon_comm_libusb
              PATHS $ENV{FALCON_SUPPORT}/lib
                    "/Program Files/NiFalcon/lib"
                    $ENV{NOVINT_DEVICE_SUPPORT}/lib
              DOC "Path to nifalcon_comm_libusb library." )
mark_as_advanced( NIFALCONAPI_COMM_USB_LIBRARY )

# Look for the ftd2xx library.
find_library( NIFALCONAPI_COMM_FTD2XX_LIBRARY
              NAMES nifalcon_comm_ftd2xx
              PATHS $ENV{FALCON_SUPPORT}/lib
                    "/Program Files/NiFalcon/lib"
                    $ENV{NOVINT_DEVICE_SUPPORT}/lib
              DOC "Path to nifalcon_comm_ftd2xx library." )
mark_as_advanced( NIFALCONAPI_COMM_FTD2XX_LIBRARY )

# Set to true if we have any communication library supported
set( HAVE_NI_FALCON_COMM_LIBRARY ( NIFALCONAPI_COMM_FTD2XX_LIBRARY AND ( NOT WIN32 OR NIFALCONAPI_LIBFTD2XX_LIBRARY ) ) OR NIFALCONAPI_COMM_USB_LIBRARY OR NIFALCONAPI_COMM_FTDI_LIBRARY )

# Look for the nifalcon_cpp library.
find_library( NIFALCONAPI_LIBRARY
              NAMES nifalcon
              PATHS $ENV{FALCON_SUPPORT}/lib
              "/Program Files/NiFalcon/lib"
              $ENV{NOVINT_DEVICE_SUPPORT}/lib
              DOC "Path to nifalcon library." )
mark_as_advanced( NIFALCONAPI_LIBRARY )

set( Boost_USE_MULTITHREADED ON )
set( Boost_USE_STATIC_LIBS ON )
if( WIN32 )
  if( NOT DEFINED NIFALCONAPI_BOOST_ROOT )
    set( NIFALCONAPI_BOOST_ROOT "" CACHE PATH
     "Set this variable to boost root folder if it is desired to compile with support for NiFalcon and boost could not be found." )
    mark_as_advanced( NIFALCONAPI_BOOST_ROOT )
  endif()
  if( EXISTS ${NIFALCONAPI_BOOST_ROOT} )
    set( BOOST_ROOT ${NIFALCONAPI_BOOST_ROOT} )
  endif()
endif()

find_package(Boost COMPONENTS program_options thread)

# Copy the results to the output variables.
if( NIFALCONAPI_INCLUDE_DIR AND HAVE_NI_FALCON_COMM_LIBRARY AND NIFALCONAPI_LIBRARY AND Boost_FOUND )
  set( NIFALCONAPI_FOUND 1 )

  # add the nifalcon library
  set( NIFALCONAPI_LIBRARIES ${NIFALCONAPI_LIBRARY} )

  # comm libraries, preferred order usb, ftdi, ftd2xx
  if( NIFALCONAPI_COMM_USB_LIBRARY )
     OPTION(NIFALCONAPI_LIBUSB
           "Use libusb for communication with Falcon device"
           ON)
    set( HAVE_SET_OPTION 1 )
    set( NIFALCONAPI_LIBRARIES ${NIFALCONAPI_LIBRARIES} ${NIFALCONAPI_COMM_USB_LIBRARY} )
  endif()
  
  # ftdi library 
  if( NIFALCONAPI_COMM_FTDI_LIBRARY )
    if( DEFINED HAVE_SET_OPTION )
      OPTION(NIFALCONAPI_LIBFTDI
             "Use libftdi for communication with Falcon device"
             OFF)
    else()
      OPTION(NIFALCONAPI_LIBFTDI
             "Use libftdi for communication with Falcon device"
             ON)
    endif()
       
    set( HAVE_SET_OPTION 1 )
    set( NIFALCONAPI_LIBRARIES ${NIFALCONAPI_LIBRARIES} ${NIFALCONAPI_COMM_FTDI_LIBRARY} )
  endif()

  # ftd2xx library
  if( NIFALCONAPI_COMM_FTD2XX_LIBRARY )
    if( DEFINED HAVE_SET_OPTION )
      OPTION(NIFALCONAPI_LIBFTD2XX
             "Use libftd2xx for communication with Falcon device"
           OFF )
    else()
      OPTION(NIFALCONAPI_LIBFTD2XX
             "Use libftd2xx for communication with Falcon device"
           ON )
    endif()

    set( NIFALCONAPI_LIBRARIES ${NIFALCONAPI_LIBRARIES} ${NIFALCONAPI_COMM_FTD2XX_LIBRARY} )
    
    if( WIN32 )
      if( NOT DEFINED NIFALCONAPI_LIBFTD2XX_LIBRARY )
        set( NIFALCONAPI_LIBFTD2XX_LIBRARY "" CACHE FILEPATH
             "Path to ftd2xx library." )
        mark_as_advanced( NIFALCONAPI_LIBFTD2XX_LIBRARY )
      else()
      endif()
      set( NIFALCONAPI_LIBRARIES ${NIFALCONAPI_LIBRARIES} ${NIFALCONAPI_LIBFTD2XX_LIBRARY} )
    endif()
  endif()
    
  set( NIFALCONAPI_INCLUDE_DIR ${NIFALCONAPI_INCLUDE_DIR} ${Boost_INCLUDE_DIR} )
else()
  set( NIFALCONAPI_FOUND 0 )
  set( NIFALCONAPI_LIBRARIES )
  set( NIFALCONAPI_INCLUDE_DIR )
endif()
