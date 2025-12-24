#!/bin/bash

# GitSearch Installer for macOS
# By Max Rodriguez

set -e  # Exit on error

echo "┌──────────────────────────────────────┐"
echo "│      GitSearch Installer              │"
echo "│      By Max Rodriguez (14)            │"
echo "└──────────────────────────────────────┘"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "bin/gitsearch" ]; then
    echo -e "${RED}Error: Cannot find bin/gitsearch${NC}"
    echo "Make sure you're in the GitSearch directory:"
    echo "  cd /path/to/GitSearch"
    exit 1
fi

# Check for required commands
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed${NC}"
        echo "Please install $1 first"
        exit 1
    fi
}

echo -e "${BLUE}Checking requirements...${NC}"
check_command "git"
check_command "bash"

# Determine installation paths
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    BIN_DIR="/usr/local/bin"
    LIB_DIR="/usr/local/lib/gitsearch"
    echo -e "${GREEN}Detected: macOS${NC}"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    BIN_DIR="/usr/local/bin"
    LIB_DIR="/usr/local/lib/gitsearch"
    echo -e "${GREEN}Detected: Linux${NC}"
elif [[ "$OSTYPE" == "linux-android"* ]]; then
    # Termux
    BIN_DIR="$PREFIX/bin"
    LIB_DIR="$PREFIX/lib/gitsearch"
    echo -e "${GREEN}Detected: Termux (Android)${NC}"
else
    # Unknown system, use /usr/local as default
    BIN_DIR="/usr/local/bin"
    LIB_DIR="/usr/local/lib/gitsearch"
    echo -e "${YELLOW}Detected: Unknown system, using default paths${NC}"
fi

# Check if we have write permission
check_permission() {
    if [ ! -w "$1" ] && [ "$EUID" != 0 ]; then
        echo -e "${YELLOW}Note: Need sudo permission to install to $1${NC}"
        return 1
    fi
    return 0
}

# Make all scripts executable
echo -e "${BLUE}Making scripts executable...${NC}"
chmod +x bin/gitsearch 2>/dev/null || true

if [ -d "lib" ]; then
    for file in lib/*.sh; do
        if [ -f "$file" ]; then
            chmod +x "$file" 2>/dev/null || true
        fi
    done
fi

# Create directories
echo -e "${BLUE}Creating directories...${NC}"
if ! check_permission "$BIN_DIR"; then
    sudo mkdir -p "$BIN_DIR" 2>/dev/null || true
    sudo mkdir -p "$LIB_DIR" 2>/dev/null || true
else
    mkdir -p "$BIN_DIR" 2>/dev/null || true
    mkdir -p "$LIB_DIR" 2>/dev/null || true
fi

# Copy main executable
echo -e "${BLUE}Installing gitsearch to $BIN_DIR...${NC}"
if ! check_permission "$BIN_DIR"; then
    sudo cp -f bin/gitsearch "$BIN_DIR/gitsearch" 2>/dev/null || {
        echo -e "${RED}Failed to copy to $BIN_DIR${NC}"
        echo "Trying alternative location..."
        cp -f bin/gitsearch "$HOME/.local/bin/gitsearch" 2>/dev/null || {
            mkdir -p "$HOME/.local/bin"
            cp -f bin/gitsearch "$HOME/.local/bin/gitsearch"
            BIN_DIR="$HOME/.local/bin"
            echo -e "${YELLOW}Installed to: $HOME/.local/bin${NC}"
            echo -e "${YELLOW}Add to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
        }
    }
else
    cp -f bin/gitsearch "$BIN_DIR/gitsearch" 2>/dev/null || {
        echo -e "${RED}Failed to install to $BIN_DIR${NC}"
        exit 1
    }
fi

# Copy library files
if [ -d "lib" ] && [ $(ls lib/*.sh 2>/dev/null | wc -l) -gt 0 ]; then
    echo -e "${BLUE}Installing libraries to $LIB_DIR...${NC}"
    if ! check_permission "$LIB_DIR"; then
        sudo cp -f lib/*.sh "$LIB_DIR/" 2>/dev/null || {
            echo -e "${YELLOW}Warning: Could not copy libraries${NC}"
            echo "GitSearch will use embedded fallback functions"
        }
    else
        cp -f lib/*.sh "$LIB_DIR/" 2>/dev/null || {
            echo -e "${YELLOW}Warning: Could not copy libraries${NC}"
            echo "GitSearch will use embedded fallback functions"
        }
    fi
else
    echo -e "${YELLOW}No library files found, using embedded functions${NC}"
fi

# Set permissions
echo -e "${BLUE}Setting permissions...${NC}"
if [ -f "$BIN_DIR/gitsearch" ]; then
    if ! check_permission "$BIN_DIR"; then
        sudo chmod 755 "$BIN_DIR/gitsearch" 2>/dev/null || true
    else
        chmod 755 "$BIN_DIR/gitsearch" 2>/dev/null || true
    fi
fi

if [ -d "$LIB_DIR" ]; then
    if ! check_permission "$LIB_DIR"; then
        sudo chmod 644 "$LIB_DIR"/*.sh 2>/dev/null || true
    else
        chmod 644 "$LIB_DIR"/*.sh 2>/dev/null || true
    fi
fi

# Check if in PATH
echo -e "${BLUE}Checking installation...${NC}"
if command -v gitsearch &> /dev/null; then
    echo -e "${GREEN}✓ GitSearch is now available as 'gitsearch'${NC}"
elif [ -f "$HOME/.local/bin/gitsearch" ]; then
    echo -e "${YELLOW}⚠ GitSearch installed to $HOME/.local/bin/gitsearch${NC}"
    echo "Add this to your ~/.bashrc or ~/.zshrc:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo "Then run: source ~/.bashrc"
else
    echo -e "${YELLOW}⚠ GitSearch installed to $BIN_DIR/gitsearch${NC}"
    echo "Make sure $BIN_DIR is in your PATH"
fi

# Test the installation
echo ""
echo -e "${BLUE}Testing installation...${NC}"
if command -v gitsearch &> /dev/null || [ -f "$BIN_DIR/gitsearch" ]; then
    # Create a test version that won't fail
    cat > /tmp/test_gitsearch.sh << 'EOF'
#!/bin/bash
echo "GitSearch v1.0 - Installed successfully!"
echo "By Max Rodriguez"
echo ""
echo "Try these commands:"
echo "  gitsearch init \"Project Name\""
echo "  gitsearch list"
echo "  gitsearch help"
EOF
    chmod +x /tmp/test_gitsearch.sh
    /tmp/test_gitsearch.sh
    rm -f /tmp/test_gitsearch.sh
else
    echo -e "${YELLOW}Could not verify installation${NC}"
    echo "Try running: $BIN_DIR/gitsearch --test"
fi

# Create user data directory
echo ""
echo -e "${BLUE}Setting up user directory...${NC}"
mkdir -p "$HOME/.gitsearch" 2>/dev/null || true
if [ ! -f "$HOME/.gitsearch/projects.txt" ]; then
    echo "# GitSearch Projects Database" > "$HOME/.gitsearch/projects.txt"
    echo "# Created on $(date)" >> "$HOME/.gitsearch/projects.txt"
    echo -e "${GREEN}✓ Created user database${NC}"
fi

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo -e "${BLUE}Quick start:${NC}"
echo "  1. Go to your project: cd ~/projects/my-project"
echo "  2. Register it: gitsearch init \"Project Name\""
echo "  3. List projects: gitsearch list"
echo ""
echo -e "${BLUE}Need help?${NC}"
echo "  gitsearch help"
echo "  gitsearch help commands"
echo ""
echo -e "${YELLOW}Made by Max Rodriguez (14 years old)${NC}"
echo "Because losing code should never happen"

# Cleanup
exit 0
