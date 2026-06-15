import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/site_photo_row.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/projects/providers/site_photos_provider.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/projects/widgets/site_photos_preview_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';

class SitePhotosTab extends ConsumerStatefulWidget {
  const SitePhotosTab({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  ConsumerState<SitePhotosTab> createState() => _SitePhotosTabState();
}

class _SitePhotosTabState extends ConsumerState<SitePhotosTab> {
  static const List<int> _pageSizeOptions = <int>[5, 10, 25, 50];

  int _pageSize = 10;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.projectId.trim().isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Project ID is unavailable for this project.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final AsyncValue<List<SitePhotoRow>> photosAsync = ref.watch(
      sitePhotosProvider(widget.projectId),
    );

    return photosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                userFriendlyErrorMessage(error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () =>
                    ref.invalidate(sitePhotosProvider(widget.projectId)),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (List<SitePhotoRow> rows) => _content(context, rows),
    );
  }

  Widget _content(BuildContext context, List<SitePhotoRow> rows) {
    final int total = rows.length;
    final int pageCount = total == 0 ? 1 : (total / _pageSize).ceil();
    if (_currentPage >= pageCount) {
      _currentPage = pageCount - 1;
    }
    if (_currentPage < 0) {
      _currentPage = 0;
    }
    final int start = total == 0 ? 0 : _currentPage * _pageSize;
    final int end = total == 0 ? 0 : (start + _pageSize).clamp(0, total);
    final List<SitePhotoRow> pageRows =
        total == 0 ? rows : rows.sublist(start, end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(child: _headerCard(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              if (rows.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No site photos available for this project.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(child: _tableArea(context, pageRows)),
            ],
          ),
        ),
        AppTablePaginationFooter(
          total: total,
          startIndex: start,
          endIndex: end,
          currentPage: _currentPage,
          pageCount: pageCount,
          pageSize: _pageSize,
          pageSizeOptions: _pageSizeOptions,
          onPageSizeChanged: (int value) => setState(() {
            _pageSize = value;
            _currentPage = 0;
          }),
          onPrevious: _currentPage > 0
              ? () => setState(() => _currentPage -= 1)
              : null,
          onNext: _currentPage < pageCount - 1
              ? () => setState(() => _currentPage += 1)
              : null,
        ),
      ],
    );
  }

  Widget _headerCard(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Site Photos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                children: <TextSpan>[
                  const TextSpan(text: 'Project ID: '),
                  TextSpan(
                    text: widget.projectId,
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
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

  Widget _tableArea(BuildContext context, List<SitePhotoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .shadow
                .withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _SitePhotosColumnLayout.totalWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _tableHeader(context),
                for (int index = 0; index < rows.length; index++) ...<Widget>[
                  if (index > 0)
                    Divider(
                      height: 1,
                      thickness: 0.6,
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.45),
                    ),
                  _tableRow(context, rows[index]),
                ],
              ],
            ),
          ),
        ),
    );
  }

  Widget _tableHeader(BuildContext context) {
    final Color headerColor = Theme.of(context).colorScheme.primary;
    return Container(
      color: headerColor,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: _SitePhotosColumnLayout.horizontalPadding / 2,
      ),
      child: Row(
        children: <Widget>[
          _headerCell('SECTION', _SitePhotosColumnLayout.section),
          _headerCell('STRUCTURE TYPE', _SitePhotosColumnLayout.structureType),
          _headerCell('STRUCTURE', _SitePhotosColumnLayout.structure),
          _headerCell(
            'STRUCTURE COMPONENT',
            _SitePhotosColumnLayout.structureComponent,
          ),
          _headerCell('COMPONENT ID', _SitePhotosColumnLayout.componentId),
          _headerCell(
            'PHOTOS COUNT',
            _SitePhotosColumnLayout.photosCount,
            centered: true,
          ),
          _headerCell('VIEW', _SitePhotosColumnLayout.view, centered: true),
        ],
      ),
    );
  }

  Widget _headerCell(
    String label,
    double width, {
    bool centered = false,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: centered ? TextAlign.center : TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _tableRow(BuildContext context, SitePhotoRow row) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool canView = row.hasPhotos;

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.22),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: _SitePhotosColumnLayout.horizontalPadding / 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _textCell(row.section, width: _SitePhotosColumnLayout.section),
            _textCell(
              row.structureType,
              width: _SitePhotosColumnLayout.structureType,
            ),
            _textCell(
              row.structure,
              width: _SitePhotosColumnLayout.structure,
              weight: FontWeight.w600,
            ),
            _textCell(
              row.structureComponent,
              width: _SitePhotosColumnLayout.structureComponent,
            ),
            _textCell(
              row.componentId,
              width: _SitePhotosColumnLayout.componentId,
            ),
            SizedBox(
              width: _SitePhotosColumnLayout.photosCount,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.75),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 30,
                    minHeight: 30,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${row.photosCount}',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: _SitePhotosColumnLayout.view,
              child: Center(
                child: FilledButton(
                  onPressed: canView
                      ? () => showSitePhotosPreviewDialog(
                            context: context,
                            row: row,
                          )
                      : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(92, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(
                    'View Photos',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textCell(
    String value, {
    required double width,
    FontWeight weight = FontWeight.w500,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        value,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: weight,
          height: 1.25,
        ),
      ),
    );
  }
}

class _SitePhotosColumnLayout {
  static const double section = 128;
  static const double structureType = 108;
  static const double structure = 196;
  static const double structureComponent = 132;
  static const double componentId = 120;
  static const double photosCount = 88;
  static const double view = 108;
  static const double horizontalPadding = 20;

  static double get totalWidth =>
      section +
      structureType +
      structure +
      structureComponent +
      componentId +
      photosCount +
      view +
      horizontalPadding;
}
