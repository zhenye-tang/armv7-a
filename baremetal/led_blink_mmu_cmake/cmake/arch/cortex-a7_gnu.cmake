set(ARCH_FLAGS " \
  -g \
  -Wall \
  -march=armv7-a \
  -nostdlib \
  -O0 \
")

set(LINK_FLAGS "\
  -T${CMAKE_CURRENT_LIST_DIR}/../link_script/${ARCH}.lds \
  -Wl,-Map=${ARCH}.map\
")

include(${CMAKE_CURRENT_LIST_DIR}/../toolchain/arm-none-eabi-gcc.cmake)

set(CMAKE_SYSTEM_PROCESSOR Cortex-A7)

