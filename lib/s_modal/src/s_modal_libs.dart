import 'dart:ui';
import 'dart:developer' as developer;

// Add the ui prefix for lerpDouble clarification if not already done in imports
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:s_packages/s_packages.dart';

part 's_modal.dart';
part 'sheet/s_modal_sheet.dart';
part 'sheet/s_sheet_animations.dart';
part 'dialog/s_modal_dialog.dart';
part 'snackbar/s_modal_snackbar.dart';

// Shorthand for logging with a specific namespace to avoid conflicts
void modalLog(String message) => developer.log(message, name: 'Modal');

// Helper function for safe lerping
double lerpDouble(double? a, double? b, double t) {
  // Provide default values for null parameters
  a ??= 0.0;
  b ??= 0.0;

  // Ensure t is within valid range to prevent errors
  t = t.clamp(0.0, 1.0);

  try {
    // Use standard lerpDouble from dart:ui with safety checks
    final result = ui.lerpDouble(a, b, t);
    return result ?? b; // Fallback to 'b' if lerp returns null
  } catch (e) {
    // Handle any unexpected errors in the calculation
    modalLog("Error in lerpDouble: $e");
    return b; // Return the target value as a sensible default
  }
}
