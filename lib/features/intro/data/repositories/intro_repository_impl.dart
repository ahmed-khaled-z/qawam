import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/intro_repository.dart';

class IntroRepositoryImpl implements IntroRepository {
  static const _key = 'hasSeenOnboarding';

  @override
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  @override
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
