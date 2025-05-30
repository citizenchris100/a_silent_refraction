#!/bin/bash
# Omni Test Runner for A Silent Refraction
# Runs all test types in sequential, gated fashion: Unit -> Component -> Subsystem
# Each subsequent test type only runs if the previous type passes completely

# Configuration
PROJECT_PATH="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"
TOOLS_DIR="$PROJECT_PATH/tools"
LOG_DIR="$PROJECT_PATH/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SUMMARY_LOG="$LOG_DIR/all_tests_summary_$TIMESTAMP.log"

# Text colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Test results tracking
UNIT_PASSED=0
COMPONENT_PASSED=0
SUBSYSTEM_PASSED=0
TOTAL_TIME_START=$(date +%s)

# Display header
echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}   A Silent Refraction - Omni Test Runner${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""
echo -e "${BLUE}Test Execution Order:${NC}"
echo "  1. Unit Tests (single component isolation)"
echo "  2. Component Tests (2-3 components interaction)"
echo "  3. Subsystem Tests (4+ components integration)"
echo ""
echo -e "${YELLOW}Note: Each test type must pass completely before the next type runs${NC}"
echo ""

# Initialize summary log
echo "A Silent Refraction - Test Execution Summary" > "$SUMMARY_LOG"
echo "===========================================" >> "$SUMMARY_LOG"
echo "Started at: $(date)" >> "$SUMMARY_LOG"
echo "" >> "$SUMMARY_LOG"

# Function to run a test type
run_test_type() {
    local test_type=$1
    local test_script=$2
    local test_description=$3
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Running $test_type Tests${NC}"
    echo -e "${BLUE}$test_description${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Record start time
    local start_time=$(date +%s)
    
    # Run the test script
    "$test_script"
    local exit_code=$?
    
    # Record end time
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Log results
    echo "" >> "$SUMMARY_LOG"
    echo "$test_type Tests:" >> "$SUMMARY_LOG"
    echo "  Duration: ${duration}s" >> "$SUMMARY_LOG"
    
    if [ $exit_code -eq 0 ]; then
        echo -e "\n${GREEN}✓ $test_type Tests PASSED${NC} (${duration}s)\n"
        echo "  Result: PASSED" >> "$SUMMARY_LOG"
        return 0
    else
        echo -e "\n${RED}✗ $test_type Tests FAILED${NC} (${duration}s)\n"
        echo "  Result: FAILED" >> "$SUMMARY_LOG"
        return 1
    fi
}

# Run Unit Tests
echo -e "${CYAN}[1/3] UNIT TESTS${NC}"
if run_test_type "Unit" "$TOOLS_DIR/run_unit_tests.sh" "Testing single components in isolation"; then
    UNIT_PASSED=1
else
    echo -e "${RED}❌ Unit tests failed - stopping test execution${NC}"
    echo -e "${RED}   Fix unit test failures before running other test types${NC}"
    echo "" >> "$SUMMARY_LOG"
    echo "Test execution halted: Unit tests failed" >> "$SUMMARY_LOG"
fi

# Run Component Tests (only if unit tests passed)
if [ $UNIT_PASSED -eq 1 ]; then
    echo -e "${CYAN}[2/3] COMPONENT TESTS${NC}"
    if run_test_type "Component" "$TOOLS_DIR/run_component_tests.sh" "Testing 2-3 components working together"; then
        COMPONENT_PASSED=1
    else
        echo -e "${RED}❌ Component tests failed - stopping test execution${NC}"
        echo -e "${RED}   Fix component test failures before running subsystem tests${NC}"
        echo "" >> "$SUMMARY_LOG"
        echo "Test execution halted: Component tests failed" >> "$SUMMARY_LOG"
    fi
fi

# Run Subsystem Tests (only if component tests passed)
if [ $COMPONENT_PASSED -eq 1 ]; then
    echo -e "${CYAN}[3/3] SUBSYSTEM TESTS${NC}"
    if run_test_type "Subsystem" "$TOOLS_DIR/run_subsystem_tests.sh" "Testing 4+ components as complete features"; then
        SUBSYSTEM_PASSED=1
    fi
fi

# Calculate total time
TOTAL_TIME_END=$(date +%s)
TOTAL_DURATION=$((TOTAL_TIME_END - TOTAL_TIME_START))

# Display final summary
echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}           Test Execution Summary${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""

# Summary in log
echo "" >> "$SUMMARY_LOG"
echo "Final Summary:" >> "$SUMMARY_LOG"
echo "===========================================" >> "$SUMMARY_LOG"

if [ $UNIT_PASSED -eq 1 ]; then
    echo -e "Unit Tests:      ${GREEN}✓ PASSED${NC}"
    echo "Unit Tests:      PASSED" >> "$SUMMARY_LOG"
else
    echo -e "Unit Tests:      ${RED}✗ FAILED${NC}"
    echo "Unit Tests:      FAILED" >> "$SUMMARY_LOG"
fi

if [ $UNIT_PASSED -eq 1 ]; then
    if [ $COMPONENT_PASSED -eq 1 ]; then
        echo -e "Component Tests: ${GREEN}✓ PASSED${NC}"
        echo "Component Tests: PASSED" >> "$SUMMARY_LOG"
    else
        echo -e "Component Tests: ${RED}✗ FAILED${NC}"
        echo "Component Tests: FAILED" >> "$SUMMARY_LOG"
    fi
else
    echo -e "Component Tests: ${YELLOW}⊗ SKIPPED${NC} (unit tests failed)"
    echo "Component Tests: SKIPPED (unit tests failed)" >> "$SUMMARY_LOG"
fi

if [ $COMPONENT_PASSED -eq 1 ]; then
    if [ $SUBSYSTEM_PASSED -eq 1 ]; then
        echo -e "Subsystem Tests: ${GREEN}✓ PASSED${NC}"
        echo "Subsystem Tests: PASSED" >> "$SUMMARY_LOG"
    else
        echo -e "Subsystem Tests: ${RED}✗ FAILED${NC}"
        echo "Subsystem Tests: FAILED" >> "$SUMMARY_LOG"
    fi
else
    echo -e "Subsystem Tests: ${YELLOW}⊗ SKIPPED${NC} (previous tests failed)"
    echo "Subsystem Tests: SKIPPED (previous tests failed)" >> "$SUMMARY_LOG"
fi

echo ""
echo -e "Total Duration: ${BLUE}${TOTAL_DURATION}s${NC}"
echo "" >> "$SUMMARY_LOG"
echo "Total Duration: ${TOTAL_DURATION}s" >> "$SUMMARY_LOG"
echo "Completed at: $(date)" >> "$SUMMARY_LOG"

# Overall result
if [ $SUBSYSTEM_PASSED -eq 1 ]; then
    echo -e "\n${GREEN}✅ ALL TESTS PASSED!${NC}"
    echo "" >> "$SUMMARY_LOG"
    echo "Overall Result: ALL TESTS PASSED" >> "$SUMMARY_LOG"
    EXIT_CODE=0
else
    echo -e "\n${RED}❌ TEST SUITE INCOMPLETE${NC}"
    echo "" >> "$SUMMARY_LOG"
    echo "Overall Result: TEST SUITE INCOMPLETE" >> "$SUMMARY_LOG"
    EXIT_CODE=1
fi

echo ""
echo -e "${BLUE}Summary log saved to: $SUMMARY_LOG${NC}"
echo -e "${CYAN}==========================================${NC}"

exit $EXIT_CODE