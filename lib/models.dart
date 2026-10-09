class RangeStats {
  final String rangeName;
  final int total;
  final int available;
  final int added;

  RangeStats({
    required this.rangeName,
    this.total = 0,
    this.available = 0,
    this.added = 0,
  });

  RangeStats copyWith({
    String? rangeName,
    int? total,
    int? available,
    int? added,
  }) =>
      RangeStats(
        rangeName: rangeName ?? this.rangeName,
        total: total ?? this.total,
        available: available ?? this.available,
        added: added ?? this.added,
      );
}