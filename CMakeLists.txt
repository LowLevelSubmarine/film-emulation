cmake_minimum_required(VERSION 3.15)
project(film_emulation C)

find_package(OpenCV)

add_executable(${PROJECT_NAME} src/main.c)
target_link_libraries(${PROJECT_NAME} opencv::opencv)
