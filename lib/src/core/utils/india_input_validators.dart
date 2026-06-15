class IndiaInputValidators {
  const IndiaInputValidators._();

  static final RegExp _panPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
  static final RegExp _gstPattern = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
  );
  static final RegExp _tenDigitPhonePattern = RegExp(r'^[0-9]{10}$');
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? validatePan(String? value, {bool required = false}) {
    final String text = value?.trim().toUpperCase() ?? '';
    if (text.isEmpty) {
      return required ? 'PAN number is required.' : null;
    }
    if (text.length != 10) {
      return 'PAN must be 10 characters (e.g. ABCDE1234F).';
    }
    if (!_panPattern.hasMatch(text)) {
      return 'Enter a valid PAN (5 letters, 4 digits, 1 letter).';
    }
    return null;
  }

  static String? validateGst(String? value) {
    final String text = value?.trim().toUpperCase() ?? '';
    if (text.isEmpty) {
      return null;
    }
    if (text.length != 15) {
      return 'GST number must be 15 characters.';
    }
    if (!_gstPattern.hasMatch(text)) {
      return 'Enter a valid GSTIN (e.g. 22ABCDE1234F1Z5).';
    }
    return null;
  }

  static String? validateTenDigitPhone(String? value, {String label = 'Number'}) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    if (!_tenDigitPhonePattern.hasMatch(text)) {
      return '$label must be exactly 10 digits.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    if (!_emailPattern.hasMatch(text)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? validateShortCode(String? value, {int maxLength = 5}) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    if (text.length > maxLength) {
      return 'Contractor short code must be at most $maxLength characters.';
    }
    return null;
  }
}
