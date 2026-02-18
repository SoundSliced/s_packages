part of '../../reports.dart';

/// Basic structure to add string helpers to the report.
mixin StringAttributeMixin {
  String _string = '';

  @override
  String toString() {
    return _string.trim();
  }

  void _concatenateString(Object obj) {
    _string += '$obj\n';
  }
}
