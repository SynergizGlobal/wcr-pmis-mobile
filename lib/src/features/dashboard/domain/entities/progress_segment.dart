class ProgressSegment {
  const ProgressSegment({
    required this.project,
    required this.projectFromKm,
    required this.projectToKm,
    required this.contractName,
    required this.contractShortName,
    required this.contractor,
    required this.subStructure,
    required this.fromKm,
    required this.toKm,
    required this.status,
    required this.progress,
    required this.structureType,
    required this.projectSection,
    required this.barColor,
  });

  final String project;
  final double projectFromKm;
  final double projectToKm;
  final String contractName;
  final String contractShortName;
  final String contractor;
  final String subStructure;
  final double fromKm;
  final double toKm;
  final String status;
  final double progress;
  final String structureType;
  final String? projectSection;
  final String barColor;

  double get spanKm => (toKm - fromKm).abs();

  bool get isPointSegment => spanKm < 0.08;

  String get chainageLabel =>
      '${_formatKm(fromKm)} to ${_formatKm(toKm)}';

  String get progressLabel => '${progress.toStringAsFixed(2)}%';

  factory ProgressSegment.fromMap(Map<String, dynamic> map) {
    return ProgressSegment(
      project: _string(map['project']),
      projectFromKm: _toDouble(map['projectFromKm']),
      projectToKm: _toDouble(map['projectToKm']),
      contractName: _string(map['contract_name']),
      contractShortName: _string(map['contractShortName']),
      contractor: _display(map['contractor']),
      subStructure: _display(map['subStructure']),
      fromKm: _toDouble(map['fromKm']),
      toKm: _toDouble(map['toKm']),
      status: _string(map['status'], fallback: 'NOT STARTED'),
      progress: _toDouble(map['progress']),
      structureType: _string(map['structureType'], fallback: '—'),
      projectSection: _nullableString(map['projectSection']),
      barColor: _string(map['barColor']),
    );
  }

  static String _string(dynamic value, {String fallback = ''}) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String? _nullableString(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static String _display(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? '—' : text;
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString().replaceAll(',', '')) ?? 0;
  }

  static String _formatKm(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(3);
  }
}
