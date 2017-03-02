# - Find NiFalconAPI
# Find the native NiFalconAPI headers and libraries.
#
#  NiFalconAPI_INCLUDE_DIRS - Where to find include files.
#  NiFalconAPI_LIBRARIES    - List of libraries when using NiFalconAPI.
#  NiFalconAPI_FOUND        - True if NiFalconAPI found.

include( H3DExternalSearchPath )
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

# Set to true if we have any communication library supported
set( HAVE_NI_FALCON_COMM_LIBRARY ( NiFalconAPI_comm_ftd2xx_LIBRARY AND ( NOT WIN32 OR NiFalconAPI_ftd2xx_LIBRARY ) ) OR NiFalconAPI_comm_usb_LIBRARY OR NiFalconAPI_comm_ftdi_LIBRARY )

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

find_package( Boost COMPONENTS program_options thread )

# Copy the results to the output variables.
if( NiFalconAPI_INCLUDE_DIR AND HAVE_NI_FALCON_COMM_LIBRARY AND NiFalconAPI_LIBRARY AND Boost_FOUND )
  set( NiFalconAPI_FOUND 1 )

  # add the nifalcon library
  set( NiFalconAPI_LIBRARIES ${NiFalconAPI_LIBRARY} )

  # comm libraries, preferred order usb, ftdi, ftd2xx
  if( NiFalconAPI_comm_usb_LIBRARY )
     option( NiFalconAPI_LIBUSB
           "Use libusb for communication with Falcon device"
           ON )
    set( HAVE_SET_OPTION 1 )
    set( NiFalconAPI_LIBRARIES ${NiFalconAPI_LIBRARIES} ${NiFalconAPI_comm_usb_LIBRARY} )
  endif()
  
  # ftdi library 
  if( NiFalconAPI_comm_ftdi_LIBRARY )
    if( DEFINED HAVE_SET_OPTION )
      option( NiFalconAPI_LIBFTDI
             "Use libftdi for communication with Falcon device"
             OFF )
    else()
      option( NiFalconAPI_LIBFTDI
             "Use libftdi for communication with Falcon device"
             ON )
    endif()
       
    set( HAVE_SET_OPTION 1 )
    set( NiFalconAPI_LIBRARIES ${NiFalconAPI_LIBRARIES} ${NiFalconAPI_comm_ftdi_LIBRARY} )
  endif()

  # ftd2xx library
  if( NiFalconAPI_comm_ftd2xx_LIBRARY )
    if( DEFINED HAVE_SET_OPTION )
      option( NiFalconAPI_LIBFTD2XX
             "Use libftd2xx for communication with Falcon device"
           OFF )
    else()
      option( NiFalconAPI_LIBFTD2XX
             "Use libftd2xx for communication with Falcon device"
           ON )
    endif()

    set( NiFalconAPI_LIBRARIES ${NiFalconAPI_LIBRARIES} ${NiFalconAPI_comm_ftd2xx_LIBRARY} )
    
    if( WIN32 )
      if( NOT DEFINED NiFalconAPI_ftd2xx_LIBRARY )
        set( NiFalconAPI_ftd2xx_LIBRARY "" CACHE FILEPATH
             "Path to ftd2xx library." )
        mark_as_advanced( NiFalconAPI_ftd2xx_LIBRARY )
      else()
      endif()
      set( NiFalconAPI_LIBRARIES ${NiFalconAPI_LIBRARIES} ${NiFalconAPI_ftd2xx_LIBRARY} )
    endif()
  endif()
    
  set( NiFalconAPI_INCLUDE_DIRS ${NiFalconAPI_INCLUDE_DIR} ${Boost_INCLUDE_DIR} )
else()
  set( NiFalconAPI_FOUND 0 )
  set( NiFalconAPI_LIBRARIES )
  set( NiFalconAPI_INCLUDE_DIRS )
endif()

# Report the results.
if( NOT NiFalconAPI_FOUND )
  set( NiFalconAPI_DIR_MESSAGE
       "NiFalconAPI was not found. Make sure to set NiFalconAPI_INCLUDE_DIR and the correct combination of NiFalconAPI_comm_ftd2xx_LIBRARY, NiFalconAPI_ftd2xx_LIBRARY, NiFalconAPI_comm_usb_LIBRARY, NiFalconAPI_comm_ftdi_LIBRARY and NiFalconAPI_LIBRARY." )
  if( NiFalconAPI_FIND_REQUIRED )
    message( FATAL_ERROR "${NiFalconAPI_DIR_MESSAGE}" )
  elseif( NOT NiFalconAPI_FIND_QUIETLY )
    message( STATUS "${NiFalconAPI_DIR_MESSAGE}" )
  endif()
endif()

# Backwards compatibility values set here.
set( NIFALCONAPI_INCLUDE_DIR ${NiFalconAPI_INCLUDE_DIRS} )
set( NIFALCONAPI_LIBRARIES ${NiFalconAPI_LIBRARIES} )
set( NIFALCONAPI_FOUND ${NiFalconAPI_Found} )