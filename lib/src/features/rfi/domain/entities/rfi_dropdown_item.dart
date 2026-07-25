class RfiDropdownItem {
  const RfiDropdownItem({
    required this.id,
    required this.name,
    this.enclosures = const <String>[],
    this.p6ActivityIdFk,
    this.pmisCalcFk,
    this.email,
    this.dyHodUserId,
    this.dyHodUserName,
    this.dyHodEmail,
    this.hodUserId,
    this.hodUserName,
    this.hodEmail,
    this.caoUserId,
    this.caoUserName,
    this.caoEmail,
  });

  final String id;
  final String name;
  final List<String> enclosures;
  final int? p6ActivityIdFk;
  final String? pmisCalcFk;

  /// From `/rfi/regularUsers` (and similar user lists).
  final String? email;

  /// From `/rfi/contractNames` contact fields.
  final String? dyHodUserId;
  final String? dyHodUserName;
  final String? dyHodEmail;
  final String? hodUserId;
  final String? hodUserName;
  final String? hodEmail;
  final String? caoUserId;
  final String? caoUserName;
  final String? caoEmail;
}
