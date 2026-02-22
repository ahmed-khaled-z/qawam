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

  /// Use a sentinel so that copyWith(errorMessage: null) actually clears it.
  static const _clearError = Object();

  SettingsState copyWith({
    SettingsStatus? status,
    // Pass [null] explicitly to clear the error. Use [_clearError] internally.
    Object? errorMessage = _clearError,
    SettingsModel? settings,
    List<Currency>? currencies,
  }) {
    return SettingsState(
      status: status ?? this.status,
      // If caller passed null → clear error. If not provided → keep current.
      errorMessage: errorMessage == _clearError
          ? this.errorMessage
          : errorMessage as String?,
      settings: settings ?? this.settings,
      currencies: currencies ?? this.currencies,
    );
  }
}
