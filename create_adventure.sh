#!/bin/bash

# ----------------------------------------
# Create Your Own Adventure Script
# ----------------------------------------

Author="William Freeman"
Description="This script creates a custom adventure."
Version="1.1"
Date=$(date) # 10/4/2024 - last edit

# ----------------------------------------
# Function Definitions
# ----------------------------------------

# Function to run opening credits
opening_credits() {
	
	# Prints opening credits to terminal
	echo -e "\nCreating a new adventure...\n"
	if [ -f "adventure_time.txt" ]; then
		cat adventure_time.txt
	else
		# Error handling for missing logo file
		echo "Welcome to... ADVENTURE TIME!"
		echo $Author
		echo $Description
		echo $Version
		echo $Date
		echo "You are missing file: adventure_time.txt"
	fi
}

# Initializes the program
main_menu() {
	
	# Main menu sequence
	echo "Press any key to begin..."
	read -n 1 -s
}

# Function to generate a dynamically lengthed line
line() {

	# Reads the width of the users terminal
	read rows cols < <(stty size)
	printf '%*s\n' "$cols" '' | tr ' ' '#'
	echo
}

# Validates that the total depth of directories is between 2 and 10.
validate_depth() {

	# Initialize local variables
	local valid=false
	local prompt_message=$1
	local error_range="Invalid choice, too high/low. Select a number between 2 and 10: "
	local error_type="Invalid choice, not a number. Select a number between 2 and 10: "
	
	# Verifies that the input is a number and also between 2 and 10,
	# if not, prints appropriate error message.
	echo -n "$prompt_message"
	while [ "$valid" = false ]; do
		read input
		if [[ "$input" =~ ^[0-9]+$ ]]; then
			if [ "$input" -ge 2 ] && [ "$input" -le 10 ]; then
				valid=true
				echo -e "\nChosen depth: $input"
			else
				echo -n "ERROR: $error_range"
			fi
		else
			echo -n "ERROR: $error_type"
		fi
	done
	return $input
}

# Generic confirmation function
confirm() {
	return_to_parent() {
	
		# Initialize local variables
		local parent_function=$1
		
		# Returns user to parent function if it exists
		if [[ -n "$parent_function" ]]; then
			$parent_function
		else
			# Error handling - no parent function detected
			echo "A critical error has occurred. Exiting with code 1..."
			exit 1
		fi
	}
	
	# Initialize local variables
	local prompt_message=$1
	local parent_function=$2
	local max_attempts=3
	local attempt=0
	
	# Limits the maximum amount of invalid attempts
	while [[ $attempt -lt $max_attempts ]]; do
		# Confirm the input
		echo -n "$prompt_message"
		read confirmation
		
		# Verifies that the input is a yes or no,
		# otherwise, reprompts user.
		if [[ "$confirmation" =~ ^[Yy][Ee][Ss]?$ ]]; then
			echo -e "Selection confirmed.\n"
			return 0
			
		elif [[ "$confirmation" =~ ^[Nn][Oo]?$ ]]; then
			echo -e "Selection not confirmed. Returning to previous prompt...\n"
			line
			
			# Returns user to parent function if they select "no"
			return_to_parent $parent_function
			return
		else
			# Increments attempts for invalid answers
			echo -n "ERROR: Invalid choice. "
			((attempt++))
		fi
	done
	
	# Error handling - maximum attempts reached
	echo -e "Maximum attempts reached. Returning to previous prompt....\n"
	line
	
	# Returns user to parent function if maximum attempts reached
	return_to_parent $parent_function
}

create_layers() {

	# Prompt user for total depth of adventure game
	validate_depth "Enter the total directory depth you desire (must be between 2 and 10): "
	confirm "Are you sure you want to use this input? (yes/no): " "create_layers"
	
	# Initialize local variables
	local layer_count=$input
	local current_path=$(pwd)

	single_layer () {
		local i=$1
		local dir_name
		local file_name
		local file_content
		local valid_name=false

		# Prompt user for the directory name
		while [ "$valid_name" = false ]; do
			read -p "Enter a name for directory $i: " dir_name

			# Confirm the directory name
			if confirm "Are you sure you want to name the directory '$dir_name'? (yes/no): " "create_layers"; then
				valid_name=true
			else
				echo "Please re-enter a name for directory $i."
			fi
		done

		# Create the directory after confirmation
		current_path="$current_path/$dir_name"
		mkdir -p "$current_path"

		# Ask the user if they want to create a file in this directory
		read -p "Do you want to add a file to this directory? (yes/no): " option
		
		# Case statement to confirm file name, no does not return to last prompt
		case "$option" in
			yes|Yes|YES)
				read -p "Enter the file name (e.g., clue.txt): " file_name
				read -p "Enter the content for $file_name: " file_content
				echo "$file_content" > "$current_path/$file_name"
				echo -e "File '$file_name' created with your content.\n"
				;;
			no|No|NO)
				echo -e "No file added to directory $i/$dir_name.\n"
				;;
			*)
				echo "Invalid option. Please enter a yes or no."
				;;
		esac
	}
	
	for (( i=1; i<=layer_count; i++ )); do
		single_layer $i
	done
	
	echo -e "Directory structure with files created successfully. \nBegin your adventure by navigating through the directories!"
	
	# Terminates program when finished
	echo "Exiting with code 0..."
	exit 0
}

# ----------------------------------------
# Main Function
# ----------------------------------------

main() {

	# Calls the function that displays the opening credits
	opening_credits
	
	# Calls the function that initializes the game
	main_menu
	
	# Calls the function that creates the directories
	create_layers
}

# Calls the main function
main
