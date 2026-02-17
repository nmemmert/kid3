#!/bin/bash
# Kid3 Docker Launcher Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
MUSIC_DIR="${MUSIC_DIR:-$HOME/Music}"
MODE="${1:-gui}"

print_usage() {
    echo "Usage: $0 [gui|cli] [music_directory]"
    echo ""
    echo "Modes:"
    echo "  gui - Launch Kid3 GUI (default)"
    echo "  cli - Launch Kid3 CLI interactive mode"
    echo ""
    echo "Examples:"
    echo "  $0                           # Launch GUI with default music dir"
    echo "  $0 gui /path/to/music        # Launch GUI with custom dir"
    echo "  $0 cli                       # Launch CLI interactive mode"
    echo "  $0 cli /path/to/music        # Launch CLI with custom dir"
    echo ""
    echo "Environment variables:"
    echo "  MUSIC_DIR - Default music directory (default: $HOME/Music)"
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker is not installed${NC}"
        exit 1
    fi
}

check_image() {
    if ! docker image inspect kid3:latest &> /dev/null; then
        echo -e "${YELLOW}Kid3 image not found. Building...${NC}"
        docker build -t kid3:latest .
    fi
}

setup_x11() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -e "${GREEN}Setting up X11 permissions...${NC}"
        xhost +local:docker 2>/dev/null || {
            echo -e "${YELLOW}Warning: Could not set X11 permissions${NC}"
            echo "You may need to run: xhost +local:docker"
        }
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${YELLOW}macOS detected. Make sure XQuartz is running.${NC}"
        echo "Allow connections from network clients in XQuartz preferences."
        # Set DISPLAY for macOS
        export DISPLAY=host.docker.internal:0
    fi
}

# Parse arguments
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    print_usage
    exit 0
fi

if [[ -n "$2" ]]; then
    MUSIC_DIR="$2"
fi

# Verify music directory exists
if [[ ! -d "$MUSIC_DIR" ]]; then
    echo -e "${RED}Error: Music directory does not exist: $MUSIC_DIR${NC}"
    echo "Please create it or specify a different directory."
    exit 1
fi

# Main execution
check_docker
check_image

case "$MODE" in
    gui)
        setup_x11
        echo -e "${GREEN}Launching Kid3 GUI...${NC}"
        echo "Music directory: $MUSIC_DIR"
        
        docker run -it --rm \
            --name kid3-gui \
            -e DISPLAY="${DISPLAY}" \
            -e QT_X11_NO_MITSHM=1 \
            -e XDG_RUNTIME_DIR=/tmp/runtime-kid3user \
            -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
            -v "$MUSIC_DIR:/music" \
            -v kid3-config:/home/kid3user/.config \
            kid3:latest kid3-qt
        ;;
    
    cli)
        echo -e "${GREEN}Launching Kid3 CLI...${NC}"
        echo "Music directory: $MUSIC_DIR"
        echo ""
        echo -e "${YELLOW}Tips:${NC}"
        echo "  - Type 'help' for available commands"
        echo "  - Use 'cd /music' to navigate to your music"
        echo "  - Type 'quit' to exit"
        echo ""
        
        docker run -it --rm \
            --name kid3-cli \
            -v "$MUSIC_DIR:/music" \
            -v kid3-config:/home/kid3user/.config \
            kid3:latest kid3-cli
        ;;
    
    *)
        echo -e "${RED}Error: Invalid mode '$MODE'${NC}"
        echo ""
        print_usage
        exit 1
        ;;
esac
