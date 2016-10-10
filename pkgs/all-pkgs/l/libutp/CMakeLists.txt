cmake_minimum_required(VERSION 2.8)
project(utp CXX)

add_definitions(-DPOSIX)

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/utp.pc.in
  ${CMAKE_CURRENT_BINARY_DIR}/utp.pc
  @ONLY
)

include_directories(.)

add_library(${PROJECT_NAME} SHARED
  utp_api.cpp
  utp_callbacks.cpp
  utp_hash.cpp
  utp_internal.cpp
  utp_packedsockaddr.cpp
  utp_utils.cpp
  ${${PROJECT_NAME}_ADD_SOURCES}
)

install(TARGETS ${PROJECT_NAME} DESTINATION lib)
install(
  FILES
    utp.h
    utp_types.h
  DESTINATION
    include/libutp
)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/utp.pc DESTINATION lib/pkgconfig)
