
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

add_library (${SZIP_LIB_TARGET} ${LIB_TYPE} ${SZIP_SRCS} ${SZIP_PUBLIC_HEADERS})
set_target_properties(${SZIP_LIB_TARGET} PROPERTIES DEFINE_SYMBOL ${SZIP_LIB_CORENAME}_EXPORTS)
target_link_libraries (${SZIP_LIB_TARGET} PRIVATE ${LINK_LIBS})
set (SZIP_LIBRARIES_TO_EXPORT ${SZIP_LIB_TARGET} PARENT_SCOPE)

if (BUILD_SHARED_LIBS)
    if (WIN32)
      set (LIBSZIP_VERSION ${SZIP_PACKAGE_VERSION_MAJOR})
    else ()
      set (LIBSZIP_VERSION ${SZIP_PACKAGE_VERSION})
    endif ()
    set_target_properties (${SZIP_LIB_TARGET} PROPERTIES VERSION ${LIBSZIP_VERSION})
    set_target_properties (${SZIP_LIB_TARGET} PROPERTIES SOVERSION ${LIBSZIP_VERSION})
endif ()

#-- Apple Specific install_name for libraries
if (APPLE)
    option (SZIP_BUILD_WITH_INSTALL_NAME "Build with library install_name set to the installation path" OFF)
    if (SZIP_BUILD_WITH_INSTALL_NAME)
      set_target_properties(SZIP_LIB_TARGET PROPERTIES
          LINK_FLAGS "-current_version ${SZIP_PACKAGE_VERSION} -compatibility_version ${SZIP_PACKAGE_VERSION}"
          INSTALL_NAME_DIR "${INSTALL_LIB_DIR}"
          BUILD_WITH_INSTALL_RPATH ${SZIP_BUILD_WITH_INSTALL_NAME}
      )
    endif ()
endif ()

#-----------------------------------------------------------------------------
# Add file(s) to CMake Install 
#-----------------------------------------------------------------------------
install (
    FILES
        ${SZIP_PUBLIC_HEADERS}
    DESTINATION
        ${INSTALL_INC_DIR}
    COMPONENT
        headers
)

#-----------------------------------------------------------------------------
# Add Target(s) to CMake Install for import into other projects
#-----------------------------------------------------------------------------
if (SZIP_EXPORTED_TARGETS)
  install (
      TARGETS
          ${SZIP_LIB_TARGET}
      EXPORT
          ${SZIP_EXPORTED_TARGETS}
      LIBRARY DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries
      ARCHIVE DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries
      RUNTIME DESTINATION ${INSTALL_BIN_DIR} COMPONENT libraries
  )
endif ()
