/// Central input validation rules for forms across the app.
class AppValidators {
  AppValidators._();

  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _pakistaniMobilePattern = RegExp(
    r'^(?:\+?92|0)?3[0-9]{9}$',
  );

  /// Mandatory non-empty text field.
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Login / registration email format.
  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Email is required';
    }
    if (!_emailPattern.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Pakistani mobile: 03XX XXXXXXX, 923XX XXXXXXX, or +923XX XXXXXXX.
  static String? pakistaniPhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Mobile number is required';
    }
    final normalized = trimmed.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!_pakistaniMobilePattern.hasMatch(normalized)) {
      return 'Enter a valid Pakistani mobile (e.g. 03XX XXXXXXX)';
    }
    return null;
  }

  /// Validates email only when the user entered a value.
  static String? emailIfProvided(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return email(value);
  }

  /// Password for auth flows (Firebase minimum length).
  static String? password(String? value, {int minLength = 6}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Password is required';
    }
    if (trimmed.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Person's full name on profile / registration forms.
  static String? fullName(String? value) {
    final error = required(value, fieldName: 'Full name');
    if (error != null) {
      return error;
    }
    if (value!.trim().length < 2) {
      return 'Enter a valid full name';
    }
    return null;
  }

  /// Project / proposal / document titles.
  static String? projectTitle(String? value) {
    return required(value, fieldName: 'Project title');
  }

  /// Multi-line descriptions and summaries.
  static String? description(String? value, {String fieldName = 'Description'}) {
    return required(value, fieldName: fieldName);
  }
}
