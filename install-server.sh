#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NO_COLOR='\033[0m'

# Starting configuration
echo -e "${CYAN}Started server configuration${NO_COLOR}"

# Install and updates packages
echo -e "${YELLOW}>> Installing and updating packages${NO_COLOR}"

if sudo apt update && sudo apt upgrade -y; then
	echo -e "${GREEN}Packages updated successfully${NO_COLOR}"
else
	echo -e "${RED}Failed to update packages${NO_COLOR}"
	exit 1
fi

# Firewall
echo -e "${YELLOW}>> Configuring firewall${NO_COLOR}"

if sudo apt install ufw -y && sudo ufw allow OpenSSH && sudo ufw enable; then
	echo -e "${GREEN}Firewall configured successfully${NO_COLOR}"
	sudo ufw status
else
	echo -e "${RED}Failed to configure firewall${NO_COLOR}"
	exit 1
fi

# Timezone
echo -e "${YELLOW}>> Configuring timezone${NO_COLOR}"

read -p "Enter your timezone (example: Asia/Tokyo): " timezone

if [ -n "$timezone" ]; then
	if sudo timedatectl set-timezone "$timezone"; then
		echo -e "${GREEN}Timezone configured successfully. Timezone: $timezone${NO_COLOR}"
	else
		echo -e "${RED}Failed to configure timezone${NO_COLOR}"
	fi
else
	echo -e "${YELLOW}The timezone has not been changed${NO_COLOR}"
fi

# Optional packages
echo -e "${YELLOW}>> Installing optional packages${NO_COLOR}"

declare -A packages=(
	["neovim"]="Text editor neovim",
	["mc"]="File manager Midnight Commander",
	["btop"]="System monitor btop"
)

for package in "${!packages[@]}"; do
	read -p "Do you want to install ${packages[$package]}? (y/n): " response

	if [ "$response" == "y" ]; then
		echo -e "${YELLOW}>> Installing ${packages[$package]}${NO_COLOR}"
		if sudo apt install "$package" -y; then
			echo -e "${GREEN}${packages[$package]} installed successfully${NO_COLOR}"
		else
			echo -e "${RED}Failed to install ${packages[$package]}${NO_COLOR}"
		fi
	else
		echo -e "${YELLOW}Skipping ${packages[$package]} installation${NO_COLOR}"
	fi
done

echo -e "${CYAN}Finished server configuration${NO_COLOR}"
