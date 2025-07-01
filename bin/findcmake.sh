#!/usr/bin/env bash

# CMake Package Finder
# This script searches for a package in various forms and generates boilerplate CMake code

# Check if package name is provided
if [ "$#" -lt 1 ]; then
	echo "Usage: $0 <package_name>"
	exit 1
fi

PACKAGE_NAME=$1
ORIGINAL_PACKAGE=$PACKAGE_NAME
OUTPUT_FILE="cmake_package_results.txt"

# Clear previous results
>"$OUTPUT_FILE"

echo "==============================================" | tee -a "$OUTPUT_FILE"
echo "CMake Package Finder - Searching for: $PACKAGE_NAME" | tee -a "$OUTPUT_FILE"
echo "==============================================" | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# Create temporary CMake project
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR" || exit 1

# Function to test a package and record results
test_package() {
	local package_name=$1
	local variation_desc=$2

	echo "Trying: $package_name ($variation_desc)" | tee -a "$OUTPUT_FILE"

	# Create test CMake file
	cat >CMakeLists.txt <<EOF
cmake_minimum_required(VERSION 3.10)
project(PackageTest)

find_package($package_name QUIET)

message(STATUS "Package found: \${${package_name}_FOUND}")
if(${package_name}_FOUND)
    message(STATUS "Version: \${${package_name}_VERSION}")
    message(STATUS "Include dirs: \${${package_name}_INCLUDE_DIRS}")
    if(DEFINED ${package_name}_LIBRARIES)
        message(STATUS "Libraries: \${${package_name}_LIBRARIES}")
    endif()
    if(DEFINED ${package_name}_LIBRARY)
        message(STATUS "Library: \${${package_name}_LIBRARY}")
    endif()
    # Try common variable names
    if(DEFINED ${package_name}_INCLUDE_DIR)
        message(STATUS "Include dir: \${${package_name}_INCLUDE_DIR}")
    endif()
    get_directory_property(vars VARIABLES)
    foreach(var \${vars})
        string(FIND "\${var}" "${package_name}" pos)
        if(NOT \${pos} EQUAL -1)
            message(STATUS "Variable: \${var}=\${\${var}}")
        endif()
    endforeach()
endif()
EOF

	# Run CMake to test package
	OUTPUT=$(cmake . 2>&1)

	# Check if package was found
	if echo "$OUTPUT" | grep -q "Package found: 1"; then
		echo "✅ FOUND! $package_name ($variation_desc)" | tee -a "$OUTPUT_FILE"
		echo "$OUTPUT" | grep "STATUS" | tee -a "$OUTPUT_FILE"
		echo "" | tee -a "$OUTPUT_FILE"

		# Generate boilerplate code section
		echo "==== CMake Boilerplate for $package_name ====" >>"$OUTPUT_FILE"
		cat >>"$OUTPUT_FILE" <<EOF
# Find and link $package_name
find_package($package_name REQUIRED)

# Add include directories
include_directories(\${${package_name}_INCLUDE_DIRS})

# Link libraries (in target_link_libraries)
# target_link_libraries(your_target \${${package_name}_LIBRARIES})

EOF
		echo "============================================" >>"$OUTPUT_FILE"
		echo "" >>"$OUTPUT_FILE"

		return 0
	else
		echo "❌ Not found" | tee -a "$OUTPUT_FILE"
		echo "" | tee -a "$OUTPUT_FILE"
		return 1
	fi
}

# Try different variations of the package name
variations=(
	"$PACKAGE_NAME:Original name"
	"$(echo "$PACKAGE_NAME" | tr '[:lower:]' '[:upper:]'):All uppercase"
	"$(echo "$PACKAGE_NAME" | tr '[:upper:]' '[:lower:]'):All lowercase"
	"$(echo "$PACKAGE_NAME" | sed 's/_//g'):Without underscores"
	"$(echo "$PACKAGE_NAME" | sed 's/-/_/g'):Replace hyphens with underscores"
	"$(echo "$PACKAGE_NAME" | sed 's/_/-/g'):Replace underscores with hyphens"
	"lib$PACKAGE_NAME:With lib prefix"
	"${PACKAGE_NAME}lib:With lib suffix"
	"$(echo "$PACKAGE_NAME" | sed 's/lib//'):Without lib prefix"
	"$(echo "$PACKAGE_NAME" | sed -r 's/([a-z])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]'):Snake case"
	"$(echo "$PACKAGE_NAME" | sed -r 's/_([a-z])/\U\1/g'):Camel case"
)

# Add more variations with first letter capitalized
for suffix in "" "Lib" "Library"; do
	name="$(echo "$PACKAGE_NAME" | sed 's/.*/\u&/'):Capitalized${suffix:+ with $suffix suffix}"
	variations+=("$(echo "$PACKAGE_NAME" | sed 's/.*/\u&/')$suffix:$name")
done

# Try each variation
success=0
for variation in "${variations[@]}"; do
	IFS=: read -r name description <<<"$variation"
	if test_package "$name" "$description"; then
		success=1
	fi
done

# Try with CONFIG mode explicitly
if test_package "$ORIGINAL_PACKAGE CONFIG" "Original with CONFIG mode"; then
	success=1
fi

# Try with REQUIRED flag to see possible error messages
echo "Attempting with REQUIRED flag to see detailed errors..." | tee -a "$OUTPUT_FILE"
cat >CMakeLists.txt <<EOF
cmake_minimum_required(VERSION 3.10)
project(PackageTest)
find_package($ORIGINAL_PACKAGE REQUIRED)
EOF

OUTPUT=$(cmake . 2>&1 || true)
echo "$OUTPUT" | grep -i "error\|could not find\|not found" | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# Clean up
cd - >/dev/null
rm -rf "$TEMP_DIR"

if [ $success -eq 1 ]; then
	echo "✅ At least one variation of the package was found!" | tee -a "$OUTPUT_FILE"
	echo "Check $OUTPUT_FILE for detailed results and CMake boilerplate." | tee -a "$OUTPUT_FILE"
else
	echo "❌ No variations of the package were found." | tee -a "$OUTPUT_FILE"
	echo "" | tee -a "$OUTPUT_FILE"
	echo "Suggestions:" | tee -a "$OUTPUT_FILE"
	echo "1. Make sure the package is installed on your system." | tee -a "$OUTPUT_FILE"
	echo "2. Check if it provides a CMake config file or module." | tee -a "$OUTPUT_FILE"
	echo "3. Try setting CMAKE_PREFIX_PATH to include the package install location." | tee -a "$OUTPUT_FILE"
	echo "4. Look for the correct package name in the package documentation." | tee -a "$OUTPUT_FILE"
fi

echo "" | tee -a "$OUTPUT_FILE"
echo "Results saved to $OUTPUT_FILE" | tee -a "$OUTPUT_FILE"
