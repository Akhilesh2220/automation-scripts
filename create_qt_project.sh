#!/bin/bash

# -----------------------------------------------------------------------------
# Qt Project Generator Script
# Version: 1.0.1
# Description: Creates a basic Qt6 C++ project using CMake with a simple
#              "Hello World" GUI, builds and runs it automatically.
# Author: Akhilesh S
# Contact: akhileshs2220@gmail.com
# Requirements: Qt 6, CMake, g++/clang++, Bash
# -----------------------------------------------------------------------------

echo "Enter your Qt project name:"
read project_name

if [ -z "$project_name" ]; then
    echo "❌ Project name cannot be empty!"
    exit 1
fi

mkdir -p "$project_name/src"
cd "$project_name" || exit

# Create CMakeLists.txt
cat <<EOL > CMakeLists.txt
cmake_minimum_required(VERSION 3.16)
project($project_name)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD 17)

find_package(Qt6 REQUIRED COMPONENTS Widgets)

add_executable($project_name src/main.cpp)
target_link_libraries($project_name Qt6::Widgets)
EOL

# Create main.cpp
cat <<EOL > src/main.cpp
#include <QApplication>
#include <QLabel>

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    QLabel label("🎉 Hello from $project_name!");
    label.resize(300, 100);
    label.setAlignment(Qt::AlignCenter);
    label.show();
    return app.exec();
}
EOL

echo "Qt project '$project_name' created successfully!"

# Build steps
echo "Creating build directory and building the project..."
mkdir -p build
cd build || exit

echo "Note: After making code changes, you should be in the 'build' directory and run:"
echo "    cmake .."
echo "    make"
echo "    ./$(basename "$project_name")"
echo ""

cmake .. || { echo "❌ CMake failed"; exit 1; }
make || { echo "❌ Build failed"; exit 1; }

echo "Running the application now..."
./"$project_name"

