################################################################################
# Project:  Lib szip
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nexgis.com
################################################################################
# Copyright (C) 2015, NextGIS <info@nextgis.com>
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

include (CheckSymbolExists)
include (CheckIncludeFiles)
include (CheckLibraryExists) 
include (CheckFunctionExists)
include (TestBigEndian)
include (CheckTypeSize)

check_include_files ("ctype.h" HAVE_CTYPE_H)
check_include_files ("stdlib.h" HAVE_STDLIB_H)

if (HAVE_CTYPE_H AND HAVE_STDLIB_H)
    set(STDC_HEADERS 1)
endif ()


check_include_files ("string.h"        HAVE_STRING_H)
check_include_files ("strings.h"       HAVE_STRINGS_H)
check_include_files ("memory.h"        HAVE_MEMORY_H)
check_include_files ("dlfcn.h"         HAVE_DLFCN_H)
check_include_files ("fcntl.h"         HAVE_FCNTL_H)
check_include_files ("inttypes.h"      HAVE_INTTYPES_H)
check_include_files ("stdint.h"        HAVE_STDINT_H)
check_include_files ("sys/stat.h"      HAVE_SYS_STAT_H)
check_include_files ("sys/types.h"     HAVE_SYS_TYPES_H)
check_include_files ("unistd.h"        HAVE_UNISTD_H)

check_function_exists (_doprnt         HAVE_DOPRNT)
check_function_exists (memset          HAVE_MEMSET)
check_function_exists (vprintf         HAVE_VPRINTF)

#-----------------------------------------------------------------------------
# Option to enable encoding
#-----------------------------------------------------------------------------
option (SZIP_ENABLE_ENCODING  "Enable SZIP Encoding" ON)
if (SZIP_ENABLE_ENCODING)
  set (HAVE_ENCODING 1)
  set (SZIP_HAVE_ENCODING 1)
endif (SZIP_ENABLE_ENCODING)

#-----------------------------------------------------------------------------
set (SZIP_PACKAGE "szip")
set (SZIP_PACKAGE_NAME "SZIP")
set (SZIP_PACKAGE_VERSION "${VERSION}")
set (SZIP_PACKAGE_VERSION_MAJOR "${SZIP_VERS_MAJOR}")
set (SZIP_PACKAGE_VERSION_MINOR "${SZIP_VERS_MINOR}")
set (SZIP_PACKAGE_STRING "${SZIP_PACKAGE_NAME} ${SZIP_PACKAGE_VERSION}")
set (SZIP_PACKAGE_TARNAME "szip")
set (SZIP_PACKAGE_URL "http://www.hdfgroup.org")
set (SZIP_PACKAGE_BUGREPORT "help@hdfgroup.org")

if (BUILD_SHARED_LIBS)
    set (SZIP_BUILT_AS_DYNAMIC_LIB 1)
endif()

configure_file(${CMAKE_MODULE_PATH}/SZconfig.h.cmakein ${CMAKE_CURRENT_BINARY_DIR}/SZconfig.h IMMEDIATE @ONLY)
add_definitions (-DHAVE_CONFIG_H)

