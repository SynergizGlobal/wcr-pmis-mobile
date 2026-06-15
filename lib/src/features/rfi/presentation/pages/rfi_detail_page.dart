import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/providers/rfi_providers.dart';

class RfiDetailPage extends ConsumerWidget {
  const RfiDetailPage({super.key, required this.rfiId});

  final int rfiId;

  static const String routeName = 'rfi-detail';
  static const String routePath = '/rfi/detail/:id';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Map<String, dynamic>> detailAsync =
        ref.watch(rfiDetailProvider(rfiId));

    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: detailAsync.maybeWhen(
          data: (Map<String, dynamic> data) {
            final String no = data['rfi_Id']?.toString() ??
                data['rfiNo']?.toString() ??
                '';
            return Text(no.isEmpty ? 'RFI Details' : no);
          },
          orElse: () => const Text('RFI Details'),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(rfiDetailProvider(rfiId)),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.error_outline, size: 48, color: scheme.error),
                const SizedBox(height: 12),
                Text(
                  'Failed to load RFI',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  userFriendlyErrorMessage(error),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(rfiDetailProvider(rfiId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (Map<String, dynamic> data) => _RfiDetailBody(data: data),
      ),
    );
  }
}

class _RfiDetailBody extends StatelessWidget {
  const _RfiDetailBody({required this.data});

  final Map<String, dynamic> data;

  static const List<String> _preferredKeys = <String>[
    'rfi_Id',
    'rfiNo',
    'status',
    'approvalStatus',
    'validationStatus',
    'inspectionStatus',
    'project',
    'work',
    'contract',
    'structure',
    'element',
    'activity',
    'typeOfRFI',
    'rfiDescription',
    'measurementType',
    'totalQty',
    'dateOfSubmission',
    'createdBy',
    'assignedPersonClient',
    'nameOfRepresentative',
  ];

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, String>> rows = <MapEntry<String, String>>[];

    for (final String key in _preferredKeys) {
      final dynamic value = data[key];
      if (value == null || value.toString().trim().isEmpty) {
        continue;
      }
      rows.add(MapEntry<String, String>(_labelFor(key), value.toString()));
    }

    for (final MapEntry<String, dynamic> entry in data.entries) {
      if (_preferredKeys.contains(entry.key)) {
        continue;
      }
      final dynamic value = entry.value;
      if (value == null ||
          value is Map ||
          value is List ||
          value.toString().trim().isEmpty) {
        continue;
      }
      rows.add(MapEntry<String, String>(_labelFor(entry.key), value.toString()));
    }

    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.6),
            ),
            itemBuilder: (BuildContext context, int index) {
              final MapEntry<String, String> row = rows[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      row.key,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      row.value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _labelFor(String key) {
    if (key == 'typeOfRFI') {
      return 'Type of RFI';
    }
    final String spaced = key.replaceAllMapped(
      RegExp('([a-z])([A-Z])'),
      (Match match) => '${match.group(1)} ${match.group(2)}',
    );
    if (spaced.isEmpty) {
      return key;
    }
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}
