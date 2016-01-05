cmake_minimum_required (VERSION 2.8)
project (SZIP_TEST)

#-----------------------------------------------------------------------------
# Setup include Directories
#-----------------------------------------------------------------------------
include_directories (${CMAKE_SOURCE_DIR})

#-----------------------------------------------------------------------------
# Define Sources
#-----------------------------------------------------------------------------
set (TEST_LIB_SRCS
    mcgill.c
)

set (TEST_LIB_HEADERS
    mcgill.h
)

add_library (${SZIP_TEST_LIB_TARGET} ${LIB_TYPE} ${TEST_LIB_SRCS} ${TEST_LIB_HEADERS})
target_link_libraries (${SZIP_TEST_LIB_TARGET} ${SZIP_LIB_TARGET})

#-- Adding test 
if (SZIP_ENABLE_ENCODING)
  add_executable (gentest gentest.c)
  if (WIN32 AND NOT MINGW)
    if (BUILD_SHARED_LIBS)
      set_target_properties (gentest PROPERTIES OUTPUT_NAME "gentestdll")
    endif ()
  endif ()  
  if (WIN32)
    if (MSVC)
      if (NOT BUILD_SHARED_LIBS)
        set_target_properties (gentest
            PROPERTIES
                LINK_FLAGS "/NODEFAULTLIB:MSVCRT"
        ) 
      endif ()
    endif ()
  endif ()
  target_link_libraries (gentest ${SZIP_TEST_LIB_TARGET} ${SZIP_LIB_TARGET})

  add_test (NAME gentest COMMAND $<TARGET_FILE:gentest>)
endif ()
