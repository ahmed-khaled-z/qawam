class Currency {
  final String code;
  final String name;
  final String flag;

  const Currency({required this.code, required this.name, required this.flag});

  String get displayName => '$flag $code – $name';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          name == other.name &&
          flag == other.flag;

  @override
  int get hashCode => code.hashCode ^ name.hashCode ^ flag.hashCode;
}
