#!/usr/bin/env bash
# Commit all changes in submodules

set -e

cd "$(dirname "$0")/.."

echo "Committing changes in all submodules..."

# List of submodules with changes
submodules=(
    "bubble_label"
    "indexscroll_listview_builder"
    "post_frame"
    "s_banner"
    "s_button"
    "s_disabled"
    "s_glow"
    "s_ink_button"
    "s_modal"
    "s_toggle"
    "s_webview"
    "signals_watch"
    "soundsliced_dart_extensions"
    "soundsliced_tween_animation_builder"
    "states_rebuilder_extended"
    "ticker_free_circular_progress_indicator"
)

for module in "${submodules[@]}"; do
    if [ -d "$module" ]; then
        echo "Processing $module..."
        cd "$module"
        git add -A
        git commit -m "Update package configuration" || echo "  No changes to commit"
        cd ..
    fi
done

echo ""
echo "Now updating submodule references in main repository..."
git add -A
git commit -m "Update submodule references" || echo "No changes to commit"

echo "Done!"
