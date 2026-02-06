class PackageInfo {
  final String name;
  final String description;
  final String category;

  PackageInfo({
    required this.name,
    required this.description,
    required this.category,
  });

  String get displayName {
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
