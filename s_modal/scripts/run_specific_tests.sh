#!/bin/bash
cd /Users/christophechanteur/Development/Flutter_projects/my_extensions/s_modal

echo "Running Modal ID Tests..."
flutter test --name "custom ID" 2>&1 | grep -E "(PASS|FAIL|✓|✗|All tests|Some tests)" | head -20
