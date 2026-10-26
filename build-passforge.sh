#!/usr/bin/env bash

set -euo pipefail
# set -x

# Resolve the repository directory from this script's location.
PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"

echo "PROJECT_DIR: "$PROJECT_DIR
echo "BUILD_DIR: "$BUILD_DIR

echo "Configuring PassForge..."
cmake -S "$PROJECT_DIR" -B "$BUILD_DIR" -DCMAKE_INSTALL_PREFIX="$BUILD_DIR/dev-install"

echo
echo "Building PassForge..."
cmake --build "$BUILD_DIR"

echo
echo "Installing PassForge QML module..."
cmake --install "$BUILD_DIR"

echo
echo "PassForge build and installation completed successfully."