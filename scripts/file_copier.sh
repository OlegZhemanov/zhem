#!/bin/bash

# File Copier Script
#
# This script copies files from a source directory structure to a destination directory.
# It recursively finds all files in the source directory and copies them to the destination 
# with a flattened structure (all files go directly to the destination folder).
#
# Usage:
#     bash file_copier.sh
#     or
#     ./file_copier.sh
#
# The script is configured to copy from:
#     ./library/upload/
# to:
#     ../mnt/S3_storage/photos/
#
# Example:
#     ./library/upload/f5570f9b-53c8-4294-8026-9f57f70e73b4/b4/8c/file.mp4
#     becomes:
#     ../mnt/S3_storage/photos/file.mp4
#
# You can modify the SOURCE_DIR and DEST_DIR variables to change the paths.

# Configuration
SOURCE_DIR="./library/upload/"
DEST_DIR="../mnt/S3_storage/photos"

# Statistics counters
FILES_COPIED=0
ERRORS=0
TOTAL_SIZE=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to format file size in human readable format
format_size() {
    local size=$1
    if [ $size -lt 1024 ]; then
        echo "${size} B"
    elif [ $size -lt 1048576 ]; then
        echo "$(( size / 1024 )) KB"
    elif [ $size -lt 1073741824 ]; then
        echo "$(( size / 1048576 )) MB"
    else
        echo "$(( size / 1073741824 )) GB"
    fi
}

# Function to copy files
copy_files() {
    local source_dir="$1"
    local dest_dir="$2"

    # Check if source directory exists
    if [ ! -d "$source_dir" ]; then
        echo -e "${RED}Error: Source directory '$source_dir' does not exist.${NC}"
        return 1
    fi

    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Could not create destination directory '$dest_dir'.${NC}"
        return 1
    fi

    echo -e "${BLUE}Copying files from '$source_dir' to '$dest_dir'...${NC}"
    echo "------------------------------------------------------------"
    
    # Find all files in source directory and copy them
    while IFS= read -r -d '' file; do
        # Get just the filename (basename)
        filename=$(basename "$file")
        dest_file="$dest_dir/$filename"

        # Get file size
        if [ -f "$file" ]; then
            file_size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo "0")

            # Copy file with preservation of timestamps
            if cp -p "$file" "$dest_file" 2>/dev/null; then
                FILES_COPIED=$((FILES_COPIED + 1))
                TOTAL_SIZE=$((TOTAL_SIZE + file_size))
                echo -e "${GREEN}Copied:${NC} $file -> $dest_file ($(format_size $file_size))"
            else
                ERRORS=$((ERRORS + 1))
                echo -e "${RED}Error copying $file${NC}"
            fi
        fi
    done < <(find "$source_dir" -type f -print0)

    return 0
}

# Main function
main() {
    echo "File Copier Script"
    echo "============================================================"
    echo -e "${BLUE}Source:${NC} $SOURCE_DIR"
    echo -e "${BLUE}Destination:${NC} $DEST_DIR"    echo "============================================================"
    
    # Auto-proceed with copy operation
    echo "Starting copy operation..."
    
    # Perform the copy operation
    if copy_files "$SOURCE_DIR" "$DEST_DIR"; then
        # Print summary
        echo ""
        echo "============================================================"
        echo "COPY OPERATION SUMMARY"
        echo "============================================================"
        echo -e "${GREEN}Files copied:${NC} $FILES_COPIED"
        echo -e "${BLUE}Total size copied:${NC} $(format_size $TOTAL_SIZE)"
        echo -e "${RED}Errors encountered:${NC} $ERRORS"

        if [ $ERRORS -gt 0 ]; then
            echo -e "\n${YELLOW}Some files could not be copied. Check the error messages above.${NC}"
            exit 1
        else
            echo -e "\n${GREEN}All files copied successfully!${NC}"
        fi
    else
        echo -e "${RED}Copy operation failed.${NC}"
        exit 1
    fi
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
