/// s_spreadsheet
///
/// A reusable Excel-style, 2D-scrollable spreadsheet/table widget built on
/// synchronized horizontal scroll controllers and a virtualized vertical list.
library;

export 'src/s_spreadsheet.dart';

// Re-export IndexedScrollController so callers don't need an extra import.
export 'package:s_packages/indexscroll_listview_builder/indexscroll_listview_builder.dart'
    show IndexedScrollController;
