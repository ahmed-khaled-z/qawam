import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.email,
    super.name,
    super.photoUrl,
    super.phoneNumber,
    super.dateOfBirth,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json, String id) {
    return ProfileModel(
      id: id,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      dateOfBirth: (json['dateOfBirth'] as Timestamp?)?.toDate(),
    );
  }

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      email: profile.email,
      name: profile.name,
      photoUrl: profile.photoUrl,
      phoneNumber: profile.phoneNumber,
      dateOfBirth: profile.dateOfBirth,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email, // Often read-only but good to have
      'name': name,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static const empty = ProfileModel(id: '', email: '');
}
