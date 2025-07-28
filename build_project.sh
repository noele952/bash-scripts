#!/bin/bash

# Directory to build (default current directory)
BUILD_DIR="${1:-.}"

echo "🔨 Starting build in directory: $BUILD_DIR"

# Check if directory exists
if [ ! -d "$BUILD_DIR" ]; then
  echo "❌ Directory not found: $BUILD_DIR"
  exit 1
fi

cd "$BUILD_DIR" || exit 1

# If Makefile exists, use make
if [ -f "Makefile" ] || [ -f "makefile" ]; then
  echo "Makefile found. Running 'make'..."
  make
  BUILD_STATUS=$?
else
  # Find all .c files
  C_FILES=(*.c)
  if [ ${#C_FILES[@]} -eq 0 ]; then
    echo "❌ No C source files found to compile."
    exit 1
  fi

  # Compile all .c files into a single executable named 'program'
  echo "No Makefile found. Compiling all .c files with gcc..."
  gcc -o program "${C_FILES[@]}"
  BUILD_STATUS=$?
fi

if [ $BUILD_STATUS -eq 0 ]; then
  echo "✅ Build successful."
else
  echo "❌ Build failed."
fi

exit $BUILD_STATUS
