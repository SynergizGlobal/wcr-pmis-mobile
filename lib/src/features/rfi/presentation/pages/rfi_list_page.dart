import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/rfi_list_kind.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/widgets/rfi_list_content.dart';

class RfiListPage extends ConsumerWidget {
  const RfiListPage({super.key, required this.kind});

  final RfiListKind kind;

  static const String routeName = 'rfi-list';
  static const String routePath = '/rfi/list/:kind';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(kind.title)),
      body: SafeArea(
        child: RfiListContent(kind: kind),
      ),
    );
  }
}
