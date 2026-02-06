#!/usr/bin/env python3
import os
import shutil
from pathlib import Path

# Base directory
base_dir = Path("/Users/christophechanteur/Development/Flutter_projects/s_packages")

# List of package directories
packages = [
    "bubble_label", "s_button", "s_dropdown", "s_modal", "s_toggle", "s_widgets",
    "s_banner", "s_bounceable", "s_client", "s_connectivity", "s_context_menu",
    "s_disabled", "s_error_widget", "s_expendable_menu", "s_future_button",
    "s_glow", "s_gridview", "s_ink_button", "s_liquid_pull_to_refresh",
    "s_maintenance_button", "s_offstage", "s_screenshot", "s_sidebar",
    "s_standby", "s_time", "s_webview", "s_animated_tabs",
    "indexscroll_listview_builder", "keystroke_listener", "pop_overlay",
    "pop_this", "post_frame", "settings_item", "shaker", "signals_watch",
    "soundsliced_dart_extensions", "soundsliced_tween_animation_builder",
    "states_rebuilder_extended", "ticker_free_circular_progress_indicator",
    "week_calendar"
]

removed_count = 0

for pkg in packages:
    git_dir = base_dir / pkg / ".git"
    if git_dir.exists() and git_dir.is_dir():
        try:
            shutil.rmtree(git_dir)
            print(f"✓ Removed {pkg}/.git")
            removed_count += 1
        except Exception as e:
            print(f"✗ Failed to remove {pkg}/.git: {e}")
    else:
        print(f"- {pkg}/.git does not exist")

print(f"\n{'='*50}")
print(f"Removed .git directories from {removed_count}/{len(packages)} packages")
print(f"{'='*50}")
