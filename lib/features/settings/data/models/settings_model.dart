import '../../domain/entities/settings.dart';

/// Data model for Settings with JSON/Firestore serialization
///
/// Extends the domain [Settings] entity and adds:
/// - JSON serialization / deserialization
/// - `copyWith` for immutable updates
/// - `fromEntity` factory for domain ↔ data conversion
class SettingsModel extends Settings {
  const SettingsModel({
    super.currency,
    super.language,
    super.dataSyncEnabled,
    super.notificationsEnabled,
    super.monthStartDay,
  });

  /// Create model from Firestore / JSON map
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      currency: json['currency'] as String? ?? 'SAR',
      language: json['language'] as String? ?? 'en',
      dataSyncEnabled: json['dataSyncEnabled'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      monthStartDay: json['monthStartDay'] as int? ?? 1,
    );
  }

  /// Convert model to JSON map for Firestore
  Map<String, dynamic> toJson() => {
    'currency': currency,
    'language': language,
    'dataSyncEnabled': dataSyncEnabled,
    'notificationsEnabled': notificationsEnabled,
    'monthStartDay': monthStartDay,
  };

  /// Create model from domain entity
  factory SettingsModel.fromEntity(Settings entity) {
    return SettingsModel(
      currency: entity.currency,
      language: entity.language,
      dataSyncEnabled: entity.dataSyncEnabled,
      notificationsEnabled: entity.notificationsEnabled,
      monthStartDay: entity.monthStartDay,
    );
  }

  /// Immutable copy
  SettingsModel copyWith({
    String? currency,
    String? language,
    bool? dataSyncEnabled,
    bool? notificationsEnabled,
    int? monthStartDay,
  }) {
    return SettingsModel(
      currency: currency ?? this.currency,
      language: language ?? this.language,
      dataSyncEnabled: dataSyncEnabled ?? this.dataSyncEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      monthStartDay: monthStartDay ?? this.monthStartDay,
    );
  }

  /// Default / empty factory
  factory SettingsModel.empty() => const SettingsModel();
}
