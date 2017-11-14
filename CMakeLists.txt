################################################################################
# Project:  Lib szip
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nexgis.com
################################################################################
# Copyright (C) 2015,2017, NextGIS <info@nextgis.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################

cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)
PROJECT (szip)

# Some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# Set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

if(OSX_FRAMEWORK AND (BUILD_SHARED_LIBS OR BUILD_STATIC_LIBS))
  message(FATAL_ERROR "Only OSX_FRAMEWORK key or any or both BUILD_SHARED_LIBS
                       and BUILD_STATIC_LIBS keys are permitted")
endif()

if(OSX_FRAMEWORK)
  set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" CACHE INTERNAL "Installation directory for executables" FORCE)
  set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/Library/Frameworks" CACHE INTERNAL "Installation directory for libraries" FORCE)
  set(INSTALL_INC_DIR "${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Headers" CACHE INTERNAL "Installation directory for headers" FORCE)
  set(SKIP_INSTALL_HEADERS ON)
  set(SKIP_INSTALL_FILES ON)
  set(SKIP_INSTALL_EXPORT ON)
  set(CMAKE_MACOSX_RPATH ON)
  set(SKIP_INSTALL_DOCS ON)
  set(SZIP_EXTERNALLY_CONFIGURED ON)
else()
    include(GNUInstallDirs)

    set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${CMAKE_INSTALL_INCLUDEDIR} CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_SHARE_DIR ${CMAKE_INSTALL_DATADIR} CACHE INTERNAL "Installation directory for share files" FORCE)
endif()

#-----------------------------------------------------------------------------
# Define some CMake variables for use later in the project
#-----------------------------------------------------------------------------
SET (SZIP_SRC_DIR                ${CMAKE_SOURCE_DIR}/src)

#-----------------------------------------------------------------------------
# Set the core names of all the libraries
#-----------------------------------------------------------------------------
SET (SZIP_LIB_CORENAME              "szip")
SET (SZIP_TEST_LIB_CORENAME         "mcgill")

#-----------------------------------------------------------------------------
# Set the true names of all the libraries if customized by external project
#-----------------------------------------------------------------------------
SET (SZIP_LIB_NAME              "${SZIP_EXTERNAL_LIB_PREFIX}${SZIP_LIB_CORENAME}")
SET (SZIP_TEST_LIB_NAME         "${SZIP_EXTERNAL_LIB_PREFIX}${SZIP_TEST_LIB_CORENAME}")

#-----------------------------------------------------------------------------
# Set the target names of all the libraries
#-----------------------------------------------------------------------------
SET (SZIP_LIB_TARGET              ${SZIP_LIB_CORENAME})
SET (SZIP_TEST_LIB_TARGET         ${SZIP_TEST_LIB_CORENAME})

include(util)
set(SZIP_VERS_MAJOR)
set(SZIP_VERS_MINOR)
set(SZLIB_FULL_VERSION)
check_version(SZIP_VERS_MAJOR SZIP_VERS_MINOR SZLIB_FULL_VERSION)

set(VERSION "${SZIP_VERS_MAJOR}.${SZIP_VERS_MINOR}")
if(OSX_FRAMEWORK)
    set(FRAMEWORK_VERSION "${SZIP_VERS_MAJOR}")
endif()
report_version(${PROJECT_NAME} "${VERSION}")

include(configure)
configure_file(${CMAKE_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake IMMEDIATE @ONLY)

#-----------------------------------------------------------------------------
# Targets built within this project are exported at Install time for use
# by other projects using FindSZIP.
#-----------------------------------------------------------------------------
if (NOT SZIP_EXPORTED_TARGETS)
  set (SZIP_EXPORTED_TARGETS "szip-targets")
endif ()

#-----------------------------------------------------------------------------
# Option to Build Shared/Static libs, default is static
#-----------------------------------------------------------------------------
if (BUILD_SHARED_LIBS OR OSX_FRAMEWORK)
  add_definitions (-DSZ_BUILT_AS_DYNAMIC_LIB)
else ()
  if (NOT WIN32)
    # should this be a user setting : Everyone uses it anyway ?
    add_definitions (-DPIC)
  endif ()
endif ()

#-----------------------------------------------------------------------------
# When building utility executables that generate other (source) files :
# we make use of the following variables defined in the root CMakeLists.
# Certain systems may add /Debug or /Release to output paths
# and we need to call the executable from inside the CMake configuration
#-----------------------------------------------------------------------------
if (WIN32)
  add_definitions (-DBIND_TO_CURRENT_VCLIBS_VERSION=1)
  add_definitions (-D_CRT_SECURE_NO_WARNINGS)
endif ()

if (MSVC)
  set (CMAKE_MFC_FLAG 0)
endif ()

#-----------------------------------------------------------------------------
# Compiler specific flags : Shouldn't there be compiler tests for these
#-----------------------------------------------------------------------------
if (CMAKE_COMPILER_IS_GNUCC)
  set (CMAKE_C_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_C_FLAGS} -std=c99 -fomit-frame-pointer -finline-functions -fno-common")
endif ()

#-----------------------------------------------------------------------------
# This is in here to help some of the GCC based IDES like Eclipse
# and code blocks parse the compiler errors and warnings better.
#-----------------------------------------------------------------------------
if (CMAKE_COMPILER_IS_GNUCC)
  set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fmessage-length=0")
endif ()
if (CMAKE_COMPILER_IS_GNUCXX)
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fmessage-length=0")
endif ()

#-----------------------------------------------------------------------------
# All libs/tests/examples need the main include directories
#-----------------------------------------------------------------------------
include_directories (${CMAKE_BINARY_DIR} ${CMAKE_SOURCE_DIR}/src)

add_subdirectory (${CMAKE_SOURCE_DIR}/src ${CMAKE_BINARY_DIR}/src)

#-----------------------------------------------------------------------------
# Dashboard and Testing Settings
#-----------------------------------------------------------------------------
option (BUILD_TESTING "Build SZIP Unit Testing" OFF)
if (BUILD_TESTING)
  set (DART_TESTING_TIMEOUT 1200 CACHE INTEGER
       "Timeout in seconds for each test (default 1200=20minutes)")
  enable_testing ()
  include (CTest)
  add_subdirectory (${CMAKE_SOURCE_DIR}/test ${CMAKE_BINARY_DIR}/test)
endif ()

#-----------------------------------------------------------------------------
# Add file(s) to CMake Install
#-----------------------------------------------------------------------------
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL)
  install (
      FILES ${CMAKE_BINARY_DIR}/SZconfig.h
      DESTINATION ${INSTALL_INC_DIR}
      COMPONENT headers
  )
endif ()

#-----------------------------------------------------------------------------
# Add Target(s) to CMake Install for import into other projects
#-----------------------------------------------------------------------------
IF (NOT SZIP_EXTERNALLY_CONFIGURED)
  install (
      EXPORT ${SZIP_EXPORTED_TARGETS}
      DESTINATION ${INSTALL_SHARE_DIR}/cmake/SZIP
      FILE SZIP-targets.cmake
      COMPONENT configinstall
  )
endif ()

#-----------------------------------------------------------------------------
# Export all exported targets to the build tree for use by parent project
#-----------------------------------------------------------------------------
if (NOT SZIP_EXTERNALLY_CONFIGURED)
    export (
        TARGETS ${SZIP_LIBRARIES_TO_EXPORT} ${SZIP_LIB_DEPENDENCIES}
        FILE ${SZIP_LIB_CORENAME}-exports.cmake
    )
endif ()

add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

#-----------------------------------------------------------------------------
# Add Document File(s) to CMake Install
#-----------------------------------------------------------------------------
if(NOT SKIP_INSTALL_DOCS AND NOT SKIP_INSTALL_ALL)
  install (
      FILES
          ${CMAKE_SOURCE_DIR}/COPYING
          ${CMAKE_SOURCE_DIR}/README
          ${CMAKE_SOURCE_DIR}/HISTORY.txt
          ${CMAKE_SOURCE_DIR}/INSTALL
          ${CMAKE_SOURCE_DIR}/RELEASE.txt
      DESTINATION ${INSTALL_SHARE_DIR}
      COMPONENT documents
  )
endif ()

if (REGISTER_PACKAGE)
    export(TARGETS ${SZIP_LIBRARIES_TO_EXPORT} FILE ${PROJECT_NAME}-exports.cmake)

    set(EXPORT_PACKAGE_NAME ${PROJECT_NAME})
    string(TOUPPER ${EXPORT_PACKAGE_NAME} EXPORT_PACKAGE_NAME_UPPER)
    set(EXPORT_PACKAGE_LIB_NAME ${PROJECT_NAME})

    export(PACKAGE ${EXPORT_PACKAGE_NAME})

    include(CMakePackageConfigHelpers)
    configure_package_config_file(
        ${CMAKE_SOURCE_DIR}/cmake/PackageConfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/${EXPORT_PACKAGE_NAME}Config.cmake
        INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR} )
    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${EXPORT_PACKAGE_NAME}ConfigVersion.cmake
        VERSION ${VERSION}
        COMPATIBILITY AnyNewerVersion )
else()
    export(TARGETS ${SZIP_LIBRARIES_TO_EXPORT} FILE ${PROJECT_NAME}-exports.cmake EXPORT_LINK_INTERFACE_LIBRARIES)
endif()

#-----------------------------------------------------------------------------
# Set the cpack variables
#-----------------------------------------------------------------------------
if (NOT SZIP_EXTERNALLY_CONFIGURED)
  set (CPACK_PACKAGE_VENDOR "HDF Group")
  set (CPACK_PACKAGE_NAME "${SZIP_PACKAGE_NAME}")
  set (CPACK_PACKAGE_INSTALL_DIRECTORY "${SZIP_PACKAGE_NAME}")
  set (CPACK_PACKAGE_VERSION "${SZIP_PACKAGE_VERSION}")
  set (CPACK_PACKAGE_VERSION_MAJOR "${SZIP_PACKAGE_VERSION_MAJOR}")
  set (CPACK_PACKAGE_VERSION_MINOR "${SZIP_PACKAGE_VERSION_MINOR}")
  set (CPACK_PACKAGE_VERSION_PATCH "")
  set (CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/RELEASE.txt")
  set (CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/COPYING")
  set (CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/RELEASE.txt")
  set (CPACK_PACKAGE_RELOCATABLE TRUE)
  if (WIN32)
    set (CPACK_NSIS_CONTACT "help@hdfgroup.org")
    set (CPACK_NSIS_MODIFY_PATH ON)
    set (CPACK_NSIS_PACKAGE_NAME "SZIP ${SZIP_PACKAGE_VERSION}")
  else ()
    set (CPACK_RPM_COMPONENT_INSTALL ON)
  endif ()
  set (CPACK_MONOLITHIC_INSTALL ON)

  include (InstallRequiredSystemLibraries)

  set (CPACK_INSTALL_CMAKE_PROJECTS "${CMAKE_BINARY_DIR};SZIP;ALL;/")

  include (CPack)

  cpack_add_component (libraries
      DISPLAY_NAME "SZIP Libraries"
      GROUP Runtime
  )
  cpack_add_component (headers
      DISPLAY_NAME "SZIP Headers"
      DEPENDS libraries
      GROUP Development
  )
  cpack_add_component (hdfdocuments
      DISPLAY_NAME "SZIP Documents"
      GROUP Documents
  )
  cpack_add_component (configinstall
      DISPLAY_NAME "SZIP CMake files"
      DEPENDS libraries
      GROUP Development
  )

endif ()
