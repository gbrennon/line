#!/bin/bash

# Line MIDI Sequencer Docker Runner
# Usage: ./run-line.sh [mode] [options]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_usage() {
    echo -e "${BLUE}Line MIDI Sequencer Docker Runner${NC}"
    echo ""
    echo "Usage: $0 [MODE] [OPTIONS]"
    echo ""
    echo "Modes:"
    echo "  alsa     - Run with ALSA MIDI (default)"
    echo "  jack     - Run with JACK MIDI support"
    echo "  build    - Build Docker image"
    echo "  setup    - Setup MIDI environment"
    echo "  test     - Test MIDI connectivity"
    echo "  clean    - Clean up containers and images"
    echo ""
    echo "Options:"
    echo "  --help   - Show this help message"
    echo "  --debug  - Run with debug output"
    echo ""
    echo "Examples:"
    echo "  $0 alsa              # Run with ALSA MIDI"
    echo "  $0 jack              # Run with JACK MIDI"
    echo "  $0 setup             # Setup virtual MIDI ports"
    echo "  $0 test              # Test MIDI connections"
}

setup_midi() {
    echo -e "${YELLOW}Setting up MIDI environment...${NC}"
    
    # Check if running as root for modprobe
    if [[ $EUID -eq 0 ]]; then
        echo "Loading virtual MIDI kernel module..."
        modprobe snd-virmidi midi_devs=4 || echo "Virtual MIDI module may already be loaded"
    else
        echo "Please run with sudo to load virtual MIDI kernel module:"
        echo "sudo modprobe snd-virmidi midi_devs=4"
    fi
    
    # Create saved_phrases directory
    mkdir -p saved_phrases
    
    # Check audio group membership
    if groups $USER | grep -q '\baudio\b'; then
        echo -e "${GREEN}User is in audio group ✓${NC}"
    else
        echo -e "${YELLOW}Adding user to audio group...${NC}"
        echo "Please run: sudo usermod -a -G audio $USER"
        echo "Then log out and log back in."
    fi
    
    # List available MIDI devices
    echo -e "${BLUE}Available MIDI devices:${NC}"
    ls -la /dev/midi* 2>/dev/null || echo "No MIDI devices found"
    
    echo -e "${BLUE}ALSA MIDI connections:${NC}"
    aconnect -l 2>/dev/null || echo "aconnect not available"
}

test_midi() {
    echo -e "${YELLOW}Testing MIDI connectivity...${NC}"
    
    echo "Available MIDI devices:"
    ls -la /dev/midi* 2>/dev/null || echo "No MIDI devices found"
    
    echo ""
    echo "ALSA sequencer clients:"
    aconnect -l 2>/dev/null || echo "aconnect not available"
    
    echo ""
    echo "JACK MIDI ports (if JACK is running):"
    jack_lsp -t midi 2>/dev/null || echo "JACK not running or jack_lsp not available"
    
    echo ""
    echo "Audio group membership:"
    groups $USER | grep audio || echo "User not in audio group"
}

build_image() {
    echo -e "${YELLOW}Building line Docker image...${NC}"
    docker build -t line-sequencer .
    echo -e "${GREEN}Build complete!${NC}"
}

run_alsa() {
    echo -e "${YELLOW}Starting line with ALSA MIDI...${NC}"
    
    # Ensure saved_phrases directory exists
    mkdir -p saved_phrases
    
    docker-compose up line
}

run_jack() {
    echo -e "${YELLOW}Starting line with JACK MIDI...${NC}"
    
    # Check if JACK is running
    if ! pgrep -x "jackd" > /dev/null; then
        echo -e "${YELLOW}JACK is not running. Starting JACK...${NC}"
        echo "You may need to start JACK manually:"
        echo "jackd -d alsa -d hw:0 -r 44100 -p 1024 -n 2"
        echo ""
        read -p "Press Enter to continue or Ctrl+C to exit..."
    fi
    
    # Ensure saved_phrases directory exists
    mkdir -p saved_phrases
    
    docker-compose --profile jack up line-with-jack
}

clean_up() {
    echo -e "${YELLOW}Cleaning up Docker containers and images...${NC}"
    
    # Stop and remove containers
    docker-compose down 2>/dev/null || true
    
    # Remove containers
    docker rm -f line-sequencer line-sequencer-jack 2>/dev/null || true
    
    # Remove image
    docker rmi line-sequencer 2>/dev/null || true
    
    echo -e "${GREEN}Cleanup complete!${NC}"
}

# Parse command line arguments
MODE="alsa"
DEBUG=false

while [[ $# -gt 0 ]]; do
    case $1 in
        alsa|jack|build|setup|test|clean)
            MODE="$1"
            shift
            ;;
        --help|-h)
            print_usage
            exit 0
            ;;
        --debug)
            DEBUG=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            print_usage
            exit 1
            ;;
    esac
done

# Enable debug mode if requested
if [ "$DEBUG" = true ]; then
    set -x
fi

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Execute based on mode
case $MODE in
    alsa)
        run_alsa
        ;;
    jack)
        run_jack
        ;;
    build)
        build_image
        ;;
    setup)
        setup_midi
        ;;
    test)
        test_midi
        ;;
    clean)
        clean_up
        ;;
    *)
        echo -e "${RED}Invalid mode: $MODE${NC}"
        print_usage
        exit 1
        ;;
esac
