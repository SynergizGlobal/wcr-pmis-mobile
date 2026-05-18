class RfiDropdownItem {
  const RfiDropdownItem({
    required this.id,
    required this.name,
    this.enclosures = const <String>[],
    this.p6ActivityIdFk,
    this.pmisCalcFk,
  });

  final String id;
  final String name;
  final List<String> enclosures;
  final int? p6ActivityIdFk;
  final String? pmisCalcFk;
}
