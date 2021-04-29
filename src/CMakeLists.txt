cmake_minimum_required (VERSION 2.8.12)
project (SZIP_SRC C)

#-----------------------------------------------------------------------------
# Setup include Directories
#-----------------------------------------------------------------------------
INCLUDE_DIRECTORIES (${SZIP_SRC_SOURCE_DIR})
INCLUDE_DIRECTORIES (${CMAKE_BINARY_DIR})

#-----------------------------------------------------------------------------
# Define szip Library
#-----------------------------------------------------------------------------
set (SZIP_SRCS
    ${SZIP_SRC_SOURCE_DIR}/rice.c
    ${SZIP_SRC_SOURCE_DIR}/sz_api.c
    ${SZIP_SRC_SOURCE_DIR}/encoding.c
)

set (SZIP_PUBLIC_HEADERS
    ${SZIP_SRC_SOURCE_DIR}/ricehdf.h
    ${SZIP_SRC_SOURCE_DIR}/szip_adpt.h
    ${SZIP_SRC_SOURCE_DIR}/szlib.h
)


set(LIB_NAME ${SZIP_LIB_TARGET})
if(BUILD_SHARED_LIBS)
    add_library(${LIB_NAME} SHARED ${SZIP_SRCS} ${SZIP_PUBLIC_HEADERS})
    set_target_properties (${LIB_NAME} PROPERTIES
        VERSION ${LIBSZIP_VERSION}
        SOVERSION ${LIBSZIP_VERSION}
        DEFINE_SYMBOL ${SZIP_LIB_CORENAME}_EXPORTS
        COMPILE_DEFINITIONS "SZ_BUILT_AS_DYNAMIC_LIB"
        PUBLIC_HEADER "${SZIP_PUBLIC_HEADERS}"
        INTERFACE_COMPILE_DEFINITIONS SZ_BUILT_AS_DYNAMIC_LIB=1
    )
elseif(OSX_FRAMEWORK)
    add_library(${LIB_NAME} SHARED ${SZIP_SRCS} ${SZIP_PUBLIC_HEADERS})
    set_target_properties(${LIB_NAME} PROPERTIES
      FRAMEWORK TRUE
      FRAMEWORK_VERSION ${FRAMEWORK_VERSION}
      MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
      MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION}
      MACOSX_FRAMEWORK_IDENTIFIER org.libhdf.szip
      XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
      PUBLIC_HEADER "${SZIP_PUBLIC_HEADERS}"
      VERSION ${LIBSZIP_VERSION}
      SOVERSION ${LIBSZIP_VERSION}
      )
else()
    add_library(${LIB_NAME} STATIC ${SZIP_SRCS} ${SZIP_PUBLIC_HEADERS})
endif()

target_link_libraries (${SZIP_LIB_TARGET} PRIVATE ${LINK_LIBS})
set_global_variable (SZIP_LIBRARIES_TO_EXPORT ${SZIP_LIB_TARGET})

if (NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL)
  install (
      FILES ${SZIP_PUBLIC_HEADERS}
      DESTINATION ${INSTALL_INC_DIR}
      COMPONENT headers
  )
endif ()

#-----------------------------------------------------------------------------
# Add Target(s) to CMake Install for import into other projects
#-----------------------------------------------------------------------------
if (SZIP_EXPORTED_TARGETS)
  install (
        TARGETS ${SZIP_LIB_TARGET}
        EXPORT ${PACKAGE_UPPER_NAME}Targets
        RUNTIME DESTINATION ${INSTALL_BIN_DIR}
        LIBRARY DESTINATION ${INSTALL_LIB_DIR}
        ARCHIVE DESTINATION ${INSTALL_LIB_DIR}
        INCLUDES DESTINATION ${INSTALL_INC_DIR}
        FRAMEWORK DESTINATION ${INSTALL_LIB_DIR}
  )
endif ()

# Create the <Package>Config.cmake file
configure_file(${CMAKE_SOURCE_DIR}/cmake/PackageConfig.cmake.in
    ${CMAKE_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake @ONLY)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL)
    # Install the <Package>Config.cmake
    install(FILES
      ${CMAKE_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake
      DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)

    # Install the export set for use with the install-tree
    install(EXPORT ${PACKAGE_UPPER_NAME}Targets DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)
endif()
