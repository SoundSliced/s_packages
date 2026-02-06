# Makefile for common development tasks
# Usage: make <target>

SHELL := /bin/zsh

.PHONY: help pub-get pub-get-example analyze format test example-test example-web-test run-example clean

help:
	@echo "Available targets:"
	@echo "  help               - Show this help"
	@echo "  pub-get            - Run 'flutter pub get' for the package root"
	@echo "  pub-get-example    - Run 'flutter pub get' inside the example app"
	@echo "  analyze            - Run 'flutter analyze'"
	@echo "  format             - Format all Dart files (dart format .)"
	@echo "  test               - Run package unit/widget tests (flutter test)"
	@echo "  example-test       - Run example tests (flutter test example/test/...)"
	@echo "  example-web-test   - Run example tests on Chrome (flutter test -d chrome ...)"
	@echo "  run-example        - Run the example app (flutter run in example folder)"
	@echo "  clean              - Run 'flutter clean'"

# Get dependencies for package root
pub-get:
	flutter pub get

# Get dependencies for example app
pub-get-example:
	cd example && flutter pub get

# Analyze project
analyze:
	flutter analyze

# Format code
format:
	dart format .

# Run package tests
test:
	flutter test -r expanded

# Run example tests (non-web)
example-test:
	cd example && flutter test -r expanded

# Run example tests on web (Chrome)
example-web-test:
	cd example && flutter test -d chrome -r expanded

# Run example app (useful for manual repro)
run-example:
	cd example && flutter pub get && flutter run -d chrome

# Clean build
clean:
	flutter clean
