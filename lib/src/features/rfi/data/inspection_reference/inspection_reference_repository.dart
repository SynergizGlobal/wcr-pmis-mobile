import '../../domain/inspection_reference/enclosure_name.dart';
import '../../domain/inspection_reference/checklist_detail.dart';
import '../../domain/inspection_reference/reference_form_item.dart';
import 'inspection_reference_api.dart';

class InspectionReferenceRepository {
  final InspectionReferenceApi api;
  InspectionReferenceRepository(this.api);

  Future<List<EnclosureName>> getEnclosureNames() async {
    final data = await api.getEnclosureNames();
    return data.map((json) => EnclosureName.fromJson(json)).toList();
  }

  Future<List<EnclosureName>> getEnclosureList() async {
    final data = await api.getEnclosureList();
    return data.map((json) => EnclosureName.fromJson(json)).toList();
  }

  Future<List<EnclosureName>> getEnclosuresByAction() async {
    final data = await api.getEnclosuresByAction();
    return data.map((json) => EnclosureName.fromJson(json)).toList();
  }

  Future<List<ChecklistDetail>> getChecklistDetails(int id) async {
    final data = await api.getChecklistDetails(id);
    return data.map((json) => ChecklistDetail.fromJson(json)).toList();
  }

  Future<List<ReferenceFormItem>> getReferenceForm() async {
    final data = await api.getReferenceForm();
    return data.map((json) => ReferenceFormItem.fromJson(json)).toList();
  }

  Future<EnclosureName> submitEnclosure(String name, String action) async {
    final data = await api.submitEnclosure(name, action);
    return EnclosureName.fromJson(data);
  }

  Future<EnclosureName> updateEnclosure(
      int id, String name, String action) async {
    final data = await api.updateEnclosure(id, name, action);
    return EnclosureName.fromJson(data);
  }

  Future<void> deleteEnclosure(int id) async {
    await api.deleteEnclosure(id);
  }


  Future<void> submitChecklistDescription(
      int enclosureId, String description) async {
    await api.submitChecklistDescription(enclosureId, description);
  }

  Future<void> updateChecklistDescription(
      int checklistId, String description) async {
    await api.updateChecklistDescription(checklistId, description);
  }

  Future<void> deleteChecklistDescription(int checklistId) async {
    await api.deleteChecklistDescription(checklistId);
  }


  Future<void> submitReferenceForm(
      String activity, String rfiDescription, String enclosures) async {
    await api.submitReferenceForm(activity, rfiDescription, enclosures);
  }

  Future<void> updateReferenceForm(
      int id, String activity, String rfiDescription, String enclosures) async {
    await api.updateReferenceForm(id, activity, rfiDescription, enclosures);
  }
}
