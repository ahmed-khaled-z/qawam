class Validator {
  // Check if a string is empty
  static String? isNotEmpty(String? value, {String message = 'Field cannot be empty'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  // Validate email format
  static String? isValidEmail(String? value, {String message = 'Invalid email address'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    String pattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return message;
    }
    return null;
  }

  // Check if a string has a minimum length
  static String? hasMinLength(String? value, int minLength, {String message = ''}) {
    message = message.isEmpty ? 'Minimum length is $minLength characters' : message;
    if (value == null || value.length < minLength) {
      return message;
    }
    return null;
  }

  // Check if a string has a maximum length
  static String? hasMaxLength(String? value, int maxLength, {String message = ''}) {
    message = message.isEmpty ? 'Maximum length is $maxLength characters' : message;
    if (value != null && value.length > maxLength) {
      return message;
    }
    return null;
  }

  // Validate if the value is a valid number
  static String? isNumeric(String? value, {String message = 'Value must be a number'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    if (double.tryParse(value) == null) {
      return message;
    }
    return null;
  }

  // Validate phone number (basic validation)
  static String? isValidPhone(String? value, {String message = 'Invalid phone number'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number cannot be empty';
    }
    String pattern = r'^\+?[0-9]{7,15}$'; // Matches phone numbers with 7 to 15 digits, optional "+" at start
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return message;
    }
    return null;
  }

  // Validate password (minimum 8 characters, at least one letter and one number)
  static String? isValidPassword(String? value, {String message = 'Password must be at least 8 characters long, contain at least one letter and one number'}) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    String pattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return message;
    }
    return null;
  }

  // Check if two passwords match
  static String? doPasswordsMatch(String? password, String? confirmPassword, {String message = 'Passwords do not match'}) {
    if (password != confirmPassword) {
      return message;
    }
    return null;
  }
}

