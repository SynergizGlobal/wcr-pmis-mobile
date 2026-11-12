import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/quality_inspection_user_access.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/quality_inspections/add_quality_inspection_form_page.dart';

const String _loggedInUser = 'Nihal';
const String _savedInspector = 'Mr. Rakesh Kumar Yadav';

Map<String, dynamic> _list(List<Map<String, dynamic>> rows) =>
    <String, dynamic>{'data': rows};

/// Fake API: the project dropdown carries the logged-in user as the default
/// inspector (as the real API does), while the saved inspection carries the
/// original inspector in `inspected_by_name`.
class _FakeDataSource extends DashboardRemoteDataSource {
  _FakeDataSource(this.inspection) : super(Dio());

  final Map<String, dynamic> inspection;

  @override
  Future<Map<String, dynamic>> fetchQualityInspectionDropdownProjects() async =>
      _list(<Map<String, dynamic>>[
        <String, dynamic>{
          'project_id_fk': 'P1',
          'project_name': 'Panna - Kajuraho Section New B.G. Line Project',
          'inspected_by': _loggedInUser,
          'inspected_by_fk': 'U-NIHAL',
        },
      ]);

  @override
  Future<Map<String, dynamic>> fetchQualityInspectionDropdownSections() async =>
      _list(<Map<String, dynamic>>[
        <String, dynamic>{'section_id': 'S1', 'section_name': 'Balupur - Ajaygarh'},
      ]);

  @override
  Future<Map<String, dynamic>>
      fetchQualityInspectionDropdownInspectionTypes() async =>
          _list(<Map<String, dynamic>>[
            <String, dynamic>{'insp_type_id': 'T1', 'type': 'Routine'},
          ]);

  @override
  Future<Map<String, dynamic>> fetchQualityInspectionDropdownCategories() async =>
      _list(<Map<String, dynamic>>[
        <String, dynamic>{
          'insp_category_id': 'C1',
          'category': 'Work Execution Check',
        },
      ]);

  @override
  Future<Map<String, dynamic>> fetchQualityInspectionDropdownSubCategories({
    required String categoryIdFk,
  }) async =>
      _list(<Map<String, dynamic>>[
        <String, dynamic>{
          'insp_sub_category_id': 'SC1',
          'sub_category': 'Hardened Concrete',
        },
      ]);

  @override
  Future<Map<String, dynamic>> fetchQualityInspectionDropdownContracts({
    required String projectIdFk,
  }) async =>
      _list(<Map<String, dynamic>>[]);

  @override
  Future<Map<String, dynamic>> fetchQualityInspectionDropdownStructureTypes({
    required String projectIdFk,
  }) async =>
      _list(<Map<String, dynamic>>[]);

  @override
  Future<Map<String, dynamic>> fetchQualityInspectionDropdownStructures({
    required String projectIdFk,
    required String structureTypeFk,
  }) async =>
      _list(<Map<String, dynamic>>[]);

  @override
  Future<Map<String, dynamic>> fetchQualityInspectionDropdownItems({
    required String structureTypeFk,
  }) async =>
      _list(<Map<String, dynamic>>[]);

  @override
  Future<Map<String, dynamic>> fetchQualityInspectionTestParameters({
    required String itemIdFk,
    required String categoryIdFk,
    required String subCategoryIdFk,
  }) async =>
      _list(<Map<String, dynamic>>[]);

  @override
  Future<Map<String, dynamic>> fetchQualityInspectionView({
    required String inspectionId,
  }) async =>
      <String, dynamic>{'data': inspection};
}

Map<String, dynamic> _inspection({
  required String step,
  required String status,
  String lotNo = '14',
}) =>
    <String, dynamic>{
      'inspection_id': 'QI-1',
      'inspection_no': 'QI-0001',
      'inspection_step': step,
      'inspection_status': status,
      'project_id_fk': 'P1',
      'project_name': 'Panna - Kajuraho Section New B.G. Line Project',
      'section_id_fk': 'S1',
      'section_name': 'Balupur - Ajaygarh',
      'contract_id_fk': 'CT1',
      'contract_name': 'EW, MNB incl. Laying and linking',
      'structure_type_fk': 'RUB',
      'structure_id_fk': '106/3',
      'structure': '106/3 (RCC BOX)',
      'item_id_fk': 'I1',
      'item_name': 'RCC',
      'type_id_fk': 'T1',
      'inspection_type': 'Routine',
      'category_id_fk': 'C1',
      'category': 'Work Execution Check',
      'sub_category_id_fk': 'SC1',
      'sub_category': 'Hardened Concrete',
      'location': 'VRS LAB',
      'lot_no': lotNo,
      'inspected_by_fk': 'U-RAKESH',
      'inspected_by_name': _savedInspector,
      'is_correction_required': 'No',
      'ncrRows': <Map<String, dynamic>>[
        <String, dynamic>{
          'parameter_id': 'PR1',
          'test_description': 'Compressive strength',
          'acceptance_criteria': '>= 30',
          'unit_of_measure': 'MPa',
          'frequency': 'Per lot',
          'category_id_fk': 'C1',
          'category': 'Work Execution Check',
          'sub_category_id_fk': 'SC1',
          'sub_category': 'Hardened Concrete',
          'result': '32',
          'pass_fail': 'Pass',
          'is_ncr_required': 'No',
        },
      ],
    };

Future<void> _pumpForm(
  WidgetTester tester, {
  required Map<String, dynamic> inspection,
  required QualityInspectionUserGroup group,
  String? inspectionId = 'QI-1',
}) async {
  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        qualityInspectionAccessProvider.overrideWithValue(
          QualityInspectionUserAccess(group),
        ),
      ],
      child: MaterialApp(
        home: AddQualityInspectionFormPage(
          dataSource: _FakeDataSource(inspection),
          inspectionId: inspectionId,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

String _fieldText(WidgetTester tester, String label) {
  final Finder column = find.ancestor(
    of: find.text(label),
    matching: find.byType(Column),
  ).first;
  final Finder field = find.descendant(
    of: column,
    matching: find.byType(TextField),
  );
  return tester.widget<TextField>(field).controller!.text;
}

FilledButton _submitButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Submit'));

void main() {
  testWidgets(
    'passed QI shows the saved inspector, not the logged-in user',
    (WidgetTester tester) async {
      await _pumpForm(
        tester,
        inspection: _inspection(step: '5', status: 'Passed'),
        group: QualityInspectionUserGroup.inspector,
      );

      expect(find.text('Inspection Created By'), findsOneWidget);
      expect(find.text('Inspection By'), findsNothing);
      expect(_fieldText(tester, 'Inspection Created By'), _savedInspector);
      expect(find.text(_loggedInUser), findsNothing);
    },
  );

  testWidgets('Lot/Batch No. is labelled required', (WidgetTester tester) async {
    await _pumpForm(
      tester,
      inspection: _inspection(step: '5', status: 'Passed'),
      group: QualityInspectionUserGroup.inspector,
    );

    expect(find.text('Lot/Batch No. *'), findsOneWidget);
    expect(_fieldText(tester, 'Lot/Batch No. *'), '14');
  });

  testWidgets(
    'draft QI: Submit is disabled until Lot/Batch No. is entered',
    (WidgetTester tester) async {
      await _pumpForm(
        tester,
        inspection: _inspection(step: '1', status: 'Draft', lotNo: ''),
        group: QualityInspectionUserGroup.inspector,
      );

      // Everything else is complete; only Lot/Batch No. is empty.
      expect(_submitButton(tester).onPressed, isNull);

      final Finder lotField = find.descendant(
        of: find.ancestor(
          of: find.text('Lot/Batch No. *'),
          matching: find.byType(Column),
        ).first,
        matching: find.byType(TextField),
      );
      await tester.enterText(lotField, '14');
      await tester.pumpAndSettle();

      expect(_submitButton(tester).onPressed, isNotNull);
    },
  );

  testWidgets(
    'reopened draft keeps the saved "Is Correction Required?" answer',
    (WidgetTester tester) async {
      await _pumpForm(
        tester,
        inspection: _inspection(step: '1', status: 'Draft'),
        group: QualityInspectionUserGroup.inspector,
      );

      final SegmentedButton<bool> toggle = tester.widget<SegmentedButton<bool>>(
        find.byType(SegmentedButton<bool>),
      );
      expect(toggle.selected, <bool>{false});
      expect(_submitButton(tester).onPressed, isNotNull);
    },
  );
}
