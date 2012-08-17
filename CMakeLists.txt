cmake_minimum_required(VERSION 2.8)
project(fme)

set(executable_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
)

set(FRAMEWORK_SOUND ON)
set(FRAMEWORK_GRAPHICS ON)
set(FRAMEWORK_XML ON)
set(FRAMEWORK_NET ON)
include(../otclient/src/framework/CMakeLists.txt)
include(../otclient/src/otclient/CMakeLists.txt)
add_executable(fme ${framework_SOURCES} ${otclient_SOURCES} ${executable_SOURCES})
target_link_libraries(fme ${framework_LIBRARIES})
