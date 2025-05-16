#!/bin/bash

# Simple script to test polygon visualizer
# It runs the camera test and enables debug tools

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Run the camera test with debug tools enabled
echo -e "${GREEN}Running camera test with debug tools enabled...${NC}"
echo -e "${GREEN}Press F2 to toggle the polygon visualizer on/off${NC}"
echo -e "${GREEN}This should show/hide the big green box${NC}"
cd /home/chris/Documents/repos/a_silent_refraction
./a_silent_refraction.sh camera