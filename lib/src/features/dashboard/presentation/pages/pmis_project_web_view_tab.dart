import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/constants/pmis_web_routes.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/pmis_authenticated_web_view.dart';

class PmisProjectWebViewTab extends StatefulWidget {
  const PmisProjectWebViewTab({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.page,
  });

  final String projectId;
  final String projectName;
  final PmisEmbeddedWebPage page;

  @override
  State<PmisProjectWebViewTab> createState() => _PmisProjectWebViewTabState();
}

class _PmisProjectWebViewTabState extends State<PmisProjectWebViewTab> {
  int _reloadToken = 0;

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: IconButton.outlined(
              tooltip: 'Refresh',
              onPressed: () => setState(() => _reloadToken++),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: PmisAuthenticatedWebView(
              key: ValueKey<String>('${widget.page.name}-${widget.projectId}'),
              url: widget.page.urlForProject(widget.projectId),
              projectId: widget.projectId,
              projectName: widget.projectName,
              reloadToken: _reloadToken,
            ),
          ),
        ],
      ),
    );
  }
}
