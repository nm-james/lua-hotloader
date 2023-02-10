cmake_minimum_required(VERSION 3.1.0)

project(falcons-drm LANGUAGES CXX)


set(CMAKE_CONFIGURATION_TYPES Release Debug)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(gmod-headers)
add_subdirectory(http-request)
add_subdirectory(json)


add_library(gmsv_falcons-drm_win32 SHARED)

target_sources(gmsv_falcons-drm_win32 PRIVATE module.cpp)

target_link_libraries(gmsv_falcons-drm_win32 gmod-module-base)

# set_gmod_suffix_prefix(falcons-drm)