#!/usr/bin/env python3
"""
File Copier Script

This script copies files from a source directory structure to a destination directory.
It recursively finds all files in the source directory and copies them to the destination 
with a flattened structure (all files go directly to the destination folder).

Usage:
    python file_copier.py

The script is configured to copy from:
    ./library/upload/
to:
    /mnt/S3_storage/photos/

Example:
    ./library/upload/f5570f9b-53c8-4294-8026-9f57f70e73b4/b4/8c/file.mp4
    becomes:
    /mnt/S3_storage/photos/file.mp4

You can modify the source_dir and dest_dir variables to change the paths.
"""

import os
import shutil
import sys
from pathlib import Path


def copy_files(source_dir, dest_dir):
    """
    Copy all files from source directory to destination directory with flattened structure.
    All files are copied directly to the destination folder regardless of their original subdirectory.
    
    Args:
        source_dir (str): Source directory path
        dest_dir (str): Destination directory path
    
    Returns:
        dict: Statistics about the copy operation
    """
    source_path = Path(source_dir)
    dest_path = Path(dest_dir)
    
    # Check if source directory exists
    if not source_path.exists():
        print(f"Error: Source directory '{source_dir}' does not exist.")
        return None
    
    # Create destination directory if it doesn't exist
    dest_path.mkdir(parents=True, exist_ok=True)
    
    stats = {
        'files_copied': 0,
        'directories_created': 0,
        'errors': 0,
        'total_size': 0
    }
    
    print(f"Copying files from '{source_dir}' to '{dest_dir}'...")
    print("-" * 60)
    
    # Walk through all files and directories in source
    for root, dirs, files in os.walk(source_path):
        # Copy all files in current directory
        for file in files:
            source_file = Path(root) / file
            # Extract just the filename for flattened structure
            dest_file = dest_path / file
            
            try:
                # Copy file with metadata
                shutil.copy2(source_file, dest_file)
                file_size = source_file.stat().st_size
                stats['files_copied'] += 1
                stats['total_size'] += file_size
                
                print(f"Copied: {source_file} -> {dest_file} ({file_size} bytes)")
                
            except Exception as e:
                stats['errors'] += 1
                print(f"Error copying {source_file}: {e}")
    
    return stats


def format_size(size_bytes):
    """Convert bytes to human readable format."""
    if size_bytes == 0:
        return "0 B"
    
    size_names = ["B", "KB", "MB", "GB", "TB"]
    import math
    i = int(math.floor(math.log(size_bytes, 1024)))
    p = math.pow(1024, i)
    s = round(size_bytes / p, 2)
    return f"{s} {size_names[i]}"


def main():
    """Main function to execute the file copying operation."""
    # Define source and destination directories
    source_dir = "./library/upload/"
    dest_dir = "../mnt/S3_storage/photos"
    
    print("File Copier Script")
    print("=" * 60)
    print(f"Source: {source_dir}")
    print(f"Destination: {dest_dir}")
    print("=" * 60)
    
    # Confirm operation
    try:
        response = input("Do you want to proceed with the copy operation? (y/N): ")
        if response.lower() not in ['y', 'yes']:
            print("Operation cancelled.")
            return
    except KeyboardInterrupt:
        print("\nOperation cancelled.")
        return
    
    # Perform the copy operation
    stats = copy_files(source_dir, dest_dir)
    
    if stats is None:
        sys.exit(1)
    
    # Print summary
    print("\n" + "=" * 60)
    print("COPY OPERATION SUMMARY")
    print("=" * 60)
    print(f"Files copied: {stats['files_copied']}")
    print(f"Directories created: {stats['directories_created']}")
    print(f"Total size copied: {format_size(stats['total_size'])}")
    print(f"Errors encountered: {stats['errors']}")
    
    if stats['errors'] > 0:
        print("\nSome files could not be copied. Check the error messages above.")
        sys.exit(1)
    else:
        print("\nAll files copied successfully!")


if __name__ == "__main__":
    main()
