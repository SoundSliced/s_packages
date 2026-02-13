#!/bin/bash
cd /Users/christophechanteur/Development/Flutter_projects/s_packages

echo "=== TAGS ==="
git tag -l
echo "=== END TAGS ==="

echo "=== GREP 1.2.7 ==="
git log --all --oneline --grep="1.2.7"
echo "=== END GREP ==="

echo "=== RECENT COMMITS ==="
git log --oneline --all -50
echo "=== END RECENT ==="
