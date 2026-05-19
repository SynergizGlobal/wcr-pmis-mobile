import 'dart:math';

/// Matches web `generateUniqueTxnId`: epoch ms + 3-digit random suffix.
String generateUniqueTxnId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final randomSuffix =
      Random().nextInt(1000).toString().padLeft(3, '0');
  return '$timestamp$randomSuffix';
}
