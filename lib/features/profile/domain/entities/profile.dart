class Profile {
  final String id;
  final String email;
  final String name;
  final String photoUrl;
  final String phoneNumber;
  final DateTime? dateOfBirth;

  const Profile({
    required this.id,
    required this.email,
    this.name = '',
    this.photoUrl = '',
    this.phoneNumber = '',
    this.dateOfBirth,
  });

  const Profile.empty()
    : id = '',
      email = '',
      name = '',
      photoUrl = '',
      phoneNumber = '',
      dateOfBirth = null;

  Profile copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          photoUrl == other.photoUrl &&
          phoneNumber == other.phoneNumber &&
          dateOfBirth == other.dateOfBirth;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      photoUrl.hashCode ^
      phoneNumber.hashCode ^
      dateOfBirth.hashCode;
}
