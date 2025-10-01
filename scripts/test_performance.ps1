# Performance-Optimized Test Execution Script
#
# This script runs tests with performance monitoring and parallelization
# for maximum efficiency while preventing timeouts and memory leaks.

param(
    [string]$TestPath = "test/",
    [int]$Concurrency = 4,
    [int]$TimeoutSeconds = 30,
    [switch]$Coverage,
    [switch]$Verbose,
    [string]$Tags = ""
)

Write-Host "🚀 Starting Performance-Optimized Test Suite" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Performance monitoring setup
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$startTime = Get-Date

Write-Host "⚙️  Configuration:" -ForegroundColor Yellow
Write-Host "   Test Path: $TestPath"
Write-Host "   Concurrency: $Concurrency"
Write-Host "   Timeout: $TimeoutSeconds seconds"
if ($Coverage) {
    Write-Host "   Coverage: Enabled"
} else {
    Write-Host "   Coverage: Disabled"
}
Write-Host ""

# Build command with optimizations
$testCommand = "flutter test"

# Add path
if ($TestPath -ne "test/") {
    $testCommand += " $TestPath"
}

# Add performance optimizations
$testCommand += " --timeout=${TimeoutSeconds}s"
$testCommand += " --concurrency=$Concurrency"
$testCommand += " --reporter=expanded"

# Add coverage if requested
if ($Coverage) {
    $testCommand += " --coverage"
    Write-Host "📊 Coverage analysis enabled" -ForegroundColor Blue
}

# Add tags filter if specified
if ($Tags) {
    $testCommand += " --tags $Tags"
    Write-Host "🏷️  Running tests with tags: $Tags" -ForegroundColor Blue
}

# Verbose output
if ($Verbose) {
    $testCommand += " --verbose"
}

Write-Host "🔧 Executing: $testCommand" -ForegroundColor Cyan
Write-Host ""

try {
    # Execute tests
    Invoke-Expression $testCommand
    $exitCode = $LASTEXITCODE

    $stopwatch.Stop()
    $duration = $stopwatch.Elapsed

    Write-Host ""
    Write-Host "📈 Performance Summary:" -ForegroundColor Green
    Write-Host "   Duration: $($duration.ToString('mm\:ss\.fff'))"
    Write-Host "   Start Time: $($startTime.ToString('HH:mm:ss'))"
    Write-Host "   End Time: $((Get-Date).ToString('HH:mm:ss'))"

    if ($exitCode -eq 0) {
        Write-Host "✅ All tests completed successfully!" -ForegroundColor Green

        # Show coverage summary if enabled
        if ($Coverage -and (Test-Path "coverage/lcov.info")) {
            Write-Host ""
            Write-Host "📊 Generating coverage report..." -ForegroundColor Blue

            # Try to generate HTML coverage report
            try {
                if (Get-Command genhtml -ErrorAction SilentlyContinue) {
                    genhtml coverage/lcov.info -o coverage/html
                    Write-Host "   Coverage report: coverage/html/index.html" -ForegroundColor Green
                } else {
                    Write-Host "   Coverage data: coverage/lcov.info" -ForegroundColor Green
                    Write-Host "   Install 'genhtml' for HTML reports" -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "   Coverage data: coverage/lcov.info" -ForegroundColor Green
            }
        }
    }
    else {
        Write-Host "❌ Tests failed with exit code: $exitCode" -ForegroundColor Red

        # Performance analysis for failed tests
        if ($duration.TotalSeconds -gt ($TimeoutSeconds * 0.8)) {
            Write-Host ""
            Write-Host "⚠️  Performance Warning:" -ForegroundColor Yellow
            Write-Host "   Tests are approaching timeout limit ($TimeoutSeconds s)"
            Write-Host "   Consider optimizing slow tests or increasing timeout"
        }
    }
}
catch {
    Write-Host "💥 Test execution failed: $($_.Exception.Message)" -ForegroundColor Red
    $exitCode = 1
}

# Performance recommendations
Write-Host ""
Write-Host "💡 Performance Tips:" -ForegroundColor Cyan
Write-Host "   • Use --tags fast for quick unit tests only"
Write-Host "   • Use --tags integration for full integration tests"
Write-Host "   • Increase --concurrency for more parallel execution"
Write-Host "   • Use --timeout for faster failure detection"

exit $exitCode