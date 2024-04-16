cmake_minimum_required(VERSION 3.10)

include(cmake/cross-compile.cmake)
project(led_blink_mmu)

file(GLOB C_SOURCES *.s *.c)
include_directories(./)

add_executable(${PROJECT_NAME}
        start.S
        ${C_SOURCES}
)

add_custom_command(
    TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_OBJDUMP} -d $<TARGET_FILE:${PROJECT_NAME}> > ${PROJECT_NAME}.s
    COMMENT "Generating disassembly for ${PROJECT_NAME}"
)

add_custom_command(
    TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.bin
    COMMENT "Generating binary file: ${PROJECT_NAME}.bin"
)

