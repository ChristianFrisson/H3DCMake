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

# Look for the nifalcon_cpp library.
find_library( NiFalconAPI_LIBRARY
              NAMES nifalcon
              PATHS $ENV{FALCON_SUPPORT}/lib
              "/Program Files/NiFalcon/lib"
              $ENV{NOVINT_DEVICE_SUPPORT}/lib
              DOC "Path to nifalcon library." )
mark_as_advanced( NiFalconAPI_LIBRARY )
message("NiFalconAPI_LIBRARY ${NiFalconAPI_LIBRARY}")

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set NiFalconAPI_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( NiFalconAPI DEFAULT_MSG
                                   NiFalconAPI_INCLUDE_DIR NiFalconAPI_LIBRARY )#${required_comm_lib_vars} Boost_FOUND )

set( NiFalconAPI_LIBRARIES ${NiFalconAPI_LIBRARY} )
set( NiFalconAPI_INCLUDE_DIRS ${NiFalconAPI_INCLUDE_DIR})# ${Boost_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( NIFALCONAPI_INCLUDE_DIR ${NiFalconAPI_INCLUDE_DIRS} )
set( NIFALCONAPI_LIBRARIES ${NiFalconAPI_LIBRARIES} )
set( NiFalconAPI_FOUND ${NIFALCONAPI_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.