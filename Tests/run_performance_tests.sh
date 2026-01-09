#!/bin/bash

# Performance Test Runner for WorkTimeReminder
# This script runs various performance tests and generates a report

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="WorkTimeReminder"
APP_PATH="/Applications/$APP_NAME.app"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         WorkTimeReminder Performance Test Suite               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to print section header
print_section() {
    echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Function to check if app is running
check_app_running() {
    if pgrep -x "$APP_NAME" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to get app PID
get_app_pid() {
    pgrep -x "$APP_NAME" || echo ""
}

# Function to measure memory
measure_memory() {
    local pid=$1
    if [ -n "$pid" ]; then
        ps -p "$pid" -o rss= 2>/dev/null | awk '{print $1/1024}'
    else
        echo "0"
    fi
}

# Function to measure CPU
measure_cpu() {
    local pid=$1
    if [ -n "$pid" ]; then
        ps -p "$pid" -o %cpu= 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Test 1: App Bundle Size
print_section "Test 1: App Bundle Size"

if [ -d "$APP_PATH" ]; then
    BUNDLE_SIZE=$(du -sh "$APP_PATH" | awk '{print $1}')
    BUNDLE_SIZE_BYTES=$(du -s "$APP_PATH" | awk '{print $1}')
    
    echo "📦 App Bundle: $APP_PATH"
    echo "📏 Size: $BUNDLE_SIZE"
    
    # Bundle should be less than 10MB for a simple menu bar app
    if [ "$BUNDLE_SIZE_BYTES" -lt 10240 ]; then
        echo -e "${GREEN}✅ PASS: Bundle size is reasonable (< 10MB)${NC}"
    else
        echo -e "${RED}❌ FAIL: Bundle size is too large${NC}"
    fi
else
    echo -e "${RED}❌ App not found at $APP_PATH${NC}"
    echo "   Please build and install the app first"
fi

# Test 2: Startup Time
print_section "Test 2: Startup Time"

if [ -d "$APP_PATH" ]; then
    # Kill app if running
    if check_app_running; then
        echo "Stopping existing instance..."
        pkill -x "$APP_NAME" 2>/dev/null || true
        sleep 1
    fi
    
    echo "Measuring startup time..."
    START_TIME=$(python3 -c 'import time; print(time.time())')
    open "$APP_PATH"
    
    # Wait for app to start (max 5 seconds)
    TIMEOUT=5
    ELAPSED=0
    while ! check_app_running && [ $ELAPSED -lt $TIMEOUT ]; do
        sleep 0.1
        ELAPSED=$((ELAPSED + 1))
    done
    
    END_TIME=$(python3 -c 'import time; print(time.time())')
    STARTUP_TIME=$(python3 -c "print(f'{($END_TIME - $START_TIME):.3f}')")
    
    if check_app_running; then
        echo "⏱️  Startup time: ${STARTUP_TIME}s"
        
        # Startup should be less than 2 seconds
        STARTUP_OK=$(python3 -c "print('1' if $STARTUP_TIME < 2.0 else '0')")
        if [ "$STARTUP_OK" = "1" ]; then
            echo -e "${GREEN}✅ PASS: Startup time is fast (< 2s)${NC}"
        else
            echo -e "${RED}❌ FAIL: Startup time is slow${NC}"
        fi
    else
        echo -e "${RED}❌ App failed to start${NC}"
    fi
fi

# Test 3: Idle Resource Usage
print_section "Test 3: Idle Resource Usage (10 second sample)"

if check_app_running; then
    PID=$(get_app_pid)
    echo "📍 App PID: $PID"
    echo ""
    echo "Collecting samples..."
    
    TOTAL_MEM=0
    TOTAL_CPU=0
    SAMPLES=10
    
    for i in $(seq 1 $SAMPLES); do
        MEM=$(measure_memory "$PID")
        CPU=$(measure_cpu "$PID")
        TOTAL_MEM=$(python3 -c "print($TOTAL_MEM + $MEM)")
        TOTAL_CPU=$(python3 -c "print($TOTAL_CPU + $CPU)")
        printf "  Sample %2d: Memory: %6.2f MB, CPU: %5.2f%%\n" "$i" "$MEM" "$CPU"
        sleep 1
    done
    
    AVG_MEM=$(python3 -c "print(f'{$TOTAL_MEM / $SAMPLES:.2f}')")
    AVG_CPU=$(python3 -c "print(f'{$TOTAL_CPU / $SAMPLES:.2f}')")
    
    echo ""
    echo "📊 Average Memory: ${AVG_MEM} MB"
    echo "📊 Average CPU: ${AVG_CPU}%"
    
    # Memory should be < 80MB for SwiftUI app, CPU should be < 3% when idle (timer updates)
    MEM_OK=$(python3 -c "print('1' if $AVG_MEM < 80 else '0')")
    CPU_OK=$(python3 -c "print('1' if $AVG_CPU < 3 else '0')")
    
    if [ "$MEM_OK" = "1" ]; then
        echo -e "${GREEN}✅ Memory PASS: < 80MB (normal for SwiftUI)${NC}"
    else
        echo -e "${RED}❌ Memory FAIL: >= 80MB${NC}"
    fi
    
    if [ "$CPU_OK" = "1" ]; then
        echo -e "${GREEN}✅ CPU PASS: < 3% (includes status bar updates)${NC}"
    else
        echo -e "${YELLOW}⚠️  CPU WARNING: >= 3%${NC}"
    fi
else
    echo -e "${RED}❌ App is not running${NC}"
fi

# Test 4: Energy Impact (using powermetrics if available)
print_section "Test 4: Energy Impact Assessment"

echo "Checking energy impact indicators..."

if check_app_running; then
    PID=$(get_app_pid)
    
    # Check if app prevents sleep
    ASSERTIONS=$(pmset -g assertions 2>/dev/null | grep -c "$APP_NAME" || echo "0")
    
    if [ "$ASSERTIONS" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  App has power assertions (may be intentional for Keep Awake feature)${NC}"
    else
        echo -e "${GREEN}✅ No power assertions (app allows system sleep)${NC}"
    fi
    
    # Check thread count
    THREADS=$(ps -M -p "$PID" 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
    
    echo "🧵 Thread count: $THREADS"
    
    if [ "$THREADS" -lt 15 ]; then
        echo -e "${GREEN}✅ Thread count is reasonable (< 15)${NC}"
    elif [ "$THREADS" -lt 25 ]; then
        echo -e "${YELLOW}⚠️  Thread count is moderate (< 25)${NC}"
    else
        echo -e "${RED}❌ Thread count is high (>= 25)${NC}"
    fi
fi

# Test 5: Memory Leak Check (simple)
print_section "Test 5: Memory Stability Check (30 seconds)"

if check_app_running; then
    PID=$(get_app_pid)
    
    INITIAL_MEM=$(measure_memory "$PID")
    echo "📍 Initial memory: ${INITIAL_MEM} MB"
    echo "Monitoring for 30 seconds..."
    
    sleep 30
    
    FINAL_MEM=$(measure_memory "$PID")
    MEM_DIFF=$(python3 -c "print(f'{$FINAL_MEM - $INITIAL_MEM:.2f}')")
    
    echo "📍 Final memory: ${FINAL_MEM} MB"
    echo "📊 Memory change: ${MEM_DIFF} MB"
    
    # Memory shouldn't grow more than 10MB in 30 seconds (decrease is OK - GC)
    MEM_GROWTH=$(python3 -c "print($MEM_DIFF)")
    MEM_STABLE=$(python3 -c "print('1' if $MEM_GROWTH < 10 else '0')")
    
    if [ "$MEM_STABLE" = "1" ]; then
        if python3 -c "exit(0 if $MEM_GROWTH <= 0 else 1)"; then
            echo -e "${GREEN}✅ PASS: Memory stable/decreased (good GC)${NC}"
        else
            echo -e "${GREEN}✅ PASS: Memory growth minimal (< 10MB)${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  WARNING: Memory grew significantly (>= 10MB)${NC}"
    fi
fi

# Summary
print_section "Performance Test Summary"

echo "Test results have been collected."
echo ""
echo "For more detailed real-time monitoring, run:"
echo "  swift Tests/PerformanceTests/PerformanceMonitor.swift [duration_seconds]"
echo ""
echo "Example:"
echo "  swift Tests/PerformanceTests/PerformanceMonitor.swift 60"
echo ""

# Overall assessment
echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Performance Assessment Complete${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

