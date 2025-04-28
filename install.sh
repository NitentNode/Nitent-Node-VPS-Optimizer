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

# Cool Loading Animation
function loading_animation() {
    echo -ne "${CYAN}Processing"
    for i in {1..5}; do
        echo -ne "."
        sleep 0.5
    done
    echo -e "${NC}"
}

# Clear screen and show banner
clear
echo -e "${BLUE}"
echo "==============================================="
echo "       🚀 Nitent Node VPS Optimizer 🚀"
echo "==============================================="
echo -e "${NC}"
echo -e "${YELLOW}Welcome to the Nitent Node VPS Optimizer Setup!${NC}"
echo ""

# Menu
echo "Choose an option:"
echo -e "${GREEN}1) Install Nitent Node VPS Optimizer${NC}"
echo -e "${GREEN}2) Update (Reinstall) Nitent Node VPS Optimizer${NC}"
echo -e "${GREEN}3) Delete Nitent Node VPS Optimizer${NC}"
echo ""
read -p "Enter your choice (1/2/3): " choice

if [ "$choice" == "1" ]; then
    echo -e "${BLUE}Starting Installation...${NC}"
    loading_animation

    echo -e "${GREEN}Installing dependencies...${NC}"
    apt update && apt install -y curl wget git

    echo -e "${GREEN}Cloning repository...${NC}"
    git clone https://github.com/NitentNode/Nitent-Node-VPS-Optimizer.git /opt/nitent-node-vps-optimizer

    echo -e "${GREEN}Setting up Nitent Node VPS Optimizer...${NC}"
    cd /opt/nitent-node-vps-optimizer
    chmod +x nitent.sh

    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}Launching Nitent Node VPS Optimizer...${NC}"
    sleep 2
    ./nitent.sh

elif [ "$choice" == "2" ]; then
    echo -e "${BLUE}Updating (Reinstalling) Nitent Node VPS Optimizer...${NC}"
    loading_animation

    echo -e "${GREEN}Removing old installation...${NC}"
    rm -rf /opt/nitent-node-vps-optimizer

    echo -e "${GREEN}Installing dependencies...${NC}"
    apt update && apt install -y curl wget git

    echo -e "${GREEN}Cloning latest repository...${NC}"
    git clone https://github.com/NitentNode/Nitent-Node-VPS-Optimizer.git /opt/nitent-node-vps-optimizer

    echo -e "${GREEN}Setup complete!${NC}"
    cd /opt/nitent-node-vps-optimizer
    chmod +x nitent.sh

    echo -e "${YELLOW}Launching Nitent Node VPS Optimizer...${NC}"
    sleep 2
    ./nitent.sh

elif [ "$choice" == "3" ]; then
    echo -e "${RED}Deleting Nitent Node VPS Optimizer...${NC}"
    loading_animation

    rm -rf /opt/nitent-node-vps-optimizer

    echo -e "${GREEN}Deletion completed successfully.${NC}"
else
    echo -e "${RED}Invalid choice! Exiting.${NC}"
    exit 1
fi
