import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/network/environment.dart';
import '../../core/utils/rfi_file_paths.dart';
import '../../core/utils/rfi_preview_fetch.dart';
import '../../core/widgets/rfi_remote_media_preview.dart';
import '../../core/providers/dio_provider.dart';
import '../../domain/inspection/inspection_item.dart';
import '../../core/utils/user_role.dart';
import '../../core/widgets/global_alert_dialog.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/inspection/inspection_form_provider.dart';
import '../../providers/inspection/inspection_form_state.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../domain/inspection/enclosure_checklist.dart';
import '../rfi_theme.dart';

class StartInspectionOnlineScreen extends ConsumerStatefulWidget {
  final InspectionItem item;
  final bool isOffline;
  const StartInspectionOnlineScreen({
    super.key,
    required this.item,
    this.isOffline = false,
  });

  @override
  ConsumerState<StartInspectionOnlineScreen> createState() =>
      _StartInspectionOnlineScreenState();
}

class _StartInspectionOnlineScreenState
    extends ConsumerState<StartInspectionOnlineScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static const double _footerBtnHeight = 46;
  static const double _footerBtnRadius = 14;

  bool _hasCapturedSelfie(InspectionFormState state) {
    final p = state.selfiePath;
    return p != null && p.trim().isNotEmpty;
  }

  void _goToInspectionStep1(InspectionFormNotifier notifier) {
    notifier.updateStep(1);
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scheduleSyncPageToStep(int step) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final index = (step - 1).clamp(0, 1);
      final current = _pageController.page?.round() ?? _pageController.initialPage;
      if (current != index) {
        _pageController.jumpToPage(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inspectionFormProvider(widget.item.id));
    final notifier = ref.read(inspectionFormProvider(widget.item.id).notifier);

    ref.listen<InspectionFormState>(
      inspectionFormProvider(widget.item.id),
      (InspectionFormState? previous, InspectionFormState next) {
        final stepChanged =
            previous == null || previous.currentStep != next.currentStep;
        final finishedInitialLoad =
            previous != null && previous.isLoading && !next.isLoading;
        if (stepChanged || finishedInitialLoad) {
          _scheduleSyncPageToStep(next.currentStep);
        }
      },
    );

    final bool isBusy = state.isSubmitting || state.isUploadingFile;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: state.currentStep == 1 && !isBusy,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        if (isBusy) return;
        if (state.currentStep == 2) {
          _goToInspectionStep1(notifier);
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                widget.isOffline ? 'RFI Inspection (Offline)' : 'RFI Inspection',
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: isBusy
                    ? null
                    : state.currentStep == 1
                        ? () {
                            if (context.canPop()) context.pop();
                          }
                        : () => _goToInspectionStep1(notifier),
              ),
            ),
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    _buildHeader(context, state.currentStep),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStep1(context, state, notifier),
                          _buildStep2(context, state, notifier),
                        ],
                      ),
                    ),
                    _buildStickyFooter(context, state, notifier),
                  ],
                ),
              ),
            ),
          ),
          if (isBusy)
            _buildBlockingLoader(
              context,
              scheme: scheme,
              message: state.isSubmitting
                  ? 'Submitting inspection…'
                  : 'Uploading document…',
            ),
        ],
      ),
    );
  }

  Widget _buildBlockingLoader(
    BuildContext context, {
    required ColorScheme scheme,
    required String message,
  }) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: scheme.scrim.withValues(alpha: 0.45),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: scheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
 

  Widget _buildHeader(BuildContext context, int step) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color activeColor = scheme.primary;
    final Color inactiveColor = scheme.outlineVariant;
    const labels = ['Inspection Setup', 'Inspection Details'];
    final currentStep = (step - 1).clamp(0, labels.length - 1);

    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isCompleted = currentStep > index;
          final isCurrent = currentStep == index;
          final nodeColor =
              (isCompleted || isCurrent) ? activeColor : inactiveColor;
          final textColor =
              isCurrent ? activeColor : scheme.onSurfaceVariant;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? activeColor : scheme.surface,
                          border: Border.all(
                            color: nodeColor,
                            width: isCurrent ? 2.5 : 2,
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: activeColor.withValues(alpha: 0.22),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: isCompleted
                            ? Icon(Icons.check_rounded,
                                size: 16, color: scheme.onPrimary)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isCurrent
                                      ? activeColor
                                      : scheme.outline,
                                ),
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (index < labels.length - 1)
                  Container(
                    width: 26,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color:
                          currentStep > index ? activeColor : inactiveColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1(
    BuildContext context,
    InspectionFormState state,
    InspectionFormNotifier notifier,
  ) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final rfi = state.rfiDetails ?? widget.item;
    final Color successColor = scheme.tertiary;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            color: scheme.primary.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: scheme.primary.withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Project Details',
                        style: RfiTheme.cardTitleStyle(textTheme, scheme)
                            ?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ID: ${rfi.rfiId ?? ""}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24, color: scheme.outlineVariant),
                  _buildDetailRow(context, 'Project', rfi.project ?? ''),
                  _buildDetailRow(
                    context,
                    'Contract',
                    rfi.contract ?? rfi.contractId ?? '',
                  ),
                  _buildDetailRow(context, 'Structure', rfi.structure ?? ''),
                  _buildDetailRow(context, 'Activity', rfi.activity ?? ''),
                  _buildDetailRow(
                    context,
                    'RFI Description',
                    rfi.rfiDescription ?? '',
                  ),
                  _buildDetailRow(
                    context,
                    'Description',
                    rfi.description ?? '',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chainage',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: state.chainage,
                          selection: TextSelection.collapsed(
                              offset: state.chainage.length),
                        ),
                      ),
                      onChanged: notifier.updateChainage,
                      decoration: RfiTheme.searchFieldDecoration(
                        context,
                        hintText: 'Enter chainage detail',
                      ).copyWith(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      'Selfie *',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _takeSelfie(notifier),
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _hasCapturedSelfie(state)
                                ? successColor
                                : scheme.outline,
                            width: 1,
                          ),
                          image: _hasCapturedSelfie(state)
                              ? DecorationImage(
                                  image: FileImage(File(state.selfiePath!.trim())),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: !_hasCapturedSelfie(state)
                            ? Icon(Icons.add_a_photo,
                                color: scheme.primary, size: 32)
                            : null,
                      ),
                    ),
                    if (_hasCapturedSelfie(state))
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle,
                                color: successColor, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Captured',
                              style: textTheme.labelSmall?.copyWith(
                                color: successColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const SizedBox(height: 92),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: RfiTheme.cardLabelStyle(textTheme, scheme)),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? 'N/A' : value,
            style: RfiTheme.cardValueStyle(textTheme, scheme),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(
    BuildContext context,
    InspectionFormState state,
    InspectionFormNotifier notifier,
  ) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStep2Inputs(context, state, notifier),
          const SizedBox(height: 24),
          _buildUploadSection(
            context,
            'Site Images Uploaded',
            state.siteImagePaths,
            () => _pickImage(notifier),
            notifier,
          ),
          const SizedBox(height: 24),
          _buildEnclosuresGridTable(context, state, notifier),
          const SizedBox(height: 24),
          _buildSupportingDocs(context, state, notifier),
          const SizedBox(height: 24),
          _buildMeasurementsTable(context, state, notifier),
          const SizedBox(height: 24),
          _buildConfirmSection(context, state, notifier),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(
    BuildContext context,
    InspectionFormState state,
    InspectionFormNotifier notifier,
  ) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: state.currentStep == 1
            ? SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _hasCapturedSelfie(state) &&
                          !state.isSubmitting &&
                          !state.isUploadingFile
                      ? () {
                          notifier.updateStep(2);
                          _pageController.animateToPage(1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        }
                      : null,
                  style: RfiTheme.primaryElevated(scheme).copyWith(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    elevation: const WidgetStatePropertyAll(0),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            : _buildActionButtons(context, state, notifier),
      ),
    );
  }

  Widget _buildStep2Inputs(
    BuildContext context,
    InspectionFormState state,
    InspectionFormNotifier notifier,
  ) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final dateStr = DateFormat('dd-MMM-yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    return Column(
      children: [
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Information',
                  style: RfiTheme.cardTitleStyle(textTheme, scheme),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Location *',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: state.isLocationLoading
                                  ? 'Fetching location...'
                                  : 'Location detail',
                              hintStyle: const TextStyle(fontSize: 13),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              prefixIcon: state.isLocationLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ))
                                  : Icon(Icons.location_on,
                                      color: state.locationPermissionDenied
                                          ? Colors.red
                                          : const Color(0xFF50589C)),
                            ),
                            controller:
                                TextEditingController(text: state.location),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => notifier.fetchLocation(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF50589C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Icon(Icons.refresh),
                      ),
                    ),
                  ],
                ),
                if (state.locationPermissionDenied)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Text(
                            'Location disabled. Please enable in settings.',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                        TextButton(
                          onPressed: () => notifier.openSettings(),
                          child: const Text('Settings',
                              style: TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildInput('Date:', dateStr, null, enabled: false)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildInput('Time:', timeStr, null, enabled: false)),
          ],
        ),
        _buildInput('Contractor\'s Representative',
            widget.item.nameOfRepresentative ?? '', null,
            enabled: false),
      ],
    );
  }

  Widget _buildInput(String label, String value, Function(String)? onChanged,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            enabled: enabled,
            onChanged: onChanged,
            controller:
                (onChanged == null) ? TextEditingController(text: value) : null,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: !enabled,
              fillColor: enabled ? Colors.white : Colors.grey.shade50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(
    BuildContext context,
    String title,
    List<String> localPaths,
    VoidCallback onUpload,
    InspectionFormNotifier notifier,
  ) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final state = ref.watch(inspectionFormProvider(widget.item.id));
    final details = state.rfiDetails?.inspectionDetails ?? [];

    final contractorImages = details
        .where((d) =>
            d.siteImage != null &&
            d.siteImage!.isNotEmpty &&
            d.uploadedBy?.toUpperCase() == 'CON')
        .expand((d) => d.siteImage!.split(','))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    final engineerImages = details
        .where((d) =>
            d.siteImage != null &&
            d.siteImage!.isNotEmpty &&
            (d.uploadedBy?.toUpperCase() == 'ENG' ||
                d.uploadedBy?.toUpperCase() == 'ENGG'))
        .expand((d) => d.siteImage!.split(','))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: RfiTheme.elevatedCardDecoration(scheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: RfiTheme.cardTitleStyle(textTheme, scheme)
                    ?.copyWith(fontSize: 15),
              ),
              ElevatedButton.icon(
                onPressed: state.isUploadingFile ? null : onUpload,
                icon: state.isUploadingFile
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onPrimary,
                        ))
                    : const Icon(Icons.add_a_photo, size: 18),
                label:
                    Text(state.isUploadingFile ? 'Uploading...' : 'Add Image'),
                style: RfiTheme.primaryElevated(scheme).copyWith(
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          if (localPaths.isNotEmpty) ...[
            const Text('New Images (To be submitted):',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange)),
            const SizedBox(height: 8),
            _buildImageGrid(localPaths, isLocal: true, notifier: notifier),
            const SizedBox(height: 16),
          ],
          if (contractorImages.isNotEmpty) ...[
            const Text('Contractor Site Images:',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            const SizedBox(height: 8),
            _buildRemoteImageGrid(contractorImages,
                uploadedBy: 'CON', notifier: notifier),
            const SizedBox(height: 16),
          ],
          if (engineerImages.isNotEmpty) ...[
            const Text('Engineer Site Images:',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            const SizedBox(height: 8),
            _buildRemoteImageGrid(engineerImages,
                uploadedBy: 'Engg', notifier: notifier),
            const SizedBox(height: 16),
          ],
          if (localPaths.isEmpty &&
              contractorImages.isEmpty &&
              engineerImages.isEmpty)
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                  child: Text('No images uploaded yet',
                      style: TextStyle(color: Colors.grey, fontSize: 13))),
            ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<String> paths,
      {required bool isLocal, required InspectionFormNotifier notifier}) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(File(paths[index])),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                if (isLocal)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => notifier.removeSiteImage(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(230),
                          shape: BoxShape.circle,
                        ),
                        height: 28,
                        width: 28,
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRemoteImageGrid(List<String> paths,
      {required String uploadedBy, required InspectionFormNotifier notifier}) {
    final userData = ref.watch(authNotifierProvider).value;
    final role = UserRole.fromLoginResponse(userData ?? {});

    bool canDelete = false;
    if (role == UserRole.engineer || role == UserRole.dyHodEngineer || role == UserRole.hod || role == UserRole.dyHod) {
      canDelete = true;
    } else if ((role == UserRole.contractor || role == UserRole.contractorRep) &&
        uploadedBy.toUpperCase() == 'CON') {
      canDelete = true;
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        itemBuilder: (context, index) {
          final imageUrl = _getPublicUrl(paths[index].trim());
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2))),
                    errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade100,
                        child:
                            const Icon(Icons.error_outline, color: Colors.red)),
                  ),
                ),
                if (canDelete)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Image'),
                            content: const Text(
                                'Are you sure you want to delete this site image?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (!context.mounted) return;
                                  Navigator.pop(context, true);
                                },
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await notifier.deleteRemoteSiteImage(
                              paths[index].trim(), uploadedBy);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(230),
                          shape: BoxShape.circle,
                        ),
                        height: 28,
                        width: 28,
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContractorSupportingDocsSection(
    BuildContext context,
    List<SupportingDocumentEntry> documents,
  ) {
    const accent = Color(0xFF50589C);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Supporting Documents (Uploaded by Contractor)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'View or download files submitted with the contractor inspection.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          if (documents.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'No supporting documents uploaded by contractor.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ] else ...[
            const SizedBox(height: 12),
            ...documents.map(
              (doc) => _ReadonlySupportingDocumentRow(
                key: ValueKey(doc.filePath),
                entry: doc,
                accentColor: accent,
                onView: () => _viewFile(doc.filePath),
                onDownload: () => _downloadFile(doc.filePath),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Widget _buildSupportingDocs(
    BuildContext context,
    InspectionFormState state,
    InspectionFormNotifier notifier,
  ) {
    final userData = ref.watch(authNotifierProvider).value;
    final role = UserRole.fromLoginResponse(userData ?? {});
    final isContractorRep = role == UserRole.contractorRep;
    final isClientSide = role == UserRole.engineer || role == UserRole.dyHodEngineer || role == UserRole.hod || role == UserRole.dyHod;


    final contractorSupportingDocs =
        extractContractorSupportingFromInspectionDetails(
      state.rfiDetails?.inspectionDetails,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isClientSide) ...[
          _buildContractorSupportingDocsSection(
            context,
            contractorSupportingDocs,
          ),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isClientSide
                        ? 'Your Supporting Documents'
                        : 'Supporting Documents',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF50589C),
                    ),
                  ),
                  if (isContractorRep || isClientSide)
                    ElevatedButton.icon(
                      onPressed: () => _pickFiles(notifier),
                      icon: const Icon(Icons.attach_file, size: 18),
                      label: const Text('Attach'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF50589C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
              if (state.supportingDocuments.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...state.supportingDocuments.asMap().entries.map((entry) {
                  final i = entry.key;
                  final doc = entry.value;
                  final path = doc.path;
                  return _SupportingDocumentFileRow(
                    key: ValueKey(path),
                    index: i,
                    doc: doc,
                    accentColor: const Color(0xFF50589C),
                    notifier: notifier,
                    onView: () => _viewFile(path),
                    onDownload: () => _downloadFile(path),
                    onDelete: () => notifier.removeSupportingDoc(i),
                  );
                }),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Description By Contractor',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          maxLines: 2,
          enabled: isContractorRep,
          onChanged: notifier.updateContractorDescription,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            hintText: 'Enter description...',
            hintStyle: const TextStyle(fontSize: 13),
            fillColor: isContractorRep ? Colors.white : Colors.grey.shade50,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          controller: TextEditingController.fromValue(
            TextEditingValue(
              text: state.contractorDescription,
              selection: TextSelection.collapsed(
                  offset: state.contractorDescription.length),
            ),
          ),
        ),
        if (isClientSide) ...[
          const SizedBox(height: 16),
          const Text('Description By Client',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            maxLines: 2,
            onChanged: notifier.updateClientDescription,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              hintText: 'Enter description...',
              hintStyle: const TextStyle(fontSize: 13),
              fillColor: Colors.white,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: state.clientDescription,
                selection: TextSelection.collapsed(
                    offset: state.clientDescription.length),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMeasurementsTable(
    BuildContext context,
    InspectionFormState state,
    InspectionFormNotifier notifier,
  ) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Measurements *',
            style: RfiTheme.cardTitleStyle(textTheme, scheme),
          ),
        ),
        const SizedBox(height: 12),
        ...state.measurements.asMap().entries.map((entry) {
          final idx = entry.key;
          final row = entry.value;

          final List<String> units;
          switch (row.type) {
            case 'Area':
              units = ['sqm', 'sqft', 'ha', 'acre', 'cm²', 'm²'];
              break;
            case 'Length':
              units = ['m', 'km', 'ft', 'in', 'mm', 'cm'];
              break;
            case 'Volume':
              units = ['cum', 'cuft', 'liters', 'ml', 'cm³', 'm³'];
              break;
            case 'Number':
              units = ['nos', 'units', 'sets', "No's"];
              break;
            case 'Weight':
              units = ['kg', 'MT', 'quintal(q)', 'g', 'Kg', 'Ton'];
              break;
            default:
              units = ['Select Units'];
          }

          final isL = ['Area', 'Length', 'Volume'].contains(row.type);
          final isB = ['Area', 'Volume'].contains(row.type);
          final isH = ['Volume'].contains(row.type);
          final isW = ['Weight'].contains(row.type);
          final isN = row.type != 'Select Type';

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTableDropdown(
                                'Type',
                                row.type,
                                [
                                  'Select',
                                  'Area',
                                  'Length',
                                  'Volume',
                                  'Number',
                                  'Weight'
                                ],
                                (val) => notifier.updateMeasurement(
                                    idx, row.copyWith(type: val))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTableDropdown(
                                'Units',
                                row.units,
                                units,
                                row.type == 'Select'
                                    ? null
                                    : (val) => notifier.updateMeasurement(
                                        idx, row.copyWith(units: val))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (isL)
                            SizedBox(
                              width: 80,
                              child: _buildTableInput(
                                  'L',
                                  row.l,
                                  (val) => notifier.updateMeasurement(
                                      idx, row.copyWith(l: val))),
                            ),
                          if (isB)
                            SizedBox(
                              width: 80,
                              child: _buildTableInput(
                                  'B',
                                  row.b,
                                  (val) => notifier.updateMeasurement(
                                      idx, row.copyWith(b: val))),
                            ),
                          if (isH)
                            SizedBox(
                              width: 80,
                              child: _buildTableInput(
                                  'H',
                                  row.h,
                                  (val) => notifier.updateMeasurement(
                                      idx, row.copyWith(h: val))),
                            ),
                          if (isW)
                            SizedBox(
                              width: 100,
                              child: _buildTableInput(
                                  'Weight',
                                  row.weight,
                                  (val) => notifier.updateMeasurement(
                                      idx, row.copyWith(weight: val))),
                            ),
                          if (isN)
                            SizedBox(
                              width: 80,
                              child: _buildTableInput(
                                  'No.',
                                  row.no,
                                  (val) => notifier.updateMeasurement(
                                      idx, row.copyWith(no: val))),
                            ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Quantity',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF50589C).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              row.totalQty.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF50589C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTableDropdown(String label, String value, List<String> items,
      Function(String)? onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        AppDropdown<String>(
          value: items.contains(value) ? value : items.first,
          items: items,
          itemLabel: (i) => i,
          onChanged:
              onChanged == null ? null : (v) => onChanged(v ?? items.first),
        ),
      ],
    );
  }

  Widget _buildTableInput(
      String label, String value, Function(String)? onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 44,
          child: TextField(
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: const Color(0xFF50589C), width: 1.5),
              ),
            ),
            keyboardType: TextInputType.number,
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: value.length),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmSection(
    BuildContext context,
    InspectionFormState state,
    InspectionFormNotifier notifier,
  ) {
    final userData = ref.watch(authNotifierProvider).value;
    final role = UserRole.fromLoginResponse(userData ?? {});
    final isContractor = role == UserRole.contractor || role == UserRole.contractorRep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text('Confirm Inspection *',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF50589C))),
        ),
        const SizedBox(height: 12),
        if (isContractor)
          _buildContractorConfirm(state, notifier)
        else
          _buildEngineerConfirm(state, notifier),
      ],
    );
  }

  Widget _buildContractorConfirm(
      InspectionFormState state, InspectionFormNotifier notifier) {
    final rfiStatus =
        (state.rfiDetails?.status ?? widget.item.status ?? '').toUpperCase();
    final showPriorFeedback = rfiStatus == 'UNDER_CON_RECTIFICATION';
    final priorDetail = showPriorFeedback
        ? _priorRectificationDetail(state, forContractorView: true)
        : null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (priorDetail != null) ...[
              _buildReadonlyRectificationPanel(
                priorDetail,
                remarksLabel: 'Remarks By Client',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
            ],
            const Text('Tests in Site/Lab *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            AppDropdown<String>(
              value: state.testInSiteLab,
              items: const ['Select', 'Visual', 'Lab test', 'Site test'],
              itemLabel: (i) => i,
              onChanged: (v) => notifier.updateTestInSiteLab(v ?? 'Select'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineerConfirm(
      InspectionFormState state, InspectionFormNotifier notifier) {
    final rfi = state.rfiDetails ?? widget.item;
    final status = rfi.status;
    final isCreated = status == 'CREATED';
    final s = (status ?? '').toUpperCase();
    final isInspected = s == 'INSPECTED_BY_CON' ||
        s == 'AE_INSP_ONGOING' ||
        s == 'INSPECTED_BY_AE' ||
        s == 'UNDER_ENGG_RECTIFICATION';

    String testResult = 'Not uploaded';
    if (isInspected && (rfi.inspectionDetails?.isNotEmpty ?? false)) {
      final detail = rfi.inspectionDetails!.first;
      testResult = (detail.testInsiteLab ?? detail.inspectionStatus ?? 'VISUAL')
          .toUpperCase();
    }

    final priorDetail = s == 'UNDER_ENGG_RECTIFICATION'
        ? _priorRectificationDetail(state, forContractorView: false)
        : null;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (priorDetail != null) ...[
              _buildReadonlyRectificationPanel(
                priorDetail,
                remarksLabel: 'Remarks',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
            ],
            Text(
              isCreated
                  ? 'Tests in Site/Lab - not uploaded'
                  : 'Tests in Site/Lab',
              style: isCreated
                  ? const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.red)
                  : const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            if (isInspected) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF67B056),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  testResult,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(height: 1),
            ),

            const Text('Inspection Status *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            AppDropdown<String>(
              value: state.inspectionStatus,
              items: const [
                'Select',
                'Accepted',
                'Rejected',
                'Rectification',
              ],
              itemLabel: (i) => i,
              onChanged: (v) => notifier.updateInspectionStatus(v ?? 'Select'),
            ),
            if (state.inspectionStatus == 'Rejected') ...[
              const SizedBox(height: 16),
              const Text('Remarks *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                maxLines: 2,
                onChanged: notifier.updateEngineerRemarks,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red.shade300)),
                  hintText: 'Enter rejection remarks (required)...',
                  hintStyle: const TextStyle(fontSize: 13),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: state.engineerRemarks,
                    selection: TextSelection.collapsed(
                        offset: state.engineerRemarks.length),
                  ),
                ),
              ),
            ],
            if (state.inspectionStatus == 'Rectification') ...[
              const SizedBox(height: 16),
              const Text('Remarks *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                maxLines: 2,
                onChanged: notifier.updateEngineerRemarks,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.amber.shade700)),
                  hintText: 'Enter remarks (required)...',
                  hintStyle: const TextStyle(fontSize: 13),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: state.engineerRemarks,
                    selection: TextSelection.collapsed(
                        offset: state.engineerRemarks.length),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  InspectionDetail? _priorRectificationDetail(
    InspectionFormState state, {
    required bool forContractorView,
  }) {
    final details = state.rfiDetails?.inspectionDetails;
    if (details == null || details.isEmpty) return null;

    final bool Function(String?) matcher =
        forContractorView ? _isClientSideUploader : _isDyHodUploader;

    for (final detail in details) {
      if (!matcher(detail.uploadedBy)) continue;
      if (_hasRectificationFeedback(detail)) return detail;
    }
    for (final detail in details) {
      if (!matcher(detail.uploadedBy)) continue;
      if (detail.engineerRemarks?.trim().isNotEmpty == true) return detail;
    }
    return null;
  }

  bool _hasRectificationFeedback(InspectionDetail detail) {
    final status = (detail.inspectionStatus ?? '').toUpperCase();
    return status.contains('RECTIFICATION') ||
        status == 'REJECTED' ||
        status == 'RETURNED_FOR_RECTIFICATION' ||
        detail.engineerRemarks?.trim().isNotEmpty == true;
  }

  bool _isClientSideUploader(String? uploadedBy) {
    final u = uploadedBy?.trim().toUpperCase() ?? '';
    if (u.isEmpty) return false;
    return u == 'ENG' ||
        u == 'ENGG' ||
        u == 'AE' ||
        u.startsWith('ENG');
  }

  bool _isDyHodUploader(String? uploadedBy) {
    final u = uploadedBy?.trim().toUpperCase() ?? '';
    if (u.isEmpty) return false;
    if (_isClientSideUploader(uploadedBy) || u == 'CON') return false;
    return u.contains('DY') ||
        u == 'HOD' ||
        u.contains('DATA') ||
        u.contains('ADMIN');
  }

  bool _looksLikeInspectionStatusValue(String? raw) {
    if (raw == null || raw.trim().isEmpty) return false;
    final u = raw.trim().toUpperCase();
    return u.contains('RECTIFICATION') ||
        u == 'REJECTED' ||
        u == 'ACCEPTED' ||
        u == 'RETURNED_FOR_RECTIFICATION';
  }

  bool _looksLikeTestInSiteLabValue(String? raw) {
    if (raw == null || raw.trim().isEmpty) return false;
    final u = raw.trim().toUpperCase();
    return u == 'VISUAL' ||
        u == 'LAB_TEST' ||
        u == 'SITE_TEST' ||
        u == 'LAB TEST' ||
        u == 'SITE TEST';
  }

  String _formatTestInSiteLabLabel(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '—';
    if (_looksLikeInspectionStatusValue(raw)) return '—';
    switch (raw.trim().toUpperCase()) {
      case 'VISUAL':
        return 'Visual';
      case 'LAB_TEST':
        return 'Lab test';
      case 'SITE_TEST':
        return 'Site test';
      default:
        return raw.replaceAll('_', ' ');
    }
  }

  String _formatInspectionStatusLabel(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '—';
    switch (raw.trim().toUpperCase()) {
      case 'RETURNED_FOR_RECTIFICATION':
      case 'RECTIFICATION':
        return 'Return For Rectification';
      case 'REJECTED':
        return 'Rejected';
      case 'ACCEPTED':
        return 'Accepted';
      default:
        if (_looksLikeTestInSiteLabValue(raw)) return '—';
        return raw.replaceAll('_', ' ');
    }
  }

  ({String testLabel, String statusLabel}) _resolvePriorConfirmLabels(
    InspectionDetail detail,
  ) {
    var testRaw = detail.testInsiteLab;
    var statusRaw = detail.inspectionStatus;

    if (_looksLikeInspectionStatusValue(testRaw) &&
        (statusRaw == null || statusRaw.trim().isEmpty)) {
      statusRaw = testRaw;
      testRaw = null;
    }

    if (_looksLikeTestInSiteLabValue(statusRaw) &&
        (testRaw == null || testRaw.trim().isEmpty)) {
      testRaw = statusRaw;
      statusRaw = null;
    }

    if (testRaw == null || testRaw.trim().isEmpty) {
      final fallback = detail.postTestType;
      if (_looksLikeTestInSiteLabValue(fallback)) {
        testRaw = fallback;
      }
    }

    return (
      testLabel: _formatTestInSiteLabLabel(testRaw),
      statusLabel: _formatInspectionStatusLabel(statusRaw),
    );
  }

  Widget _buildReadonlyRectificationPanel(
    InspectionDetail detail, {
    required String remarksLabel,
  }) {
    final statusLabel = _resolvePriorConfirmLabels(detail).statusLabel;
    final remarks = detail.engineerRemarks?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inspection Status',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        _buildReadonlyConfirmField(statusLabel),
        const SizedBox(height: 16),
        Text(
          '$remarksLabel *',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        _buildReadonlyConfirmField(
          remarks.isEmpty ? '—' : remarks,
          minLines: 3,
        ),
      ],
    );
  }

  Widget _buildReadonlyConfirmField(String value, {int minLines = 1}) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minLines * 22.0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade800,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    InspectionFormState state,
    InspectionFormNotifier notifier,
  ) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isBusy = state.isSubmitting || state.isUploadingFile;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: _footerBtnHeight,
                child: OutlinedButton(
                  onPressed: isBusy ? null : () => _goToInspectionStep1(notifier),
                  style: RfiTheme.secondaryOutlined(scheme).copyWith(
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 14),
                    ),
                    minimumSize: WidgetStatePropertyAll(Size.zero),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(_footerBtnRadius),
                      ),
                    ),
                    backgroundColor:
                        WidgetStatePropertyAll(scheme.surface),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Back',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: _footerBtnHeight,
                child: OutlinedButton(
                  onPressed: isBusy || state.isDraftSaving
                      ? null
                      : () async {
                          await notifier.saveDraft();
                          if (!mounted) return;
                          GlobalAlertDialog.show(
                            context,
                            title: 'Success',
                            message: 'Draft Saved Successfully!',
                            type: DialogType.success,
                          );
                        },
                  style: RfiTheme.secondaryOutlined(scheme).copyWith(
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 14),
                    ),
                    minimumSize: WidgetStatePropertyAll(Size.zero),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(_footerBtnRadius),
                      ),
                    ),
                    backgroundColor:
                        WidgetStatePropertyAll(scheme.surface),
                  ),
                  child: state.isDraftSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.primary,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Save Draft',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Builder(builder: (btnContext) {
          final isReady = !isBusy &&
              !state.locationPermissionDenied &&
              notifier.checkIsStep2Valid(widget.isOffline);
          final radius = BorderRadius.circular(_footerBtnRadius);
          final showGradient = isReady;

          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: showGradient
                  ? [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isBusy || !isReady
                      ? null
                      : () async {
                          try {
                            await notifier.submit(isOffline: widget.isOffline);
                            if (!mounted) return;
                            if (btnContext.mounted) {
                              GlobalAlertDialog.show(
                                btnContext,
                                title: 'Success',
                                message: 'Inspection submitted successfully!',
                                type: DialogType.success,
                                onConfirm: () {
                                  if (btnContext.mounted) {
                                    btnContext.pop();
                                  }
                                },
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            if (btnContext.mounted) {
                              final msg = _submitErrorMessage(e);
                              GlobalAlertDialog.show(
                                btnContext,
                                title: 'Error',
                                message: msg,
                                type: DialogType.error,
                              );
                            }
                          }
                        },
                  borderRadius: radius,
                  splashColor: Colors.white.withValues(alpha: 0.22),
                  highlightColor: Colors.white.withValues(alpha: 0.08),
                  child: Ink(
                    height: _footerBtnHeight,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      color: showGradient
                          ? scheme.primary
                          : scheme.surfaceContainerHighest,
                      border: showGradient
                          ? null
                          : Border.all(color: scheme.outline, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state.isSubmitting)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: scheme.onPrimary,
                            ),
                          )
                        else ...[
                          Icon(
                            Icons.send_rounded,
                            size: 18,
                            color: isReady
                                ? scheme.onPrimary
                                : scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isBusy ? 'Please wait…' : 'Submit Inspection',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.25,
                              color: isReady
                                  ? scheme.onPrimary
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<bool> _handlePermission(Permission permission) async {
    var status = await permission.status;
    if (status.isGranted || status.isLimited) return true;

    if (status.isDenied) {
      status = await permission.request();
      if (status.isGranted || status.isLimited) return true;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Permission Required'),
            content: Text(
                'Please enable ${permission.toString().split('.').last} permission in Settings to continue.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(ctx);
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      return false;
    }

    return false;
  }

  Future<bool> _handleGalleryPermission() async {
    return true;
  }

  Future<void> _takeSelfie(InspectionFormNotifier notifier) async {
    if (!await _handlePermission(Permission.camera)) return;

    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );
      if (img != null) {
        notifier.updateSelfie(img.path);
      }
    } catch (e) {
      if (mounted) {
        GlobalAlertDialog.show(
          context,
          title: 'Error',
          message: 'Error capturing selfie: $e',
          type: DialogType.error,
        );
      }
    }
  }

  Future<void> _pickImage(InspectionFormNotifier notifier) async {
    if (!await _handleGalleryPermission()) return;

    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: ImageSource.gallery);
      if (img != null) {
        await notifier.uploadSiteImageRealtime(img.path);
      }
    } catch (e) {
      if (mounted) {
        GlobalAlertDialog.show(
          context,
          title: 'Error',
          message: 'Error picking image: $e',
          type: DialogType.error,
        );
      }
    }
  }

  Future<void> _pickPDF(InspectionFormNotifier notifier,
      {String? requiredEnclosureName}) async {
    final state = ref.read(inspectionFormProvider(widget.item.id));
    final rfi = state.rfiDetails ?? widget.item;
    final enclosureNames = rfi.enclosuresList ?? [];

    if (enclosureNames.isEmpty && requiredEnclosureName == null) {
      GlobalAlertDialog.show(
        context,
        title: 'Missing data',
        message: 'No enclosure names defined for this RFI',
        type: DialogType.info,
      );
      return;
    }

    try {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

      if (result != null && result.files.single.path != null) {
        if (!context.mounted) return;
        String? selectedName;

        if (requiredEnclosureName != null) {
          selectedName = requiredEnclosureName;
        } else if (enclosureNames.length == 1) {
          selectedName = enclosureNames.first;
        } else {
          if (!mounted) return;
          selectedName = await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Select Enclosure Name'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: enclosureNames.length,
                  itemBuilder: (c, i) => ListTile(
                    title: Text(enclosureNames[i]),
                    onTap: () => Navigator.pop(c, enclosureNames[i]),
                  ),
                ),
              ),
            ),
          );
        }

        if (selectedName != null) {
          await notifier.uploadEnclosureRealtime(
              result.files.single.path!, selectedName);
        }
      }
    } catch (e) {
      if (mounted) {
        GlobalAlertDialog.show(
          context,
          title: 'Error',
          message: 'Error picking file: $e',
          type: DialogType.error,
        );
      }
    }
  }

  String _submitErrorMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) return data['error'].toString();
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (data is String && data.isNotEmpty) return data;
      if (e.message != null && e.message!.isNotEmpty) return e.message!;
    }
    final raw = e.toString();
    return raw.startsWith('Exception: ') ? raw.substring(11) : raw;
  }

  Widget _buildEnclosuresGridTable(
    BuildContext context,
    InspectionFormState state,
    InspectionFormNotifier notifier,
  ) {
    final rfi = state.rfiDetails ?? widget.item;
    final enclosureNames = rfi.enclosuresList ?? [];

    if (enclosureNames.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enclosures *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF50589C),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFEDF7F9)),
              columnSpacing: 24,
              horizontalMargin: 16,
              columns: const [
                DataColumn(
                    label: Text('RFI Description',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(
                    label: Text('Enclosure',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(
                    label: Text('Action',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(
                    label: Text('Uploaded',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(
                    label: Text('Test Report',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: enclosureNames.map((name) {
                final hasChecklist = state.enclosureHasChecklist[name] ?? false;
                final uploadedFiles = state.rfiDetails?.enclosure
                        ?.where((e) => e.enclosureName == name)
                        .toList() ??
                    [];

                return DataRow(cells: [
                  DataCell(Text(rfi.rfiDescription ?? 'N/A',
                      style: const TextStyle(fontSize: 12))),
                  DataCell(Text(name, style: const TextStyle(fontSize: 12))),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasChecklist && !widget.isOffline)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _buildChecklistOpenButton(
                                context, notifier, name),
                          ),
                        ElevatedButton(
                          onPressed: state.isUploadingFile || state.isSubmitting
                              ? null
                              : () => _pickPDF(
                                    notifier,
                                    requiredEnclosureName: name,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 0),
                            elevation: 0,
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Text('Upload',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    uploadedFiles.isEmpty
                        ? const Text('---',
                            style: TextStyle(color: Colors.grey))
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: uploadedFiles.map((enc) {
                              final fileUrl = enc.id != null
                                  ? '${Environment.baseUrl}api/rfi/view-enclosure?id=${enc.id}'
                                  : _getPublicUrl(
                                      enc.enclosureUploadFile ?? '',
                                    );

                              return Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Row(
                                  children: [
                                    _buildMiniIconBtn(
                                        Icons.visibility_outlined,
                                        Colors.grey.shade700,
                                        () => _viewFile(fileUrl, isPDF: true)),
                                    _buildMiniIconBtn(
                                        Icons.download_for_offline_outlined,
                                        Colors.grey.shade700,
                                        () => _downloadFile(fileUrl)),
                                    if (enc.id != null)
                                      _buildMiniIconBtn(
                                          Icons.delete_outline_rounded,
                                          Colors.red, () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title:
                                                const Text('Remove Enclosure'),
                                            content: const Text(
                                                'Are you sure you want to remove this enclosure?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, false),
                                                  child: const Text('Cancel')),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.red),
                                                child: const Text('Remove'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await notifier
                                              .deleteRemoteEnclosure(enc.id!);
                                        }
                                      }),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  const DataCell(
                      Text('---', style: TextStyle(color: Colors.grey))),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFiles(InspectionFormNotifier notifier) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) return;

      final path = result.files.single.path!;
      notifier.addSupportingDoc(path);
    } catch (e) {
      if (mounted) {
        GlobalAlertDialog.show(
          context,
          title: 'Error',
          message: 'Error picking file: $e',
          type: DialogType.error,
        );
      }
    }
  }

  Future<void> _viewFile(String path, {bool isPDF = false}) async {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return;

    final localFile = File(trimmed);
    if (await localFile.exists()) {
      final result = await OpenFile.open(trimmed);
      if (!mounted) return;
      if (result.type != ResultType.done) {
        GlobalAlertDialog.show(
          context,
          title: 'Unable to open file',
          message: 'Could not open file: ${result.message}',
          type: DialogType.error,
        );
      }
      return;
    }

    if (!mounted) return;
    await RfiMediaViewerDialog.show(
      context,
      source: trimmed,
      dio: ref.read(dioProvider),
      title: trimmed.split('/').last.split('?').first,
    );
  }

  Future<void> _downloadFile(String path) async {
    if (!mounted) return;

    if (path.startsWith('http') ||
        path.contains('view-enclosure') ||
        path.contains('previewFiles')) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final dio = ref.read(dioProvider);
        final dir = await getApplicationDocumentsDirectory();
        var fileName = path.split('/').last.split('?').first;
        if (fileName.isEmpty || fileName.contains('=')) {
          fileName = 'enclosure_${DateTime.now().millisecondsSinceEpoch}.pdf';
        }
        fileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
        final savePath = '${dir.path}/$fileName';

        if (path.contains('view-enclosure')) {
          final idMatch =
              RegExp(r'id=(\d+)').firstMatch(path)?.group(1);
          if (idMatch != null) {
            await dio.download(
              'api/rfi/view-enclosure',
              savePath,
              queryParameters: <String, String>{'id': idMatch},
              options: Options(extra: <String, dynamic>{'silentError': true}),
            );
          } else {
            await dio.download(
              path,
              savePath,
              options: Options(extra: <String, dynamic>{'silentError': true}),
            );
          }
        } else {
          final bytes = await RfiPreviewFetch.fetchBytes(dio, path);
          await File(savePath).writeAsBytes(bytes);
        }

        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        await OpenFile.open(savePath);
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        GlobalAlertDialog.show(
          context,
          title: 'Download failed',
          message: e.toString(),
          type: DialogType.error,
        );
      }
      return;
    }

    try {
      final file = File(path);
      if (!await file.exists()) {
        if (mounted) {
          GlobalAlertDialog.show(
            context,
            title: 'File not found',
            message: 'File does not exist',
            type: DialogType.error,
          );
        }
        return;
      }
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        GlobalAlertDialog.show(
          context,
          title: 'Success',
          message: 'File saved to local storage.',
          type: DialogType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        GlobalAlertDialog.show(
          context,
          title: 'Download failed',
          message: 'Download failed: $e',
          type: DialogType.error,
        );
      }
    }
  }

  String _getPublicUrl(String path) => RfiPreviewFetch.resolvePublicUrl(path);

  Widget _buildChecklistOpenButton(
      BuildContext context, InspectionFormNotifier notifier, String name) {
    final isCompleted = notifier.isChecklistCompleted(name);
    final isStarted = notifier.isChecklistStarted(name);

    Color bgColor = Colors.grey.shade100;
    Color fgColor = Colors.black87;
    IconData icon = Icons.playlist_add_check;
    String label = 'Open';

    if (isCompleted) {
      bgColor = const Color(0xFFE8F5E9);
      fgColor = const Color(0xFF2E7D32);
      icon = Icons.check_circle_outline;
      label = 'Done';
    } else if (isStarted) {
      bgColor = const Color(0xFFFFF3E0);
      fgColor = const Color(0xFFEF6C00);
      icon = Icons.edit_note;
      label = 'Ongoing';
    }

    return ElevatedButton.icon(
      onPressed: () => _showChecklistDialog(name, notifier),
      icon: Icon(icon, size: 14, color: fgColor),
      label: Text(label,
          style: TextStyle(
              fontSize: 11, color: fgColor, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        elevation: 0,
        minimumSize: const Size(0, 32),
        side: BorderSide(color: fgColor.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  void _showChecklistDialog(
      String enclosureName, InspectionFormNotifier notifier) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Checklist',
      pageBuilder: (ctx, anim1, anim2) => _ChecklistDialog(
        enclosureName: enclosureName,
        rfiId: widget.item.id,
        notifier: notifier,
      ),
    );
  }
}
class _ChecklistDialog extends ConsumerStatefulWidget {
  final String enclosureName;
  final int rfiId;
  final InspectionFormNotifier notifier;

  const _ChecklistDialog({
    required this.enclosureName,
    required this.rfiId,
    required this.notifier,
  });

  @override
  ConsumerState<_ChecklistDialog> createState() => _ChecklistDialogState();
}

class _ChecklistDialogState extends ConsumerState<_ChecklistDialog> {
  String? _selectedAll;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inspectionFormProvider(widget.rfiId));
    final items = state.enclosureChecklists[widget.enclosureName] ?? [];

    final userData = ref.watch(authNotifierProvider).value;
    final role = UserRole.fromLoginResponse(userData ?? {});
    final isContractor = role == UserRole.contractor || role == UserRole.contractorRep;
    final isEngineer = role == UserRole.engineer || role == UserRole.dyHodEngineer || role == UserRole.hod || role == UserRole.dyHod;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.enclosureName.toUpperCase(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (state.isSavingChecklist)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: () async {
                try {
                  await widget.notifier
                      .saveEnclosureChecklist(widget.enclosureName);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  GlobalAlertDialog.show(
                    context,
                    title: 'Success',
                    message: 'Checklist saved successfully',
                    type: DialogType.success,
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  GlobalAlertDialog.show(
                    context,
                    title: 'Error',
                    message: 'Error: $e',
                    type: DialogType.error,
                  );
                }
              },
              child: const Text('SAVE',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildInfoSection(state),

          _buildSelectAllSection(isContractor, isEngineer),

          const Divider(height: 1),

          _buildTableLabels(),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: items.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (ctx, index) {
                final item = items[index];
                return _buildChecklistItem(
                    item, index, isContractor, isEngineer);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(InspectionFormState state) {
    final rfi = state.rfiDetails;
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Row(
            children: [
              _buildInfoItem('Name of Work', rfi?.work ?? 'N/A'),
              const SizedBox(width: 12),
              _buildInfoItem('Date', rfi?.dateOfInspection ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem('Structure Type', rfi?.structureType ?? 'N/A'),
              const SizedBox(width: 12),
              _buildInfoItem('Component', rfi?.component ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem('RFI No', rfi?.rfiId ?? 'N/A'),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Grade Of Concrete/Steel',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 36,
                      child: TextField(
                        enabled: [UserRole.contractor, UserRole.contractorRep].contains(UserRole.fromLoginResponse(
                                ref.watch(authNotifierProvider).value ?? {})),
                        onChanged: (val) => widget.notifier
                            .updateEnclosureGrade(widget.enclosureName, val),
                        controller: TextEditingController(
                            text: state.enclosureGrades[widget.enclosureName] ??
                                "")
                          ..selection = TextSelection.fromPosition(TextPosition(
                              offset: (state.enclosureGrades[
                                          widget.enclosureName] ??
                                      "")
                                  .length)),
                        decoration: InputDecoration(
                          hintText: 'Enter Grade',
                          hintStyle: const TextStyle(fontSize: 12),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildSelectAllSection(bool isContractor, bool isEngineer) {
    if (!isContractor && !isEngineer) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('${isContractor ? 'Contractor' : 'Engineer'} Select All: ',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedAll,
                hint: const Text('--Select--', style: TextStyle(fontSize: 12)),
                items: ['YES', 'NO', 'N/A', 'CLEAR']
                    .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, style: const TextStyle(fontSize: 12))))
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedAll = val);
                  widget.notifier
                      .selectAllStatus(widget.enclosureName, val, isContractor);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableLabels() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      child: const Row(
        children: [
          SizedBox(
              width: 24,
              child: Text('ID',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(
              flex: 3,
              child: Text('Description',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text('Status',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center)),
          Expanded(
              flex: 2,
              child: Text('Remark',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(
      ChecklistItem item, int index, bool isContractor, bool isEngineer) {
    final status = isContractor ? item.contractorStatus : item.engineerStatus;
    final otherStatus =
        isContractor ? item.engineerStatus : item.contractorStatus;
    final remark = isContractor ? item.contractorRemarks : item.engineerRemark;
    final otherRemark =
        isContractor ? item.engineerRemark : item.contractorRemarks;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 24,
                  child: Text('${index + 1}',
                      style: const TextStyle(fontSize: 12))),
              Expanded(
                flex: 3,
                child: Text(item.checklistDescription ?? 'N/A',
                    style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildStatusChip(
                        'YES',
                        status,
                        isContractor,
                        isEngineer,
                        () => widget.notifier.updateChecklistItemStatus(
                            widget.enclosureName, index, 'YES', isContractor)),
                    const SizedBox(height: 4),
                    _buildStatusChip(
                        'NO',
                        status,
                        isContractor,
                        isEngineer,
                        () => widget.notifier.updateChecklistItemStatus(
                            widget.enclosureName, index, 'NO', isContractor)),
                    const SizedBox(height: 4),
                    _buildStatusChip(
                        'N/A',
                        status,
                        isContractor,
                        isEngineer,
                        () => widget.notifier.updateChecklistItemStatus(
                            widget.enclosureName, index, 'N/A', isContractor)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    TextField(
                      controller: TextEditingController(text: remark ?? "")
                        ..selection = TextSelection.fromPosition(
                            TextPosition(offset: (remark ?? "").length)),
                      onChanged: (val) => widget.notifier
                          .updateChecklistItemRemark(
                              widget.enclosureName, index, val, isContractor),
                      decoration: InputDecoration(
                        hintText: 'My Remark',
                        hintStyle: const TextStyle(fontSize: 11),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      style: const TextStyle(fontSize: 11),
                      maxLines: 2,
                    ),
                    if (otherRemark != null && otherRemark.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('${isContractor ? 'Engg' : 'Con'}: $otherRemark',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (otherStatus != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 32),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (isContractor
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFFE8F5E9)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                    '${isContractor ? 'Engineer' : 'Contractor'} Status: $otherStatus',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: (isContractor
                            ? const Color(0xFF1976D2)
                            : const Color(0xFF2E7D32)))),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String? currentStatus,
      bool isContractor, bool isEngineer, VoidCallback onTap) {
    if (!isContractor && !isEngineer) {
      final isSelected = currentStatus == label;
      if (!isSelected) return const SizedBox.shrink();
    }

    final isSelected = currentStatus == label;
    final color = label == 'YES'
        ? Colors.green
        : label == 'NO'
            ? Colors.red
            : Colors.grey;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? color : Colors.grey.shade600,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal)),
        ),
      ),
    );
  }
}

class _ReadonlySupportingDocumentRow extends StatelessWidget {
  const _ReadonlySupportingDocumentRow({
    super.key,
    required this.entry,
    required this.accentColor,
    required this.onView,
    required this.onDownload,
  });

  final SupportingDocumentEntry entry;
  final Color accentColor;
  final VoidCallback onView;
  final VoidCallback onDownload;

  Widget _miniIcon(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = entry.filePath;
    final fileName = path.split('/').last.split('?').first;
    final description = entry.documentsDescription.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insert_drive_file, size: 24, color: accentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fileName.isEmpty ? 'Document' : fileName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _miniIcon(Icons.visibility_outlined, Colors.blue, onView),
              _miniIcon(
                Icons.download_for_offline_outlined,
                Colors.green,
                onDownload,
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ],
      ),
    );
  }
}

class _SupportingDocumentFileRow extends StatefulWidget {
  const _SupportingDocumentFileRow({
    super.key,
    required this.index,
    required this.doc,
    required this.accentColor,
    required this.notifier,
    required this.onView,
    required this.onDownload,
    required this.onDelete,
  });

  final int index;
  final SupportingDocument doc;
  final Color accentColor;
  final InspectionFormNotifier notifier;
  final VoidCallback onView;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  @override
  State<_SupportingDocumentFileRow> createState() =>
      _SupportingDocumentFileRowState();
}

class _SupportingDocumentFileRowState extends State<_SupportingDocumentFileRow> {
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.doc.description);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _miniIcon(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.doc.path;
    final fileName = path.split('/').last;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insert_drive_file, size: 24, color: widget.accentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _miniIcon(Icons.visibility_outlined, Colors.blue, widget.onView),
              _miniIcon(
                Icons.download_for_offline_outlined,
                Colors.green,
                widget.onDownload,
              ),
              _miniIcon(
                Icons.delete_outline_rounded,
                Colors.red,
                widget.onDelete,
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'e.g. test report, drawing',
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 12,
                color: widget.accentColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
            ),
            onChanged: (value) => widget.notifier
                .updateSupportingDocDescription(widget.index, value),
          ),
        ],
      ),
    );
  }
}
