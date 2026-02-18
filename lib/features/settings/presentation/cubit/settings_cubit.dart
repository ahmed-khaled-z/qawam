import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/language/language_manager.dart';
import '../../data/models/settings_model.dart';
import '../../domain/use_cases/fetch_currencies_use_case.dart';
import '../../domain/use_cases/fetch_settings_use_case.dart';
import '../../domain/use_cases/save_settings_use_case.dart';
import 'settings_state.dart';

/// Cubit responsible for managing Settings state and business logic
class SettingsCubit extends Cubit<SettingsState> {
  final FetchSettingsUseCase _fetchSettingsUseCase;
  final SaveSettingsUseCase _saveSettingsUseCase;
  final FetchCurrenciesUseCase _fetchCurrenciesUseCase;

  SettingsCubit({
    required FetchSettingsUseCase fetchSettingsUseCase,
    required SaveSettingsUseCase saveSettingsUseCase,
    required FetchCurrenciesUseCase fetchCurrenciesUseCase,
  }) : _fetchSettingsUseCase = fetchSettingsUseCase,
       _saveSettingsUseCase = saveSettingsUseCase,
       _fetchCurrenciesUseCase = fetchCurrenciesUseCase,
       super(const SettingsState());

  /// Fetch settings and currencies on screen load
  Future<void> loadSettings() async {
    emit(state.copyWith(status: SettingsStatus.loading));

    // Parallel fetch
    final settingsFuture = _fetchSettingsUseCase.call();
    final currenciesFuture = _fetchCurrenciesUseCase.call();

    final results = await Future.wait([settingsFuture, currenciesFuture]);
    final settingsResult = results[0];
    final currenciesResult = results[1];

    // Handle Settings Result
    settingsResult.fold(
      (exception) => emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: exception.toString(),
        ),
      ),
      (settings) {
        // We need to cast because Future.wait returns dynamic/Object types in mixed lists
        // effectively, but here we know the types.
        // Actually, let's just handle them carefully.
        final model = SettingsModel.fromEntity(settings as dynamic);

        // Settings loaded, now check currencies...
        currenciesResult.fold(
          (currException) {
            // If currencies fail, we can still show settings but maybe with empty currencies?
            // Or just log it. We'll proceed with empty currencies if fail,
            // as the default list logic is in the repo layer anyway.
            emit(
              state.copyWith(
                status: SettingsStatus.loaded,
                settings: model,
                errorMessage: null, // Don't block UI for this
              ),
            );
          },
          (currencies) {
            // Both success
            emit(
              state.copyWith(
                status: SettingsStatus.loaded,
                settings: model,
                currencies: currencies as dynamic,
                errorMessage: null,
              ),
            );

            // Apply language from saved settings
            final savedLocale = Locale(model.language);
            if (languageManager.locale != savedLocale) {
              languageManager.setLocale(savedLocale);
            }
          },
        );
      },
    );
  }

  // ... (rest of methods: setCurrency, etc. - mostly unchanged except for injection)

  /// Update currency and persist
  Future<void> setCurrency(String currency) async {
    final updated = state.settings.copyWith(currency: currency);
    await _saveAndEmit(updated);
  }

  /// Update language, apply globally, and persist
  Future<void> setLanguage(String langCode) async {
    final updated = state.settings.copyWith(language: langCode);
    languageManager.setLocale(Locale(langCode));
    await _saveAndEmit(updated);
  }

  /// Toggle data sync
  Future<void> setDataSync(bool enabled) async {
    final updated = state.settings.copyWith(dataSyncEnabled: enabled);
    await _saveAndEmit(updated);
  }

  /// Toggle notifications
  Future<void> setNotifications(bool enabled) async {
    final updated = state.settings.copyWith(notificationsEnabled: enabled);
    await _saveAndEmit(updated);
  }

  /// Set month start day
  Future<void> setMonthStartDay(int day) async {
    final updated = state.settings.copyWith(monthStartDay: day);
    await _saveAndEmit(updated);
  }

  Future<void> _saveAndEmit(SettingsModel model) async {
    emit(state.copyWith(settings: model, status: SettingsStatus.saving));

    final result = await _saveSettingsUseCase.call(model);

    result.fold(
      (exception) => emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: exception.toString(),
        ),
      ),
      (saved) => emit(
        state.copyWith(
          status: SettingsStatus.saved,
          settings: SettingsModel.fromEntity(saved),
          errorMessage: null,
        ),
      ),
    );
  }
}
