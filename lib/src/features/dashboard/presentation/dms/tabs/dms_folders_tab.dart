import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

class DmsFoldersTab extends StatefulWidget {
  const DmsFoldersTab({super.key, required this.dataSource});

  final DashboardRemoteDataSource dataSource;

  @override
  State<DmsFoldersTab> createState() => _DmsFoldersTabState();
}

class _DmsProjectOption {
  const _DmsProjectOption({required this.id, required this.name});

  final String id;
  final String name;
}

class _DmsFolderRecord {
  const _DmsFolderRecord({
    required this.id,
    required this.name,
    required this.parentId,
  });

  final int id;
  final String name;
  final int? parentId;
}

class _DmsGridItem {
  const _DmsGridItem.folder({
    required this.id,
    required this.name,
    this.count,
    this.isCorrespondence = false,
    this.correspondenceType,
  }) : isFile = false,
       fileType = null,
       revisionNo = null,
       filePath = null;

  const _DmsGridItem.file({
    required this.id,
    required this.name,
    required this.fileType,
    this.revisionNo,
    this.filePath,
  }) : isFile = true,
       count = null,
       isCorrespondence = false,
       correspondenceType = null;

  final dynamic id;
  final String name;
  final bool isFile;
  final String? fileType;
  final String? revisionNo;
  final String? filePath;
  final int? count;
  final bool isCorrespondence;
  final String? correspondenceType;
}

class _BreadcrumbItem {
  const _BreadcrumbItem({
    required this.label,
    this.folderId,
    this.correspondenceType,
  });

  final String label;
  final int? folderId;
  final String? correspondenceType;
}

class _DmsFoldersTabState extends State<DmsFoldersTab> {
  static const int _correspondenceFolderId = -1;
  static const String _incomingType = 'Incoming';
  static const String _outgoingType = 'Outgoing';

  bool _loadingLookups = true;
  bool _loadingContracts = false;
  bool _loadingGrid = false;
  String? _loadError;

  List<_DmsProjectOption> _projects = <_DmsProjectOption>[];
  List<String> _contracts = <String>[];
  List<_DmsFolderRecord> _allFolders = <_DmsFolderRecord>[];

  _DmsProjectOption? _selectedProject;
  String? _selectedContract;

  List<_DmsGridItem> _gridItems = <_DmsGridItem>[];
  final List<_BreadcrumbItem> _breadcrumbs = <_BreadcrumbItem>[];
  int? _currentFolderId;
  String? _currentCorrespondenceType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLookups());
  }

  List<String> get _projectFilter {
    final String? name = _selectedProject?.name;
    if (name == null || name.isEmpty) {
      return const <String>[];
    }
    return <String>[name];
  }

  List<String> get _contractFilter {
    final String? name = _selectedContract;
    if (name == null || name.isEmpty) {
      return const <String>[];
    }
    return <String>[name];
  }

  bool get _hasProjectOrContractFilter =>
      _projectFilter.isNotEmpty || _contractFilter.isNotEmpty;

  Future<void> _loadLookups() async {
    setState(() {
      _loadingLookups = true;
      _loadError = null;
    });
    try {
      final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
        widget.dataSource.fetchDmsProjectNames(),
        widget.dataSource.fetchDmsFolders(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _projects = _mapProjects(results[0] as List<Map<String, dynamic>>);
        _allFolders = _mapFolders(results[1] as List<Map<String, dynamic>>);
        _loadingLookups = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingLookups = false;
        _loadError = error.toString();
      });
    }
  }

  List<_DmsProjectOption> _mapProjects(List<Map<String, dynamic>> rows) {
    return rows
        .map(
          (Map<String, dynamic> row) => _DmsProjectOption(
            id: _str(row['id']),
            name: _str(row['name']).isNotEmpty ? _str(row['name']) : _str(row['id']),
          ),
        )
        .where((_DmsProjectOption item) => item.name.isNotEmpty)
        .toList();
  }

  List<_DmsFolderRecord> _mapFolders(List<Map<String, dynamic>> rows) {
    return rows
        .map((Map<String, dynamic> row) {
          final int? id = int.tryParse(_str(row['id']));
          if (id == null) {
            return null;
          }
          final int? parentId = int.tryParse(_str(row['parentId']));
          return _DmsFolderRecord(
            id: id,
            name: _str(row['name']),
            parentId: parentId,
          );
        })
        .whereType<_DmsFolderRecord>()
        .where((_DmsFolderRecord folder) => folder.name.isNotEmpty)
        .toList();
  }

  Future<void> _onProjectChanged(_DmsProjectOption project) async {
    setState(() {
      _selectedProject = project;
      _selectedContract = null;
      _contracts = <String>[];
      _loadingContracts = true;
      _resetNavigation();
    });
    try {
      final List<String> contracts =
          await widget.dataSource.fetchDmsContractsByProject(project.name);
      if (!mounted) {
        return;
      }
      setState(() {
        _contracts = contracts;
        _loadingContracts = false;
      });
      await _refreshGrid();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingContracts = false;
        _loadError = error.toString();
      });
    }
  }

  Future<void> _onContractChanged(String contract) async {
    setState(() {
      _selectedContract = contract;
      _resetNavigation();
    });
    await _refreshGrid();
  }

  void _resetNavigation() {
    _breadcrumbs.clear();
    _currentFolderId = null;
    _currentCorrespondenceType = null;
    _gridItems = <_DmsGridItem>[];
  }

  Future<void> _refreshGrid() async {
    if (!_hasProjectOrContractFilter) {
      setState(() {
        _gridItems = <_DmsGridItem>[];
      });
      return;
    }
    if (_currentFolderId != null) {
      await _openFolder(
        _currentFolderId!,
        _breadcrumbs.isNotEmpty ? _breadcrumbs.last.label : '',
        pushBreadcrumb: false,
      );
      return;
    }
    if (_currentCorrespondenceType != null) {
      await _openCorrespondenceType(
        _currentCorrespondenceType!,
        pushBreadcrumb: false,
      );
      return;
    }
    await _loadRootGrid();
  }

  Future<void> _loadRootGrid() async {
    setState(() {
      _loadingGrid = true;
      _loadError = null;
    });
    try {
      final List<_DmsFolderRecord> rootFolders = _allFolders
          .where((_DmsFolderRecord folder) => folder.parentId == null)
          .toList()
        ..sort(
          ( _DmsFolderRecord a, _DmsFolderRecord b) =>
              a.name.compareTo(b.name),
        );

      final List<Future<List<Map<String, dynamic>>>> countFutures =
          rootFolders
              .map(
                (_DmsFolderRecord folder) =>
                    widget.dataSource.fetchDmsSubfolderFiles(
                  folder.id,
                  projects: _projectFilter,
                  contracts: _contractFilter,
                ),
              )
              .toList();

      final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
        widget.dataSource.fetchDmsRootFiles(
          projects: _projectFilter,
          contracts: _contractFilter,
        ),
        ...countFutures,
      ]);

      if (!mounted) {
        return;
      }

      final List<Map<String, dynamic>> rootFiles =
          (results[0] as List<Map<String, dynamic>>);
      final Map<int, int> counts = <int, int>{};
      for (int i = 0; i < rootFolders.length; i++) {
        final List<Map<String, dynamic>> files =
            results[i + 1] as List<Map<String, dynamic>>;
        counts[rootFolders[i].id] = files.length;
      }

      final List<_DmsGridItem> items = <_DmsGridItem>[
        for (final _DmsFolderRecord folder in rootFolders)
          _DmsGridItem.folder(
            id: folder.id,
            name: folder.name,
            count: counts[folder.id] ?? 0,
          ),
        for (final Map<String, dynamic> file in rootFiles)
          _DmsGridItem.file(
            id: _str(file['id']),
            name: _str(file['fileName']).isNotEmpty
                ? _str(file['fileName'])
                : _str(file['name']),
            fileType: _str(file['fileType']),
            revisionNo: _str(file['revisionNo']),
            filePath: _str(file['filePath']),
          ),
        const _DmsGridItem.folder(
          id: _correspondenceFolderId,
          name: 'Correspondence',
          count: 0,
          isCorrespondence: true,
        ),
      ];

      setState(() {
        _gridItems = items;
        _loadingGrid = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingGrid = false;
        _loadError = error.toString();
        _gridItems = <_DmsGridItem>[];
      });
    }
  }

  Future<void> _openFolder(
    int folderId,
    String folderName, {
    bool pushBreadcrumb = true,
  }) async {
    setState(() {
      _loadingGrid = true;
      _loadError = null;
      _currentFolderId = folderId;
      _currentCorrespondenceType = null;
      if (pushBreadcrumb) {
        _breadcrumbs.add(
          _BreadcrumbItem(label: folderName, folderId: folderId),
        );
      }
    });
    try {
      final List<_DmsFolderRecord> childFolders = _allFolders
          .where((_DmsFolderRecord folder) => folder.parentId == folderId)
          .toList()
        ..sort(
          ( _DmsFolderRecord a, _DmsFolderRecord b) =>
              a.name.compareTo(b.name),
        );
      final List<Map<String, dynamic>> files =
          await widget.dataSource.fetchDmsSubfolderFiles(
        folderId,
        projects: _projectFilter,
        contracts: _contractFilter,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _gridItems = <_DmsGridItem>[
          for (final _DmsFolderRecord folder in childFolders)
            _DmsGridItem.folder(
              id: folder.id,
              name: folder.name,
              count: null,
            ),
          for (final Map<String, dynamic> file in files)
            _DmsGridItem.file(
              id: _str(file['id']),
              name: _str(file['fileName']).isNotEmpty
                  ? _str(file['fileName'])
                  : _str(file['name']),
              fileType: _str(file['fileType']),
              revisionNo: _str(file['revisionNo']),
              filePath: _str(file['filePath']),
            ),
        ];
        _loadingGrid = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingGrid = false;
        _loadError = error.toString();
      });
    }
  }

  Future<void> _openCorrespondenceRoot({bool pushBreadcrumb = true}) async {
    setState(() {
      _loadingGrid = false;
      _currentFolderId = null;
      _currentCorrespondenceType = null;
      if (pushBreadcrumb) {
        _breadcrumbs.add(
          const _BreadcrumbItem(
            label: 'Correspondence',
            folderId: _correspondenceFolderId,
          ),
        );
      }
      _gridItems = const <_DmsGridItem>[
        _DmsGridItem.folder(
          id: 'incoming',
          name: _incomingType,
          isCorrespondence: true,
          correspondenceType: _incomingType,
        ),
        _DmsGridItem.folder(
          id: 'outgoing',
          name: _outgoingType,
          isCorrespondence: true,
          correspondenceType: _outgoingType,
        ),
      ];
    });
  }

  Future<void> _openCorrespondenceType(
    String type, {
    bool pushBreadcrumb = true,
  }) async {
    setState(() {
      _loadingGrid = true;
      _loadError = null;
      _currentCorrespondenceType = type;
      _currentFolderId = null;
      if (pushBreadcrumb) {
        _breadcrumbs.add(
          _BreadcrumbItem(label: type, correspondenceType: type),
        );
      }
    });
    try {
      final List<Map<String, dynamic>> files =
          await widget.dataSource.fetchCorrespondenceFolderFiles(
        type: type,
        projects: _projectFilter,
        contracts: _contractFilter,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _gridItems = files
            .map(
              (Map<String, dynamic> file) => _DmsGridItem.file(
                id: _str(file['id']),
                name: _str(file['fileName']).isNotEmpty
                    ? _str(file['fileName'])
                    : _str(file['letterNumber']),
                fileType: _str(file['fileType']),
                revisionNo: _str(file['revisionNo']),
                filePath: _str(file['filePath']),
              ),
            )
            .toList();
        _loadingGrid = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingGrid = false;
        _loadError = error.toString();
      });
    }
  }

  void _goToRoot() {
    setState(() {
      _breadcrumbs.clear();
      _currentFolderId = null;
      _currentCorrespondenceType = null;
    });
    _loadRootGrid();
  }

  void _goToBreadcrumb(int index) {
    if (index < 0) {
      _goToRoot();
      return;
    }
    final List<_BreadcrumbItem> trail = _breadcrumbs.sublist(0, index + 1);
    final _BreadcrumbItem target = trail.last;
    setState(() {
      _breadcrumbs
        ..clear()
        ..addAll(trail);
      _currentFolderId = target.folderId == _correspondenceFolderId
          ? null
          : target.folderId;
      _currentCorrespondenceType = target.correspondenceType;
    });
    if (target.folderId == _correspondenceFolderId &&
        target.correspondenceType == null) {
      _openCorrespondenceRoot(pushBreadcrumb: false);
      return;
    }
    if (target.correspondenceType != null) {
      _openCorrespondenceType(
        target.correspondenceType!,
        pushBreadcrumb: false,
      );
      return;
    }
    if (target.folderId != null) {
      _openFolder(target.folderId!, target.label, pushBreadcrumb: false);
      return;
    }
    _loadRootGrid();
  }

  Future<void> _onItemTap(_DmsGridItem item) async {
    if (item.isFile) {
      await AppDialog.show(
        context: context,
        title: item.name,
        message: <String>[
          if ((item.fileType ?? '').isNotEmpty) 'Type: ${item.fileType}',
          if ((item.revisionNo ?? '').isNotEmpty) 'Revision: ${item.revisionNo}',
          if ((item.filePath ?? '').isNotEmpty) 'Path: ${item.filePath}',
        ].join('\n'),
        type: AppDialogType.info,
      );
      return;
    }
    if (item.isCorrespondence) {
      if (item.correspondenceType != null) {
        await _openCorrespondenceType(item.correspondenceType!);
        return;
      }
      await _openCorrespondenceRoot();
      return;
    }
    await _openFolder(item.id as int, item.name);
  }

  String _itemLabel(_DmsGridItem item) {
    if (item.isFile) {
      return item.name;
    }
    if (item.count != null) {
      return '${item.name} [${item.count}]';
    }
    return item.name;
  }

  String _str(dynamic value) {
    if (value == null) {
      return '';
    }
    final String text = value.toString().trim();
    return text.toLowerCase() == 'null' ? '' : text;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    if (_loadingLookups) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null && _projects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _loadError!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.error),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: AppSelectSheetField<_DmsProjectOption>(
                  label: 'Project',
                  title: 'Select Project',
                  compact: true,
                  items: _projects,
                  value: _selectedProject,
                  itemLabelBuilder: (_DmsProjectOption item) => item.name,
                  onChanged: _onProjectChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppSelectSheetField<String>(
                  label: 'Contract',
                  title: 'Select Contract',
                  compact: true,
                  enabled: _selectedProject != null && !_loadingContracts,
                  items: _contracts,
                  value: _selectedContract,
                  itemLabelBuilder: (String item) => item,
                  onChanged: _onContractChanged,
                ),
              ),
            ],
          ),
        ),
        if (_breadcrumbs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: <Widget>[
                InkWell(
                  onTap: _goToRoot,
                  child: Text(
                    'Folders',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                for (int i = 0; i < _breadcrumbs.length; i++) ...<Widget>[
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                  InkWell(
                    onTap: () => _goToBreadcrumb(i),
                    child: Text(
                      _breadcrumbs[i].label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Text(
            'Folders',
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: _buildGridBody(theme, cs)),
      ],
    );
  }

  Widget _buildGridBody(ThemeData theme, ColorScheme cs) {
    if (!_hasProjectOrContractFilter) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Select a project and contract to view folders.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    if (_loadingGrid || _loadingContracts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _loadError!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.error),
          ),
        ),
      );
    }

    if (_gridItems.isEmpty) {
      return Center(
        child: Text(
          'No data found.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: _gridItems.length,
      itemBuilder: (BuildContext context, int index) {
        final _DmsGridItem item = _gridItems[index];
        final bool isPdf =
            (item.fileType ?? '').toLowerCase().contains('pdf');
        return Material(
          color: cs.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.65),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _onItemTap(item),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    item.isFile
                        ? (isPdf
                            ? Icons.picture_as_pdf_outlined
                            : Icons.insert_drive_file_outlined)
                        : Icons.folder_rounded,
                    size: 42,
                    color: item.isFile
                        ? (isPdf ? Colors.red.shade700 : cs.primary)
                        : const Color(0xFFF4B400),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _itemLabel(item),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
