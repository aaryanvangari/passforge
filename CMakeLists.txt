cmake_minimum_required(VERSION 3.21)

project(PassForge LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Qml)

qt_standard_project_setup()

qt_policy(SET QTP0001 OLD)

qt_add_qml_module(passforge
    URI OpenSquares.PassForge
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/contents/ui/OpenSquares/PassForge"
    SOURCES
        src/SecureRandom.h
        src/SecureRandom.cpp
)

target_include_directories(passforge
    PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/src"
)

target_link_libraries(passforge
    PRIVATE
        Qt6::Core
        Qt6::Qml
)

set_target_properties(passforgeplugin PROPERTIES
    INSTALL_RPATH "$ORIGIN"
)

install(
    TARGETS passforge
    LIBRARY DESTINATION contents/ui/OpenSquares/PassForge
)

install(
    TARGETS passforgeplugin
    LIBRARY DESTINATION contents/ui/OpenSquares/PassForge
)

install(
    FILES contents/screenshot.png
    DESTINATION contents
)

install(
    DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/contents/ui/OpenSquares/PassForge/"
    DESTINATION contents/ui/OpenSquares/PassForge
    FILES_MATCHING
        PATTERN "qmldir"
        PATTERN "*.qmltypes"
)