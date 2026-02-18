import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/currency_model.dart';
import '../../models/settings_model.dart';

/// Local data source interface for Settings (cache / offline)
abstract class SettingsLocalDataSource {
  /// Get cached settings from local storage
  Future<SettingsModel?> getCachedSettings();

  /// Cache settings to local storage
  Future<void> cacheSettings(SettingsModel settings);

  /// Clear cached settings
  Future<void> clearCache();

  /// Get cached currencies
  Future<List<CurrencyModel>?> getCachedCurrencies();

  /// Cache currencies
  Future<void> cacheCurrencies(List<CurrencyModel> currencies);
}

/// SharedPreferences-backed implementation of [SettingsLocalDataSource]
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const _cacheKey = 'cached_user_settings';

  SettingsLocalDataSourceImpl();

  @override
  Future<SettingsModel?> getCachedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      if (jsonString == null) return null;
      return SettingsModel.fromJson(json.decode(jsonString));
    } catch (e) {
      debugPrint('[Settings] Error reading cache: $e');
      return null;
    }
  }

  @override
  Future<void> cacheSettings(SettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(settings.toJson()));
    } catch (e) {
      debugPrint('[Settings] Error writing cache: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_currenciesCacheKey);
  }

  static const _currenciesCacheKey = 'cached_currencies_list';

  @override
  Future<List<CurrencyModel>?> getCachedCurrencies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_currenciesCacheKey);
      if (jsonString == null) return null;
      final list = json.decode(jsonString) as List;
      return list.map((e) => CurrencyModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('[Settings] Error reading currencies cache: $e');
      return null;
    }
  }

  @override
  Future<void> cacheCurrencies(List<CurrencyModel> currencies) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _currenciesCacheKey,
        json.encode(currencies.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('[Settings] Error writing currencies cache: $e');
    }
  }
}
