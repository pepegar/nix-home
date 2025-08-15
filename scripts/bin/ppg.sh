#!/usr/bin/env bash

# Define colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current hostname
CURRENT_HOST=$(hostname -s)

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Helper function to print usage
print_usage() {
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  ppg <command> [args...]"
    echo
    echo -e "${BLUE}Available commands:${NC}"
    
    # List built-in commands
    echo -e "  home [hostname]   - Run home-manager for specified host (default: current host)"
    echo -e "  darwin [hostname] - Run darwin-rebuild for specified host (default: current host)"
    
    # List ppg-* scripts as available commands
    local ppg_scripts
    ppg_scripts=($(find "$SCRIPT_DIR" -name "ppg-*" -executable -type f | sort))
    if [ ${#ppg_scripts[@]} -gt 0 ]; then
        echo
        echo -e "${BLUE}Extension commands:${NC}"
        for script in "${ppg_scripts[@]}"; do
            local cmd_name=$(basename "$script" | sed 's/^ppg-//')
            local description=""
            # Try to get description from script's first comment line
            if [[ -f "$script" ]]; then
                description=$(head -n 20 "$script" | grep -E "^#.*[Dd]escription:|^# " | head -1 | sed 's/^#[[:space:]]*//' | sed 's/^[Dd]escription:[[:space:]]*//')
            fi
            if [[ -n "$description" ]]; then
                echo -e "  $cmd_name - $description"
            else
                echo -e "  $cmd_name"
            fi
        done
    fi
    
    echo
    echo -e "${BLUE}Examples:${NC}"
    echo -e "  ppg home              - Home-manager for current host"
    echo -e "  ppg home bart         - Home-manager for bart"
    echo -e "  ppg darwin homer      - Darwin-rebuild for homer"
}

# Helper function to print status messages
print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

# Helper function to print warnings
print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Helper function to print errors
print_error() {
    echo -e "${RED}Error:${NC} $1"
}

# Function to find and execute ppg-* scripts
execute_ppg_script() {
    local command=$1
    shift
    local script_path="$SCRIPT_DIR/ppg-$command"
    
    if [[ -x "$script_path" ]]; then
        exec "$script_path" "$@"
    else
        return 1
    fi
}

# Main function
main() {
    # Check if command is provided
    if [ $# -lt 1 ]; then
        print_error "No command specified"
        print_usage
        exit 1
    fi

    COMMAND=$1
    shift
    
    # First try to execute as ppg-* script
    if execute_ppg_script "$COMMAND" "$@"; then
        return 0
    fi
    
    # Fall back to built-in commands
    HOST=${1:-$CURRENT_HOST}
    
    # Change to the flake directory for built-in commands
    cd ~/.config/home-manager || { print_error "Could not find home-manager config directory"; exit 1; }

    case $COMMAND in
        home)
            print_status "Running home-manager for host: ${HOST}"
            if [[ "$HOST" == "$CURRENT_HOST" || "$HOST" == "pepe" ]]; then
                print_status "Using default home configuration"
                nix run --impure .#homeConfigurations.pepe.activationPackage
            else
                print_status "Using home configuration for pepe@${HOST}"
                nix run --impure .#homeConfigurations."pepe@${HOST}".activationPackage
            fi
            ;;
        darwin)
            print_status "Running darwin-rebuild for host: ${HOST}"
            print_status "Using darwin configuration for ${HOST}"
            nix build --impure .#darwinConfigurations.${HOST}.system
            sudo ./result/sw/bin/darwin-rebuild switch --flake .#${HOST}
            ;;
        *)
            print_error "Unknown command: $COMMAND"
            print_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
