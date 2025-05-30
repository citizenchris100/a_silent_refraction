#!/bin/bash
# Script to run component tests headlessly from the command line
# Component tests verify the interaction between 2-3 closely related components/systems
#
# Usage:
#   ./tools/run_component_tests.sh                  # Run all component tests
#   ./tools/run_component_tests.sh test1 test2      # Run only specified tests
#   ./tools/run_component_tests.sh test1.tscn       # Run test with full name

# Configuration
GODOT_PATH="godot" # Change this to the path of your Godot executable if needed
PROJECT_PATH="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"
TEST_DIR="$PROJECT_PATH/src/component_tests"
LOG_DIR="$PROJECT_PATH/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/component_tests_$TIMESTAMP.log"
TEST_TIMEOUT=120 # Timeout in seconds for each test - longer than unit tests due to complexity

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Text colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display header
echo -e "${YELLOW}==========================================${NC}"
echo -e "${YELLOW}  Running A Silent Refraction Component Tests${NC}"
echo -e "${YELLOW}==========================================${NC}"
echo "Project path: $PROJECT_PATH"
echo "Test path: $TEST_DIR"
echo "Log file: $LOG_FILE"
echo ""

# Initialize global counters for total pass/fail across all tests
global_passes=0
global_fails=0

# Function to run a test
run_test() {
    local test_scene=$1
    local test_name=$(basename "$test_scene" .tscn)
    
    echo -e "${YELLOW}Running component test: ${test_name}${NC}"
    
    # Get custom timeout for specific tests that need more time
    local timeout_value=$TEST_TIMEOUT
    case "$test_name" in
        "camera_walkable_component_test"|"navigation_oscillation_component_test")
            timeout_value=$((TEST_TIMEOUT*2)) # Double timeout for complex tests
            echo -e "${BLUE}Using extended timeout ($timeout_value seconds) for complex component test${NC}"
            ;;
    esac
    
    # Run the test with Godot headless and a timeout
    echo -e "${BLUE}Executing: $GODOT_PATH --no-window --path $PROJECT_PATH $test_scene${NC}"
    timeout $timeout_value $GODOT_PATH --no-window --path "$PROJECT_PATH" "$test_scene" > "$LOG_DIR/${test_name}_${TIMESTAMP}.log" 2>&1
    local exit_code=$?
    
    # Set default status
    local failures=0
    
    # Check if the test ran successfully
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ Test process completed${NC}"
        
        # Extract and count unique test results to prevent double-counting
        # First, identify all test results and save them to a temp file
        local temp_file=$(mktemp)
        
        # Use grep to extract lines containing test results
        grep -E "PASS:|✓ PASS|PASS -" "$LOG_DIR/${test_name}_${TIMESTAMP}.log" > "${temp_file}_passes"
        grep -E "FAIL:|✗ FAIL|FAIL -" "$LOG_DIR/${test_name}_${TIMESTAMP}.log" > "${temp_file}_fails"
        
        # Extract test names to get unique tests
        # Parse lines like "[PREFIX] ✓ PASS: test_name" to extract "test_name"
        cat "${temp_file}_passes" | sed -E 's/.*PASS:? +(test_[^ ,:].*)( .*)?$/\1/' | sort | uniq > "${temp_file}_unique_passes"
        cat "${temp_file}_fails" | sed -E 's/.*FAIL:? +(test_[^ ,:].*)( .*)?$/\1/' | sort | uniq > "${temp_file}_unique_fails"
        
        # Count unique tests
        local passes=$(wc -l < "${temp_file}_unique_passes")
        local failures=$(wc -l < "${temp_file}_unique_fails")
        
        # Clean up temp files
        rm "${temp_file}_passes" "${temp_file}_fails" "${temp_file}_unique_passes" "${temp_file}_unique_fails"
        local total=$((passes + failures))
        
        # Update global counters
        global_passes=$((global_passes + passes))
        global_fails=$((global_fails + failures))
        
        # If no explicit test results found, check if there were any assertions
        if [ $total -eq 0 ]; then
            # Look for assertion failures or errors
            if grep -q -E "Assertion failed|ERROR|FAILED" "$LOG_DIR/${test_name}_${TIMESTAMP}.log"; then
                echo -e "${RED}✗ Test failed with errors${NC}"
                echo -e "${RED}Errors:${NC}"
                grep -E "Assertion failed|ERROR|FAILED" "$LOG_DIR/${test_name}_${TIMESTAMP}.log" | sed 's/^/  /'
                failures=1
                global_fails=$((global_fails + 1))
            else
                # No assertions found either, assume it passed
                echo -e "${BLUE}ℹ No explicit test results found, but no errors detected${NC}"
                passes=1
                global_passes=$((global_passes + 1))
            fi
            total=1
        fi
        
        # Display results
        if [ $failures -eq 0 ]; then
            echo -e "${GREEN}✓ All tests passed: $passes/$total${NC}"
        else
            echo -e "${RED}✗ Some tests failed: $passes/$total passed, $failures failed${NC}"
            # Print failed tests for all formats
            echo -e "${RED}Failed tests:${NC}"
            grep -E "FAIL:|✗ FAIL|FAIL -" "$LOG_DIR/${test_name}_${TIMESTAMP}.log" | sed 's/^/  /'
        fi
    elif [ $exit_code -eq 124 ]; then
        # Test timed out - count as failure
        echo -e "${RED}✗ Test timed out after $timeout_value seconds${NC}"
        failures=1
        global_fails=$((global_fails + 1))
    else
        # Any other error - count as failure
        echo -e "${RED}✗ Test failed to run (exit code: $exit_code)${NC}"
        failures=1
        global_fails=$((global_fails + 1))
    fi
    
    echo ""
    # Add to main log file
    echo "=== Component Test: $test_name ===" >> "$LOG_FILE"
    echo "Exit code: $exit_code" >> "$LOG_FILE"
    cat "$LOG_DIR/${test_name}_${TIMESTAMP}.log" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    
    # Return status (1 for any failures, 0 for success)
    return $failures
}

# Find all test scenes
# Find individual test files, or allow specific tests via command-line args
if [ "$#" -gt 0 ]; then
    # User specified specific tests to run
    test_files=""
    for test_name in "$@"; do
        if [[ "$test_name" == *".tscn" ]]; then
            # Already has .tscn extension
            found_file=$(find "$TEST_DIR" -name "$test_name" | head -n 1)
        else
            # Add .tscn extension
            found_file=$(find "$TEST_DIR" -name "${test_name}.tscn" | head -n 1)
        fi
        
        if [ -n "$found_file" ]; then
            test_files="$test_files\n$found_file"
        else
            echo -e "${RED}Warning: Test '$test_name' not found${NC}"
        fi
    done
    
    # Remove leading newline and convert to proper format for iteration
    test_files=$(echo -e "$test_files" | sed '/^$/d')
    
    if [ -z "$test_files" ]; then
        echo -e "${RED}No valid test files found for the specified test names${NC}"
        exit 1
    fi
else
    # Run all tests
    test_files=$(find "$TEST_DIR" -name "*.tscn" | sort)
fi

# Count test files
total_test_files=$(echo "$test_files" | wc -l)
if [ -z "$test_files" ]; then
    total_test_files=0
fi

# Initialize counters for test files
passed_test_files=0
failed_test_files=0

# Run each test
for test_file in $test_files; do
    run_test "$test_file"
    
    # Update test file counters based on return code
    if [ $? -eq 0 ]; then
        passed_test_files=$((passed_test_files + 1))
    else
        failed_test_files=$((failed_test_files + 1))
    fi
done

# Calculate total tests across all files
total_tests=$((global_passes + global_fails))

# Display summary
echo -e "${YELLOW}==========================================${NC}"
echo -e "${YELLOW}         Component Test Summary${NC}"
echo -e "${YELLOW}==========================================${NC}"
echo "Total component test files: $total_test_files"
echo -e "Files passed: ${GREEN}$passed_test_files${NC}"
echo -e "Files failed: ${RED}$failed_test_files${NC}"
echo ""
echo "Total individual tests: $total_tests"
echo -e "Tests passed: ${GREEN}$global_passes${NC}"
echo -e "Tests failed: ${RED}$global_fails${NC}"
echo ""
echo "Logs saved to: $LOG_FILE"
echo -e "${YELLOW}==========================================${NC}"

# Return non-zero exit code if any tests failed
if [ $failed_test_files -gt 0 ] || [ $global_fails -gt 0 ]; then
    exit 1
fi
exit 0