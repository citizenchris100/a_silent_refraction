#!/bin/bash

# test_iteration_planner.sh - Test script for the enhanced iteration planner

echo "Testing Enhanced Iteration Planner..."
echo "======================================"
echo ""

# Create a test directory
TEST_DIR="iteration_planner_test"
mkdir -p ${TEST_DIR}
cd ${TEST_DIR}

# Copy the new script
cp ../iteration_planner.sh.new ./iteration_planner.sh
chmod +x ./iteration_planner.sh

echo "1. Testing initialization..."
./iteration_planner.sh init
if [ -d "docs/iterations" ] && [ -f "docs/iteration_progress.md" ]; then
    echo "   ✅ Initialization successful"
else
    echo "   ❌ Initialization failed"
    exit 1
fi

echo ""
echo "2. Testing iteration creation with requirements..."
# Remove existing iteration if it exists
rm -f docs/iterations/iteration99_plan.md

./iteration_planner.sh create 99 "Test Iteration"
if [ -f "docs/iterations/iteration99_plan.md" ]; then
    echo "   ✅ Iteration creation successful"
else
    echo "   ❌ Iteration creation failed"
    exit 1
fi

# Check if Requirements section exists
if grep -q "## Requirements" "docs/iterations/iteration99_plan.md"; then
    echo "   ✅ Requirements section exists"
else
    echo "   ❌ Requirements section missing"
    exit 1
fi

echo ""
echo "3. Testing add-req command..."
./iteration_planner.sh add-req 99 business "New business requirement for testing"
if grep -q "New business requirement for testing" "docs/iterations/iteration99_plan.md"; then
    echo "   ✅ Business requirement added successfully"
else
    echo "   ❌ Business requirement not added"
    exit 1
fi

./iteration_planner.sh add-req 99 user "New user requirement for testing"
if grep -q "New user requirement for testing" "docs/iterations/iteration99_plan.md"; then
    echo "   ✅ User requirement added successfully"
else
    echo "   ❌ User requirement not added"
    exit 1
fi

echo ""
echo "4. Testing add-story command..."
./iteration_planner.sh add-story 99 1 "As a tester, I want to verify the iteration planner, so that I can ensure it works correctly"
if grep -q "As a tester, I want to verify" "docs/iterations/iteration99_plan.md"; then
    echo "   ✅ User story added successfully"
else
    echo "   ❌ User story not added"
    exit 1
fi

echo ""
echo "5. Testing report generation with requirements..."
./iteration_planner.sh report > report_output.txt
if grep -q "Key Requirements" "docs/iteration_progress.md"; then
    echo "   ✅ Report includes requirements section"
else
    echo "   ❌ Requirements missing from report"
    exit 1
fi

echo ""
echo "Test Summary:"
echo "============="
echo "All tests passed! The enhanced iteration planner is working correctly."
echo ""
echo "Cleaning up test directory..."

# Clean up
cd ..
rm -rf ${TEST_DIR}

echo "Done!"