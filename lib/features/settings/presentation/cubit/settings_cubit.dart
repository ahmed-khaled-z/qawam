import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/language/language_manager.dart';
import '../../data/models/settings_model.dart';
import '../../domain/entities/currency.dart';
import '../../domain/use_cases/fetch_currencies_use_case.dart';
import '../../domain/use_cases/fetch_settings_use_case.dart';
import '../../domain/use_cases/save_settings_use_case.dart';
import 'settings_state.dart';

/// Cubit responsible for managing Settings state and business logic.
///
/// Initialization flow:
/// 1. [loadSettings] is called once in [app.dart] via BlocProvider.
/// 2. Settings are loaded from local cache first (instant) then remote syncs.
/// 3. Each setter method updates state, saves locally, and syncs to remote.
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

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Load settings and currencies on app startup or screen open.
  ///
  /// Settings are fetched from local cache first (fast), then currencies
  /// are loaded. A remote background sync happens automatically inside
  /// the repository layer.
  Future<void> loadSettings() async {
    emit(state.copyWith(status: SettingsStatus.loading));

    // Fetch settings (local-first) and currencies separately
    // to avoid type mixing issues with Future.wait.
    final settingsResult = await _fetchSettingsUseCase.call();
    final currenciesResult = await _fetchCurrenciesUseCase.call();

    SettingsModel loadedModel = SettingsModel.empty();

    // ── Handle settings result ──────────────────────────────────────────────
    settingsResult.fold(
      (exception) {
        debugPrint('[SettingsCubit] Failed to load settings: $exception');
        // Keep default settings but mark as loaded so UI is not blocked.
        emit(
          state.copyWith(
            status: SettingsStatus.loaded,
            settings: SettingsModel.empty(),
            errorMessage: exception.toString(),
          ),
        );
        return;
      },
      (settings) {
        loadedModel = SettingsModel.fromEntity(settings);
      },
    );

    // ── Handle currencies result ────────────────────────────────────────────
    List<Currency> currencies = const [];
    currenciesResult.fold(
      (exception) {
        debugPrint('[SettingsCubit] Failed to load currencies: $exception');
        // Non-fatal — proceed with empty list; UI shows no dropdown items.
      },
      (list) {
        currencies = list;
      },
    );

    // ── Emit loaded state ───────────────────────────────────────────────────
    emit(
      state.copyWith(
        status: SettingsStatus.loaded,
        settings: loadedModel,
        currencies: currencies,
        errorMessage: null,
      ),
    );

    // ── Apply saved language globally ───────────────────────────────────────
    _applyLanguage(loadedModel.language);

    debugPrint(
      '[SettingsCubit] Settings loaded: currency=${loadedModel.currency}, '
      'lang=${loadedModel.language}, '
      'sync=${loadedModel.dataSyncEnabled}, '
      'notifications=${loadedModel.notificationsEnabled}, '
      'monthStart=${loadedModel.monthStartDay}',
    );
  }

  // ── Setters ────────────────────────────────────────────────────────────────

  /// Update the active currency and persist.
  Future<void> setCurrency(String currency) async {
    final updated = state.settings.copyWith(currency: currency);
    await _saveAndEmit(updated);
  }

  /// Update the app language, apply globally, and persist.
  Future<void> setLanguage(String langCode) async {
    final updated = state.settings.copyWith(language: langCode);
    _applyLanguage(langCode);
    await _saveAndEmit(updated);
  }

  /// Toggle data sync preference.
  Future<void> setDataSync(bool enabled) async {
    final updated = state.settings.copyWith(dataSyncEnabled: enabled);
    await _saveAndEmit(updated);
  }

  /// Toggle notification preference.
  Future<void> setNotifications(bool enabled) async {
    final updated = state.settings.copyWith(notificationsEnabled: enabled);
    await _saveAndEmit(updated);
  }

  /// Update the month start day (1–28).
  Future<void> setMonthStartDay(int day) async {
    final updated = state.settings.copyWith(monthStartDay: day);
    await _saveAndEmit(updated);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Emit optimistic state immediately, then save and confirm.
  ///
  /// The UI updates instantly on user interaction. If saving fails
  /// (which is very unlikely since we save locally first), we report
  /// the error without reverting to avoid a jarring UX.
  Future<void> _saveAndEmit(SettingsModel model) async {
    // Optimistic UI update — show the change immediately.
    emit(state.copyWith(settings: model, status: SettingsStatus.saving));

    final result = await _saveSettingsUseCase.call(model);

    result.fold(
      (exception) {
        debugPrint('[SettingsCubit] Save failed: $exception');
        emit(
          state.copyWith(
            // Keep the model the user selected (don't revert).
            settings: model,
            status: SettingsStatus.error,
            errorMessage: exception.toString(),
          ),
        );
      },
      (saved) {
        emit(
          state.copyWith(
            status: SettingsStatus.saved,
            settings: SettingsModel.fromEntity(saved),
            errorMessage: null,
          ),
        );
        debugPrint('[SettingsCubit] Settings saved: ${model.toJson()}');
      },
    );
  }

  /// Apply a language code to the global [LanguageManager].
  void _applyLanguage(String langCode) {
    try {
      final newLocale = Locale(langCode);
      if (languageManager.locale != newLocale) {
        languageManager.setLocale(newLocale);
      }
    } catch (e) {
      debugPrint('[SettingsCubit] Failed to apply language "$langCode": $e');
    }
  }
}
