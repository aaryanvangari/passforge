cmake_minimum_required(VERSION 3.21)

project(PassForge LANGUAGES CXX)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${CMAKE_MODULE_PATH})

find_package(Plasma REQUIRED)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Qml)

qt_standard_project_setup()

set(KDE_INSTALL_USE_QT_SYS_PATHS TRUE)
include(KDEInstallDirs6)

if(CMAKE_INSTALL_PREFIX STREQUAL "/usr")
    set(PASSFORGE_QML_INSTALL_DIR "${KDE_INSTALL_QMLDIR}")
else()
    set(PASSFORGE_QML_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}${KDE_INSTALL_QMLDIR}")
endif()

set(PASSFORGE_PACKAGE_DIR "${CMAKE_CURRENT_BINARY_DIR}/package")

file(MAKE_DIRECTORY "${PASSFORGE_PACKAGE_DIR}/contents")

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/metadata.json"
    "${PASSFORGE_PACKAGE_DIR}/metadata.json"
    COPYONLY
)

file(GLOB PASSFORGE_UI_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/*.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/*.js"
)

file(COPY ${PASSFORGE_UI_FILES}
    DESTINATION "${PASSFORGE_PACKAGE_DIR}/contents/ui"
)

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/contents/screenshot.png"
    "${PASSFORGE_PACKAGE_DIR}/contents/screenshot.png"
    COPYONLY
)

file(COPY
    "${CMAKE_CURRENT_SOURCE_DIR}/contents/screenshots"
    DESTINATION "${PASSFORGE_PACKAGE_DIR}/contents"
)

file(COPY
    "${CMAKE_CURRENT_SOURCE_DIR}/contents/config"
    DESTINATION "${PASSFORGE_PACKAGE_DIR}/contents"
)

plasma_install_package(
    "${PASSFORGE_PACKAGE_DIR}"
    "com.opensquares.passforge"
)

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
    LIBRARY DESTINATION "${PASSFORGE_QML_INSTALL_DIR}/OpenSquares/PassForge"
)

install(
    TARGETS passforgeplugin
    LIBRARY DESTINATION "${PASSFORGE_QML_INSTALL_DIR}/OpenSquares/PassForge"
)

install(
    DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/contents/ui/OpenSquares/PassForge/"
    DESTINATION "${PASSFORGE_QML_INSTALL_DIR}/OpenSquares/PassForge"
    FILES_MATCHING
        PATTERN "qmldir"
        PATTERN "*.qmltypes"
)