
#-----------------------------------------------------------------------------
# Setup include Directories
#-----------------------------------------------------------------------------
include_directories (${SZIP_SRC_DIR})
include_directories (${CMAKE_BINARY_DIR})

#-----------------------------------------------------------------------------
# Define szip Library
#-----------------------------------------------------------------------------
set (SZIP_SRCS
    rice.c
    sz_api.c
    encoding.c
)

set (SZIP_PUBLIC_HEADERS
    ricehdf.h
    szip_adpt.h
    szlib.h
)

set(LIB_NAME ${SZIP_LIB_TARGET})
if(BUILD_SHARED_LIBS)
    add_library(${LIB_NAME} SHARED ${SZIP_SRCS} ${SZIP_PUBLIC_HEADERS})
    set_target_properties (${LIB_NAME} PROPERTIES
        VERSION ${LIBSZIP_VERSION}
        SOVERSION ${LIBSZIP_VERSION}
        DEFINE_SYMBOL ${SZIP_LIB_CORENAME}_EXPORTS
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

target_link_libraries (${SZIP_LIB_TARGET} ${LINK_LIBS})
set (SZIP_LIBRARIES_TO_EXPORT ${SZIP_LIB_TARGET} PARENT_SCOPE)

#-----------------------------------------------------------------------------
# Add file(s) to CMake Install
#-----------------------------------------------------------------------------
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL)
    install (
    FILES
        ${SZIP_PUBLIC_HEADERS}
    DESTINATION
        ${INSTALL_INC_DIR}
    COMPONENT
        headers
    )
endif()

#-----------------------------------------------------------------------------
# Add Target(s) to CMake Install for import into other projects
#-----------------------------------------------------------------------------
if (SZIP_EXPORTED_TARGETS)
  install (
      TARGETS
          ${SZIP_LIB_TARGET}
      EXPORT
          ${SZIP_EXPORTED_TARGETS}
      RUNTIME DESTINATION ${INSTALL_BIN_DIR} COMPONENT applications
      ARCHIVE DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries
      LIBRARY DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries
      FRAMEWORK DESTINATION ${INSTALL_LIB_DIR}
  )
endif ()
