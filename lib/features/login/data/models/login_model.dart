import '../../domain/entities/login.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.displayName,
    super.email,
    super.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json['uid'] as String,
    displayName: json['displayName'] as String?,
    email: json['email'] as String?,
    photoUrl: json['photoUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'displayName': displayName,
    'email': email,
    'photoUrl': photoUrl,
  };

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
