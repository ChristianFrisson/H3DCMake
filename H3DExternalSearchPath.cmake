# Contains a function which can be used to get default search paths
# for include and lib directory on windows.

message( AUTHOR_WARNING "H3DExternalSearchPath.cmake is deprecated. Change from include( H3DExternalSearchPath ) to include( H3DCommonFindModuleFunctions ) and you might also need include H3DUtilityFunctions." )
include( H3DUtilityFunctions )
include( H3DCommonFindModuleFunctions )