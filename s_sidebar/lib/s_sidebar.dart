/// s_sidebar package
///
/// A beautiful, customizable, and responsive sidebar widget for Flutter
/// with smooth animations, badge support, and adaptive layouts.
///
/// ## Features
///
/// - **Collapsible Design**: Toggle between minimized and expanded states
/// - **Highly Customizable**: Extensive styling options for colors, sizes, and spacing
/// - **Responsive**: Intelligently adapts to available space
/// - **Badge Support**: Display notifications or counts on menu items
/// - **Smart Layout**: Automatically optimizes space usage
/// - **Smooth Animations**: Beautiful transitions and effects
/// - **Accessible**: Built-in semantics and tooltip support
/// - **Programmatic Control**: SideBarController for external control
/// - **Popup Sidebars**: Create overlay sidebars for context menus
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:s_sidebar/s_sidebar.dart';
///
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: Scaffold(
///         body: Row(
///           children: [
///             SSideBar(
///               sidebarItems: [
///                 SSideBarItem(
///                   iconSelected: Icons.home,
///                   iconUnselected: Icons.home_outlined,
///                   title: 'Home',
///                 ),
///                 SSideBarItem(
///                   iconSelected: Icons.settings,
///                   iconUnselected: Icons.settings_outlined,
///                   title: 'Settings',
///                 ),
///               ],
///               onTapForAllTabButtons: (index) {
///                 print('Tapped item at index: $index');
///               },
///             ),
///             Expanded(child: Center(child: Text('Main Content'))),
///           ],
///         ),
///       ),
///     );
///   }
/// }
/// ```
///
/// ## Popup Sidebars
///
/// ```dart
/// // Create a popup sidebar overlay
/// SideBarController.activateSideBar(
///   SSideBar(
///     sidebarItems: [
///       SSideBarItem(iconSelected: Icons.favorite, title: 'Favorites'),
///       SSideBarItem(iconSelected: Icons.history, title: 'Recent'),
///     ],
///     onTapForAllTabButtons: (index) {},
///   ),
/// );
///
/// // Dismiss the popup
/// SideBarController.deactivateSideBar();
/// ```
library;

export 'src/s_sidebar.dart';
