/// POST body shape for RFI Log list and filter-list APIs (empty string = no filter).
Map<String, dynamic> rfiLogFilterRequestBody({
  String project = '',
  String contract = '',
  String structureType = '',
  String structure = '',
  String status = '',
  String searchText = '',
  String rfiId = '',
}) {
  return <String, dynamic>{
    'project': project.trim(),
    'contract': contract.trim(),
    'structureType': structureType.trim(),
    'structure': structure.trim(),
    'status': status.trim(),
    'searchText': searchText.trim(),
    'rfiId': rfiId.trim(),
  };
}
