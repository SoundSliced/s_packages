/// s_spreadsheet
///
/// A reusable Excel-style, 2D-scrollable spreadsheet/table widget built on
/// synchronized horizontal scroll controllers and a virtualized vertical list.
library;

export 'src/s_spreadsheet.dart';

// Re-export IndexedScrollController so callers don't need an extra import.
export 'package:s_packages/indexscroll_listview_builder/indexscroll_listview_builder.dart'
    show IndexedScrollController;

// Re-export public hit-test types so callers can use GlobalKey<SSpreadsheetState>
// and receive SSpreadsheetHitResult without extra imports.
export 'src/s_spreadsheet.dart' show SSpreadsheetState, SSpreadsheetHitResult;
