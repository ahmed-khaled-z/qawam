class UserEntity {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  const UserEntity({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
  });
}
