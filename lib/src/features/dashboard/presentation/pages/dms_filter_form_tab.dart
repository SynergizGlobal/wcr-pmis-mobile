import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

enum _FilterFormSubTab {
  department('Department'),
  status('Status'),
  folders('Folders');

  const _FilterFormSubTab(this.label);

  final String label;
}

class DmsFilterFormTab extends StatefulWidget {
  const DmsFilterFormTab({super.key, required this.dataSource});

  final DashboardRemoteDataSource dataSource;

  @override
  State<DmsFilterFormTab> createState() => _DmsFilterFormTabState();
}

class _DmsFilterFormTabState extends State<DmsFilterFormTab> {
  _FilterFormSubTab _subTab = _FilterFormSubTab.department;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark
                  ? cs.surfaceContainerHighest.withValues(alpha: 0.45)
                  : cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.55),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: _FilterFormSubTab.values.map((_FilterFormSubTab tab) {
                  final bool selected = tab == _subTab;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => setState(() => _subTab = tab),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? cs.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              tab.label,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: selected ? cs.onPrimary : cs.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        Expanded(
          child: switch (_subTab) {
            _FilterFormSubTab.department => _DmsDepartmentPanel(
              dataSource: widget.dataSource,
            ),
            _FilterFormSubTab.status => _DmsStatusPanel(
              dataSource: widget.dataSource,
            ),
            _FilterFormSubTab.folders => _DmsFilterFoldersPanel(
              dataSource: widget.dataSource,
            ),
          },
        ),
      ],
    );
  }
}

class _NamedRecord {
  const _NamedRecord({required this.id, required this.name});

  final int id;
  final String name;
}

class _DmsDepartmentPanel extends StatefulWidget {
  const _DmsDepartmentPanel({required this.dataSource});

  final DashboardRemoteDataSource dataSource;

  @override
  State<_DmsDepartmentPanel> createState() => _DmsDepartmentPanelState();
}

class _DmsDepartmentPanelState extends State<_DmsDepartmentPanel> {
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _loadError;
  String _search = '';
  List<_NamedRecord> _items = <_NamedRecord>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final List<Map<String, dynamic>> rows =
          await widget.dataSource.fetchDmsDepartments();
      if (!mounted) {
        return;
      }
      setState(() {
        _items = _mapRows(rows);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _loadError = error.toString();
      });
    }
  }

  List<_NamedRecord> _mapRows(List<Map<String, dynamic>> rows) {
    return rows
        .map((Map<String, dynamic> row) {
          final int? id = int.tryParse(_str(row['id']));
          if (id == null) {
            return null;
          }
          return _NamedRecord(id: id, name: _str(row['name']));
        })
        .whereType<_NamedRecord>()
        .where((_NamedRecord item) => item.name.isNotEmpty)
        .toList()
      ..sort(
        ( _NamedRecord a, _NamedRecord b) => a.name.compareTo(b.name),
      );
  }

  List<_NamedRecord> get _visibleItems {
    if (_search.trim().isEmpty) {
      return _items;
    }
    final String q = _search.trim().toLowerCase();
    return _items
        .where((_NamedRecord item) => item.name.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _add() async {
    final String? name = await _promptName(
      context: context,
      title: 'Add Department',
      hint: 'Department name',
    );
    if (name == null || name.trim().isEmpty || !mounted) {
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.dataSource.createDmsDepartment(name: name.trim());
      if (!mounted) {
        return;
      }
      await _load();
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Add failed',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete(_NamedRecord item) async {
    await AppDialog.show(
      context: context,
      type: AppDialogType.confirmation,
      title: 'Delete Department',
      message: 'Delete "${item.name}"?',
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Delete',
          isPrimary: true,
          onPressed: () async {
            setState(() => _saving = true);
            try {
              await widget.dataSource.deleteDmsDepartment(item.id);
              if (!mounted) {
                return;
              }
              await _load();
            } catch (error) {
              if (!mounted) {
                return;
              }
              await AppDialog.show(
                context: context,
                title: 'Delete failed',
                message: error.toString(),
                type: AppDialogType.error,
              );
            } finally {
              if (mounted) {
                setState(() => _saving = false);
              }
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _NamedListPanel(
      addLabel: 'Add Department',
      loading: _loading,
      saving: _saving,
      loadError: _loadError,
      searchController: _searchController,
      onSearchChanged: (String value) => setState(() => _search = value),
      onAdd: _add,
      onRetry: _load,
      items: _visibleItems,
      onDelete: _delete,
    );
  }
}

class _DmsStatusPanel extends StatefulWidget {
  const _DmsStatusPanel({required this.dataSource});

  final DashboardRemoteDataSource dataSource;

  @override
  State<_DmsStatusPanel> createState() => _DmsStatusPanelState();
}

class _DmsStatusPanelState extends State<_DmsStatusPanel> {
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _loadError;
  String _search = '';
  List<_NamedRecord> _items = <_NamedRecord>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final List<Map<String, dynamic>> rows =
          await widget.dataSource.fetchDmsStatuses();
      if (!mounted) {
        return;
      }
      setState(() {
        _items = _mapRows(rows);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _loadError = error.toString();
      });
    }
  }

  List<_NamedRecord> _mapRows(List<Map<String, dynamic>> rows) {
    return rows
        .map((Map<String, dynamic> row) {
          final int? id = int.tryParse(_str(row['id']));
          if (id == null) {
            return null;
          }
          return _NamedRecord(id: id, name: _str(row['name']));
        })
        .whereType<_NamedRecord>()
        .where((_NamedRecord item) => item.name.isNotEmpty)
        .toList()
      ..sort(
        ( _NamedRecord a, _NamedRecord b) => a.name.compareTo(b.name),
      );
  }

  List<_NamedRecord> get _visibleItems {
    if (_search.trim().isEmpty) {
      return _items;
    }
    final String q = _search.trim().toLowerCase();
    return _items
        .where((_NamedRecord item) => item.name.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _add() async {
    final String? name = await _promptName(
      context: context,
      title: 'Add Status',
      hint: 'Status name',
    );
    if (name == null || name.trim().isEmpty || !mounted) {
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.dataSource.createDmsStatus(name: name.trim());
      if (!mounted) {
        return;
      }
      await _load();
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Add failed',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete(_NamedRecord item) async {
    await AppDialog.show(
      context: context,
      type: AppDialogType.confirmation,
      title: 'Delete Status',
      message: 'Delete "${item.name}"?',
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Delete',
          isPrimary: true,
          onPressed: () async {
            setState(() => _saving = true);
            try {
              await widget.dataSource.deleteDmsStatus(item.id);
              if (!mounted) {
                return;
              }
              await _load();
            } catch (error) {
              if (!mounted) {
                return;
              }
              await AppDialog.show(
                context: context,
                title: 'Delete failed',
                message: error.toString(),
                type: AppDialogType.error,
              );
            } finally {
              if (mounted) {
                setState(() => _saving = false);
              }
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _NamedListPanel(
      addLabel: 'Add Status',
      loading: _loading,
      saving: _saving,
      loadError: _loadError,
      searchController: _searchController,
      onSearchChanged: (String value) => setState(() => _search = value),
      onAdd: _add,
      onRetry: _load,
      items: _visibleItems,
      onDelete: _delete,
    );
  }
}

class _FolderTreeNode {
  _FolderTreeNode({
    required this.id,
    required this.name,
    required this.parentId,
  });

  final int id;
  final String name;
  final int? parentId;
  final List<_FolderTreeNode> children = <_FolderTreeNode>[];
}

class _DmsFilterFoldersPanel extends StatefulWidget {
  const _DmsFilterFoldersPanel({required this.dataSource});

  final DashboardRemoteDataSource dataSource;

  @override
  State<_DmsFilterFoldersPanel> createState() => _DmsFilterFoldersPanelState();
}

class _DmsFilterFoldersPanelState extends State<_DmsFilterFoldersPanel> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newFolderController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _loadError;
  String _search = '';
  List<_FolderTreeNode> _roots = <_FolderTreeNode>[];
  final Map<int, _FolderTreeNode> _byId = <int, _FolderTreeNode>{};
  final Set<int> _expandedIds = <int>{};
  int? _selectedFolderId;

  @override
  void initState() {
    super.initState();
    _newFolderController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _newFolderController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final List<Map<String, dynamic>> rows =
          await widget.dataSource.fetchDmsFolders();
      if (!mounted) {
        return;
      }
      _buildTree(rows);
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _loadError = error.toString();
      });
    }
  }

  void _buildTree(List<Map<String, dynamic>> rows) {
    _byId.clear();
    _roots = <_FolderTreeNode>[];

    for (final Map<String, dynamic> row in rows) {
      final int? id = int.tryParse(_str(row['id']));
      if (id == null) {
        continue;
      }
      final String name = _str(row['name']);
      if (name.isEmpty) {
        continue;
      }
      final int? parentId = int.tryParse(_str(row['parentId']));
      _byId[id] = _FolderTreeNode(id: id, name: name, parentId: parentId);
    }

    for (final _FolderTreeNode node in _byId.values) {
      if (node.parentId != null && _byId.containsKey(node.parentId)) {
        _byId[node.parentId!]!.children.add(node);
      } else {
        _roots.add(node);
      }
    }

    void sortNodes(List<_FolderTreeNode> nodes) {
      nodes.sort(
        ( _FolderTreeNode a, _FolderTreeNode b) => a.name.compareTo(b.name),
      );
      for (final _FolderTreeNode node in nodes) {
        sortNodes(node.children);
      }
    }

    sortNodes(_roots);

    if (_selectedFolderId != null && !_byId.containsKey(_selectedFolderId)) {
      _selectedFolderId = null;
    }
  }

  _FolderTreeNode? get _selectedFolder =>
      _selectedFolderId == null ? null : _byId[_selectedFolderId];

  bool _matchesSearch(_FolderTreeNode node) {
    if (_search.trim().isEmpty) {
      return true;
    }
    final String q = _search.trim().toLowerCase();
    if (node.name.toLowerCase().contains(q)) {
      return true;
    }
    return node.children.any(_matchesSearch);
  }

  Future<void> _addFolder() async {
    final String name = _newFolderController.text.trim();
    if (name.isEmpty) {
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.dataSource.createDmsFolder(
        name: name,
        parentId: _selectedFolderId,
      );
      if (!mounted) {
        return;
      }
      _newFolderController.clear();
      if (_selectedFolderId != null) {
        _expandedIds.add(_selectedFolderId!);
      }
      await _load();
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Add failed',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _deleteFolder(_FolderTreeNode node) async {
    await AppDialog.show(
      context: context,
      type: AppDialogType.confirmation,
      title: 'Delete Folder',
      message: 'Delete "${node.name}"?',
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Delete',
          isPrimary: true,
          onPressed: () async {
            setState(() => _saving = true);
            try {
              await widget.dataSource.deleteDmsFolder(node.id);
              if (!mounted) {
                return;
              }
              if (_selectedFolderId == node.id) {
                _selectedFolderId = null;
              }
              _expandedIds.remove(node.id);
              await _load();
            } catch (error) {
              if (!mounted) {
                return;
              }
              await AppDialog.show(
                context: context,
                title: 'Delete failed',
                message: error.toString(),
                type: AppDialogType.error,
              );
            } finally {
              if (mounted) {
                setState(() => _saving = false);
              }
            }
          },
        ),
      ],
    );
  }

  void _toggleExpanded(int id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  void _selectFolder(int? id) {
    setState(() => _selectedFolderId = id);
  }

  List<Widget> _buildFolderRows(List<_FolderTreeNode> nodes, {int depth = 0}) {
    final List<Widget> rows = <Widget>[];
    for (final _FolderTreeNode node in nodes) {
      if (!_matchesSearch(node)) {
        continue;
      }
      final bool hasChildren = node.children.isNotEmpty;
      final bool expanded = _expandedIds.contains(node.id);
      final bool selected = _selectedFolderId == node.id;

      rows.add(
        Material(
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          child: InkWell(
            onTap: () => _selectFolder(node.id),
            child: Padding(
              padding: EdgeInsets.fromLTRB(12 + depth * 18.0, 8, 8, 8),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 24,
                    child: hasChildren
                        ? IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            iconSize: 18,
                            onPressed: () => _toggleExpanded(node.id),
                            icon: Icon(
                              expanded
                                  ? Icons.keyboard_arrow_down_rounded
                                  : Icons.keyboard_arrow_right_rounded,
                            ),
                          )
                        : null,
                  ),
                  Icon(
                    Icons.folder_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      node.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (hasChildren)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${node.children.length}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  IconButton(
                    tooltip: 'Delete',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    onPressed: _saving ? null : () => _deleteFolder(node),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      if (hasChildren && (expanded || _search.trim().isNotEmpty)) {
        rows.addAll(_buildFolderRows(node.children, depth: depth + 1));
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final _FolderTreeNode? selected = _selectedFolder;
    final bool canAdd = _newFolderController.text.trim().isNotEmpty && !_saving;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.65)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search folders...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (String value) => setState(() => _search = value),
              ),
            ),
            if (selected != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'PATH:',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selected.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Clear selection',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: () => _selectFolder(null),
                          icon: const Icon(Icons.close_rounded, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _loadError != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  _loadError!,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.error,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: _load,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _roots.isEmpty
                          ? Center(
                              child: Text(
                                'No folders found.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.only(top: 8),
                              children: _buildFolderRows(_roots),
                            ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Icon(
                                Icons.create_new_folder_outlined,
                                color: cs.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _newFolderController,
                                enabled: !_saving,
                                decoration: InputDecoration(
                                  hintText: selected == null
                                      ? 'New root folder name...'
                                      : 'New sub-folder inside "${selected.name}"...',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: cs.surface,
                                ),
                                onSubmitted: (_) {
                                  if (canAdd) {
                                    _addFolder();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: canAdd ? _addFolder : null,
                              child: const Text('+ Add'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          selected == null
                              ? 'Type a name above to add a root folder. Tap a folder to add sub-folders inside it.'
                              : 'Adding inside: ${selected.name}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NamedListPanel extends StatelessWidget {
  const _NamedListPanel({
    required this.addLabel,
    required this.loading,
    required this.saving,
    required this.loadError,
    required this.searchController,
    required this.onSearchChanged,
    required this.onAdd,
    required this.onRetry,
    required this.items,
    required this.onDelete,
  });

  final String addLabel;
  final bool loading;
  final bool saving;
  final String? loadError;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAdd;
  final VoidCallback onRetry;
  final List<_NamedRecord> items;
  final ValueChanged<_NamedRecord> onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.65)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: <Widget>[
                  FilledButton(
                    onPressed: saving ? null : onAdd,
                    child: Text(addLabel),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: onSearchChanged,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              color: cs.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Name',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: Text(
                      'Action',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : loadError != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  loadError!,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.error,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: onRetry,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : items.isEmpty
                          ? Center(
                              child: Text(
                                'No records found.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (BuildContext context, int index) {
                                final _NamedRecord item = items[index];
                                final Color bg = index.isEven
                                    ? cs.primary.withValues(alpha: 0.07)
                                    : cs.surface;
                                return ColoredBox(
                                  color: bg,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Delete',
                                          onPressed: saving
                                              ? null
                                              : () => onDelete(item),
                                          icon: Icon(
                                            Icons.delete_outline_rounded,
                                            color: cs.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> _promptName({
  required BuildContext context,
  required String title,
  required String hint,
}) async {
  final TextEditingController controller = TextEditingController();
  final String? result = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (String value) =>
              Navigator.of(context).pop(value.trim()),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
  controller.dispose();
  return result;
}

String _str(dynamic value) {
  if (value == null) {
    return '';
  }
  final String text = value.toString().trim();
  return text.toLowerCase() == 'null' ? '' : text;
}
