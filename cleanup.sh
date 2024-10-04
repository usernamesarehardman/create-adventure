#!/bin/bash


# Function to clean up the created directories and files
cleanup() {
	
	# Initialize local variables
	# Update safe_list when adding new permanent files to the directory
	local target_dir=$(pwd)
	local safe_list=(
		"adventure_time.txt" "cleanup.sh" "create_adventure.sh" "README.md" "visual_guide.mmd"
		)
	
	# cd to target directory to perform cleaning
	cd "$target_dir" || { echo "ERROR: Directory not found. Exiting with code 1..."; exit 1; }
	
	# Cycles through directories removing files unless they are on the safe_list
	for item in *; do
	if [[ ! " ${safe_list[@]} " =~ " $item " ]]; then
		echo "Deleting: $item"
		rm -rf "$item"
	else
		echo "Keeping: $item"
	fi
done
}

main () {
	cleanup
	echo "Cleanup completed. All created directories and files have been deleted."
}

main
