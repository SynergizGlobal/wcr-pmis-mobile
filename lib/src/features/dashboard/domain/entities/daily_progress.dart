class DailyProgressStructureRow {
  const DailyProgressStructureRow({
    required this.structure,
    required this.unit,
    required this.scope,
    required this.plannedTillDate,
    required this.actualTillDate,
    required this.askingRatePerDay,
    required this.actualForDay,
    required this.cumulativeActual,
    required this.mpDeployment,
    required this.manpowerDeployment,
    required this.tdc,
  });

  final String structure;
  final String unit;
  final double scope;
  final double plannedTillDate;
  final double actualTillDate;
  final double? askingRatePerDay;
  final double actualForDay;
  final double cumulativeActual;
  final String mpDeployment;
  final String manpowerDeployment;
  final String tdc;
}

class DailyProgressGroup {
  const DailyProgressGroup({
    required this.section,
    required this.activity,
    required this.unit,
    required this.structureCount,
    required this.scope,
    required this.completedQty,
    required this.balance,
    required this.progressOnDate,
    required this.tdc,
    required this.structures,
  });

  final String section;
  final String activity;
  final String unit;
  final int structureCount;
  final double scope;
  final double completedQty;
  final double balance;
  final double progressOnDate;
  final String tdc;
  final List<DailyProgressStructureRow> structures;

  String get groupKey => '$section|$activity';
}
