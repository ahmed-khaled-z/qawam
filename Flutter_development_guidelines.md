# FLUTTER DEVELOPMENT GUIDELINES

We are using the [**flutter_custom_creator](https://pub.dev/packages/flutter_custom_creator) package to create a new project**

# Project Structure
lib/
├── config/
│   ├── app_helper/
│   │   ├── app_extension.dart
│   │   ├── app_formats.dart
│   │   ├── app_functions.dart
│   │   ├── app_gaps.dart
│   │   └── app_padding.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── unknown_route.dart
│   └── theme/
│       ├── dark_theme.dart
│       ├── light_theme.dart
│       └── theme_manager.dart
├── core/
│   ├── network/
│   │   ├── api_provider.dart
│   │   └── app_endpoints.dart
│   └── utils/
│       ├── dialogs.dart
│       ├── logger.dart
│       ├── snack_bar_utils.dart
│       └── validator.dart
├── features/
├── app.dart
├── injection_container.dart
└── main.dart

# Feature Structure

We are using the [**clean_architecture_with_state_management](https://pub.dev/packages/clean_architecture_with_state_management) package to create a new f**eature

```markdown
lib/features/[feature_name]/
├── data/
│   ├── data_sources/
│   │   ├── local/
│   │   │   └── [feature]_local_data_source.dart
│   │   └── remote/
│   │       └── [feature]_remote_data_source.dart
│   ├── models/
│   │   └── [feature]_model.dart
│   └── repositories/
│       └── [feature]_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── [feature]_entity.dart (if different from model)
│   ├── repositories/
│   │   └── [feature]_repository.dart
│   └── use_cases/
│       ├── [action1]_use_case.dart
│       └── [action2]_use_case.dart
├── dto/
│   └── [feature]_dto.dart
├── presentation/
│   ├── [state_management]/
│   │   ├── [feature]_cubit.dart (or bloc/provider)
│   │   └── [feature]_state.dart
│   ├── screens/
│   │   ├── [feature]_screen.dart
│   │   └── [sub_screen]_screen.dart (if applicable)
│   └── widgets/
│       ├── [component1]_widget.dart
│       └── [component2]_widget.dart
├── utils/ (if feature-specific utilities exist)
│   └── [feature]_utils.dart
└── inject_[feature].dart
```

**File Roles & Responsibilities**

```markdown

#### **Presentation Layer**
- **`[feature]_screen.dart`**:
  - **Role**: Main UI screen implementation
  - **Responsibilities**: Widget tree, user interactions, state observation
  - **Dependencies**: Cubit/Bloc, core widgets, localization

- **`[feature]_cubit.dart`**:
  - **Role**: State management and business logic coordination
  - **Responsibilities**: State emissions, use case orchestration, error handling
  - **Dependencies**: Use cases, state definitions

- **`[feature]_state.dart`**:
  - **Role**: State definitions and status enums
  - **Responsibilities**: State immutability, state transitions
  - **Dependencies**: Models, entities

- **`[widget]_widget.dart`**:
  - **Role**: Reusable UI components
  - **Responsibilities**: Specific UI functionality, styling consistency
  - **Dependencies**: Models, theme, localization

#### **Domain Layer**
- **`[feature]_repository.dart`**:
  - **Role**: Data access interface/contract
  - **Responsibilities**: Method signatures, return types
  - **Dependencies**: Entities, error types

- **`[action]_use_case.dart`**:
  - **Role**: Business logic implementation
  - **Responsibilities**: Single responsibility operations, data transformation
  - **Dependencies**: Repository interface, entities

#### **Data Layer**
- **`[feature]_model.dart`**:
  - **Role**: Data representation and serialization
  - **Responsibilities**: JSON conversion, data validation
  - **Dependencies**: JSON annotations, core types

- **`[feature]_repository_impl.dart`**:
  - **Role**: Repository interface implementation
  - **Responsibilities**: Data source coordination, error handling
  - **Dependencies**: Data sources, models

- **`[feature]_remote_data_source.dart`**:
  - **Role**: API communication
  - **Responsibilities**: HTTP requests, response handling
  - **Dependencies**: API provider, DTOs

- **`[feature]_local_data_source.dart`**:
  - **Role**: Local storage operations
  - **Responsibilities**: Cache management, offline data
  - **Dependencies**: Storage providers, models

#### **Supporting Files**
- **`[feature]_dto.dart`**:
  - **Role**: Data transfer objects for API
  - **Responsibilities**: Request/response formatting
  - **Dependencies**: JSON serialization

- **`inject_[feature].dart`**:
  - **Role**: Dependency injection configuration
  - **Responsibilities**: Service registration, dependency wiring
  - **Dependencies**: Service locator, all feature classes
```

**Component Interaction Flow**

```markdown

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│     UI      │◄──►│    Cubit    │◄──►│  Use Cases  │◄──►│ Repository  │
│   Screen    │    │   /Bloc     │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Widgets   │    │    State    │    │ Domain      │    │ Data        │
│ Components  │    │ Management  │    │ Logic       │    │ Sources     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```
```

**Constructor Requirements**

```markdown
- Always use `const` constructors when possible
- Always include `super.key` parameter: `const HomeScreen({super.key})`
- Use named parameters for optional arguments
- Required parameters should be marked with `required`
```

**Import Organization**

```markdown
// 1. Dart core libraries
import 'dart:async';
import 'dart:convert';

// 2. Flutter libraries
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages (alphabetically)
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// 4. Internal imports (alphabetically)
import '../../../core/error/failures.dart';
import '../../../core/utils/constants.dart';
import '../domain/entities/user.dart';
```

**Data Flow Description**

```markdown
1. **UI → State Management**: User interactions trigger cubit methods
2. **State Management → Domain**: Cubit calls appropriate use cases
3. **Domain → Data**: Use cases request data through repository
4. **Data → External**: Repository coordinates with data sources
5. **Response Flow**: Data flows back through the same layers
6. **State Updates**: Cubit emits new states, UI rebuilds accordingly
```

# utilities

## 📌 App Constants Structure

### 🔹 Idea

We put all fixed values (strings, keys, names, styles) in **one place** called `AppConstants`.

This makes the code **cleaner, easier to update, and reusable**.

// Show app name
print(AppConstants.appName)

```dart
class AppConstants {
  static const String appName = 'app name';
}

//🔹 How to use
print(AppConstants.appName)

```

# 📌 Extension Structure

### 🔹 Idea

- **Extensions** add extra functions to existing classes (like `String`, `DateTime`, `BuildContext`) without changing their original code.
- They make the code **shorter, cleaner, and more reusable**.

```dart
// String extension
"hello".capitalize(); // "Hello"
"verylongtext".smallLength(maxLength: 5); // "veryl..."

// Context extension
final screenHeight = context.height;
final textStyle = context.textStyleFor(16);

// DateTime extension
DateTime.now().timeAgo; // "just now"

// Position extension
Position pos = ...;
print(pos.formattedAddress); // "30.123456, 31.654321"
```

## 📌 AppFormats Structure

### 🔹 Idea

- Instead of writing date/time formats everywhere in the code, we create **one class** (`AppFormats`) that stores all the date/time patterns.
- This makes it **consistent** (same format across the app) and **easy to change** (just update in one place).
- It also supports **localization** using `easy_localization`

```dart
final now = DateTime.now();

// Using AppFormats
String formattedDate = AppFormats().dateFormat.format(now);
print(formattedDate); // 2025-09-24

String time = AppFormats().timeFormat.format(now);
print(time); // 03:45 PM

// Static usage
String serverDate = AppFormats.serverDateFormat.format(now);
print(serverDate); // 24-09-2025
```

## 📌 AppFunctions Structure

### 🔹 Idea

- This class stores **reusable helper methods** that perform common tasks.
- Instead of rewriting the same logic in multiple places, you just call `AppFunctions.methodName()`.
- It keeps your project **organized, clean, and DRY (Don’t Repeat Yourself)**.

```dart
// Extract number
String num = AppFunctions.extractNumber("abc123def");
print(num); // "123"

// Convert string to TimeOfDay
TimeOfDay time = AppFunctions.stringToTimeOfDay("14:30");
print(time.hour); // 14

// Call a phone number
await AppFunctions.callPhoneNumber("123456789");

// Get device type
print(AppFunctions.getDeviceType()); // "android"

// Show image source dialog
final source = await AppFunctions.getImageSource(context);
if (source == ImageSource.camera) {
  // Take photo
} else {
  // Pick from gallery
}
```

### 📌 AppGaps (Spacing System)

The `AppGaps` class defines a set of **predefined spacing values** that can be used across the app to keep the design consistent.

Instead of writing numbers everywhere (like `Gap(10)` or `Gap(40)`), we give them names so the UI looks clean and developers know what each size means.

### Example:

- `extraSmallGap` → very small space (2px)
- `soSmallGap` → small space (5px)
- `smallGap` → normal small gap (10px)
- `defaultGap` → standard space (20px)
- `bigGap` → large space (40px)
- `soBigGap` → very large space (80px)
- `extraBigGap` → extra large space (120px)

```dart
Column(
  children: [
    Text("Title"),
    AppGaps.defaultGap, // adds standard spacing
    Text("Subtitle"),
  ],
);
```

### 📏 AppPadding (Spacing Constants)

The `AppPadding` class stores all the **padding values** used in the app in one place.

This makes the design **consistent** and easy to update — if you change a value here, it updates everywhere in the app.

🔑 Key Points:

- All values are `static const`, so they never change.
- Names describe the size: `extraSmall`, `small`, `default`, `big`, etc.
- Helps maintain **clean UI spacing** without magic numbers spread in the code.

```dart
Padding(
  padding: EdgeInsets.all(AppPadding.defaultPadding),
  child: Text("Hello World"),
);

Container(
  padding: EdgeInsets.symmetric(
    horizontal: AppPadding.smallPadding,
    vertical: AppPadding.bigPadding,
  ),
  child: Text("Consistent UI"),
);

```

# 🔐 AuthManager (User Authentication Manager)

The `AuthManager` class handles **login, logout, and saving user data** in the app.

It works with **any user model** because it uses `fromJson` and `toJson` functions to convert data.

---

## 🔑 Key Features

- **Login / Logout** → Saves and clears user data.
- **Check Login State** → `isLoggedIn` tells if the user is logged in.
- **Get Current User** → Access the saved user with `currentUser`.
- **Persistent Storage** → Uses `SharedPreferences` to remember login after app restart.
- **Generic Support** → Works with any user model (dynamic, or custom with `fromJson/toJson`).

---

## ⚡ How It Works

1. When user logs in → `login(user)` saves data in local storage.
2. When user logs out → `logout()` clears the data and redirects to **LoginScreen**.
3. On app start → `loadUser()` loads user data from storage automatically.

```dart
// Define user model conversion
final authManager = await AuthManager.loadUser<UserModel>(
  fromJson: (json) => UserModel.fromJson(json),
  toJson: (user) => user.toJson(),
);

// Login
await authManager.login(userModel);

// Check login state
if (authManager.isLoggedIn) {
  print(authManager.currentUser);
}

// Logout
await authManager.logout();

```

# 🌍 LanguageManager (App Language Controller)

The `LanguageManager` controls the **current app language and locale**.

It works with `easy_localization` and `SharedPreferences` to **save and switch languages**.

---

## 🔑 Key Features

- Stores the **current language** (`en` or `ar`).
- Provides the **current locale** for `easy_localization`.
- **Change language** and update the app instantly.
- **Toggle language** between English ↔ Arabic.
- **Saves preference** in `SharedPreferences` so it stays after app restart.
- Updates the app’s **theme font** when the language changes.

---

## ⚡ How It Works

1. On startup → `loadLanguage()` loads saved language from storage.
2. When user changes → `changeLanguage(code, context)` updates locale + saves it.
3. When toggling → `toggleLanguage()` switches between `en` and `ar`.
4. The UI updates automatically because `LanguageManager` extends `ChangeNotifier`.

```dart
// Load saved language on app start
languageManager = await LanguageManager.loadLanguage();

// Get current language
print(languageManager.currentLanguage); // "en" or "ar"

// Change language manually
await changeLanguage("ar", context);

// Toggle between en ↔ ar
await toggleLanguage(context);

```

# 🌐 ApiProvider (Network Manager)

The `ApiProvider` is a **central class** to handle all API calls in the app.

It uses the **Dio** package for HTTP requests.

---

## 🔑 Key Features

- Supports **GET, POST, PUT, DELETE** requests.
- Automatically adds:
    - **Authorization token** (if user is logged in).
    - **Language header** (based on current app language).
- Handles **success and error responses** consistently.
- Detects **no internet connection** and returns a friendly message.
- Logs requests and responses in **debug mode** for easier debugging.

---

## ⚡ How It Works

1. Call `requestAPI()` with:
    - `url` → API endpoint
    - `body` → request data (optional)
    - `headers` → extra headers
    - `type` → request type (GET/POST/PUT/DELETE)
2. It adds headers for:
    - **Authorization** → `Bearer token`
    - **Language** → current app language
3. Sends request using Dio.
4. Handles response:
    - ✅ If success → returns `data` or `meta + data`.
    - ❌ If error → extracts message from API or returns fallback error.
5. Handles exceptions like:
    - No internet
    - Timeout
    - API error messages

```dart
final api = ApiProvider(Dio());

final response = await api.requestAPI(
  url: "https://api.example.com/users",
  headers: {},
  type: RequestType.get,
);

print(response);
```

# ⚙️ AppConfig (Remote Configuration Manager)

The `AppConfig` class is used to manage **environment-specific settings** (like `baseUrl`) for your app.

It uses **Firebase Remote Config** to fetch values dynamically.

---

## 🔑 Key Features

- Loads configuration from **Firebase Remote Config**.
- Supports different values for **Debug, Profile, and Release** modes.
- Automatically sets the correct **baseUrl** depending on the app mode.
- Helps you switch between environments (Dev, Staging, Production) without changing code.

---

## ⚡ How It Works

1. `init()` is called when the app starts.
2. It connects to Firebase Remote Config with settings like:
    - `fetchTimeout` → max time to fetch config.
    - `minimumFetchInterval` → how often config can refresh.
3. Fetches the latest config and activates it.
4. Sets `baseUrl`:
    - If **Debug mode** → use `debug_base_url` from Firebase.
    - If **Profile mode** → use `profile_base_url`.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();

  print(AppConfig.baseUrl); // Prints baseUrl depending on app mode
  runApp(MyApp());
}

```

## 🌐 AppUrls (API Endpoint Manager)

The **AppUrls** class centralizes all API endpoints in your app.

It builds URLs dynamically based on the `baseUrl` provided by `AppConfig`.

This ensures that API requests always point to the correct environment (Dev, Staging, Production) without needing code changes.

---

### 🔑 Key Features

- Provides **typed and centralized access** to all API endpoints.
- Builds URLs dynamically using `AppConfig.baseUrl`.
- Includes both **static endpoints** (e.g., `/login`, `/settings`) and **dynamic endpoints** that require IDs (e.g., `/trips/{id}/start`).
- Groups related endpoints (Auth, Trips, User, etc.) for clarity and maintainability.

---

### ⚡ How It Works

1. `AppConfig.init()` initializes the `baseUrl` (via Firebase Remote Config).
2. `AppUrls` uses this `baseUrl` to build all endpoints dynamically.
3. When you call an endpoint (e.g., `AppUrls.login`), it automatically includes the correct environment URL.

```dart
// Example: Using AppUrls in a repository or service
final response = await http.post(Uri.parse(AppUrls.login), body: {
  "email": "test@example.com",
  "password": "123456",
});

print(AppUrls.startTrip(42));  
// Output: https://<baseUrl>/trips/42/start
```

## 🧭 AppRouter (Navigation Manager)

The **AppRouter** class centralizes navigation in your app.

It manages **all routes**, provides a **global Navigator key**, and simplifies navigation (push, replace, remove until).

---

### 🔑 Key Features

- **Centralized route management**: All screens are registered in one place.
- Uses `navigatorKey` to navigate **without needing BuildContext**.
- Provides helper methods (`to`, `toReplacement`, `toAndRemoveUntil`, `pop`) for common navigation patterns.
- Handles **unknown routes** gracefully by showing a fallback screen.
- Works seamlessly with named routes (`Screen.routeName`).

---

### ⚡ How It Works

1. Each screen defines a `static const routeName`.
2. `AppRouter.onGenerateRoute` maps route names → screens.
3. Use `AppRouter.to(routeName)` instead of `Navigator.pushNamed(context, routeName)`.
4. The `navigatorKey` allows navigation from anywhere (even outside widgets, like Cubit/Bloc or services).

```dart
// Navigate to Login Screen
AppRouter.to(LoginScreen.routeName);

// Navigate to Main Screen and clear history
AppRouter.toAndRemoveUntil(MainScreen.routeName);

// Replace current screen with ResetPassword
AppRouter.toReplacement(ResetPasswordScreen.routeName);

// Close dialogs, bottom sheets, or go back
AppRouter.pop();

```

## 🚀 Main Entry Point (App Initialization)

This **main.dart** file is the starting point of the app.

It initializes all the **core services, managers, and configurations** before launching the app.

---

### 🔑 Key Responsibilities

- Initializes **Flutter bindings** and **Firebase**.
- Loads **language**, **theme**, and **user session**.
- Configures **remote app settings** (via `AppConfig`).
- Sets up **notifications**, **permissions**, and **services**.
- Wraps the app with **EasyLocalization** for multi-language support.

---

### ⚡ How It Works

1. **Ensure Flutter is ready** → `WidgetsFlutterBinding.ensureInitialized()`.
2. **Date Formatting** → initializes date/time formats (`initializeDateFormatting`).
3. **Firebase Initialization** → uses platform-specific options from `firebase_options.dart`.
4. **Load Managers**:
    - `LanguageManager` → loads saved language.
    - `ThemeManager` → loads saved theme & applies language-specific theme.
    - `AuthManager` → loads user session (with custom JSON parsing).
5. **Permissions**:
    - Requests location permission (`LocationUtils`).
    - Creates notification channel (Android-specific).
6. **Remote Config** → `AppConfig.init()` loads environment configs (dev, staging, prod).
7. **Notifications** → initializes `EasyNotify` and `NotificationService`.
8. **Service Locator** → sets up dependency injection (`ServiceLocator().setup()`).
9. **Run App** → wrapped in `EasyLocalization` with supported locales.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase setup
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load language & theme
  languageManager = await LanguageManager.loadLanguage();
  themeManager = await ThemeManager.loadTheme(languageManager.currentLanguage);

  // Load user session
  authManager = await AuthManager.loadUser(
    fromJson: (json) => UserWithToken.fromJson(json),
    toJson: (user) => user.toJson(),
  );

  // Initialize services
  await AppConfig.init();
  await EasyNotify.init();
  await NotificationService.instance.initialize();

  // Start app with localization
  runApp(
    EasyLocalization(
      path: 'assets/lang',
      startLocale: languageManager.currentLocale,
      supportedLocales: [Locale('ar', 'DZ'), Locale('en', 'US')],
      child: App(),
    ),
  );
}

```

## 🛠 Service Locator (Dependency Injection)

This file defines the **ServiceLocator** class, which uses GetIt for dependency injection.

It registers and manages all services and feature modules across the app, making them accessible from anywhere.

---

### 🔑 Key Responsibilities

- Provide a **central registry** for all dependencies.
- Register core services like:
    - `Dio` (HTTP client)
    - `ApiProvider` (API manager)
- Initialize and register dependencies for each feature module

### ⚡ How It Works

1. **Global Instance**
    - `final GetIt getIt = GetIt.instance;`
    - Provides a singleton container for all registered services.
2. **Setup Method**
    - Call `ServiceLocator().setup()` before running the app.
    - Registers all dependencies using `getIt.registerFactory()`.
3. **Dependency Registration**
    - `Dio` → provides a new HTTP client instance.
    - `ApiProvider` → handles API calls and depends on Dio.
    - `inject*()` functions → register feature-specific services.
4. **Usage**
    
    After setup, you can access any dependency anywhere in the app:
    
    ```dart
    final dio = getIt<Dio>();
    final api = getIt<ApiProvider>();
    
    ```
    
5. **Integration with Main**
    
    Typically used in `main.dart`:
    
    ```dart
    Future.wait([
      ServiceLocator().setup(),
    ]).then((_) {
      runApp(const MyApp());
    });
    
    ```
    

# Full feature example

### Presentation Layer

### Main Screen Implementation

```dart
// lib/features/[feature_name]/presentation/screens/[feature]_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

// Core imports - shared widgets and utilities
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../utils/dialogs.dart';
import '../../../../injection_container.dart';

// Feature-specific imports
import '../cubit/[feature]_cubit.dart';
import '../cubit/[feature]_state.dart';
import '../widgets/[feature]_card.dart';
import '../../dto/[feature]_dto.dart';

/// Main screen widget for [Feature Name] functionality
///
/// This screen provides users with the ability to:
/// - [Primary functionality 1]
/// - [Primary functionality 2]
/// - [Primary functionality 3]
///
/// The screen follows the BLoC pattern for state management and
/// implements clean architecture principles.
class [Feature]Screen extends StatefulWidget {
  /// Route name constant for navigation
  static const routeName = "/[feature_name]";

  /// Optional parameters that can be passed to the screen
  final [ParameterType]? [parameterName];

  const [Feature]Screen({
    super.key,
    this.[parameterName],
  });

  @override
  State<[Feature]Screen> createState() => _[Feature]ScreenState();
}

class _[Feature]ScreenState extends State<[Feature]Screen> {
  /// ScrollController for managing list scrolling behavior
  /// Used for pagination, scroll-to-top, and performance optimization
  late final ScrollController _scrollController;

  /// TextEditingController for search functionality (if applicable)
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _scrollController = ScrollController();
    _searchController = TextEditingController();

    // Set up scroll listener for pagination (if needed)
    _scrollController.addListener(_onScroll);

    // Initialize any screen-specific setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Trigger initial data fetch after widget is built
      context.read<[Feature]Cubit>().fetchInitialData();
    });
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Handle scroll events for pagination or scroll-to-top functionality
  void _onScroll() {
    // Example: Load more data when reaching bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<[Feature]Cubit>().loadMoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Create and provide the cubit instance using dependency injection
      create: (context) => getIt<[Feature]Cubit>()
        ..fetchInitialData(), // Trigger initial data load

      child: BlocConsumer<[Feature]Cubit, [Feature]State>(
        // Listen for state changes that require UI side effects
        listener: (context, state) {
          _handleStateChanges(context, state);
        },

        // Build UI based on current state
        builder: (context, state) {
          return _buildScreenContent(context, state);
        },
      ),
    );
  }

  /// Handle state changes that require side effects (dialogs, navigation, etc.)
  void _handleStateChanges(BuildContext context, [Feature]State state) {
    switch (state.status) {
      case [Feature]Status.loading:
        // Show loading dialog for actions (not initial load)
        if (state.isActionLoading) {
          DialogUtils.showLoadingDialog();
        }
        break;

      case [Feature]Status.error:
        // Hide any existing dialogs and show error
        DialogUtils.hideDialog();
        DialogUtils.showErrorDialog(
          title: 'error'.tr(),
          message: state.errorMessage?.message ?? 'an_error_occurred'.tr(),
        );
        break;

      case [Feature]Status.success:
        // Hide loading dialog and show success message
        DialogUtils.hideDialog();
        DialogUtils.showSuccessDialog(
          title: 'success'.tr(),
          message: state.successMessage ?? 'operation_successful'.tr(),
        );
        break;

      case [Feature]Status.actionCompleted:
        // Handle completion of specific actions (e.g., data uploaded)
        DialogUtils.hideDialog();
        _showActionCompletedFeedback(state);
        break;
    }
  }

  /// Build the main screen content based on current state
  Widget _buildScreenContent(BuildContext context, [Feature]State state) {
    // Handle different loading states
    if (state.status == [Feature]Status.initialLoading) {
      return _buildLoadingScreen();
    }

    // Handle error states
    if (state.status == [Feature]Status.error && state.data.isEmpty) {
      return _buildErrorScreen(state);
    }

    // Build the main content when data is available
    return _buildMainContent(context, state);
  }

  /// Build loading screen for initial data fetch
  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: LoadingState(),
    );
  }

  /// Build error screen when no data is available
  Widget _buildErrorScreen([Feature]State state) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: ErrorState(
        exception: state.errorMessage ?? Exception('unknown_error'.tr()),
        onRetry: () {
          // Retry the failed operation
          context.read<[Feature]Cubit>().fetchInitialData();
        },
      ),
    );
  }

  /// Build the main screen content with all UI components
  Widget _buildMainContent(BuildContext context, [Feature]State state) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context, state),
      floatingActionButton: _buildFloatingActionButton(context, state),
      bottomNavigationBar: _buildBottomBar(context, state), // if applicable
    );
  }

  /// Build the app bar with title and actions
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      // Use localized title
      title: Text('[feature_name]'.tr()),

      // Add action buttons if needed
      actions: [
        // Search action
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Implement search functionality
            _showSearchDialog(context);
          },
          tooltip: 'search'.tr(),
        ),

        // Filter/Menu action
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'refresh',
              child: ListTile(
                leading: const Icon(Icons.refresh),
                title: Text('refresh'.tr()),
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: Text('settings'.tr()),
              ),
            ),
          ],
        ),
      ],

      // Add elevation for visual separation
      elevation: 2,
    );
  }

  /// Build the main body content
  Widget _buildBody(BuildContext context, [Feature]State state) {
    return RefreshIndicator(
      // Pull-to-refresh functionality
      onRefresh: () async {
        await context.read<[Feature]Cubit>().refreshData();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Search bar (if applicable)
          if (state.hasSearchFeature) _buildSearchSliver(context, state),

          // Filter chips (if applicable)
          if (state.hasFilters) _buildFilterSliver(context, state),

          // Main content list
          _buildContentSliver(context, state),

          // Loading indicator for pagination
          if (state.isLoadingMore) _buildLoadingMoreSliver(),
        ],
      ),
    );
  }

  /// Build the main content as a sliver list
  Widget _buildContentSliver(BuildContext context, [Feature]State state) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Handle empty state
          if (state.data.isEmpty) {
            return _buildEmptyState(context);
          }

          // Build individual list items
          final item = state.data[index];
          return [Feature]Card(
            item: item,
            onTap: () => _handleItemTap(context, item),
            onLongPress: () => _handleItemLongPress(context, item),
          );
        },
        childCount: state.data.isEmpty ? 1 : state.data.length,
      ),
    );
  }

  /// Build empty state widget when no data is available
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state illustration
          Icon(
            Icons.[empty_icon],
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),

          // Empty state title
          Text(
            'no_data_available'.tr(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          // Empty state description
          Text(
            'no_data_description'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Action button to add first item
          ElevatedButton.icon(
            onPressed: () => _handleAddAction(context),
            icon: const Icon(Icons.add),
            label: Text('add_first_item'.tr()),
          ),
        ],
      ),
    );
  }

  /// Build floating action button for primary actions
  Widget? _buildFloatingActionButton(BuildContext context, [Feature]State state) {
    // Only show FAB when not in loading state
    if (state.status == [Feature]Status.loading) {
      return null;
    }

    return FloatingActionButton(
      onPressed: () => _handleAddAction(context),
      tooltip: 'add_new'.tr(),
      child: const Icon(Icons.add),
    );
  }

  /// Handle item tap events
  void _handleItemTap(BuildContext context, [ItemType] item) {
    // Navigate to detail screen or perform action
    Navigator.pushNamed(
      context,
      '[Detail]Screen.routeName',
      arguments: item.id,
    );
  }

  /// Handle item long press events
  void _handleItemLongPress(BuildContext context, [ItemType] item) {
    // Show context menu or selection mode
    _showItemContextMenu(context, item);
  }

  /// Handle add action from FAB or empty state
  void _handleAddAction(BuildContext context) {
    // Show add dialog or navigate to add screen
    _showAddDialog(context);
  }

  /// Handle menu actions from app bar
  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'refresh':
        context.read<[Feature]Cubit>().refreshData();
        break;
      case 'settings':
        // Navigate to settings
        break;
    }
  }

  /// Show action completed feedback to user
  void _showActionCompletedFeedback([Feature]State state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.successMessage ?? 'action_completed'.tr()),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Additional helper methods for dialogs and interactions
  void _showSearchDialog(BuildContext context) {
    // Implement search dialog
  }

  void _showItemContextMenu(BuildContext context, [ItemType] item) {
    // Implement context menu
  }

  void _showAddDialog(BuildContext context) {
    // Implement add item dialog
  }
}

```

### State Management Implementation

```dart
// lib/features/[feature_name]/presentation/cubit/[feature]_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

// Domain layer imports
import '../../domain/use_cases/[fetch_data]_use_case.dart';
import '../../domain/use_cases/[create_item]_use_case.dart';
import '../../domain/use_cases/[update_item]_use_case.dart';
import '../../domain/use_cases/[delete_item]_use_case.dart';

// Data transfer objects
import '../../dto/[feature]_dto.dart';

// State definition
import '[feature]_state.dart';

/// Cubit responsible for managing [Feature] state and business logic
///
/// This cubit coordinates between the UI and domain layer, handling:
/// - Data fetching and caching
/// - User actions (create, update, delete)
/// - Error handling and recovery
/// - Loading states and user feedback
class [Feature]Cubit extends Cubit<[Feature]State> {
  /// Use case for fetching data from repository
  final [FetchData]UseCase _fetchDataUseCase;

  /// Use case for creating new items
  final [CreateItem]UseCase _createItemUseCase;

  /// Use case for updating existing items
  final [UpdateItem]UseCase _updateItemUseCase;

  /// Use case for deleting items
  final [DeleteItem]UseCase _deleteItemUseCase;

  /// Constructor with dependency injection
  ///
  /// All use cases are injected via constructor to enable:
  /// - Dependency inversion principle
  /// - Easy testing with mocks
  /// - Loose coupling between layers
  [Feature]Cubit({
    required [FetchData]UseCase fetchDataUseCase,
    required [CreateItem]UseCase createItemUseCase,
    required [UpdateItem]UseCase updateItemUseCase,
    required [DeleteItem]UseCase deleteItemUseCase,
  }) : _fetchDataUseCase = fetchDataUseCase,
       _createItemUseCase = createItemUseCase,
       _updateItemUseCase = updateItemUseCase,
       _deleteItemUseCase = deleteItemUseCase,
       super(const [Feature]State.initial());

  /// Fetch initial data when screen loads
  ///
  /// This method handles the initial data loading process:
  /// 1. Emit loading state to show loading UI
  /// 2. Call the fetch data use case
  /// 3. Handle success/error responses
  /// 4. Update state accordingly
  Future<void> fetchInitialData() async {
    try {
      // Don't show loading if we already have data (for refresh scenarios)
      if (state.data.isEmpty) {
        emit(state.copyWith(status: [Feature]Status.initialLoading));
      }

      // Execute the fetch data use case
      final result = await _fetchDataUseCase.call();

      // Handle the Either result (success or failure)
      result.fold(
        // Handle error case
        (failure) {
          emit(state.copyWith(
            status: [Feature]Status.error,
            errorMessage: failure,
            isActionLoading: false,
          ));
        },
        // Handle success case
        (data) {
          emit(state.copyWith(
            status: [Feature]Status.loaded,
            data: data,
            errorMessage: null,
            isActionLoading: false,
            lastUpdated: DateTime.now(),
          ));
        },
      );
    } catch (e) {
      // Handle unexpected errors
      emit(state.copyWith(
        status: [Feature]Status.error,
        errorMessage: Exception('Unexpected error: ${e.toString()}'),
        isActionLoading: false,
      ));
    }
  }

  /// Refresh data with pull-to-refresh or manual refresh
  ///
  /// Similar to fetchInitialData but optimized for refresh scenarios:
  /// - Maintains existing data during refresh
  /// - Shows subtle loading indicators
  /// - Handles network errors gracefully
  Future<void> refreshData() async {
    try {
      // Set refreshing flag without clearing existing data
      emit(state.copyWith(isRefreshing: true));

      final result = await _fetchDataUseCase.call();

      result.fold(
        (failure) {
          // On refresh error, keep existing data and show error feedback
          emit(state.copyWith(
            isRefreshing: false,
            errorMessage: failure,
            // Keep existing data and loaded status
          ));
        },
        (data) {
          emit(state.copyWith(
            status: [Feature]Status.loaded,
            data: data,
            errorMessage: null,
            isRefreshing: false,
            lastUpdated: DateTime.now(),
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: Exception('Refresh failed: ${e.toString()}'),
      ));
    }
  }

  /// Load more data for pagination
  ///
  /// Handles infinite scrolling and pagination:
  /// - Checks if more data is available
  /// - Prevents multiple simultaneous requests
  /// - Appends new data to existing list
  Future<void> loadMoreData() async {
    // Prevent multiple simultaneous pagination requests
    if (state.isLoadingMore || !state.hasMoreData) {
      return;
    }

    try {
      emit(state.copyWith(isLoadingMore: true));

      // Calculate pagination parameters
      final offset = state.data.length;
      const limit = 20; // Items per page

      final result = await _fetchDataUseCase.call(
        offset: offset,
        limit: limit,
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            isLoadingMore: false,
            errorMessage: failure,
          ));
        },
        (newData) {
          // Append new data to existing list
          final updatedData = [...state.data, ...newData];

          emit(state.copyWith(
            data: updatedData,
            isLoadingMore: false,
            hasMoreData: newData.length == limit, // Has more if full page returned
            errorMessage: null,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: Exception('Load more failed: ${e.toString()}'),
      ));
    }
  }

  /// Create a new item
  ///
  /// Handles the creation of new items with optimistic updates:
  /// - Shows loading state immediately
  /// - Calls create use case
  /// - Updates local data on success
  /// - Handles validation and server errors
  Future<void> createItem([Feature]Dto dto) async {
    try {
      // Show loading state for the create action
      emit(state.copyWith(
        status: [Feature]Status.loading,
        isActionLoading: true,
      ));

      final result = await _createItemUseCase.call(dto);

      result.fold(
        (failure) {
          emit(state.copyWith(
            status: [Feature]Status.error,
            errorMessage: failure,
            isActionLoading: false,
          ));
        },
        (newItem) {
          // Add new item to the beginning of the list (most recent first)
          final updatedData = [newItem, ...state.data];

          emit(state.copyWith(
            status: [Feature]Status.actionCompleted,
            data: updatedData,
            successMessage: 'Item created successfully',
            errorMessage: null,
            isActionLoading: false,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: [Feature]Status.error,
        errorMessage: Exception('Create failed: ${e.toString()}'),
        isActionLoading: false,
      ));
    }
  }

  /// Update an existing item
  ///
  /// Handles item updates with optimistic UI updates:
  /// - Immediately updates local data
  /// - Calls update use case
  /// - Reverts changes on failure
  Future<void> updateItem(String itemId, [Feature]Dto dto) async {
    try {
      // Store original data for potential rollback
      final originalData = List<[ItemType]>.from(state.data);
      final itemIndex = state.data.indexWhere((item) => item.id == itemId);

      if (itemIndex == -1) {
        emit(state.copyWith(
          errorMessage: Exception('Item not found'),
        ));
        return;
      }

      // Optimistic update - immediately update UI
      final updatedData = List<[ItemType]>.from(state.data);
      updatedData[itemIndex] = updatedData[itemIndex].copyWith(
        // Update fields from DTO
        [field]: dto.[field],
        // ... other fields
      );

      emit(state.copyWith(
        data: updatedData,
        isActionLoading: true,
      ));

      final result = await _updateItemUseCase.call(itemId, dto);

      result.fold(
        (failure) {
          // Rollback optimistic update on failure
          emit(state.copyWith(
            data: originalData,
            status: [Feature]Status.error,
            errorMessage: failure,
            isActionLoading: false,
          ));
        },
        (updatedItem) {
          // Update with server response (may have additional fields)
          final finalData = List<[ItemType]>.from(state.data);
          finalData[itemIndex] = updatedItem;

          emit(state.copyWith(
            data: finalData,
            status: [Feature]Status.actionCompleted,
            successMessage: 'Item updated successfully',
            errorMessage: null,
            isActionLoading: false,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: [Feature]Status.error,
        errorMessage: Exception('Update failed: ${e.toString()}'),
        isActionLoading: false,
      ));
    }
  }

  /// Delete an item
  ///
  /// Handles item deletion with confirmation and optimistic updates:
  /// - Immediately removes from UI
  /// - Calls delete use case
  /// - Handles undo functionality
  Future<void> deleteItem(String itemId) async {
    try {
      // Find and store the item for potential restoration
      final itemIndex = state.data.indexWhere((item) => item.id == itemId);
      if (itemIndex == -1) {
        emit(state.copyWith(
          errorMessage: Exception('Item not found'),
        ));
        return;
      }

      final deletedItem = state.data[itemIndex];
      final updatedData = List<[ItemType]>.from(state.data)
        ..removeAt(itemIndex);

      // Optimistically remove item from UI
      emit(state.copyWith(
        data: updatedData,
        isActionLoading: true,
      ));

      final result = await _deleteItemUseCase.call(itemId);

      result.fold(
        (failure) {
          // Restore item on failure
          final restoredData = List<[ItemType]>.from(state.data);
          restoredData.insert(itemIndex, deletedItem);

          emit(state.copyWith(
            data: restoredData,
            status: [Feature]Status.error,
            errorMessage: failure,
            isActionLoading: false,
          ));
        },
        (_) {
          emit(state.copyWith(
            status: [Feature]Status.actionCompleted,
            successMessage: 'Item deleted successfully',
            errorMessage: null,
            isActionLoading: false,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: [Feature]Status.error,
        errorMessage: Exception('Delete failed: ${e.toString()}'),
        isActionLoading: false,
      ));
    }
  }

  /// Search/filter items based on query
  ///
  /// Handles local search and server-side filtering:
  /// - Debounces search queries
  /// - Supports both local and remote search
  /// - Maintains search state
  Future<void> searchItems(String query) async {
    try {
      if (query.isEmpty) {
        // Reset to original data when search is cleared
        await fetchInitialData();
        return;
      }

      emit(state.copyWith(
        isSearching: true,
        searchQuery: query,
      ));

      // For local search (if data is already loaded)
      if (state.data.isNotEmpty) {
        final filteredData = state.data.where((item) =>
          item.[searchField].toLowerCase().contains(query.toLowerCase())
        ).toList();

        emit(state.copyWith(
          filteredData: filteredData,
          isSearching: false,
        ));
        return;
      }

      // For server-side search
      final result = await _fetchDataUseCase.call(searchQuery: query);

      result.fold(
        (failure) {
          emit(state.copyWith(
            status: [Feature]Status.error,
            errorMessage: failure,
            isSearching: false,
          ));
        },
        (searchResults) {
          emit(state.copyWith(
            filteredData: searchResults,
            isSearching: false,
            errorMessage: null,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: [Feature]Status.error,
        errorMessage: Exception('Search failed: ${e.toString()}'),
        isSearching: false,
      ));
    }
  }

  /// Clear any error states
  ///
  /// Allows users to dismiss errors and return to normal state
  void clearError() {
    emit(state.copyWith(
      status: state.data.isEmpty ? [Feature]Status.initial : [Feature]Status.loaded,
      errorMessage: null,
    ));
  }

  /// Reset the entire state
  ///
  /// Useful for logout scenarios or feature resets
  void reset() {
    emit(const [Feature]State.initial());
  }
}

```

### State Definition

```dart
// lib/features/[feature_name]/presentation/cubit/[feature]_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/[feature]_model.dart';

/// Enum defining all possible states for the [Feature] feature
///
/// States are organized by lifecycle and action types:
/// - Lifecycle: initial, loading, loaded, error
/// - Actions: actionCompleted for specific user actions
enum [Feature]Status {
  /// Initial state when cubit is first created
  initial,

  /// Loading state for initial data fetch
  initialLoading,

  /// Successfully loaded with data
  loaded,

  /// Error state when operations fail
  error,

  /// Loading state for user actions (create, update, delete)
  loading,

  /// State indicating a user action was completed successfully
  actionCompleted,
}

/// Immutable state class for [Feature] feature
///
/// Contains all UI-relevant data and follows these principles:
/// - Immutability: State objects never change after creation
/// - Completeness: Contains all data needed by UI
/// - Minimal: No derived or computed data
/// - Serializable: Can be easily serialized for state persistence
class [Feature]State extends Equatable {
  /// Current status of the feature
  final [Feature]Status status;

  /// List of main data items displayed in the UI
  final List<[ItemType]> data;

  /// Filtered/searched data subset (null means no filter applied)
  final List<[ItemType]>? filteredData;

  /// Current error message if any operation failed
  final Exception? errorMessage;

  /// Success message for positive user feedback
  final String? successMessage;

  /// Loading flag for specific actions (not initial load)
  final bool isActionLoading;

  /// Flag indicating if data is being refreshed
  final bool isRefreshing;

  /// Flag indicating if more data is being loaded (pagination)
  final bool isLoadingMore;

  /// Flag indicating if more pages are available for pagination
  final bool hasMoreData;

  /// Flag indicating if search operation is in progress
  final bool isSearching;

  /// Current search query string
  final String searchQuery;

  /// Timestamp of last successful data update
  final DateTime? lastUpdated;

  /// Selected items (for multi-select scenarios)
  final Set<String> selectedItems;

  /// Current filter criteria
  final Map<String, dynamic> filters;

  /// Private constructor to ensure immutability
  const [Feature]State._({
    required this.status,
    required this.data,
    this.filteredData,
    this.errorMessage,
    this.successMessage,
    required this.isActionLoading,
    required this.isRefreshing,
    required this.isLoadingMore,
    required this.hasMoreData,
    required this.isSearching,
    required this.searchQuery,
    this.lastUpdated,
    required this.selectedItems,
    required this.filters,
  });

  /// Factory constructor for initial state
  ///
  /// Creates the default state when cubit is first instantiated
  const [Feature]State.initial()
      : this._(
          status: [Feature]Status.initial,
          data: const [],
          isActionLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          hasMoreData: true,
          isSearching: false,
          searchQuery: '',
          selectedItems: const {},
          filters: const {},
        );

  /// Create a copy of the state with updated values
  ///
  /// This method enables immutable updates by creating new state objects
  /// while preserving unchanged values from the current state
  [Feature]State copyWith({
    [Feature]Status? status,
    List<[ItemType]>? data,
    List<[ItemType]>? filteredData,
    Exception? errorMessage,
    String? successMessage,
    bool? isActionLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMoreData,
    bool? isSearching,
    String? searchQuery,
    DateTime? lastUpdated,
    Set<String>? selectedItems,
    Map<String, dynamic>? filters,
  }) {
    return [Feature]State._(
      status: status ?? this.status,
      data: data ?? this.data,
      filteredData: filteredData,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      selectedItems: selectedItems ?? this.selectedItems,
      filters: filters ?? this.filters,
    );
  }

  /// Computed property: Get the data to display (filtered or all)
  ///
  /// Returns filtered data if search/filter is active, otherwise all data
  List<[ItemType]> get displayData => filteredData ?? data;

  /// Computed property: Check if any data is available
  bool get hasData => data.isNotEmpty;

  /// Computed property: Check if search/filter is active
  bool get isFiltered => filteredData != null;

  /// Computed property: Check if any items are selected
  bool get hasSelectedItems => selectedItems.isNotEmpty;

  /// Computed property: Check if all visible items are selected
  bool get areAllItemsSelected =>
      displayData.isNotEmpty &&
      displayData.every((item) => selectedItems.contains(item.id));

  /// Computed property: Check if the state represents a loading condition
  bool get isLoading => status == [Feature]Status.initialLoading ||
                        status == [Feature]Status.loading ||
                        isRefreshing ||
                        isLoadingMore ||
                        isSearching;

  /// Computed property: Check if the feature has search capability
  bool get hasSearchFeature => true; // Configure based on feature needs

  /// Computed property: Check if the feature has filter capability
  bool get hasFilters => filters.isNotEmpty;

  @override
  List<Object?> get props => [
        status,
        data,
        filteredData,
        errorMessage,
        successMessage,
        isActionLoading,
        isRefreshing,
        isLoadingMore,
        hasMoreData,
        isSearching,
        searchQuery,
        lastUpdated,
        selectedItems,
        filters,
      ];

  @override
  String toString() {
    return '[Feature]State('
        'status: $status, '
        'dataCount: ${data.length}, '
        'hasError: ${errorMessage != null}, '
        'isLoading: $isLoading, '
        'searchQuery: "$searchQuery", '
        'selectedCount: ${selectedItems.length}'
        ')';
  }
}

```

### Custom Widget Implementation

```dart
// lib/features/[feature_name]/presentation/widgets/[feature]_card.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../data/models/[feature]_model.dart';

/// Custom card widget for displaying [Feature] items
///
/// This reusable widget provides:
/// - Consistent visual design across the app
/// - Accessibility support
/// - Interactive feedback
/// - Customizable actions and content
///
/// Design follows Material 3 guidelines with:
/// - Proper elevation and shadows
/// - Theme-aware colors
/// - Responsive layout
/// - Touch feedback animations
class [Feature]Card extends StatelessWidget {
  /// The data item to display in this card
  final [ItemType] item;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Callback when the card is long pressed
  final VoidCallback? onLongPress;

  /// Whether this card is currently selected (for multi-select)
  final bool isSelected;

  /// Whether to show additional actions (edit, delete buttons)
  final bool showActions;

  /// Custom action buttons to display
  final List<Widget>? customActions;

  /// Whether the card should be compact (reduced padding/content)
  final bool isCompact;

  const [Feature]Card({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.showActions = true,
    this.customActions,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: isCompact ? 4.0 : 8.0,
      ),
      child: Card(
        // Use theme elevation for consistency
        elevation: isSelected ? 8.0 : 2.0,

        // Animated selection state
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,

        // Consistent card shape
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: isSelected
              ? BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                )
              : BorderSide.none,
        ),

        // Ensure proper semantics for accessibility
        child: Semantics(
          button: true,
          selected: isSelected,
          label: _buildAccessibilityLabel(context),
          child: InkWell(
            // Handle user interactions
            onTap: onTap,
            onLongPress: onLongPress,

            // Match card border radius for ink effect
            borderRadius: BorderRadius.circular(12.0),

            // Provide haptic feedback on long press
            onSecondaryTap: onLongPress,

            child: Padding(
              padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
              child: _buildCardContent(context),
            ),
          ),
        ),
      ),
    );
  }

  /// Build the main content of the card
  Widget _buildCardContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header row with title and status
        _buildHeaderRow(context),

        if (!isCompact) ...[
          const SizedBox(height: 8.0),
          // Subtitle or description
          _buildSubtitle(context),

          const SizedBox(height: 12.0),
          // Main content area
          _buildMainContent(context),

          if (showActions || customActions != null) ...[
            const SizedBox(height: 16.0),
            // Action buttons row
            _buildActionsRow(context),
          ],
        ],
      ],
    );
  }

  /// Build the header row with title and status indicators
  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      children: [
        // Leading icon (if applicable)
        if (item.hasIcon) ...[
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              item.iconData,
              size: 24.0,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12.0),
        ],

        // Title and status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main title
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              if (item.subtitle != null) ...[
                const SizedBox(height: 4.0),
                Text(
                  item.subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        // Status badge or trailing content
        if (item.hasStatus) _buildStatusBadge(context),

        // Selection indicator
        if (isSelected)
          Container(
            margin: const EdgeInsets.only(left: 8.0),
            child: Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 24.0,
            ),
          ),
      ],
    );
  }

  /// Build subtitle text if not in compact mode
  Widget _buildSubtitle(BuildContext context) {
    if (item.description == null) return const SizedBox.shrink();

    return Text(
      item.description!,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.9)
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build main content area with key information
  Widget _buildMainContent(BuildContext context) {
    return Row(
      children: [
        // Primary metrics or data
        Expanded(
          child: _buildMetrics(context),
        ),

        // Secondary information (date, tags, etc.)
        if (item.hasMetadata)
          _buildMetadata(context),
      ],
    );
  }

  /// Build metrics display (numbers, progress, etc.)
  Widget _buildMetrics(BuildContext context) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: [
        // Example metric 1
        if (item.metric1 != null)
          _buildMetricChip(
            context,
            icon: Icons.analytics,
            label: item.metric1!.toString(),
            color: Theme.of(context).colorScheme.tertiary,
          ),

        // Example metric 2
        if (item.metric2 != null)
          _buildMetricChip(
            context,
            icon: Icons.trending_up,
            label: item.metric2!,
            color: Theme.of(context).colorScheme.secondary,
          ),
      ],
    );
  }

  /// Build individual metric chip
  Widget _buildMetricChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.0,
            color: color,
          ),
          const SizedBox(width: 4.0),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build metadata section (date, tags, etc.)
  Widget _buildMetadata(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Date/time information
        if (item.createdAt != null)
          Text(
            DateFormat.yMd().format(item.createdAt!),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

        // Tags or categories
        if (item.tags != null && item.tags!.isNotEmpty) ...[
          const SizedBox(height: 4.0),
          Wrap(
            spacing: 4.0,
            children: item.tags!.take(2).map((tag) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  tag,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ).toList(),
          ),
        ],
      ],
    );
  }

  /// Build status badge
  Widget _buildStatusBadge(BuildContext context) {
    Color badgeColor;
    String statusText;

    switch (item.status) {
      case ItemStatus.active:
        badgeColor = Colors.green;
        statusText = 'active'.tr();
        break;
      case ItemStatus.pending:
        badgeColor = Colors.orange;
        statusText = 'pending'.tr();
        break;
      case ItemStatus.inactive:
        badgeColor = Colors.red;
        statusText = 'inactive'.tr();
        break;
      default:
        badgeColor = Colors.grey;
        statusText = 'unknown'.tr();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Text(
        statusText,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Build action buttons row
  Widget _buildActionsRow(BuildContext context) {
    return Row(
      children: [
        // Custom actions have priority
        if (customActions != null) ...customActions!,

        // Default actions if no custom ones provided
        if (customActions == null && showActions) ...[
          // Edit action
          TextButton.icon(
            onPressed: () => _handleEditAction(context),
            icon: Icon(
              Icons.edit,
              size: 16.0,
            ),
            label: Text('edit'.tr()),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(width: 8.0),

          // Delete action
          TextButton.icon(
            onPressed: () => _handleDeleteAction(context),
            icon: Icon(
              Icons.delete_outline,
              size: 16.0,
            ),
            label: Text('delete'.tr()),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],

        const Spacer(),

        // More actions menu
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onSelected: (action) => _handleMenuAction(context, action),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('share'.tr()),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: 'duplicate',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('duplicate'.tr()),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: 'archive',
              child: ListTile(
                leading: Icon(Icons.archive),
                title: Text('archive'.tr()),
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build accessibility label for screen readers
  String _buildAccessibilityLabel(BuildContext context) {
    final buffer = StringBuffer();
    buffer.write(item.title);

    if (item.subtitle != null) {
      buffer.write(', ${item.subtitle}');
    }

    if (item.hasStatus) {
      buffer.write(', status: ${item.status}');
    }

    if (isSelected) {
      buffer.write(', ${'selected'.tr()}');
    }

    buffer.write('. ${'double_tap_to_open'.tr()}');

    return buffer.toString();
  }

  /// Handle edit action
  void _handleEditAction(BuildContext context) {
    // Navigate to edit screen or show edit dialog
    // Implementation depends on app navigation structure
  }

  /// Handle delete action with confirmation
  void _handleDeleteAction(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm_delete'.tr()),
        content: Text('delete_confirmation_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Trigger delete action through cubit
              // context.read<[Feature]Cubit>().deleteItem(item.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }

  /// Handle menu actions
  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'share':
        // Implement share functionality
        break;
      case 'duplicate':
        // Implement duplicate functionality
        break;
      case 'archive':
        // Implement archive functionality
        break;
    }
  }
}

```

### Domain Layer

### Use Case Implementation

```dart
// lib/features/[feature_name]/domain/use_cases/[fetch_data]_use_case.dart

import 'package:dartz/dartz.dart';

import '../entities/[feature]_entity.dart';
import '../repositories/[feature]_repository.dart';
import '../../../../core/error/exceptions.dart';

/// Use case for fetching [Feature] data from repository
///
/// This use case encapsulates the business logic for data retrieval:
/// - Validates input parameters
/// - Coordinates with repository layer
/// - Handles business rules and transformations
/// - Returns standardized Either results
///
/// Follows Single Responsibility Principle - only handles data fetching
class [FetchData]UseCase {
  /// Repository dependency for data access
  final [Feature]Repository _repository;

  /// Constructor with dependency injection
  const [FetchData]UseCase(this._repository);

  /// Execute the use case to fetch data
  ///
  /// Parameters:
  /// - [offset]: Starting index for pagination (optional)
  /// - [limit]: Number of items to fetch (optional)
  /// - [searchQuery]: Search term for filtering (optional)
  /// - [filters]: Additional filter criteria (optional)
  ///
  /// Returns:
  /// - Either<Exception, List<[Entity]>> representing success or failure
  Future<Either<Exception, List<[Entity]>>> call({
    int offset = 0,
    int limit = 20,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // Validate input parameters
      if (offset < 0) {
        return Left(ValidationException('Offset cannot be negative'));
      }

      if (limit <= 0 || limit > 100) {
        return Left(ValidationException('Limit must be between 1 and 100'));
      }

      // Apply business rules for search query
      if (searchQuery != null) {
        final trimmedQuery = searchQuery.trim();
        if (trimmedQuery.isEmpty) {
          searchQuery = null; // Treat empty search as no search
        } else if (trimmedQuery.length < 2) {
          return Left(ValidationException('Search query must be at least 2 characters'));
        }
      }

      // Call repository with validated parameters
      final result = await _repository.fetchData(
        offset: offset,
        limit: limit,
        searchQuery: searchQuery,
        filters: filters,
      );

      // Apply any business logic transformations
      return result.map((entities) => _applyBusinessRules(entities));

    } catch (e) {
      // Handle unexpected errors
      return Left(UnexpectedException('Unexpected error in fetch data use case: $e'));
    }
  }

  /// Apply business-specific rules and transformations to entities
  ///
  /// This method can be used to:
  /// - Sort entities according to business logic
  /// - Filter out entities that don't meet business criteria
  /// - Transform or enrich entity data
  /// - Apply user-specific permissions
  List<[Entity]> _applyBusinessRules(List<[Entity]> entities) {
    return entities
        // Example: Filter out inactive items for regular users
        .where((entity) => entity.isActive || _userHasAdminPermissions())
        // Example: Sort by business priority
        .toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// Check if current user has admin permissions
  ///
  /// In a real implementation, this would check user role/permissions
  bool _userHasAdminPermissions() {
    // Implement actual permission checking logic
    // This might involve checking user role from a user service
    return false; // Placeholder
  }
}

```

### Repository Interface

```dart
// lib/features/[feature_name]/domain/repositories/[feature]_repository.dart

import 'package:dartz/dartz.dart';

import '../entities/[feature]_entity.dart';
import '../../dto/[feature]_dto.dart';

/// Abstract repository interface for [Feature] data operations
///
/// This interface defines the contract between domain and data layers:
/// - Provides method signatures for all data operations
/// - Uses domain entities (not data models)
/// - Returns Either types for error handling
/// - Follows Repository pattern from Clean Architecture
///
/// Implementation details are hidden from domain layer
abstract class [Feature]Repository {
  /// Fetch a list of entities with optional parameters
  ///
  /// Parameters:
  /// - [offset]: Starting index for pagination
  /// - [limit]: Maximum number of items to return
  /// - [searchQuery]: Optional search term
  /// - [filters]: Optional filter criteria
  ///
  /// Returns:
  /// - Either<Exception, List<[Entity]>> - Success with entities or failure with exception
  Future<Either<Exception, List<[Entity]>>> fetchData({
    int offset = 0,
    int limit = 20,
    String? searchQuery,
    Map<String, dynamic>? filters,
  });

  /// Fetch a single entity by its unique identifier
  ///
  /// Parameters:
  /// - [id]: Unique identifier of the entity
  ///
  /// Returns:
  /// - Either<Exception, [Entity]> - Success with entity or failure with exception
  Future<Either<Exception, [Entity]>> fetchById(String id);

  /// Create a new entity
  ///
  /// Parameters:
  /// - [dto]: Data transfer object containing creation data
  ///
  /// Returns:
  /// - Either<Exception, [Entity]> - Success with created entity or failure with exception
  Future<Either<Exception, [Entity]>> create([Feature]Dto dto);

  /// Update an existing entity
  ///
  /// Parameters:
  /// - [id]: Unique identifier of entity to update
  /// - [dto]: Data transfer object containing updated data
  ///
  /// Returns:
  /// - Either<Exception, [Entity]> - Success with updated entity or failure with exception
  Future<Either<Exception, [Entity]>> update(String id, [Feature]Dto dto);

  /// Delete an entity
  ///
  /// Parameters:
  /// - [id]: Unique identifier of entity to delete
  ///
  /// Returns:
  /// - Either<Exception, void> - Success or failure with exception
  Future<Either<Exception, void>> delete(String id);

  /// Batch operations for multiple entities
  ///
  /// Parameters:
  /// - [ids]: List of entity identifiers
  /// - [action]: Action to perform (delete, archive, etc.)
  ///
  /// Returns:
  /// - Either<Exception, List<[Entity]>> - Success with affected entities or failure
  Future<Either<Exception, List<[Entity]>>> batchOperation(
    List<String> ids,
    String action,
  );

  /// Search entities with advanced criteria
  ///
  /// Parameters:
  /// - [criteria]: Complex search criteria object
  ///
  /// Returns:
  /// - Either<Exception, List<[Entity]>> - Success with matching entities or failure
  Future<Either<Exception, List<[Entity]>>> search([SearchCriteria] criteria);
}

```

### Data Layer

### Model Implementation

```dart
// lib/features/[feature_name]/data/models/[feature]_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/[feature]_entity.dart';

// This generates the serialization code
part '[feature]_model.g.dart';

/// Data model for [Feature] with JSON serialization
///
/// This model:
/// - Handles JSON serialization/deserialization
/// - Extends domain entity for data consistency
/// - Provides factory constructors for different sources
/// - Implements data validation and transformation
///
/// Code generation creates toJson/fromJson methods automatically
@JsonSerializable()
class [Feature]Model extends [Feature]Entity {
  /// Constructor with all required and optional parameters
  const [Feature]Model({
    required super.id,
    required super.title,
    required super.description,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.subtitle,
    super.tags,
    super.metadata,
    super.isActive,
    super.priority,
  });

  /// Create model from JSON map (from API response)
  ///
  /// Handles:
  /// - Field mapping and transformation
  /// - Data validation
  /// - Default value assignment
  /// - Type conversion
  factory [Feature]Model.fromJson(Map<String, dynamic> json) {
    try {
      return _$[Feature]ModelFromJson(json);
    } catch (e) {
      throw FormatException('Invalid JSON format for [Feature]Model: $e');
    }
  }

  /// Convert model to JSON map (for API requests)
  ///
  /// Excludes:
  /// - Read-only fields (id, createdAt, updatedAt for create requests)
  /// - Null values where appropriate
  /// - Internal/computed fields
  Map<String, dynamic> toJson() => _$[Feature]ModelToJson(this);

  /// Create model from domain entity
  ///
  /// Useful for:
  /// - Converting entities back to models for API calls
  /// - Testing with mock entities
  /// - Data layer transformations
  factory [Feature]Model.fromEntity([Feature]Entity entity) {
    return [Feature]Model(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      subtitle: entity.subtitle,
      tags: entity.tags,
      metadata: entity.metadata,
      isActive: entity.isActive,
      priority: entity.priority,
    );
  }

  /// Create a copy with updated values (immutable updates)
  ///
  /// Maintains immutability while allowing field updates
  /// Used for:
  /// - Optimistic UI updates
  /// - State management
  /// - Data transformation
  [Feature]Model copyWith({
    String? id,
    String? title,
    String? description,
    String? subtitle,
    ItemStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    bool? isActive,
    int? priority,
  }) {
    return [Feature]Model(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subtitle: subtitle ?? this.subtitle,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
    );
  }

  /// Create empty/default model instance
  ///
  /// Useful for:
  /// - Form initialization
  /// - Default state values
  /// - Testing scenarios
  factory [Feature]Model.empty() {
    return [Feature]Model(
      id: '',
      title: '',
      description: '',
      status: ItemStatus.inactive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: false,
      priority: 0,
    );
  }

  /// Validate model data integrity
  ///
  /// Checks:
  /// - Required fields are not empty
  /// - Data formats are correct
  /// - Business rules are satisfied
  /// - Cross-field validation
  bool isValid() {
    return id.isNotEmpty &&
           title.isNotEmpty &&
           description.isNotEmpty &&
           priority >= 0 &&
           createdAt.isBefore(DateTime.now().add(const Duration(minutes: 1))) &&
           _validateCustomRules();
  }

  /// Apply custom business validation rules
  bool _validateCustomRules() {
    // Example: Title should not exceed certain length
    if (title.length > 100) return false;

    // Example: Description should be meaningful
    if (description.length < 10) return false;

    // Example: Tags should be properly formatted
    if (tags != null) {
      for (final tag in tags!) {
        if (tag.isEmpty || tag.length > 20) return false;
      }
    }

    return true;
  }

  /// Convert to display-friendly format
  ///
  /// Transforms data for UI consumption:
  /// - Formats dates and numbers
  /// - Handles null values gracefully
  /// - Applies localization where needed
  Map<String, String> toDisplayMap() {
    return {
      'ID': id,
      'Title': title,
      'Description': description,
      'Status': status.displayName,
      'Created': DateFormat.yMMMd().format(createdAt),
      'Updated': DateFormat.yMMMd().format(updatedAt),
      'Priority': priority.toString(),
      'Active': isActive ? 'Yes' : 'No',
      if (tags != null && tags!.isNotEmpty)
        'Tags': tags!.join(', '),
    };
  }

  @override
  String toString() {
    return '[Feature]Model('
        'id: $id, '
        'title: $title, '
        'status: $status, '
        'isActive: $isActive'
        ')';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        subtitle,
        status,
        createdAt,
        updatedAt,
        tags,
        metadata,
        isActive,
        priority,
      ];
}

```

### Repository Implementation

```dart
// lib/features/[feature_name]/data/repositories/[feature]_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../domain/entities/[feature]_entity.dart';
import '../../domain/repositories/[feature]_repository.dart';
import '../../dto/[feature]_dto.dart';
import '../data_sources/remote/[feature]_remote_data_source.dart';
import '../data_sources/local/[feature]_local_data_source.dart';
import '../models/[feature]_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';

/// Implementation of [Feature]Repository interface
///
/// This implementation:
/// - Coordinates between remote and local data sources
/// - Handles offline/online scenarios
/// - Implements caching strategies
/// - Provides error handling and recovery
/// - Transforms models to entities
class [Feature]RepositoryImpl implements [Feature]Repository {
  /// Remote data source for API communication
  final [Feature]RemoteDataSource _remoteDataSource;

  /// Local data source for caching and offline support
  final [Feature]LocalDataSource _localDataSource;

  /// Network connectivity checker
  final NetworkInfo _networkInfo;

  /// Constructor with dependency injection
  const [Feature]RepositoryImpl({
    required [Feature]RemoteDataSource remoteDataSource,
    required [Feature]LocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Exception, List<[Feature]Entity>>> fetchData({
    int offset = 0,
    int limit = 20,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // Check network connectivity
      if (await _networkInfo.isConnected) {
        return await _fetchDataFromRemote(
          offset: offset,
          limit: limit,
          searchQuery: searchQuery,
          filters: filters,
        );
      } else {
        return await _fetchDataFromLocal(
          offset: offset,
          limit: limit,
          searchQuery: searchQuery,
          filters: filters,
        );
      }
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  /// Fetch data from remote source with caching
  Future<Either<Exception, List<[Feature]Entity>>> _fetchDataFromRemote({
    int offset = 0,
    int limit = 20,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // Fetch from remote API
      final models = await _remoteDataSource.fetchData(
        offset: offset,
        limit: limit,
        searchQuery: searchQuery,
        filters: filters,
      );

      // Cache the fetched data for offline access
      if (offset == 0) {
        // Only cache the first page to avoid storage issues
        await _localDataSource.cacheData(models);
      }

      // Transform models to entities
      final entities = models.map((model) => model as [Feature]Entity).toList();
      return Right(entities);

    } on ServerException catch (e) {
      // Fall back to cached data on server error
      final cachedResult = await _fetchDataFromLocal(
        offset: offset,
        limit: limit,
        searchQuery: searchQuery,
        filters: filters,
      );

      return cachedResult.fold(
        (_) => Left(e), // Return original server error if no cached data
        (cachedData) => Right(cachedData), // Return cached data
      );
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  /// Fetch data from local cache
  Future<Either<Exception, List<[Feature]Entity>>> _fetchDataFromLocal({
    int offset = 0,
    int limit = 20,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final models = await _localDataSource.getCachedData(
        offset: offset,
        limit: limit,
        searchQuery: searchQuery,
        filters: filters,
      );

      if (models.isEmpty && offset == 0) {
        return Left(CacheException('No cached data available'));
      }

      final entities = models.map((model) => model as [Feature]Entity).toList();
      return Right(entities);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Exception, [Feature]Entity>> fetchById(String id) async {
    try {
      // Validate input
      if (id.isEmpty) {
        return Left(ValidationException('ID cannot be empty'));
      }

      // Try local cache first for better performance
      final cachedModel = await _localDataSource.getCachedById(id);
      if (cachedModel != null) {
        return Right(cachedModel as [Feature]Entity);
      }

      // Check network connectivity before remote call
      if (!await _networkInfo.isConnected) {
        return Left(NetworkException('No network connection and no cached data'));
      }

      // Fetch from remote source
      final model = await _remoteDataSource.fetchById(id);

      // Cache the result
      await _localDataSource.cacheItem(model);

      return Right(model as [Feature]Entity);

    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Exception, [Feature]Entity>> create([Feature]Dto dto) async {
    try {
      // Validate input
      if (!dto.isValid()) {
        return Left(ValidationException('Invalid DTO data'));
      }

      // Check network connectivity (creation requires network)
      if (!await _networkInfo.isConnected) {
        return Left(NetworkException('Network connection required for creating items'));
      }

      // Create via remote source
      final model = await _remoteDataSource.create(dto);

      // Add to local cache
      await _localDataSource.cacheItem(model);

      return Right(model as [Feature]Entity);

    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Exception, [Feature]Entity>> update(
    String id,
    [Feature]Dto dto,
  ) async {
    try {
      // Validate input
      if (id.isEmpty) {
        return Left(ValidationException('ID cannot be empty'));
      }

      if (!dto.isValid()) {
        return Left(ValidationException('Invalid DTO data'));
      }

      // Check network connectivity (update requires network)
      if (!await _networkInfo.isConnected) {
        return Left(NetworkException('Network connection required for updating items'));
      }

      // Update via remote source
      final model = await _remoteDataSource.update(id, dto);

      // Update local cache
      await _localDataSource.updateCachedItem(model);

      return Right(model as [Feature]Entity);

    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Exception, void>> delete(String id) async {
    try {
      // Validate input
      if (id.isEmpty) {
        return Left(ValidationException('ID cannot be empty'));
      }

      // Check network connectivity (deletion requires network)
      if (!await _networkInfo.isConnected) {
        return Left(NetworkException('Network connection required for deleting items'));
      }

      // Delete via remote source
      await _remoteDataSource.delete(id);

      // Remove from local cache
      await _localDataSource.removeCachedItem(id);

      return const Right(null);

    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Exception, List<[Feature]Entity>>> batchOperation(
    List<String> ids,
    String action,
  ) async {
    try {
      // Validate input
      if (ids.isEmpty) {
        return Left(ValidationException('IDs list cannot be empty'));
      }

      if (action.isEmpty) {
        return Left(ValidationException('Action cannot be empty'));
      }

      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkException('Network connection required for batch operations'));
      }

      // Perform batch operation via remote source
      final models = await _remoteDataSource.batchOperation(ids, action);

      // Update local cache based on action
      switch (action.toLowerCase()) {
        case 'delete':
          for (final id in ids) {
            await _localDataSource.removeCachedItem(id);
          }
          break;
        case 'update':
        case 'archive':
          for (final model in models) {
            await _localDataSource.updateCachedItem(model);
          }
          break;
      }

      final entities = models.map((model) => model as [Feature]Entity).toList();
      return Right(entities);

    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Exception, List<[Feature]Entity>>> search(
    [SearchCriteria] criteria,
  ) async {
    try {
      // Validate search criteria
      if (!criteria.isValid()) {
        return Left(ValidationException('Invalid search criteria'));
      }

      // For complex search, prefer remote source
      if (await _networkInfo.isConnected) {
        final models = await _remoteDataSource.search(criteria);
        final entities = models.map((model) => model as [Feature]Entity).toList();
        return Right(entities);
      } else {
        // Fall back to local search with limited capabilities
        final models = await _localDataSource.searchCached(criteria);
        final entities = models.map((model) => model as [Feature]Entity).toList();
        return Right(entities);
      }

    } catch (e) {
      return Left(_handleException(e));
    }
  }

  /// Handle and transform exceptions to appropriate types
  Exception _handleException(dynamic error) {
    if (error is ServerException) {
      return error;
    } else if (error is CacheException) {
      return error;
    } else if (error is NetworkException) {
      return error;
    } else if (error is ValidationException) {
      return error;
    } else {
      return UnexpectedException('Repository error: ${error.toString()}');
    }
  }

  /// Clear all cached data (useful for logout or data refresh)
  Future<Either<Exception, void>> clearCache() async {
    try {
      await _localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  /// Get cache statistics (useful for debugging)
  Future<Either<Exception, CacheStats>> getCacheStats() async {
    try {
      final stats = await _localDataSource.getCacheStats();
      return Right(stats);
    } catch (e) {
      return Left(_handleException(e));
    }
  }
}

```

### Dependency Injection

### Injection Configuration

```dart
// lib/features/[feature_name]/inject_[feature].dart

import 'package:get_it/get_it.dart';

// Data layer imports
import 'data/data_sources/local/[feature]_local_data_source.dart';
import 'data/data_sources/remote/[feature]_remote_data_source.dart';
import 'data/repositories/[feature]_repository_impl.dart';

// Domain layer imports
import 'domain/repositories/[feature]_repository.dart';
import 'domain/use_cases/[fetch_data]_use_case.dart';
import 'domain/use_cases/[create_item]_use_case.dart';
import 'domain/use_cases/[update_item]_use_case.dart';
import 'domain/use_cases/[delete_item]_use_case.dart';

// Presentation layer imports
import 'presentation/cubit/[feature]_cubit.dart';

/// Dependency injection configuration for [Feature] feature
///
/// This function registers all dependencies required by the feature:
/// - Data sources (remote and local)
/// - Repository implementation
/// - Use cases
/// - State management (Cubit)
///
/// Registration types:
/// - Factory: New instance each time (for stateful objects like Cubits)
/// - LazySingleton: Single instance created when first requested
/// - Singleton: Single instance created immediately
///
/// Call this function in the main service locator setup
void inject[Feature]() {
  final getIt = GetIt.instance;

  // ==================== PRESENTATION LAYER ====================

  /// Register Cubit as Factory
  ///
  /// Factory registration ensures each screen gets a fresh cubit instance
  /// This prevents state pollution between different screen instances
  getIt.registerFactory<[Feature]Cubit>(
    () => [Feature]Cubit(
      fetchDataUseCase: getIt<[FetchData]UseCase>(),
      createItemUseCase: getIt<[CreateItem]UseCase>(),
      updateItemUseCase: getIt<[UpdateItem]UseCase>(),
      deleteItemUseCase: getIt<[DeleteItem]UseCase>(),
    ),
  );

  // ==================== DOMAIN LAYER ====================

  /// Register Use Cases as Lazy Singletons
  ///
  /// Use cases are stateless and can be safely shared across the app
  /// Lazy singleton ensures they're created only when needed
  getIt.registerLazySingleton<[FetchData]UseCase>(
    () => [FetchData]UseCase(
      getIt<[Feature]Repository>(),
    ),
  );

  getIt.registerLazySingleton<[CreateItem]UseCase>(
    () => [CreateItem]UseCase(
      getIt<[Feature]Repository>(),
    ),
  );

  getIt.registerLazySingleton<[UpdateItem]UseCase>(
    () => [UpdateItem]UseCase(
      getIt<[Feature]Repository>(),
    ),
  );

  getIt.registerLazySingleton<[DeleteItem]UseCase>(
    () => [DeleteItem]UseCase(
      getIt<[Feature]Repository>(),
    ),
  );

  /// Register Repository as Lazy Singleton
  ///
  /// Repository coordinates data access and can maintain internal state
  /// Single instance ensures consistent caching and data management
  getIt.registerLazySingleton<[Feature]Repository>(
    () => [Feature]RepositoryImpl(
      remoteDataSource: getIt<[Feature]RemoteDataSource>(),
      localDataSource: getIt<[Feature]LocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(), // Assumed to be registered globally
    ),
  );

  // ==================== DATA LAYER ====================

  /// Register Remote Data Source as Lazy Singleton
  ///
  /// Remote data source handles API communication
  /// Single instance allows for connection pooling and request optimization
  getIt.registerLazySingleton<[Feature]RemoteDataSource>(
    () => [Feature]RemoteDataSourceImpl(
      apiProvider: getIt<ApiProvider>(), // Assumed to be registered globally
      baseUrl: getIt<AppConfig>().apiBaseUrl, // Assumed global config
    ),
  );

  /// Register Local Data Source as Lazy Singleton
  ///
  /// Local data source manages caching and offline storage
  /// Single instance ensures data consistency and proper cache management
  getIt.registerLazySingleton<[Feature]LocalDataSource>(
    () => [Feature]LocalDataSourceImpl(
      cacheManager: getIt<CacheManager>(), // Assumed to be registered globally
      databaseHelper: getIt<DatabaseHelper>(), // Assumed to be registered globally
    ),
  );
```