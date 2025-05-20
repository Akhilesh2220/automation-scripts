#!/bin/bash

# -----------------------------------------------------------------------------
# Qt Project Generator Script
# Version: 1.0.3
# Author: Akhilesh S
# Contact: akhileshs2220@gmail.com
# -----------------------------------------------------------------------------

SCRIPT_NAME="qt-create"
SCRIPT_PATH="$(realpath "$0")"

get_global_bin_dir() {
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Darwin*)    echo "/usr/local/bin" ;; # macOS
        Linux*)     echo "/usr/local/bin" ;; # Linux
        *)          echo "/usr/local/bin" ;; # fallback
    esac
}

# Check if script is globally accessible
if command -v "$SCRIPT_NAME" >/dev/null 2>&1; then
    echo "Hey there!"
else
    echo "Script '$SCRIPT_NAME' is NOT accessible globally."

    read -rp "Do you want to install '$SCRIPT_NAME' globally? (y/n) " answer
    case "$answer" in
        [Yy]* )
            BIN_DIR=$(get_global_bin_dir)
            echo "Installing to $BIN_DIR ..."

            if [[ "$SCRIPT_PATH" != "$BIN_DIR/$SCRIPT_NAME" ]]; then
                sudo cp "$SCRIPT_PATH" "$BIN_DIR/$SCRIPT_NAME"
                sudo chmod +x "$BIN_DIR/$SCRIPT_NAME"
                echo "Moved script to $BIN_DIR/$SCRIPT_NAME and made it executable."
            else
                echo "Script already in global bin directory."
            fi

            CURRENT_SHELL=$(basename "$SHELL")
            if [[ "$CURRENT_SHELL" == "zsh" ]]; then
                SHELL_RC="$HOME/.zshrc"
            elif [[ "$CURRENT_SHELL" == "bash" ]]; then
                SHELL_RC="$HOME/.bashrc"
            else
                SHELL_RC=""
            fi

            if [[ -f "$SHELL_RC" ]]; then
                echo "Sourcing $SHELL_RC to refresh PATH..."
                CUR_DIR="$(pwd)"
                # shellcheck disable=SC1090
                source "$SHELL_RC"
                cd "$CUR_DIR" || exit
            fi

            echo "Installation complete. You can now run '$SCRIPT_NAME' from anywhere."
            echo "Please run the script again."
            exit 0
            ;;
        * )
            echo "Continuing without global installation."
            ;;
    esac
fi

echo "Enter your Qt project name:"
read project_name

if [ -z "$project_name" ]; then
    echo "Project name cannot be empty!"
    exit 1
fi

if [ -d "$project_name" ]; then
    echo "Error: Project directory '$project_name' already exists in the current directory."
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

# Create src/main.cpp
cat <<EOL > src/main.cpp
#include <QApplication>
#include <QLabel>

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    QLabel label("Hello from $project_name!");
    label.resize(300, 100);
    label.setAlignment(Qt::AlignCenter);
    label.show();
    return app.exec();
}
EOL

echo "Qt project '$project_name' created successfully."

mkdir -p build
cd build || exit

echo "Running cmake .."
cmake .. || { echo "CMake failed"; exit 1; }

echo "Running make"
make || { echo "Build failed"; exit 1; }

echo "Running the application:"
./"$project_name"

echo "Exiting..."
echo "You can now run the application from the build directory."
echo "cd $project_name/build"
echo "cmkake .."
echo "make"
echo "Run the application using ./$project_name"
