// This file provides a registry for package examples

import 'package:flutter/material.dart';
import 'package:s_packages_example/screens/examples/bubble_label_example_screen.dart';
import 'package:s_packages_example/screens/examples/indexscroll_listview_builder_example_screen.dart';
import 'package:s_packages_example/screens/examples/keystroke_listener_example_screen.dart';
import 'package:s_packages_example/screens/examples/pop_overlay_example_screen.dart';
import 'package:s_packages_example/screens/examples/pop_this_example_screen.dart';
import 'package:s_packages_example/screens/examples/post_frame_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_animated_tabs_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_banner_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_bounceable_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_button_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_client_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_connectivity_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_context_menu_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_disabled_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_dropdown_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_error_widget_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_expendable_menu_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_future_button_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_glow_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_gridview_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_ink_button_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_liquid_pull_to_refresh_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_maintenance_button_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_modal_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_offstage_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_screenshot_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_sidebar_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_standby_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_time_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_toggle_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_webview_example_screen.dart';
import 'package:s_packages_example/screens/examples/s_widgets_example_screen.dart';
import 'package:s_packages_example/screens/examples/settings_item_example_screen.dart';
import 'package:s_packages_example/screens/examples/shaker_example_screen.dart';
import 'package:s_packages_example/screens/examples/signals_watch_example_screen.dart';
import 'package:s_packages_example/screens/examples/soundsliced_dart_extensions_example_screen.dart';
import 'package:s_packages_example/screens/examples/soundsliced_tween_animation_builder_example_screen.dart';
import 'package:s_packages_example/screens/examples/states_rebuilder_extended_example_screen.dart';
import 'package:s_packages_example/screens/examples/ticker_free_circular_progress_indicator_example_screen.dart';
import 'package:s_packages_example/screens/examples/week_calendar_example_screen.dart';

/// Registry of all package examples
/// To add an example, create a wrapper screen that demonstrates the package
class PackageExamplesRegistry {
  static final Map<String, Widget Function()> _examples = {
    // UI Components
    'bubble_label': () => const BubbleLabelExampleScreen(),
    'pop_overlay': () => const PopOverlayExampleScreen(),
    's_animated_tabs': () => const SAnimatedTabsExampleScreen(),
    's_banner': () => const SBannerExampleScreen(),
    's_bounceable': () => const SBounceableExampleScreen(),
    's_button': () => const SButtonExampleScreen(),
    's_context_menu': () => const SContextMenuExampleScreen(),
    's_disabled': () => const SDisabledExampleScreen(),
    's_dropdown': () => const SDropdownExampleScreen(),
    's_error_widget': () => const SErrorWidgetExampleScreen(),
    's_expendable_menu': () => const SExpendableMenuExampleScreen(),
    's_future_button': () => const SFutureButtonExampleScreen(),
    's_glow': () => const SGlowExampleScreen(),
    's_gridview': () => const SGridviewExampleScreen(),
    's_ink_button': () => const SInkButtonExampleScreen(),
    's_liquid_pull_to_refresh': () => const SLiquidPullToRefreshExampleScreen(),
    's_maintenance_button': () => const SMaintenanceButtonExampleScreen(),
    's_modal': () => const SModalExampleScreen(),
    's_offstage': () => const SOffstageExampleScreen(),
    's_screenshot': () => const SScreenshotExampleScreen(),
    's_sidebar': () => const SSidebarExampleScreen(),
    's_standby': () => const SStandbyExampleScreen(),
    's_time': () => const STimeExampleScreen(),
    's_toggle': () => const SToggleExampleScreen(),
    's_webview': () => const SWebviewExampleScreen(),
    's_widgets': () => const SWidgetsExampleScreen(),
    'settings_item': () => const SettingsItemExampleScreen(),
    'ticker_free_circular_progress_indicator': () =>
        const TickerFreeCircularProgressIndicatorExampleScreen(),

    // Lists
    'indexscroll_listview_builder': () =>
        const IndexscrollListviewBuilderExampleScreen(),

    // Input
    'keystroke_listener': () => const KeystrokeListenerExampleScreen(),

    // Navigation
    'pop_this': () => const PopThisExampleScreen(),

    // Utilities
    'post_frame': () => const PostFrameExampleScreen(),
    'soundsliced_dart_extensions': () =>
        const SoundslicedDartExtensionsExampleScreen(),

    // Networking
    's_client': () => const SClientExampleScreen(),
    's_connectivity': () => const SConnectivityExampleScreen(),

    // Animations
    'shaker': () => const ShakerExampleScreen(),
    'soundsliced_tween_animation_builder': () =>
        const SoundslicedTweenAnimationBuilderExampleScreen(),

    // State Management
    'signals_watch': () => const SignalsWatchExampleScreen(),
    'states_rebuilder_extended': () =>
        const StatesRebuilderExtendedExampleScreen(),

    // Calendar
    'week_calendar': () => const WeekCalendarExampleScreen(),
  };

  /// Get the example widget for a package
  /// Returns null if no example is available
  static Widget? getExample(String packageName) {
    final builder = _examples[packageName];
    return builder?.call();
  }

  /// Check if an example is available for a package
  static bool hasExample(String packageName) {
    return _examples.containsKey(packageName);
  }

  /// Get all package names that have examples
  static List<String> getAvailableExamples() {
    return _examples.keys.toList();
  }
}
