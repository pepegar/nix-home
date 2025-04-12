#!/usr/bin/env bash

# Define colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current hostname
CURRENT_HOST=$(hostname -s)

# Helper function to print usage
print_usage() {
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  ppg home [hostname]   - Run home-manager for specified host (default: current host)"
    echo -e "  ppg darwin [hostname] - Run darwin-rebuild for specified host (default: current host)"
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

# Main function
main() {
    # Check if command is provided
    if [ $# -lt 1 ]; then
        print_error "No command specified"
        print_usage
        exit 1
    fi

    COMMAND=$1
    HOST=${2:-$CURRENT_HOST}
    
    # Change to the flake directory
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
            ./result/sw/bin/darwin-rebuild switch --flake .#${HOST}
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
