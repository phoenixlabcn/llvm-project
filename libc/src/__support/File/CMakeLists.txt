if(NOT (TARGET libc.src.__support.threads.mutex))
  # Not all platforms have a mutex implementation. If mutex is unvailable,
  # we just skip everything about files.
  return()
endif()

add_object_library(
  file
  SRCS
    file.cpp
  HDRS
    file.h
  DEPENDS
    libc.src.__support.threads.mutex
    libc.include.errno
    libc.src.errno.errno
)

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${LIBC_TARGET_OS}_file.cpp)
  add_object_library(
    platform_file
    SRCS
      ${LIBC_TARGET_OS}_file.cpp
    DEPENDS
      .file
      libc.include.errno
      libc.include.fcntl
      libc.include.sys_syscall
      libc.src.__support.OSUtil.osutil
      libc.src.errno.errno
  )
endif()

