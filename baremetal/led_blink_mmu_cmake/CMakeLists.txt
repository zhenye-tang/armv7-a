cmake_minimum_required(VERSION 3.10)
project(led_blink_mmu)
enable_language(C CXX ASM)

set(LINKER_SCRIPT_PATH ${CMAKE_CURRENT_LIST_DIR}/link.lds)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set(CMAKE_C_COMPILER "/usr/bin/arm-none-eabi-gcc")
set(CMAKE_ASM_COMPILER "/usr/bin/arm-none-eabi-gcc")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -march=armv7-a -nostdlib -O0")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -march=armv7-a")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -T${LINKER_SCRIPT_PATH} -Wl,-Map=led_blink_mmu.map")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)



file(GLOB C_SOURCES *.c *.s)
include_directories(./)
# # Generate executable
add_executable(led_blink_mmu
        ${C_SOURCES}
)

