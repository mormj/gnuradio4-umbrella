cmake_minimum_required(VERSION 3.27)

project(integration_smoke LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(gnuradio4 CONFIG REQUIRED)
find_package(gnuradio4Algorithm CONFIG REQUIRED)
find_package(gnuradio4Blocks CONFIG REQUIRED)
find_package(GnuRadioBlockLib CONFIG REQUIRED)

add_executable(integration_smoke main.cpp)
target_link_libraries(
  integration_smoke
  PRIVATE gnuradio4::gnuradio-core
          gnuradio4::gnuradio-blocklib-core
          gnuradio4::gnuradio-algorithm
          gnuradio4::gr-basic
          gnuradio4::gr-testing)

