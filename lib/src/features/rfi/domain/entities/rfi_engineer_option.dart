/// Parsed entry from `/api/auth/engineer-names` CSV rows.
///
/// Format: `userId,name,department,email` (email optional for older responses).
class RfiEngineerOption {
  const RfiEngineerOption({
    required this.userId,
    required this.name,
    required this.department,
    required this.email,
    required this.raw,
  });

  final String userId;
  final String name;
  final String department;
  final String email;
  final String raw;

  @override
  bool operator ==(Object other) {
    return other is RfiEngineerOption && other.raw == raw;
  }

  @override
  int get hashCode => raw.hashCode;

  static RfiEngineerOption parse(String raw) {
    final String trimmed = raw.trim();
    final List<String> parts =
        trimmed.split(',').map((String p) => p.trim()).toList();
    if (parts.length >= 4) {
      return RfiEngineerOption(
        userId: parts[0],
        name: parts[1],
        department: parts[2],
        email: parts[3],
        raw: trimmed,
      );
    }
    if (parts.length == 3) {
      return RfiEngineerOption(
        userId: parts[0],
        name: parts[1],
        department: parts[2],
        email: '',
        raw: trimmed,
      );
    }
    return RfiEngineerOption(
      userId: '',
      name: trimmed,
      department: '',
      email: '',
      raw: trimmed,
    );
  }

  static List<RfiEngineerOption> parseList(dynamic data) {
    if (data is! List) {
      return const <RfiEngineerOption>[];
    }
    return data
        .map((dynamic e) => parse(e.toString()))
        .where((RfiEngineerOption e) => e.name.isNotEmpty)
        .toList();
  }
}
