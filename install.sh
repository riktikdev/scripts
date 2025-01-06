#!/bin/bash

# Install function
install() {
	# Check if the script is being run as root
	if [ "$(id -u)" != "0" ]; then
		echo "This script must be run as root" >&2
		exit 1
	fi

	# Check if the script is running on MacOS
	if [ "$(uname)" = "Darwin" ]; then
		echo "This script must be run on Linux" >&2
		exit 1
	fi

	# Check if the script is running inside a container
	if [ -f /.dockerenv ]; then
		echo "This script must be run on Linux" >&2
		exit 1
	fi

	# Define color codes
	GREEN="\033[0;32m"
	YELLOW="\033[1;33m"
	BLUE="\033[0;34m"
	RED="\033[0;31m"
	NC="\033[0m"

	# Start server configuration
	printf "${BLUE}>> Starting server configuration${NC}\n"

	# Install and update packages
	printf "${YELLOW}>> Installing and updating packages${NC}\n"
	if sudo apt update && sudo apt upgrade -y; then
		printf "${GREEN}Packages updated successfully${NC}\n"
	else
		printf "${RED}Failed to update packages${NC}\n"
		exit 1
	fi

	# Configure firewall
	printf "${YELLOW}>> Configuring firewall${NC}\n"
	if sudo apt install ufw -y && sudo ufw allow OpenSSH && sudo ufw enable; then
		printf "${GREEN}Firewall configured successfully${NC}\n"
		sudo ufw status
	else
		printf "${RED}Failed to configure firewall${NC}\n"
		exit 1
	fi

	# Set timezone
	read -p "Do you want to change the timezone? (y/n): " timezone_response
	if [ "$timezone_response" == "y" ]; then
		read -p "Enter your desired timezone (example: Asia/Tokyo): " timezone
		if sudo timedatectl set-timezone "$timezone"; then
			printf "${GREEN}Timezone set to $timezone successfully${NC}\n"
		else
			printf "${RED}Failed to set timezone${NC}\n"
			exit 1
		fi
	fi

	# Set hostname
	read -p "Do you want to change the hostname? (y/n): " hostname_response
	if [ "$hostname_response" == "y" ]; then
		read -p "Enter new hostname: " new_hostname
		if sudo hostnamectl set-hostname "$new_hostname"; then
			printf "${GREEN}Hostname changed to $new_hostname${NC}\n"
		else
			printf "${RED}Failed to change hostname${NC}\n"
			exit 1
		fi
	fi

	# Install optional packages
	printf "${YELLOW}>> Installing optional packages${NC}\n"
	declare -A packages=(
		["neovim"]="neovim"
		["mc"]="mc"
		["btop"]="btop"
	)

	for package in "${!packages[@]}"; do
		read -p "Do you want to install ${packages[$package]}? (y/n): " response
		if [ "$response" == "y" ]; then
			printf "${YELLOW}>> Installing ${packages[$package]}${NC}\n"
			if sudo apt install "${packages[$package]}" -y; then
				printf "${GREEN}${packages[$package]} installed successfully${NC}\n"
			else
				printf "${RED}Failed to install ${packages[$package]}${NC}\n"
			fi
		else
			printf "${YELLOW}Skipping ${packages[$package]} installation${NC}\n"
		fi
	done

	# Finish server configuration
	printf "${BLUE}>> Finished server configuration${NC}\n"
}

# Main script execution
install