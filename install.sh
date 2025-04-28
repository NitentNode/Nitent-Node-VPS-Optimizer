#!/bin/bash

# Exit immediately on error
set -e

# Define colors
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define installation directory
INSTALL_DIR="/opt/nitent-node-vps-optimizer"

# Cool Loading Animation
function loading_animation() {
    echo -ne "${CYAN}Processing"
    for i in {1..5}; do
        echo -ne "."
        sleep 0.3
    done
    echo -e "${NC}"
}

# Beautiful Big Banner
function show_banner() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                  ║"
    echo "║          🚀🚀  WELCOME TO NITENT NODE VPS OPTIMIZER 🚀🚀         ║"
    echo "║                                                                  ║"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    echo "║      The Fastest, Smartest, and Most Powerful VPS Booster!        ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Install or Update Optimizer
function install_or_update() {
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}Previous installation found. Updating...${NC}"
        rm -rf "$INSTALL_DIR"
    else
        echo -e "${GREEN}No previous installation found. Installing fresh...${NC}"
    fi

    echo -e "${GREEN}Installing dependencies...${NC}"
    apt update && apt install -y curl wget git

    echo -e "${GREEN}Cloning repository...${NC}"
    git clone https://github.com/NitentNode/Nitent-Node-VPS-Optimizer.git "$INSTALL_DIR"

    echo -e "${GREEN}Setting up...${NC}"
    cd "$INSTALL_DIR"
    chmod +x nitent.sh

    echo ""
    echo -e "${CYAN}Installation/Update completed successfully!${NC}"
}

# Start Optimizer
function start_optimizer() {
    echo -e "${YELLOW}Launching Nitent Node VPS Optimizer...${NC}"
    sleep 2
    cd "$INSTALL_DIR"
    ./nitent.sh
}

# Delete Optimizer
function delete_optimizer() {
    echo -e "${RED}Deleting Nitent Node VPS Optimizer...${NC}"
    loading_animation

    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        echo -e "${GREEN}Deletion completed successfully.${NC}"
    else
        echo -e "${RED}No installation found to delete.${NC}"
    fi
}

# Run the Banner
show_banner

# Menu
echo "Choose an option:"
echo -e "${GREEN}1) Install / Fresh Setup${NC}"
echo -e "${GREEN}2) Update (Reinstall Latest Version)${NC}"
echo -e "${GREEN}3) Delete Nitent Node VPS Optimizer${NC}"
echo -e "${GREEN}4) Start Optimization (Auto Install/Update + Start)${NC}"
echo ""
read -p "Enter your choice (1/2/3/4): " choice

if [ "$choice" == "1" ]; then
    echo -e "${BLUE}Starting Installation...${NC}"
    loading_animation
    install_or_update
    start_optimizer

elif [ "$choice" == "2" ]; then
    echo -e "${BLUE}Starting Update (Reinstall)...${NC}"
    loading_animation
    install_or_update
    start_optimizer

elif [ "$choice" == "3" ]; then
    delete_optimizer

elif [ "$choice" == "4" ]; then
    echo -e "${BLUE}Starting Optimization Process...${NC}"
    loading_animation
    install_or_update
    start_optimizer

else
    echo -e "${RED}Invalid choice! Exiting.${NC}"
    exit 1
fi
