import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'injection_container.dart';
import 'config/theme/theme_manager.dart';
import 'config/auth/auth_manager.dart';
import 'config/language/language_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize managers
  themeManager = await ThemeManager.loadTheme();
  authManager = await AuthManager.loadUser();
  await LanguageManager.create();

  Future.wait([ServiceLocator().setup()]).then((value) {
    runApp(const App());
  });
}
