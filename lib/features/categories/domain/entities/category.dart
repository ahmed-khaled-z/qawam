class Category {
  final String id;
  final String name;
  final int iconCode;
  final int color;
  final bool isSyncedToFirebase;
  final DateTime? lastSyncedAt;

  const Category({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.color,
    this.isSyncedToFirebase = false,
    this.lastSyncedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          iconCode == other.iconCode &&
          color == other.color &&
          isSyncedToFirebase == other.isSyncedToFirebase &&
          lastSyncedAt == other.lastSyncedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      iconCode.hashCode ^
      color.hashCode ^
      isSyncedToFirebase.hashCode ^
      lastSyncedAt.hashCode;
}
