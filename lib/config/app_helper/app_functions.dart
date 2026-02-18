
class AppFunctions {
  /// Extracts the first number found in the given [input] string.
  ///
  /// Returns an empty string if no number is found.
  ///
  /// Example:
  ///   extractNumber('abc123def456') // '123'
  static String extractNumber(String input) {
    RegExp regExp = RegExp(r'\d+');
    String? number = regExp.firstMatch(input)?.group(0);
    return number ?? ''; // Return an empty string if no number is found
  }
}

