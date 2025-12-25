#!/bin/bash

# Flutter Template - Initial Project Setup Script
# This script automates the initial configuration of your new Flutter project

set -e

echo "🚀 Flutter Template Setup"
echo "========================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    exit 1
fi

print_success "Flutter detected"

# Get project information
echo ""
print_info "Let's configure your new project"
echo ""

read -p "Enter your app name (e.g., My Awesome App): " APP_NAME
read -p "Enter your bundle ID (e.g., com.company.app): " BUNDLE_ID
read -p "Enter your API base URL (e.g., https://api.yourapp.com): " API_URL

# Optional Mason CLI
echo ""
read -p "Do you want to install Mason CLI for code generation? (y/n): " INSTALL_MASON

echo ""
print_info "Starting setup..."
echo ""

# 1. Install dependencies
print_info "Installing Flutter dependencies..."
flutter pub get
print_success "Dependencies installed"

# 2. Rename app
print_info "Renaming app to: $APP_NAME"
dart run rename setAppName --targets ios,android,web,windows,macos,linux --value "$APP_NAME" > /dev/null 2>&1
print_success "App name updated"

print_info "Setting bundle ID to: $BUNDLE_ID"
dart run rename setBundleId --targets ios,android --value "$BUNDLE_ID" > /dev/null 2>&1
print_success "Bundle ID updated"

# 3. Update API base URL
print_info "Updating API base URL..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|https://api.yourapp.com|$API_URL|g" lib/core/constants/app_constants.dart
else
    # Linux
    sed -i "s|https://api.yourapp.com|$API_URL|g" lib/core/constants/app_constants.dart
fi
print_success "API URL updated"

# 4. Create environment files
print_info "Creating environment files..."
if [ -f ".env.example" ]; then
    cp .env.example .env.development
    cp .env.example .env.staging
    cp .env.example .env.production
    
    # Update development env
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|API_BASE_URL=.*|API_BASE_URL=$API_URL|g" .env.development
        sed -i '' "s|APP_NAME=.*|APP_NAME=$APP_NAME|g" .env.development
    else
        sed -i "s|API_BASE_URL=.*|API_BASE_URL=$API_URL|g" .env.development
        sed -i "s|APP_NAME=.*|APP_NAME=$APP_NAME|g" .env.development
    fi
    
    print_success "Environment files created"
else
    print_warning ".env.example not found, skipping environment files"
fi

# 5. Install Mason CLI (optional)
if [ "$INSTALL_MASON" = "y" ] || [ "$INSTALL_MASON" = "Y" ]; then
    print_info "Installing Mason CLI..."
    dart pub global activate mason_cli > /dev/null 2>&1
    print_success "Mason CLI installed"
    
    print_info "Getting Mason bricks..."
    mason get > /dev/null 2>&1
    print_success "Mason bricks ready"
fi

# 6. Run code generation
print_info "Running code generation (this may take a minute)..."
dart run build_runner build --delete-conflicting-outputs > /dev/null 2>&1
print_success "Code generation complete"

# 7. Clean and verify
print_info "Cleaning project..."
flutter clean > /dev/null 2>&1
flutter pub get > /dev/null 2>&1
print_success "Project cleaned"

echo ""
echo "================================================"
print_success "Setup Complete! 🎉"
echo "================================================"
echo ""
print_info "Your project is ready:"
echo "  • App Name: $APP_NAME"
echo "  • Bundle ID: $BUNDLE_ID"
echo "  • API URL: $API_URL"
echo ""
print_info "Next steps:"
echo "  1. Run: flutter run"
echo "  2. Generate features: mason make feature --name your_feature"
echo "  3. Start building! 🚀"
echo ""
print_warning "Don't forget to:"
echo "  • Add .env.* files to .gitignore"
echo "  • Update app icons and splash screen"
echo "  • Configure your backend API"
echo ""
