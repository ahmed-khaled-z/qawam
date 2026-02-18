import '../../data/models/settings_model.dart';
import '../../domain/entities/currency.dart';

/// Status enum for the Settings feature lifecycle
enum SettingsStatus {
  /// Initial state when cubit is first created
  initial,

  /// Loading state for initial data fetch
  loading,

  /// Successfully loaded with data
  loaded,

  /// Error state when operations fail
  error,

  /// Loading state for user actions (save)
  saving,

  /// State indicating a save was completed successfully
  saved,
}

/// Immutable state for the Settings feature
class SettingsState {
  final SettingsStatus status;
  final String? errorMessage;
  final SettingsModel settings;
  final List<Currency> currencies;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.errorMessage,
    this.settings = const SettingsModel(),
    this.currencies = const [],
  });

  SettingsState copyWith({
    SettingsStatus? status,
    String? errorMessage,
    SettingsModel? settings,
    List<Currency>? currencies,
  }) {
    return SettingsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      settings: settings ?? this.settings,
      currencies: currencies ?? this.currencies,
    );
  }
}
