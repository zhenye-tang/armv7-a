cmake_minimum_required(VERSION 3.10)

include(cmake/cross-compile.cmake)
project(led_blink_mmu)

add_custom_target(asm_generation
    COMMAND ${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}objdump -D ${CMAKE_BINARY_DIR}/bin/${PROJECT_NAME}.elf > ${CMAKE_BINARY_DIR}/bin/${PROJECT_NAME}.s
    COMMENT "Generating assembly code from ELF"
    VERBATIM
)

add_custom_target(bin_generation
    COMMAND ${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}objcopy -O binary ${CMAKE_BINARY_DIR}/bin/${PROJECT_NAME}.elf ${CMAKE_BINARY_DIR}/bin/${PROJECT_NAME}.bin
    COMMENT "Generating binary file from ELF"
    VERBATIM
)

file(GLOB C_SOURCES *.s *.c)
include_directories(./)
add_executable(led_blink_mmu
        start.S
        ${C_SOURCES}
)

