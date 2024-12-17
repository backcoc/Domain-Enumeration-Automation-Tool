#!/bin/bash

# Domain Enumeration Automation Script
# Version: 1.1
# Author: Bug Bounty Automation Team

# Color Codes for Formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration Variables
HOME_DIR="${HOME}"
SCRIPT_NAME=$(basename "$0")
CONFIG_DIR="${HOME_DIR}/.domain_enum"
LOG_BASE_DIR="${CONFIG_DIR}/logs"
RESULTS_BASE_DIR="${CONFIG_DIR}/results"
CHECKPOINT_FILE="${CONFIG_DIR}/checkpoint.txt"

# Logging Configuration
create_timestamp() {
    date +"%Y%m%d_%H%M%S"
}

# Ensure Directories Exist
setup_directories() {
    mkdir -p "${LOG_BASE_DIR}"
    mkdir -p "${RESULTS_BASE_DIR}"
    mkdir -p "${CONFIG_DIR}"
}

# Dependency Installation Function
install_dependencies() {
    echo -e "${YELLOW}[*] Checking and Installing Dependencies...${NC}"
    
    # Update Package Lists
    sudo apt-get update -qq

    # Install Essential Packages
    sudo apt-get install -y -qq \
        wget \
        curl \
        git \
        jq \
        unzip

    # Check and Install Go
    if ! command -v go &> /dev/null; then
        echo -e "${BLUE}[*] Installing Go...${NC}"
        wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz -O /tmp/go.tar.gz
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh
        source /etc/profile.d/golang.sh
    fi

    # Install Domain Enumeration Tools
    local tools=(
        "github.com/OWASP/Amass/v3/..."
        "github.com/projectdiscovery/subfinder/v2/cmd/subfinder"
        "github.com/tomnomnom/assetfinder"
        "github.com/projectdiscovery/httpx/cmd/httpx"
        "github.com/tomnomnom/anew"
    )

    for tool in "${tools[@]}"; do
        go install -v "${tool}@latest"
    done

    # Verify Tool Installation
    echo -e "${GREEN}[✓] Dependencies Installed Successfully!${NC}"
}

# Check and Validate Tools
validate_tools() {
    local required_tools=(
        "amass"
        "subfinder"
        "assetfinder"
        "httpx"
        "anew"
        "go"
        "jq"
    )

    for tool in "${required_tools[@]}"; do
        if ! command -v "${tool}" &> /dev/null; then
            echo -e "${RED}[!] ${tool} is not installed.${NC}"
            read -p "Would you like to install dependencies? (y/n): " install_choice
            if [[ "${install_choice}" == "y" ]]; then
                install_dependencies
                break
            else
                echo -e "${RED}[!] Cannot proceed without dependencies.${NC}"
                exit 1
            fi
        fi
    done
}

# Domain Enumeration Core Function
enumerate_domains() {
    local domain="$1"
    local timestamp=$(create_timestamp)
    local output_base="${RESULTS_BASE_DIR}/${domain}_${timestamp}"

    echo -e "${GREEN}[+] Enumerating Subdomains for ${domain}${NC}"

    # Amass Enumeration
    amass enum -d "${domain}" -o "${output_base}_amass.txt" 2>> "${LOG_BASE_DIR}/${domain}_amass.log"

    # Subfinder Enumeration
    subfinder -d "${domain}" -o "${output_base}_subfinder.txt" 2>> "${LOG_BASE_DIR}/${domain}_subfinder.log"

    # Assetfinder Enumeration
    assetfinder "${domain}" > "${output_base}_assetfinder.txt" 2>> "${LOG_BASE_DIR}/${domain}_assetfinder.log"

    # Combine Unique Domains
    cat "${output_base}"_*.txt | sort -u > "${output_base}_unique_domains.txt"

    # Probe Live Domains
    cat "${output_base}_unique_domains.txt" | httpx -silent > "${output_base}_live_domains.txt"

    # Generate Multiple Formats
    formats=("txt" "csv" "json" "xml")
    for format in "${formats[@]}"; do
        case "${format}" in
            "csv")
                awk '{print "domain,"$0}' "${output_base}_unique_domains.txt" > "${output_base}.csv"
                ;;
            "json")
                jq -R '.' "${output_base}_unique_domains.txt" | jq -s '.' > "${output_base}.json"
                ;;
            "xml")
                echo '<?xml version="1.0" encoding="UTF-8"?><domains>' > "${output_base}.xml"
                while IFS= read -r line; do
                    echo "<domain>${line}</domain>" >> "${output_base}.xml"
                done < "${output_base}_unique_domains.txt"
                echo '</domains>' >> "${output_base}.xml"
                ;;
        esac
    done

    echo -e "${GREEN}[✓] Enumeration Completed for ${domain}${NC}"
    echo -e "${BLUE}[*] Results stored in: ${output_base}${NC}"
}

# Bulk Domain Processing
process_domains() {
    local input_file="$1"

    if [[ ! -f "${input_file}" ]]; then
        echo -e "${RED}[!] Input file not found: ${input_file}${NC}"
        exit 1
    fi

    # Read domains, skip comments and empty lines
    while IFS= read -r domain || [[ -n "${domain}" ]]; do
        # Skip empty lines and comments
        [[ -z "${domain}" || "${domain}" =~ ^[[:space:]]*# ]] && continue

        # Trim whitespace
        domain=$(echo "${domain}" | xargs)

        echo -e "${YELLOW}[*] Processing: ${domain}${NC}"
        enumerate_domains "${domain}"
        
        # Optional: Small delay between domains
        sleep 2
    done < "${input_file}"
}

# Main Execution Function
main() {
    setup_directories
    validate_tools

    case "$#" in
        0)
            echo -e "${RED}[!] Usage: ${SCRIPT_NAME} <domain> OR ${SCRIPT_NAME} -f <domains_file>${NC}"
            exit 1
            ;;
        1)
            # Single Domain Mode
            enumerate_domains "$1"
            ;;
        2)
            # Multiple Domains Mode
            if [[ "$1" == "-f" && -f "$2" ]]; then
                process_domains "$2"
            else
                echo -e "${RED}[!] Invalid arguments. Use: ${SCRIPT_NAME} -f <domains_file>${NC}"
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}[!] Too many arguments${NC}"
            exit 1
            ;;
    esac
}

# Program Entry Point
main "$@"
