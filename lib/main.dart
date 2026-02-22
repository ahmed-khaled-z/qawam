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

  // 1. Load environment variables
  await dotenv.load(fileName: '.env');

  // 2. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Initialize global managers (theme, auth, language)
  //    These MUST complete before runApp so the UI has correct initial state.
  themeManager = await ThemeManager.loadTheme();
  authManager = await AuthManager.loadUser();
  await LanguageManager.create();

  // 4. Set up dependency injection (Hive, Firestore, all features)
  await ServiceLocator().setup();

  // 5. Launch the app — all dependencies are ready
  runApp(const App());
}
