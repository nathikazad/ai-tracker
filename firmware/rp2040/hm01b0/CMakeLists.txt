# == DO NEVER EDIT THE NEXT LINES for Raspberry Pi Pico VS Code Extension to work ==
if(WIN32)
    set(USERHOME $ENV{USERPROFILE})
else()
    set(USERHOME $ENV{HOME})
endif()
set(sdkVersion 2.0.0)
set(toolchainVersion 13_2_Rel1)
set(picotoolVersion 2.0.0)
set(picoVscode ${USERHOME}/.pico-sdk/cmake/pico-vscode.cmake)
if (EXISTS ${picoVscode})
    include(${picoVscode})
endif()
# ====================================================================================
cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)

project(pico_hm01b0)

pico_sdk_init()

add_library(pico_hm01b0 INTERFACE)

target_sources(pico_hm01b0 INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/src/hm01b0.c
)

target_include_directories(pico_hm01b0 INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/src/include
)

target_link_libraries(pico_hm01b0 INTERFACE
    cmsis_core
    hardware_dma
    hardware_i2c
    hardware_pio
    hardware_pwm
)

add_subdirectory("examples/serial_terminal")
