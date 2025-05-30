#!/bin/bash

# Run subsystem tests for A Silent Refraction
# These tests verify that multiple components work together as cohesive subsystems

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GODOT_EXECUTABLE="godot"
SUBSYSTEM_TEST_DIR="src/subsystem_tests"
LOG_DIR="logs/subsystem_tests"
TIMEOUT=300  # 5 minutes timeout for subsystem tests (they're longer)

# Command line arguments
TEST_PATTERN="$1"
VISUAL_FLAG=""
PROFILE_FLAG=""
HEADLESS_FLAG="--no-window"

# Parse additional flags
for arg in "$@"; do
    case $arg in
        --visual)
            VISUAL_FLAG="--visual"
            HEADLESS_FLAG=""  # Can't be headless with visual tests
            ;;
        --profile)
            PROFILE_FLAG="--profile"
            ;;
        --headless)
            HEADLESS_FLAG="--no-window"
            ;;
        --timeout=*)
            TIMEOUT="${arg#*=}"
            ;;
    esac
done

# Create log directory with timestamp
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Function to run a single subsystem test
run_subsystem_test() {
    local test_name="$1"
    local test_scene="$SUBSYSTEM_TEST_DIR/${test_name}.tscn"
    local log_file="$LOG_DIR/${test_name}_${TIMESTAMP}.log"
    
    # Check if test scene exists
    if [ ! -f "$test_scene" ]; then
        echo -e "${RED}✗ Test scene not found: $test_scene${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Running subsystem test: ${test_name}${NC}"
    
    # Run the test with timeout
    timeout "$TIMEOUT" $GODOT_EXECUTABLE $HEADLESS_FLAG --path "$PROJECT_ROOT" "$test_scene" $VISUAL_FLAG $PROFILE_FLAG > "$log_file" 2>&1
    local exit_code=$?
    
    # Check if it was a timeout (exit code 124)
    if [ $exit_code -eq 124 ]; then
        echo -e "${RED}✗ ${test_name} - TIMEOUT (exceeded ${TIMEOUT}s)${NC}"
        
        # Kill any remaining Godot processes
        pkill -f "$test_scene" 2>/dev/null
        
        return 1
    elif [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ ${test_name} - PASSED${NC}"
        
        # Show performance summary if profiling
        if [ ! -z "$PROFILE_FLAG" ]; then
            grep -A5 "Performance Summary:" "$log_file" | tail -n +2
        fi
        
        return 0
    else
        echo -e "${RED}✗ ${test_name} - FAILED (exit code: $exit_code)${NC}"
        
        # Show failure summary
        echo "Failed tests:"
        grep "✗ FAIL:" "$log_file" | head -10
        
        # Show any errors
        if grep -q "ERROR" "$log_file"; then
            echo "Errors detected:"
            grep "ERROR" "$log_file" | head -5
        fi
        
        return 1
    fi
}

# Function to discover subsystem tests
discover_subsystem_tests() {
    local pattern="$1"
    
    if [ -z "$pattern" ]; then
        # Find all subsystem test files
        find "$SUBSYSTEM_TEST_DIR" -name "*_subsystem_test.tscn" -type f | while read -r scene; do
            basename "$scene" .tscn
        done
    else
        # Find matching test files
        find "$SUBSYSTEM_TEST_DIR" -name "*${pattern}*.tscn" -type f | while read -r scene; do
            local test_name=$(basename "$scene" .tscn)
            if [[ "$test_name" == *"_subsystem_test" ]] || [[ "$test_name" == *"_subsystem"* ]]; then
                echo "$test_name"
            fi
        done
    fi
}

# Main execution
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}A Silent Refraction - Subsystem Tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Show configuration
echo "Configuration:"
echo "  Test pattern: ${TEST_PATTERN:-all}"
echo "  Visual mode: $([ -z "$VISUAL_FLAG" ] && echo "disabled" || echo "enabled")"
echo "  Profiling: $([ -z "$PROFILE_FLAG" ] && echo "disabled" || echo "enabled")"
echo "  Timeout: ${TIMEOUT}s"
echo "  Log directory: $LOG_DIR"
echo ""

# Discover tests to run
echo "Discovering subsystem tests..."
TESTS=$(discover_subsystem_tests "$TEST_PATTERN")

if [ -z "$TESTS" ]; then
    echo -e "${YELLOW}No subsystem tests found matching pattern: ${TEST_PATTERN}${NC}"
    exit 0
fi

# Count tests
TEST_COUNT=$(echo "$TESTS" | wc -l)
echo "Found $TEST_COUNT subsystem test(s) to run"
echo ""

# Run tests
PASSED=0
FAILED=0
MASTER_LOG="$LOG_DIR/subsystem_tests_${TIMESTAMP}.log"

echo "Starting test execution..." | tee "$MASTER_LOG"
echo "=========================" | tee -a "$MASTER_LOG"

for test in $TESTS; do
    echo "" | tee -a "$MASTER_LOG"
    
    if run_subsystem_test "$test"; then
        ((PASSED++))
        echo "[$test] PASSED" >> "$MASTER_LOG"
    else
        ((FAILED++))
        echo "[$test] FAILED" >> "$MASTER_LOG"
    fi
done

# Summary
echo "" | tee -a "$MASTER_LOG"
echo -e "${BLUE}========================================${NC}" | tee -a "$MASTER_LOG"
echo -e "${BLUE}Test Summary${NC}" | tee -a "$MASTER_LOG"
echo -e "${BLUE}========================================${NC}" | tee -a "$MASTER_LOG"
echo -e "Total: $TEST_COUNT" | tee -a "$MASTER_LOG"
echo -e "${GREEN}Passed: $PASSED${NC}" | tee -a "$MASTER_LOG"
echo -e "${RED}Failed: $FAILED${NC}" | tee -a "$MASTER_LOG"
echo "" | tee -a "$MASTER_LOG"

# Generate performance report if profiling was enabled
if [ ! -z "$PROFILE_FLAG" ]; then
    echo "Generating performance report..."
    PERF_REPORT="$LOG_DIR/performance_report_${TIMESTAMP}.json"
    
    # Aggregate performance data from logs
    {
        echo "{"
        echo "  \"timestamp\": \"$TIMESTAMP\","
        echo "  \"tests\": ["
        
        first=true
        for test in $TESTS; do
            log_file="$LOG_DIR/${test}_${TIMESTAMP}.log"
            if [ -f "$log_file" ] && grep -q "Performance Summary:" "$log_file"; then
                if [ "$first" = false ]; then
                    echo ","
                fi
                first=false
                
                echo "    {"
                echo "      \"name\": \"$test\","
                echo "      \"metrics\": {"
                
                # Extract performance metrics
                avg_frame=$(grep "Avg Frame Time:" "$log_file" | sed 's/.*: \([0-9.]*\)ms.*/\1/')
                max_frame=$(grep "Max Frame Time:" "$log_file" | sed 's/.*: \([0-9.]*\)ms.*/\1/')
                
                echo "        \"avg_frame_time\": ${avg_frame:-0},"
                echo "        \"max_frame_time\": ${max_frame:-0}"
                echo "      }"
                echo -n "    }"
            fi
        done
        
        echo ""
        echo "  ]"
        echo "}"
    } > "$PERF_REPORT"
    
    echo "Performance report saved to: $PERF_REPORT"
fi

# Exit with appropriate code
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All subsystem tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some subsystem tests failed!${NC}"
    echo "Check logs in: $LOG_DIR"
    exit 1
fi