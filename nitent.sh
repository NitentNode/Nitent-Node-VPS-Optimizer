#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ASCII Art
ASCII_ART="${CYAN}
 ███╗   ██╗██╗████████╗███████╗███╗   ██╗████████╗
 ████╗  ██║██║╚══██╔══╝██╔════╝████╗  ██║╚══██╔══╝
 ██╔██╗ ██║██║   ██║   █████╗  ██╔██╗ ██║   ██║   
 ██║╚██╗██║██║   ██║   ██╔══╝  ██║╚██╗██║   ██║   
 ██║ ╚████║██║   ██║   ███████╗██║ ╚████║   ██║   
 ╚═╝  ╚═══╝╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝   ╚═╝   
${NC}"

# Check root access
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Please run as root${NC}"
        exit 1
    fi
}

# Initialize
initialize() {
    check_root
    if ! command -v figlet &> /dev/null; then
        apt-get update -y
        apt-get install -y figlet
    fi
    clear
    echo -e "$ASCII_ART"
    echo -e "${YELLOW}Enterprise Hosting Support:${NC} https://discord.gg/V4uWMy8bfP"
    echo -e "${YELLOW}Technical Community:${NC} https://discord.gg/TmFZNMWuDF"
    echo -e "\n${RED}SECURITY NOTICE: This script will make significant system changes!${NC}\n"
}

# Display Header
section_header() {
    clear
    echo -e "${CYAN}"
    figlet -c "$1"
    echo -e "${NC}"
    echo "======================================================"
}

# Progress Bar
progress_bar() {
    local duration=$1
    local steps=20
    local step_delay=$(bc -l <<< "$duration/$steps")
    
    echo -ne "${BLUE}["
    for ((i=0; i<steps; i++)); do
        echo -ne "="
        sleep $step_delay
    done
    echo -ne "]${NC}\n"
}

# Full System Optimization
full_optimization() {
    section_header "Full Optimization"
    
    echo -e "${YELLOW}[1/8] Deep Cleaning System...${NC}"
    rm -rf /tmp/* /var/tmp/*
    rm -rf /var/cache/apt/archives/* /var/cache/apt/*.bin
    rm -rf /var/lib/apt/lists/*
    journalctl --vacuum-size=200M --quiet
    find /var/log -type f -regex '.*\.\(gz\|[0-9]\)$' -delete
    apt-get clean -y && apt-get autoclean -y
    apt-get autoremove --purge -y
    progress_bar 2

    echo -e "${YELLOW}[2/8] Swap Configuration...${NC}"
    swapoff -a 2>/dev/null
    rm -f /swapfile 2>/dev/null
    dd if=/dev/zero of=/swapfile bs=1M count=4096 status=progress
    chmod 600 /swapfile
    mkswap /swapfile >/dev/null
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo "vm.swappiness=10" >> /etc/sysctl.conf
    echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf
    progress_bar 1

    echo -e "${YELLOW}[3/8] Kernel Optimization...${NC}"
    cat >> /etc/sysctl.conf << EOL
# Network Optimization
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_fastopen=3
net.core.somaxconn=65535
net.core.netdev_max_backlog=16384
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=15

# DDoS Protection
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_max_syn_backlog=2048
net.ipv4.tcp_synack_retries=3
net.ipv4.tcp_syn_retries=3
EOL
    sysctl -p >/dev/null
    progress_bar 1

    echo -e "${YELLOW}[4/8] Security Hardening...${NC}"
    chmod 700 /root
    chmod 600 /etc/ssh/sshd_config
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
    echo "kernel.kptr_restrict=2" >> /etc/sysctl.conf
    echo "kernel.dmesg_restrict=1" >> /etc/sysctl.conf
    progress_bar 1

    echo -e "${YELLOW}[5/8] Installing Tools...${NC}"
    apt-get install -y zram-tools tuned sysstat iotop fail2ban
    systemctl enable tuned && systemctl start tuned
    tuned-adm profile latency-performance
    progress_bar 2

    echo -e "${YELLOW}[6/8] Filesystem Tuning...${NC}"
    if lsblk -d -o rota | grep -q '0'; then
        sed -i '/noatime/d' /etc/fstab
        sed -i '/relatime/d' /etc/fstab
        echo "/ / ext4 defaults,noatime,relatime,discard 0 0" >> /etc/fstab
        fstrim -av
    else
        echo "noatime,relatime" >> /etc/fstab
    fi
    mount -o remount /
    progress_bar 1

    echo -e "${YELLOW}[7/8] CPU Optimization...${NC}"
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        for governor in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo performance > $governor 2>/dev/null
        done
    fi
    echo 'GOVERNOR="performance"' | tee /etc/default/cpufrequtils >/dev/null 2>&1
    progress_bar 1

    echo -e "${YELLOW}[8/8] Scheduling Maintenance...${NC}"
    (crontab -l 2>/dev/null; echo "@daily /usr/bin/env bash /root/.nitent_cleaner.sh --silent") | crontab -
    cat > /root/.nitent_cleaner.sh << 'EOL'
#!/bin/bash
echo "$(date) - Nitent AutoClean Running..."
rm -rf /tmp/* /var/tmp/*
apt-get autoremove --purge -y
journalctl --vacuum-time=1d --quiet
echo 3 > /proc/sys/vm/drop_caches
fstrim -av
EOL
    chmod 700 /root/.nitent_cleaner.sh
    progress_bar 1

    echo -e "\n${GREEN}Optimization Complete!${NC}"
    echo -e "${YELLOW}Recommended Actions:"
    echo "1. Reboot server"
    echo "2. Check: sysctl -a | grep 'swappiness\|vfs_cache_pressure'"
    echo "3. Monitor with: htop && iotop"
    echo -e "${NC}"
    sleep 3
    main_menu
}

# DDoS Protection Menu
ddos_protection_menu() {
    section_header "DDoS Protection"
    
    PS3=$'\n'"Select Protection Type: "
    options=("Game Server Protection" "Panel Protection" "Network Protection" "Return")
    select opt in "${options[@]}"; do
        case $opt in
            "Game Server Protection") game_protection ;;
            "Panel Protection") panel_protection ;;
            "Network Protection") network_protection ;;
            "Return") main_menu ;;
            *) echo -e "${RED}Invalid option!${NC}";;
        esac
        break
    done
}

# Game Server Protection
game_protection() {
    section_header "Game Protection"
    
    echo -e "${YELLOW}Connection Limit Recommendations:${NC}"
    echo -e "${CYAN}+---------------------+-------------------+${NC}"
    echo -e "| Small (10-20 players) | 5-10             |"
    echo -e "| Medium (50-100)       | 10-20            |"
    echo -e "| Large (100+)          | 20-50            |"
    echo -e "${CYAN}+---------------------+-------------------+${NC}"
    
    read -p "Enter game ports (e.g., 25565,27015-27020): " ports
    read -p "Max connections/IP (default 20): " max_conn
    max_conn=${max_conn:-20}

    apt-get install -y iptables-persistent ipset

    ipset create whitelist hash:ip timeout 86400
    ipset create blacklist hash:ip timeout 86400

    iptables -N GAME_PROTECT
    iptables -A INPUT -p tcp -m multiport --dports ${ports} -j GAME_PROTECT
    
    iptables -A GAME_PROTECT -m connlimit --connlimit-above ${max_conn} --connlimit-mask 24 -j DROP
    iptables -A GAME_PROTECT -m recent --name DDOS --update --seconds 60 --hitcount 50 -j DROP
    iptables -A GAME_PROTECT -m recent --name DDOS --set
    
    iptables -A GAME_PROTECT -p tcp --syn -m limit --limit 100/second --limit-burst 200 -j ACCEPT
    iptables -A GAME_PROTECT -p tcp --syn -j DROP
    iptables -A GAME_PROTECT -p udp -m limit --limit 50/sec --limit-burst 100 -j ACCEPT
    iptables -A GAME_PROTECT -p udp -j DROP
    
    iptables -A GAME_PROTECT -m set --match-set whitelist src -j ACCEPT
    iptables -A GAME_PROTECT -m set --match-set blacklist src -j DROP
    
    ipset save > /etc/ipset.rules
    iptables-save > /etc/iptables/rules.v4
    
    echo -e "\n${GREEN}Game Protection Activated!${NC}"
    sleep 2
    main_menu
}

# Panel Protection
panel_protection() {
    section_header "Panel Protection"
    
    apt-get install -y fail2ban

    cat > /etc/fail2ban/jail.d/panel.conf << EOL
[panel]
enabled = true
port = http,https,8080,2022
filter = panel
logpath = /var/www/pterodactyl/storage/logs/*
maxretry = 3
findtime = 600
bantime = 86400
EOL

    iptables -N PANEL_PROTECT
    iptables -A INPUT -p tcp -m multiport --dports 80,443,8080,2022 -j PANEL_PROTECT
    iptables -A PANEL_PROTECT -m recent --name HTTPFLOOD --update --seconds 60 --hitcount 200 -j DROP
    iptables -A PANEL_PROTECT -m recent --name HTTPFLOOD --set
    iptables -A PANEL_PROTECT -m limit --limit 100/minute -j ACCEPT
    
    systemctl restart fail2ban
    iptables-save > /etc/iptables/rules.v4
    
    echo -e "\n${GREEN}Panel Protection Activated!${NC}"
    sleep 2
    main_menu
}

# Network Protection
network_protection() {
    section_header "Network Protection"
    
    iptables -N NET_PROTECT
    iptables -A INPUT -j NET_PROTECT
    
    iptables -A NET_PROTECT -p tcp --tcp-flags ALL NONE -j DROP
    iptables -A NET_PROTECT -p tcp --tcp-flags ALL ALL -j DROP
    iptables -A NET_PROTECT -p icmp --icmp-type echo-request -m limit --limit 1/sec -j ACCEPT
    
    iptables -A NET_PROTECT -p tcp --syn -m limit --limit 100/sec --limit-burst 200 -j ACCEPT
    iptables -A NET_PROTECT -p tcp --syn -j DROP
    
    iptables-save > /etc/iptables/rules.v4
    
    echo -e "\n${GREEN}Network Protection Activated!${NC}"
    sleep 2
    main_menu
}

# Pterodactyl Management
pterodactyl_setup() {
    section_header "Pterodactyl"
    
    PS3=$'\n'"Select Operation: "
    options=("Install Panel" "Update Panel" "Return")
    select opt in "${options[@]}"; do
        case $opt in
            "Install Panel")
                echo -e "\n${CYAN}Installing Pterodactyl...${NC}"
                bash <(curl -s https://pterodactyl-installer.se)
                ;;
            "Update Panel")
                echo -e "\n${CYAN}Updating Pterodactyl...${NC}"
                cd /var/www/pterodactyl
                php artisan down
                curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv
                chmod -R 755 storage/* bootstrap/cache
                chown -R www-data:www-data /var/www/pterodactyl/*
                composer install --no-dev --optimize-autoloader
                php artisan view:clear
                php artisan config:clear
                php artisan migrate --seed --force
                php artisan queue:restart
                php artisan up
                ;;
            "Return") main_menu ;;
            *) echo -e "${RED}Invalid option!${NC}";;
        esac
        break
    done
    
    echo -e "\n${GREEN}Operation completed!${NC}"
    sleep 2
    main_menu
}

# Emergency Repair
emergency_repair() {
    section_header "Emergency Repair"
    
    read -p "${RED}Are you sure? This will reset all optimizations! [y/N]:${NC} " confirm
    if [[ ! $confirm =~ [Yy] ]]; then
        main_menu
        return
    fi

    echo -e "\n${CYAN}Reverting changes...${NC}"
    
    swapoff -a
    rm -f /swapfile
    sed -i '/swapfile/d' /etc/fstab
    
    iptables -F
    iptables -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    
    apt-get remove --purge -y fail2ban zram-tools tuned
    rm -rf /etc/fail2ban
    
    sed -i '/vm.swappiness/d' /etc/sysctl.conf
    sed -i '/vm.vfs_cache_pressure/d' /etc/sysctl.conf
    sed -i '/net.core.rmem_max/d' /etc/sysctl.conf
    sed -i '/kernel.kptr_restrict/d' /etc/sysctl.conf
    sysctl -p
    
    crontab -l | grep -v 'nitent_cleaner' | crontab -
    rm -f /root/.nitent_cleaner.sh
    
    echo -e "\n${GREEN}System restored to default state!${NC}"
    sleep 2
    main_menu
}

# Main Menu
main_menu() {
    section_header "Nitent Node VPS Optimizer"
    
    PS3=$'\n'"Select Operation: "
    options=("Full System Optimization" 
             "Advanced DDoS Protection" 
             "Pterodactyl Management" 
             "Emergency Repair" 
             "Exit")
    
    select opt in "${options[@]}"; do
        case $opt in
            "Full System Optimization") full_optimization ;;
            "Advanced DDoS Protection") ddos_protection_menu ;;
            "Pterodactyl Management") pterodactyl_setup ;;
            "Emergency Repair") emergency_repair ;;
            "Exit") exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}";;
        esac
    done
}

# Start Script
initialize
main_menu
