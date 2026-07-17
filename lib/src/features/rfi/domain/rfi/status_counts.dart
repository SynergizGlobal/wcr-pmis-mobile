class StatusCounts {
  const StatusCounts({
    this.inspectedByCon = 0,
    this.pending = 0,
    this.approved = 0,
    this.rejected = 0,
    this.rescheduled = 0,
    this.closed = 0,
    this.conInspOngoing = 0,
  });

  final int inspectedByCon;
  final int pending;
  final int approved;
  final int rejected;
  final int rescheduled;
  final int closed;
  final int conInspOngoing;

  factory StatusCounts.fromJson(Map<String, dynamic> json) {
    int read(String key) {
      final dynamic value = json[key];
      if (value is num) {
        return value.toInt();
      }
      return 0;
    }

    // WCR API sends SUBMITTED; older responses used INSPECTED_BY_CON.
    final int inspectedByCon = json.containsKey('SUBMITTED')
        ? read('SUBMITTED')
        : read('INSPECTED_BY_CON');

    return StatusCounts(
      inspectedByCon: inspectedByCon,
      pending: read('PENDING'),
      approved: read('APPROVED'),
      rejected: read('REJECTED'),
      rescheduled: read('RESCHEDULED'),
      closed: read('CLOSED'),
      conInspOngoing: read('CON_INSP_ONGOING'),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'INSPECTED_BY_CON': inspectedByCon,
        'PENDING': pending,
        'APPROVED': approved,
        'REJECTED': rejected,
        'RESCHEDULED': rescheduled,
        'CLOSED': closed,
        'CON_INSP_ONGOING': conInspOngoing,
      };
}
