#!/bin/bash

# Get the current directory name (project name)
PROJECT_NAME="${PWD##*/}"

# Check if 'build' directory exists
if [ ! -d build ]; then
  mkdir build
fi

cd build

# Run cmake and make
cmake ..
make

# Run the executable by project name
./"$PROJECT_NAME"

