import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_list_item.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/inspection/inspection_item.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/utils/rfi_user_role.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/widgets/assign_executive_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/widgets/delete_rfi_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/widgets/rfi_action_menu.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/widgets/upload_attachment_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/widgets/upload_test_results_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/utils/rfi_list_item_mapper.dart';

class RfiListActions {
  const RfiListActions._();

  static List<RfiActionItem> build({
    required BuildContext context,
    required RfiListItem item,
    required RfiUserRole role,
    required VoidCallback onRefresh,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String status = item.status;
    final bool canView = role.canViewRfi(status);
    final bool canEdit = role.canEditRfi(status);
    final bool canDelete = role.canDeleteRfi(status);
    final bool canStart = role.canStartInspection(status);
    final bool canClose = role.canRejectOrClose(status);
    final bool canSubmit = role.canSubmitInspection(status);
    final bool canUploadAttachments = role.canUploadAttachments(status);
    final bool canUploadTestResults = role.canUploadTestResults(status);
    final bool canChangeExecutive = role.canChangeExecutive(status);

    if (!canView &&
        !canEdit &&
        !canDelete &&
        !canStart &&
        !canClose &&
        !canSubmit &&
        !canUploadAttachments &&
        !canUploadTestResults &&
        !canChangeExecutive) {
      return const <RfiActionItem>[];
    }

    final List<RfiActionItem> actions = <RfiActionItem>[];

    if (canView) {
      actions.add(
        RfiActionItem(
          title: 'View Details',
          icon: Icons.remove_red_eye_outlined,
          color: RfiTheme.actionView(scheme),
          onTap: () => context.pushNamed(
            'rfi-detail',
            pathParameters: <String, String>{'id': item.rfiId.toString()},
          ),
        ),
      );
    }

    if (canEdit) {
      actions.add(
        RfiActionItem(
          title: 'Edit RFI',
          icon: Icons.edit_outlined,
          color: RfiTheme.actionEdit(scheme),
          onTap: () => context.pushNamed('rfi-update', extra: item),
        ),
      );
    }

    if (canUploadAttachments) {
      actions.add(
        RfiActionItem(
          title: 'Upload Attachments',
          icon: Icons.attach_file_rounded,
          color: RfiTheme.actionDefault(scheme),
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (_) => UploadAttachmentDialog(rfiId: item.rfiId),
            );
          },
        ),
      );
    }

    if (canUploadTestResults) {
      actions.add(
        RfiActionItem(
          title: 'Upload Test Results',
          icon: Icons.biotech_rounded,
          color: RfiTheme.actionDefault(scheme),
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (_) => UploadTestResultsDialog(rfiId: item.rfiId),
            );
          },
        ),
      );
    }

    if (canStart) {
      actions.add(
        RfiActionItem(
          title: 'Start Inspection Online',
          icon: Icons.online_prediction,
          color: RfiTheme.actionDefault(scheme),
          onTap: () => _startInspection(context, item, offline: false),
        ),
      );
      actions.add(
        RfiActionItem(
          title: 'Start Inspection Offline',
          icon: Icons.offline_pin_outlined,
          color: RfiTheme.actionDefault(scheme),
          onTap: () => _startInspection(context, item, offline: true),
        ),
      );
    }

    if (canSubmit) {
      actions.add(
        RfiActionItem(
          title: 'Submit',
          icon: Icons.check_circle_outline_rounded,
          color: RfiTheme.actionDefault(scheme),
          onTap: () => _startInspection(context, item, offline: false),
        ),
      );
    }

    if (canClose) {
      actions.add(
        RfiActionItem(
          title: 'Close RFI',
          icon: Icons.lock_outline_rounded,
          color: RfiTheme.actionClose(scheme),
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (BuildContext ctx) => DeleteRfiDialog(
                item: item,
                isClose: true,
                onSuccess: onRefresh,
              ),
            );
          },
        ),
      );
    }

    if (canDelete) {
      actions.add(
        RfiActionItem(
          title: 'Delete RFI',
          icon: Icons.delete_outline,
          color: RfiTheme.actionDelete(scheme),
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (BuildContext ctx) => DeleteRfiDialog(
                item: item,
                onSuccess: onRefresh,
              ),
            );
          },
        ),
      );
    }

    if (canChangeExecutive) {
      actions.add(
        RfiActionItem(
          title: 'Change Executive',
          icon: Icons.person_search_outlined,
          color: RfiTheme.actionDefault(scheme),
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (_) => AssignExecutiveDialog(
                item: toPortedRfiListItem(item),
              ),
            );
          },
        ),
      );
    }

    return actions;
  }

  static void _startInspection(
    BuildContext context,
    RfiListItem item, {
    required bool offline,
  }) {
    final InspectionItem inspectionItem = InspectionItem(
      id: item.rfiId,
      rfiId: item.rfiNo,
      project: item.project,
      work: item.work,
      contract: item.contract ?? '',
      structure: item.structure,
      element: item.element,
      activity: item.activity,
      status: item.status,
      dateOfSubmission: item.dateOfSubmission,
      assignedPersonClient: item.assignedPersonClient,
      nameOfRepresentative: item.nameOfRepresentative,
    );
    context.pushNamed(
      'rfi-inspection-start',
      extra: <String, dynamic>{
        'item': inspectionItem,
        'isOffline': offline,
      },
    );
  }

  static RfiUserRole roleFromSession(AuthSession? session) =>
      RfiUserRole.fromSession(session);
}
