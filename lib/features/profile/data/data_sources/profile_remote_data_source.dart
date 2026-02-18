import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<void> saveProfile(ProfileModel profile);
  Future<void> deleteAccount();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  CollectionReference get _profilesCollection =>
      _firestore.collection('users_profile');

  @override
  Future<ProfileModel> getProfile() async {
    final user = _currentUser;
    if (user == null) throw Exception('No authenticated user');

    try {
      final doc = await _profilesCollection.doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        return ProfileModel.fromJson(
          doc.data() as Map<String, dynamic>,
          user.uid,
        );
      } else {
        // Return empty profile with current user auth info
        return ProfileModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          photoUrl: user.photoURL ?? '',
        );
      }
    } catch (e) {
      debugPrint('[Profile] Fetch failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveProfile(ProfileModel profile) async {
    final user = _currentUser;
    if (user == null) throw Exception('No authenticated user');

    try {
      await _profilesCollection
          .doc(user.uid)
          .set(profile.toJson(), SetOptions(merge: true));

      // Optionally update Auth profile as well (displayName, photoUrl)
      // This keeps Auth and DB in sync for basic info
      if (profile.name.isNotEmpty && profile.name != user.displayName) {
        await user.updateDisplayName(profile.name);
      }
      if (profile.photoUrl.isNotEmpty && profile.photoUrl != user.photoURL) {
        await user.updatePhotoURL(profile.photoUrl);
      }
    } catch (e) {
      debugPrint('[Profile] Save failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _currentUser;
    if (user == null) throw Exception('No authenticated user');

    try {
      // 1. Delete profile doc
      await _profilesCollection.doc(user.uid).delete();

      // 2. Delete user auth (Standard, requires re-auth if sensitive)
      await user.delete();
    } catch (e) {
      debugPrint('[Profile] Delete failed: $e');
      rethrow;
    }
  }
}
