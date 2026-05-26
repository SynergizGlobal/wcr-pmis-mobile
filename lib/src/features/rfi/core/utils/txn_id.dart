import 'dart:math';

String generateUniqueTxnId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final randomSuffix =
      Random().nextInt(1000).toString().padLeft(3, '0');
  return '$timestamp$randomSuffix';
}
