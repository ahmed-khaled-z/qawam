import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/currency_model.dart';
import '../../models/settings_model.dart';

/// Remote data source interface for Settings
abstract class SettingsRemoteDataSource {
  /// Fetch settings from Firestore
  Future<SettingsModel> fetchSettings();

  /// Save settings to Firestore
  Future<SettingsModel> saveSettings(SettingsModel settings);

  /// Requesting currencies
  Future<List<CurrencyModel>> fetchCurrencies();
}

/// Firestore-backed implementation of [SettingsRemoteDataSource]
class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final FirebaseFirestore _firestore;

  SettingsRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Document reference for the current user's settings
  DocumentReference? get _settingsDoc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('app')
        .doc('settings');
  }

  @override
  Future<SettingsModel> fetchSettings() async {
    final doc = _settingsDoc;
    if (doc == null) {
      return SettingsModel.empty();
    }

    final snapshot = await doc.get();
    if (snapshot.exists) {
      return SettingsModel.fromJson(snapshot.data() as Map<String, dynamic>);
    }

    // First time — save defaults and return them
    final defaults = SettingsModel.empty();
    await doc.set(defaults.toJson());
    return defaults;
  }

  @override
  Future<SettingsModel> saveSettings(SettingsModel settings) async {
    final doc = _settingsDoc;
    if (doc == null) {
      throw Exception('No authenticated user — cannot save settings');
    }

    await doc.set(settings.toJson(), SetOptions(merge: true));
    return settings;
  }

  @override
  Future<List<CurrencyModel>> fetchCurrencies() async {
    try {
      final querySnapshot = await _firestore
          .collection('configurations')
          .doc('currencies')
          .get();

      if (querySnapshot.exists && querySnapshot.data() != null) {
        final data = querySnapshot.data()!;
        if (data.containsKey('list')) {
          final list = data['list'] as List;
          return list
              .map((e) => CurrencyModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[Settings] Failed to fetch remote currencies: $e');
    }

    // Return hardcoded defaults if remote fails or is empty
    return const [
      CurrencyModel(code: 'SAR', name: 'Saudi Riyal', flag: '🇸🇦'),
      CurrencyModel(code: 'USD', name: 'US Dollar', flag: '🇺🇸'),
      CurrencyModel(code: 'EUR', name: 'Euro', flag: '🇪🇺'),
      CurrencyModel(code: 'GBP', name: 'British Pound', flag: '🇬🇧'),
      CurrencyModel(code: 'AED', name: 'UAE Dirham', flag: '🇦🇪'),
      CurrencyModel(code: 'EGP', name: 'Egyptian Pound', flag: '🇪🇬'),
      CurrencyModel(code: 'KWD', name: 'Kuwaiti Dinar', flag: '🇰🇼'),
      CurrencyModel(code: 'QAR', name: 'Qatari Riyal', flag: '🇶🇦'),
      CurrencyModel(code: 'BHD', name: 'Bahraini Dinar', flag: '🇧🇭'),
      CurrencyModel(code: 'OMR', name: 'Omani Rial', flag: '🇴🇲'),
    ];
  }
}
