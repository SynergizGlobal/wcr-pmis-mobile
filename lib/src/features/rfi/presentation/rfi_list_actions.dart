import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_list_item.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/utils/rfi_user_role.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/pages/rfi_detail_page.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/widgets/delete_rfi_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/widgets/rfi_action_menu.dart';

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
          onTap: () {
            context.pushNamed(
              RfiDetailPage.routeName,
              pathParameters: <String, String>{'id': item.rfiId.toString()},
            );
          },
        ),
      );
    }

    if (canEdit) {
      actions.add(
        RfiActionItem(
          title: 'Edit RFI',
          icon: Icons.edit_outlined,
          color: RfiTheme.actionEdit(scheme),
          onTap: () => _comingSoon(context, 'Edit RFI'),
        ),
      );
    }

    if (canUploadAttachments) {
      actions.add(
        RfiActionItem(
          title: 'Upload Attachments',
          icon: Icons.attach_file_rounded,
          color: RfiTheme.actionDefault(scheme),
          onTap: () => _comingSoon(context, 'Upload Attachments'),
        ),
      );
    }

    if (canUploadTestResults) {
      actions.add(
        RfiActionItem(
          title: 'Upload Test Results',
          icon: Icons.biotech_rounded,
          color: RfiTheme.actionDefault(scheme),
          onTap: () => _comingSoon(context, 'Upload Test Results'),
        ),
      );
    }

    if (canStart) {
      actions.add(
        RfiActionItem(
          title: 'Start Inspection Online',
          icon: Icons.online_prediction,
          color: RfiTheme.actionDefault(scheme),
          onTap: () => _comingSoon(context, 'Start Inspection Online'),
        ),
      );
      actions.add(
        RfiActionItem(
          title: 'Start Inspection Offline',
          icon: Icons.offline_pin_outlined,
          color: RfiTheme.actionDefault(scheme),
          onTap: () => _comingSoon(context, 'Start Inspection Offline'),
        ),
      );
    }

    if (canSubmit) {
      actions.add(
        RfiActionItem(
          title: 'Submit',
          icon: Icons.check_circle_outline_rounded,
          color: RfiTheme.actionDefault(scheme),
          onTap: () => _comingSoon(context, 'Submit Inspection'),
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
          onTap: () => _comingSoon(context, 'Change Executive'),
        ),
      );
    }

    return actions;
  }

  static RfiUserRole roleFromSession(AuthSession? session) =>
      RfiUserRole.fromSession(session);

  static Future<void> _comingSoon(BuildContext context, String action) {
    return AppDialog.show(
      context: context,
      title: action,
      message: '$action will be available in a future update.',
      type: AppDialogType.info,
    );
  }
}
