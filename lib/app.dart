import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qawam/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:qawam/injection_container.dart';
import 'config/theme/theme_manager.dart';
import 'config/auth/auth_manager.dart';
import 'config/language/language_manager.dart';
import 'config/router/app_router.dart';
import 'config/app_helper/app_constants.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    themeManager.addListener(_notifyChange);
    authManager.addListener(_notifyChange);
    languageManager.addListener(_notifyChange);
  }

  @override
  void dispose() {
    themeManager.removeListener(_notifyChange);
    authManager.removeListener(_notifyChange);
    languageManager.removeListener(_notifyChange);
    super.dispose();
  }

  void _notifyChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<SettingsCubit>()..loadSettings()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: themeManager.themeData,
        debugShowCheckedModeBanner: false,
        navigatorKey: AppRouter.navigatorKey,
        initialRoute: '/',
        onGenerateRoute: AppRouter.onGenerateRoute,

        // Localization
        locale: languageManager.locale,
        supportedLocales: LanguageManager.supportedLocales,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
