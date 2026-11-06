import '../common/filter_option.dart';

class RfiLogFilterOptions {
  const RfiLogFilterOptions({
    this.projects = const <FilterOption>[],
    this.contracts = const <FilterOption>[],
    this.structureTypes = const <String>[],
    this.structures = const <String>[],
    this.statuses = const <String>[],
  });

  final List<FilterOption> projects;
  final List<FilterOption> contracts;
  final List<String> structureTypes;
  final List<String> structures;
  final List<String> statuses;

  static const RfiLogFilterOptions empty = RfiLogFilterOptions();
}
