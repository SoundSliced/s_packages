#!/bin/bash

cd /Users/christophechanteur/Development/Flutter_projects/s_packages

# List of all package directories
packages=(
    "bubble_label"
    "s_button"
    "s_dropdown"
    "s_modal"
    "s_toggle"
    "s_widgets"
    "s_banner"
    "s_bounceable"
    "s_client"
    "s_connectivity"
    "s_context_menu"
    "s_disabled"
    "s_error_widget"
    "s_expendable_menu"
    "s_future_button"
    "s_glow"
    "s_gridview"
    "s_ink_button"
    "s_liquid_pull_to_refresh"
    "s_maintenance_button"
    "s_offstage"
    "s_screenshot"
    "s_sidebar"
    "s_standby"
    "s_time"
    "s_webview"
    "s_animated_tabs"
    "indexscroll_listview_builder"
    "keystroke_listener"
    "pop_overlay"
    "pop_this"
    "post_frame"
    "settings_item"
    "shaker"
    "signals_watch"
    "soundsliced_dart_extensions"
    "soundsliced_tween_animation_builder"
    "states_rebuilder_extended"
    "ticker_free_circular_progress_indicator"
    "week_calendar"
)

# Remove .git from each package
for pkg in "${packages[@]}"; do
    if [ -d "$pkg/.git" ]; then
        rm -rf "$pkg/.git"
        echo "Removed $pkg/.git"
    fi
done

echo "Done removing .git directories from all packages"
