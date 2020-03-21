import 'package:flutter_test/flutter_test.dart';
import 'package:instagrow/utils/auth_field_validator.dart';

void main() {
  test('hasEmptyField', () {
    List<String> emptyList = [],
        doesNotContainEmpty = ["email", "password"],
        containsEmpty = ["email", ""],
        containsEmpty2 = ["", "password"];

    expect(AuthFieldValidator.hasEmptyField(emptyList), false);
    expect(AuthFieldValidator.hasEmptyField(doesNotContainEmpty), false);
    expect(AuthFieldValidator.hasEmptyField(containsEmpty), true);
    expect(AuthFieldValidator.hasEmptyField(containsEmpty2), true);
  });

  test('passwordMismatch', () {
    String password = "password", incorrect = "not the same password", correct = "password";

    expect(AuthFieldValidator.passwordMismatch(password, incorrect), true);
    expect(AuthFieldValidator.passwordMismatch(password, correct), false);
  });

  test('passwordTooShort', () {
    String longPassword = "password", shortPassword = "pass";

    expect(AuthFieldValidator.passwordTooShort(longPassword), false);
    expect(AuthFieldValidator.passwordTooShort(shortPassword), true);
  });
}
