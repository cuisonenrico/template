import 'package:flutter_test/flutter_test.dart';
import 'package:template/core/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('returns error for null value', () {
      final validator = Validators.required();
      expect(validator(null), isNotNull);
    });

    test('returns error for empty string', () {
      final validator = Validators.required();
      expect(validator(''), isNotNull);
    });

    test('returns error for whitespace only', () {
      final validator = Validators.required();
      expect(validator('   '), isNotNull);
    });

    test('returns null for valid input', () {
      final validator = Validators.required();
      expect(validator('hello'), isNull);
    });

    test('uses custom message', () {
      final validator = Validators.required('Field cannot be empty');
      expect(validator(''), 'Field cannot be empty');
    });
  });

  group('Validators.email', () {
    test('returns null for empty value (optional)', () {
      final validator = Validators.email();
      expect(validator(''), isNull);
    });

    test('returns error for invalid email', () {
      final validator = Validators.email();
      expect(validator('invalid'), isNotNull);
      expect(validator('invalid@'), isNotNull);
      expect(validator('@domain.com'), isNotNull);
    });

    test('returns null for valid email', () {
      final validator = Validators.email();
      expect(validator('test@example.com'), isNull);
      expect(validator('user.name+tag@domain.co.uk'), isNull);
    });
  });

  group('Validators.minLength', () {
    test('returns error when too short', () {
      final validator = Validators.minLength(5);
      expect(validator('abc'), isNotNull);
    });

    test('returns null when long enough', () {
      final validator = Validators.minLength(5);
      expect(validator('abcde'), isNull);
      expect(validator('abcdefgh'), isNull);
    });
  });

  group('Validators.maxLength', () {
    test('returns error when too long', () {
      final validator = Validators.maxLength(5);
      expect(validator('abcdef'), isNotNull);
    });

    test('returns null when short enough', () {
      final validator = Validators.maxLength(5);
      expect(validator('abcde'), isNull);
      expect(validator('abc'), isNull);
    });
  });

  group('Validators.password', () {
    test('returns error for short password', () {
      final validator = Validators.password();
      expect(validator('Ab1'), isNotNull);
    });

    test('returns error for missing uppercase', () {
      final validator = Validators.password();
      expect(validator('abcdefgh1'), isNotNull);
    });

    test('returns error for missing lowercase', () {
      final validator = Validators.password();
      expect(validator('ABCDEFGH1'), isNotNull);
    });

    test('returns error for missing number', () {
      final validator = Validators.password();
      expect(validator('Abcdefghi'), isNotNull);
    });

    test('returns null for valid password', () {
      final validator = Validators.password();
      expect(validator('Abcdefgh1'), isNull);
    });

    test('can require special character', () {
      final validator = Validators.password(requireSpecialChar: true);
      expect(validator('Abcdefgh1'), isNotNull);
      expect(validator('Abcdefgh1!'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('returns error when passwords do not match', () {
      final validator = Validators.confirmPassword(() => 'password123');
      expect(validator('different'), isNotNull);
    });

    test('returns null when passwords match', () {
      final validator = Validators.confirmPassword(() => 'password123');
      expect(validator('password123'), isNull);
    });
  });

  group('Validators.phone', () {
    test('returns error for invalid phone', () {
      final validator = Validators.phone();
      expect(validator('abc'), isNotNull);
      expect(validator('123'), isNotNull);
    });

    test('returns null for valid phone', () {
      final validator = Validators.phone();
      expect(validator('+1234567890'), isNull);
      expect(validator('123-456-7890'), isNull);
      expect(validator('(123) 456-7890'), isNull);
    });
  });

  group('Validators.url', () {
    test('returns error for invalid URL', () {
      final validator = Validators.url();
      expect(validator('not-a-url'), isNotNull);
      expect(validator('ftp://invalid'), isNotNull);
    });

    test('returns null for valid URL', () {
      final validator = Validators.url();
      expect(validator('http://example.com'), isNull);
      expect(validator('https://example.com/path?query=1'), isNull);
    });
  });

  group('Validators.numeric', () {
    test('returns error for non-numeric', () {
      final validator = Validators.numeric();
      expect(validator('abc'), isNotNull);
      expect(validator('12.34'), isNotNull); // numeric expects integers
    });

    test('returns null for valid integer', () {
      final validator = Validators.numeric();
      expect(validator('123'), isNull);
      expect(validator('-456'), isNull);
    });
  });

  group('Validators.decimal', () {
    test('returns error for non-numeric', () {
      final validator = Validators.decimal();
      expect(validator('abc'), isNotNull);
    });

    test('returns null for valid decimal', () {
      final validator = Validators.decimal();
      expect(validator('123'), isNull);
      expect(validator('12.34'), isNull);
      expect(validator('-45.67'), isNull);
    });
  });

  group('Validators.range', () {
    test('returns error for out of range', () {
      final validator = Validators.range(1, 10);
      expect(validator('0'), isNotNull);
      expect(validator('11'), isNotNull);
    });

    test('returns null for in range', () {
      final validator = Validators.range(1, 10);
      expect(validator('1'), isNull);
      expect(validator('5'), isNull);
      expect(validator('10'), isNull);
    });
  });

  group('Validators.creditCard', () {
    test('returns error for invalid card', () {
      final validator = Validators.creditCard();
      expect(validator('1234567890123456'), isNotNull);
    });

    test('returns null for valid card (Luhn check)', () {
      final validator = Validators.creditCard();
      // Test Visa card number that passes Luhn
      expect(validator('4111111111111111'), isNull);
    });
  });

  group('Validators.username', () {
    test('returns error for too short', () {
      final validator = Validators.username();
      expect(validator('ab'), isNotNull);
    });

    test('returns error for invalid characters', () {
      final validator = Validators.username();
      expect(validator('user@name'), isNotNull);
      expect(validator('user name'), isNotNull);
    });

    test('returns error for underscore at start/end', () {
      final validator = Validators.username();
      expect(validator('_username'), isNotNull);
      expect(validator('username_'), isNotNull);
    });

    test('returns null for valid username', () {
      final validator = Validators.username();
      expect(validator('valid_user'), isNull);
      expect(validator('user123'), isNull);
    });
  });

  group('Validators.compose', () {
    test('runs all validators and returns first error', () {
      final validator = Validators.compose([
        Validators.required('Required'),
        Validators.minLength(5, 'Too short'),
      ]);

      expect(validator(''), 'Required');
      expect(validator('abc'), 'Too short');
      expect(validator('abcde'), isNull);
    });
  });

  group('String validation extensions', () {
    test('isValidEmail works', () {
      expect('test@example.com'.isValidEmail, true);
      expect('invalid'.isValidEmail, false);
    });

    test('isBlank and isNotBlank work', () {
      expect(''.isBlank, true);
      expect('   '.isBlank, true);
      expect('hello'.isBlank, false);

      expect('hello'.isNotBlank, true);
      expect(''.isNotBlank, false);
    });
  });
}
