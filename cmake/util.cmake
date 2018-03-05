################################################################################
# Project:  Lib TIFF
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

function(check_version major minor rel full)

    #-----------------------------------------------------------------------------
    # parse the full version number from szlib.h and include in SZLIB_FULL_VERSION
    #-----------------------------------------------------------------------------
    set(VERSION_FILE ${SZIP_SRC_DIR}/szlib.h)
    file (READ ${VERSION_FILE} _szlib_h_contents)
    string (REGEX REPLACE ".*#define[ \t]+SZLIB_VERSION[ \t]+\"([0-9]*).*$"
        "\\1" SZIP_VERS_MAJOR ${_szlib_h_contents})
    string (REGEX REPLACE ".*#define[ \t]+SZLIB_VERSION[ \t]+\"[0-9]*.([0-9]*).*\".*$"
        "\\1" SZIP_VERS_MINOR ${_szlib_h_contents})
    string (REGEX REPLACE ".*#define[ \t]+SZLIB_VERSION[ \t]+\"[0-9]*.[0-9]*.([0-9]*)\".*$"
        "\\1" SZIP_VERS_RELEASE ${_szlib_h_contents})
    string (REGEX REPLACE ".*#define[ \t]+SZLIB_VERSION[ \t]+\"([0-9A-Za-z.]+)\".*"
        "\\1" SZLIB_FULL_VERSION ${_szlib_h_contents})

    set(${major} ${SZIP_VERS_MAJOR} PARENT_SCOPE)
    set(${minor} ${SZIP_VERS_MINOR} PARENT_SCOPE)
    set(${rel} ${SZIP_VERS_RELEASE} PARENT_SCOPE)
    set(${full} ${SZLIB_FULL_VERSION} PARENT_SCOPE)

    # Store version string in file for installer needs
    file(TIMESTAMP ${VERSION_FILE} VERSION_DATETIME "%Y-%m-%d %H:%M:%S" UTC)
    set(VERSION ${SZIP_VERS_MAJOR}.${SZIP_VERS_MINOR}.${SZIP_VERS_RELEASE})
    get_cpack_filename(${VERSION} PROJECT_CPACK_FILENAME)
    file(WRITE ${CMAKE_BINARY_DIR}/version.str "${VERSION}\n${VERSION_DATETIME}\n${PROJECT_CPACK_FILENAME}")

endfunction(check_version)


function(report_version name ver)

    string(ASCII 27 Esc)
    set(BoldYellow  "${Esc}[1;33m")
    set(ColourReset "${Esc}[m")

    message("${BoldYellow}${name} version ${ver}${ColourReset}")

endfunction()


function(get_cpack_filename ver name)
    get_compiler_version(COMPILER)
    if(BUILD_STATIC_LIBS)
        set(STATIC_PREFIX "static-")
    endif()

    if(BUILD_SHARED_LIBS OR OSX_FRAMEWORK)
        set(${name} ${PROJECT_NAME}-${STATIC_PREFIX}${ver}-${COMPILER} PARENT_SCOPE)
    else()
        set(${name} ${PROJECT_NAME}-${STATIC_PREFIX}${ver}-STATIC-${COMPILER} PARENT_SCOPE)
    endif()
endfunction()

function(get_compiler_version ver)
    ## Limit compiler version to 2 or 1 digits
    string(REPLACE "." ";" VERSION_LIST ${CMAKE_C_COMPILER_VERSION})
    list(LENGTH VERSION_LIST VERSION_LIST_LEN)
    if(VERSION_LIST_LEN GREATER 2 OR VERSION_LIST_LEN EQUAL 2)
        list(GET VERSION_LIST 0 COMPILER_VERSION_MAJOR)
        list(GET VERSION_LIST 1 COMPILER_VERSION_MINOR)
        set(COMPILER ${CMAKE_C_COMPILER_ID}-${COMPILER_VERSION_MAJOR}.${COMPILER_VERSION_MINOR})
    else()
        set(COMPILER ${CMAKE_C_COMPILER_ID}-${CMAKE_C_COMPILER_VERSION})
    endif()

    if(WIN32)
        if(CMAKE_CL_64)
            set(COMPILER "${COMPILER}-64bit")
        endif()
    endif()

    set(${ver} ${COMPILER} PARENT_SCOPE)
endfunction()
