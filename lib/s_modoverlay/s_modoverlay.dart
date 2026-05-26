/// Public entrypoint for the `s_modoverlay` subpackage.
///
/// Exposes modal and pop-overlay systems plus interleaving stack utilities.
library;

export 'mod_overlay_lifecycle.dart';
export 'pop_overlay/pop_overlay.dart';
export 's_modal/s_modal.dart';
export 'interleaving_manager/stack_order.dart';
export 'interleaving_manager/interleave_manager.dart';
