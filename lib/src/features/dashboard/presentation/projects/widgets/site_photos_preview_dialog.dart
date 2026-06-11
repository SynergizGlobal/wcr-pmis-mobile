import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/site_photo_row.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/projects/providers/site_photos_provider.dart';

Future<void> showSitePhotosPreviewDialog({
  required BuildContext context,
  required SitePhotoRow row,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return _SitePhotosPreviewDialog(row: row);
    },
  );
}

class _SitePhotosPreviewDialog extends ConsumerStatefulWidget {
  const _SitePhotosPreviewDialog({required this.row});

  final SitePhotoRow row;

  @override
  ConsumerState<_SitePhotosPreviewDialog> createState() =>
      _SitePhotosPreviewDialogState();
}

class _SitePhotosPreviewDialogState
    extends ConsumerState<_SitePhotosPreviewDialog> {
  late int _photoIndex;

  @override
  void initState() {
    super.initState();
    _photoIndex = 0;
  }

  SitePhotoRow get row => widget.row;

  List<String> get _photos => row.photos;

  String get _currentFileName => _photos[_photoIndex];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final bool canGoPrevious = _photoIndex > 0;
    final bool canGoNext = _photoIndex < _photos.length - 1;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: <Widget>[
                        _MetaChip(label: 'Section', value: row.section),
                        _MetaChip(label: 'Structure', value: row.structure),
                        _MetaChip(
                          label: 'Component',
                          value: row.structureComponent,
                        ),
                        _MetaChip(
                          label: 'Component ID',
                          value: row.componentId,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: cs.error.withValues(alpha: 0.12),
                      foregroundColor: cs.error,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.55),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isDark
                        ? cs.surfaceContainerHighest.withValues(alpha: 0.35)
                        : cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.45),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: _StructurePhotoViewer(fileName: _currentFileName),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: canGoPrevious
                        ? () => setState(() => _photoIndex -= 1)
                        : null,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${_photoIndex + 1} / ${_photos.length}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed:
                        canGoNext ? () => setState(() => _photoIndex += 1) : null,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text('Next'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
      ),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.labelMedium?.copyWith(
            color: cs.onSurface,
            height: 1.2,
          ),
          children: <TextSpan>[
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _StructurePhotoViewer extends ConsumerWidget {
  const _StructurePhotoViewer({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final AsyncValue<Uint8List> photoAsync = ref.watch(
      structurePhotoBytesProvider(fileName),
    );

    return photoAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: cs.primary),
      ),
      error: (Object error, StackTrace _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.broken_image_outlined, color: cs.error, size: 36),
              const SizedBox(height: 8),
              Text(
                'Unable to load photo.',
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
      data: (Uint8List bytes) => InteractiveViewer(
        minScale: 0.8,
        maxScale: 4,
        child: Center(
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
