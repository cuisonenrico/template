/// Form validation utilities for common input validation
///
/// Usage:
/// ```dart
/// TextFormField(
///   validator: Validators.compose([
///     Validators.required('Email is required'),
///     Validators.email(),
///   ]),
/// )
/// ```
class Validators {
  Validators._();

  /// Compose multiple validators into one
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  /// Required field validator
  static String? Function(String?) required([String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message ?? 'This field is required';
      }
      return null;
    };
  }

  /// Email validator
  static String? Function(String?) email([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
      );
      if (!emailRegex.hasMatch(value)) {
        return message ?? 'Please enter a valid email address';
      }
      return null;
    };
  }

  /// Minimum length validator
  static String? Function(String?) minLength(int length, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value.length < length) {
        return message ?? 'Must be at least $length characters';
      }
      return null;
    };
  }

  /// Maximum length validator
  static String? Function(String?) maxLength(int length, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value.length > length) {
        return message ?? 'Must be at most $length characters';
      }
      return null;
    };
  }

  /// Exact length validator
  static String? Function(String?) exactLength(int length, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value.length != length) {
        return message ?? 'Must be exactly $length characters';
      }
      return null;
    };
  }

  /// Password strength validator
  /// Requires at least: 8 chars, 1 uppercase, 1 lowercase, 1 number
  static String? Function(String?) password({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumber = true,
    bool requireSpecialChar = false,
    String? message,
  }) {
    return (value) {
      if (value == null || value.isEmpty) return null;

      final errors = <String>[];

      if (value.length < minLength) {
        errors.add('at least $minLength characters');
      }
      if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
        errors.add('one uppercase letter');
      }
      if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
        errors.add('one lowercase letter');
      }
      if (requireNumber && !value.contains(RegExp(r'[0-9]'))) {
        errors.add('one number');
      }
      if (requireSpecialChar &&
          !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        errors.add('one special character');
      }

      if (errors.isNotEmpty) {
        return message ?? 'Password must contain ${errors.join(', ')}';
      }
      return null;
    };
  }

  /// Password confirmation validator
  static String? Function(String?) confirmPassword(
    String Function() getPassword, [
    String? message,
  ]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value != getPassword()) {
        return message ?? 'Passwords do not match';
      }
      return null;
    };
  }

  /// Phone number validator (international format)
  static String? Function(String?) phone([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      // Matches international phone formats: +1234567890, (123) 456-7890, etc.
      final phoneRegex = RegExp(
        r'^[\+]?[(]?[0-9]{1,4}[)]?[-\s\.]?[(]?[0-9]{1,3}[)]?[-\s\.]?[0-9]{3,4}[-\s\.]?[0-9]{3,6}$',
      );
      if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
        return message ?? 'Please enter a valid phone number';
      }
      return null;
    };
  }

  /// URL validator
  static String? Function(String?) url([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
      );
      if (!urlRegex.hasMatch(value)) {
        return message ?? 'Please enter a valid URL';
      }
      return null;
    };
  }

  /// Numeric validator (integers only)
  static String? Function(String?) numeric([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (int.tryParse(value) == null) {
        return message ?? 'Please enter a valid number';
      }
      return null;
    };
  }

  /// Decimal validator
  static String? Function(String?) decimal([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (double.tryParse(value) == null) {
        return message ?? 'Please enter a valid number';
      }
      return null;
    };
  }

  /// Range validator for numeric values
  static String? Function(String?) range(num min, num max, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final number = num.tryParse(value);
      if (number == null) {
        return 'Please enter a valid number';
      }
      if (number < min || number > max) {
        return message ?? 'Value must be between $min and $max';
      }
      return null;
    };
  }

  /// Regex pattern validator
  static String? Function(String?) pattern(RegExp regex, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (!regex.hasMatch(value)) {
        return message ?? 'Invalid format';
      }
      return null;
    };
  }

  /// Credit card number validator (Luhn algorithm)
  static String? Function(String?) creditCard([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final sanitized = value.replaceAll(RegExp(r'[\s-]'), '');

      if (!RegExp(r'^[0-9]{13,19}$').hasMatch(sanitized)) {
        return message ?? 'Please enter a valid card number';
      }

      // Luhn algorithm
      int sum = 0;
      bool alternate = false;
      for (int i = sanitized.length - 1; i >= 0; i--) {
        int n = int.parse(sanitized[i]);
        if (alternate) {
          n *= 2;
          if (n > 9) n -= 9;
        }
        sum += n;
        alternate = !alternate;
      }

      if (sum % 10 != 0) {
        return message ?? 'Please enter a valid card number';
      }
      return null;
    };
  }

  /// Date validator (format: YYYY-MM-DD, MM/DD/YYYY, DD/MM/YYYY)
  static String? Function(String?) date([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;

      // Try parsing common date formats
      final formats = [
        RegExp(r'^\d{4}-\d{2}-\d{2}$'), // YYYY-MM-DD
        RegExp(r'^\d{2}/\d{2}/\d{4}$'), // MM/DD/YYYY or DD/MM/YYYY
      ];

      bool matchesFormat = formats.any((regex) => regex.hasMatch(value));
      if (!matchesFormat) {
        return message ?? 'Please enter a valid date';
      }

      // Try to parse the date
      try {
        DateTime.parse(value.replaceAll('/', '-'));
      } catch (_) {
        return message ?? 'Please enter a valid date';
      }

      return null;
    };
  }

  /// Alphanumeric validator
  static String? Function(String?) alphanumeric([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
        return message ?? 'Only letters and numbers are allowed';
      }
      return null;
    };
  }

  /// Username validator (alphanumeric + underscore, 3-20 chars)
  static String? Function(String?) username({
    int minLength = 3,
    int maxLength = 20,
    String? message,
  }) {
    return (value) {
      if (value == null || value.isEmpty) return null;

      if (value.length < minLength || value.length > maxLength) {
        return message ?? 'Username must be $minLength-$maxLength characters';
      }

      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
        return message ??
            'Username can only contain letters, numbers, and underscores';
      }

      if (value.startsWith('_') || value.endsWith('_')) {
        return message ?? 'Username cannot start or end with underscore';
      }

      return null;
    };
  }

  /// Name validator (letters, spaces, hyphens, apostrophes)
  static String? Function(String?) name([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
        return message ?? 'Please enter a valid name';
      }
      return null;
    };
  }

  /// IP address validator (IPv4)
  static String? Function(String?) ipv4([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final regex = RegExp(
        r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
      );
      if (!regex.hasMatch(value)) {
        return message ?? 'Please enter a valid IP address';
      }
      return null;
    };
  }

  /// Custom validator
  static String? Function(String?) custom(
    bool Function(String value) isValid, [
    String? message,
  ]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (!isValid(value)) {
        return message ?? 'Invalid value';
      }
      return null;
    };
  }
}

/// Extension for String validation
extension StringValidation on String? {
  bool get isValidEmail => this != null && Validators.email()(this) == null;

  bool get isValidPhone => this != null && Validators.phone()(this) == null;

  bool get isValidUrl => this != null && Validators.url()(this) == null;

  bool get isNotBlank => this != null && this!.trim().isNotEmpty;

  bool get isBlank => this == null || this!.trim().isEmpty;
}
