# Qawam - Secure Expense Tracker

Qawam is a modern, privacy-focused expense tracking mobile application built with Flutter. It follows Clean Architecture principles and provides end-to-end encryption for sensitive financial data.

## 🌟 Key Features

- **End-to-End Encryption**: Expense amounts are encrypted locally using AES-256 before being stored or synced. Only your device holds the keys.
- **Bi-directional Cloud Sync**: Seamless synchronization with Firebase Firestore ensures your data is available across devices, respecting your privacy settings.
- **Offline First**: Full functionality without an internet connection, using Hive for high-performance local storage.
- **Smart Statistics**: Visual insights into your spending habits with interactive charts and metrics.
- **Category Management**: Organize your expenses with customizable categories and vibrant icons.
- **Internationalization**: Full support for multiple languages, including Arabic and English.

## 🏗️ Architecture

The project is built using **Clean Architecture** to ensure scalability, testability, and maintainability:

- **Domain Layer**: Contains Entities, Use Cases, and Repository Interfaces (Pure Dart).
- **Data Layer**: Implements Repositories and Data Sources (Hive, Firestore, Shared Preferences).
- **Presentation Layer**: Handles UI and State Management using **Bloc/Cubit**.

## 🛠️ Technology Stack

- **Framework**: Flutter
- **State Management**: flutter_bloc
- **Local Database**: Hive (NoSQL)
- **Cloud Database**: Firebase Firestore
- **Authentication**: Firebase Auth (Google Sign-In)
- **Security**: AES-256 Encryption (encrypt package), Secure Key Storage (flutter_secure_storage)
- **Dependency Injection**: GetIt
- **UI/Charts**: fl_chart

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.11.0)
- Firebase Account and Project

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/YOUR_USERNAME/qawam.git
    cd qawam
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure Firebase:**
    - Place your `google-services.json` in `android/app/`.
    - Place your `GoogleService-Info.plist` in `ios/Runner/`.

4.  **Run the app:**
    ```bash
    flutter run
    ```

## 🔒 Security Architecture

Qawam prioritizes user privacy. When an expense is added:
1.  The amount is converted to a string.
2.  A random IV is generated.
3.  AES-256 encryption is applied using a device-unique key.
4.  The result is stored as `encryptedAmount` in both Hive and Firestore.
5.  Decryption happens only on the device before displaying to the user.

## 📄 License

This project is for private use only. See `publish_to: 'none'` in `pubspec.yaml`.
