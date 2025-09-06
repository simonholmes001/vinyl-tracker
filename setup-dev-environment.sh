#!/bin/bash
# Setup script for Vinyl Tracker development environment
# This script installs pre-commit hooks and configures development tools

echo "🚀 Setting up Vinyl Tracker development environment..."
echo "======================================================="

# Check if we're in the right directory
if [ ! -f "VinylTracker_Clean/VinlyTracker/VinlyTracker.xcodeproj/project.pbxproj" ]; then
    echo "❌ ERROR: Run this script from the root of the vinyl-tracker repository"
    exit 1
fi

# Install pre-commit hook
echo "📋 Installing pre-commit hook..."
if [ -f ".git/hooks/pre-commit" ]; then
    echo "✅ Pre-commit hook already installed"
else
    echo "❌ Pre-commit hook not found!"
    echo "   The hook should be at: .git/hooks/pre-commit"
    echo "   Please ensure you've cloned the repository completely"
    exit 1
fi

# Make sure the hook is executable
chmod +x .git/hooks/pre-commit
echo "✅ Pre-commit hook permissions set"

# Test the Xcode project
echo ""
echo "🧪 Testing Xcode project setup..."
cd VinylTracker_Clean/VinlyTracker

# Check if Xcode project exists
if [ ! -f "VinlyTracker.xcodeproj/project.pbxproj" ]; then
    echo "❌ ERROR: Xcode project not found"
    echo "   Expected: VinylTracker_Clean/VinlyTracker/VinlyTracker.xcodeproj"
    exit 1
fi

# Try a quick build test
echo "🔨 Testing build configuration..."
xcodebuild -project VinlyTracker.xcodeproj -scheme VinlyTracker -showdestinations | grep "iPhone 15" > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ iPhone 15 simulator destination available"
else
    echo "⚠️  WARNING: iPhone 15 simulator not found"
    echo "   You may need to install iOS 17.0 simulators in Xcode"
    echo "   The pre-commit hook may fail until this is resolved"
fi

cd ../..

# Check for SwiftLint (optional)
if command -v swiftlint >/dev/null 2>&1; then
    echo "✅ SwiftLint found: $(swiftlint version)"
else
    echo "⚠️  SwiftLint not found - installing via Homebrew..."
    if command -v brew >/dev/null 2>&1; then
        brew install swiftlint
        echo "✅ SwiftLint installed"
    else
        echo "⚠️  Homebrew not found. Please install SwiftLint manually:"
        echo "   https://github.com/realm/SwiftLint#installation"
    fi
fi

echo ""
echo "🎉 Development environment setup complete!"
echo "======================================================="
echo "📋 What's configured:"
echo "   ✅ Pre-commit hook installed"
echo "   ✅ Unit tests will run before every commit"
echo "   ✅ Commits will fail if tests fail"
echo "   ✅ TDD standards enforced locally"
echo ""
echo "🧪 Testing the setup:"
echo "   Try making a commit - you should see tests running"
echo "   Example: git commit -m 'test: verify pre-commit hook'"
echo ""
echo "⚠️  Important:"
echo "   - All tests must pass before commits succeed"
echo "   - This enforces TDD at the commit level"
echo "   - Build and test times will add ~30-60 seconds per commit"
echo "======================================================="
