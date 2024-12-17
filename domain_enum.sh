#!/bin/bash

# Advanced Domain Enumeration Script
# Version: 2.0
# Enhanced with Authentication and Advanced Recon Capabilities

# Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration Variables
CONFIG_FILE="$HOME/.domain_enum_config"
LOG_DIR="$HOME/advanced_domain_enum_logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Declare Associative Arrays for Advanced Options
declare -A AUTH_OPTIONS
declare -A RECON_MODES

# Tools Array
REQUIRED_TOOLS=(
    "amass"
    "subfinder"
    "httpx"
    "nuclei"
    "nmap"
    "jq"
    "curl"
)

# Authentication Menu
show_auth_menu() {
    clear
    echo -e "${BLUE}===== Authentication Options =====${NC}"
    echo "1. Basic Authentication (Username/Password)"
    echo "2. Cookie-based Authentication"
    echo "3. API Token Authentication"
    echo "4. No Authentication"
    echo "0. Back to Main Menu"
    read -p "Choose an authentication method (0-4): " auth_choice
}

# Configure Authentication
configure_authentication() {
    while true; do
        show_auth_menu
        
        case $auth_choice in
            1)  # Basic Authentication
                read -p "Enter Username: " username
                read -sp "Enter Password: " password
                AUTH_OPTIONS["type"]="basic"
                AUTH_OPTIONS["username"]="$username"
                AUTH_OPTIONS["password"]="$password"
                break
                ;;
            2)  # Cookie Authentication
                read -p "Enter Cookie Value: " cookie
                AUTH_OPTIONS["type"]="cookie"
                AUTH_OPTIONS["value"]="$cookie"
                break
                ;;
            3)  # API Token
                read -p "Enter API Token: " api_token
                AUTH_OPTIONS["type"]="api"
                AUTH_OPTIONS["token"]="$api_token"
                break
                ;;
            4)  # No Authentication
                AUTH_OPTIONS["type"]="none"
                break
                ;;
            0)  # Exit
                return
                ;;
            *)
                echo -e "${RED}Invalid option. Try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

# Reconnaissance Mode Selection
show_recon_menu() {
    clear
    echo -e "${BLUE}===== Reconnaissance Modes =====${NC}"
    echo "1. Basic Subdomain Enumeration"
    echo "2. Advanced Network Scanning"
    echo "3. Web Technology Detection"
    echo "4. Vulnerability Scanning"
    echo "5. Custom Recon Mode"
    echo "0. Back to Main Menu"
    read -p "Choose a reconnaissance mode (0-5): " recon_choice
}

# Configure Reconnaissance Mode
configure_recon_mode() {
    while true; do
        show_recon_menu
        
        case $recon_choice in
            1)  # Basic Subdomain Enumeration
                RECON_MODES["mode"]="basic"
                RECON_MODES["depth"]=2
                break
                ;;
            2)  # Advanced Network Scanning
                RECON_MODES["mode"]="network"
                RECON_MODES["ports"]="1-65535"
                break
                ;;
            3)  # Web Technology Detection
                RECON_MODES["mode"]="web_tech"
                RECON_MODES["fingerprint"]=true
                break
                ;;
            4)  # Vulnerability Scanning
                RECON_MODES["mode"]="vuln_scan"
                RECON_MODES["severity"]="medium"
                break
                ;;
            5)  # Custom Recon Mode
                read -p "Enter custom mode name: " custom_mode
                RECON_MODES["mode"]="$custom_mode"
                break
                ;;
            0)  # Exit
                return
                ;;
            *)
                echo -e "${RED}Invalid option. Try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

# Perform Domain Enumeration with Advanced Options
advanced_domain_enum() {
    local domain=$1
    local output_base="${LOG_DIR}/${domain}_${TIMESTAMP}"

    # Authentication Handling
    case ${AUTH_OPTIONS["type"]} in
        "basic")
            echo -e "${YELLOW}[*] Using Basic Authentication${NC}"
            # Curl or specific tool authentication logic here
            ;;
        "cookie")
            echo -e "${YELLOW}[*] Using Cookie Authentication${NC}"
            # Cookie-based authentication logic
            ;;
        "api")
            echo -e "${YELLOW}[*] Using API Token Authentication${NC}"
            # API token authentication logic
            ;;
    esac

    # Reconnaissance Mode Handling
    case ${RECON_MODES["mode"]} in
        "basic")
            # Basic subdomain enumeration
            subfinder -d "$domain" -o "${output_base}_subdomains.txt"
            amass enum -d "$domain" -o "${output_base}_amass_subdomains.txt"
            ;;
        "network")
            # Advanced network scanning
            nmap -sV -p${RECON_MODES["ports"]} "$domain" -oA "${output_base}_nmap_scan"
            ;;
        "web_tech")
            # Web technology detection
            httpx -l "${output_base}_subdomains.txt" -technologies -o "${output_base}_tech_fingerprint.txt"
            ;;
        "vuln_scan")
            # Vulnerability scanning
            nuclei -l "${output_base}_subdomains.txt" -severity ${RECON_MODES["severity"]} -o "${output_base}_vulnerabilities.txt"
            ;;
        *)
            echo -e "${RED}[!] Unknown recon mode: ${RECON_MODES["mode"]}${NC}"
            ;;
    esac

    # Combine and process results
    cat "${output_base}"_*subdomains.txt | sort -u > "${output_base}_final_subdomains.txt"
}

# Main Menu
main_menu() {
    while true; do
        clear
        echo -e "${GREEN}===== Advanced Domain Enumeration Tool =====${NC}"
        echo "1. Configure Authentication"
        echo "2. Configure Reconnaissance Mode"
        echo "3. Start Domain Enumeration"
        echo "4. View Previous Logs"
        echo "0. Exit"
        
        read -p "Choose an option (0-4): " main_choice
        
        case $main_choice in
            1) configure_authentication ;;
            2) configure_recon_mode ;;
            3) 
                read -p "Enter domain or path to domains file: " domain_input
                if [[ -f "$domain_input" ]]; then
                    while IFS= read -r domain; do
                        advanced_domain_enum "$domain"
                    done < "$domain_input"
                else
                    advanced_domain_enum "$domain_input"
                fi
                ;;
            4)
                echo "Showing recent logs:"
                ls -lt "$LOG_DIR" | head -n 10
                read -p "Press Enter to continue..." 
                ;;
            0) 
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

# Initialization
mkdir -p "$LOG_DIR"

# Entry Point
main_menu
