class AuthFieldValidator {
  static const int MIN_PASSWORD_LENGTH = 6;

  static bool hasEmptyField(List<String> fields) {
    return fields.any((String fieldText) => fieldText.isEmpty);
  }

  static bool passwordMismatch(String password1, String password2) {
    return password1 != password2;
  }

  static bool passwordTooShort(String password) {
    return password.length < MIN_PASSWORD_LENGTH;
  }
}