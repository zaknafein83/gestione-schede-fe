import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api_error.dart';
import '../../../core/smart_back_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_controller.dart';
import '../../auth/data/auth_storage.dart';
import '../data/admin_api.dart';
import '../models/admin_models.dart';

/// Pannello admin: ricerca + tabella utenti + grant/revoke/delete inline.
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  int _page = 0;
  static const int _pageSize = 20;

  AdminUserPage? _data;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final access = await ref.read(authStorageProvider).loadAccess();
      if (access == null) {
        throw StateError('Not authenticated');
      }
      final page = await ref.read(adminApiProvider).listUsers(
            access,
            q: _query.isEmpty ? null : _query,
            page: _page,
            pageSize: _pageSize,
          );
      if (!mounted) return;
      setState(() {
        _data = page;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _onSearch(String value) {
    setState(() {
      _query = value.trim();
      _page = 0;
    });
    _load();
  }

  Future<void> _grant(AdminUser u) async {
    final l10n = AppL10n.of(context);
    try {
      final access = await ref.read(authStorageProvider).loadAccess();
      await ref.read(adminApiProvider).grantPremium(access!, u.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminSnackGranted(u.email))),
      );
      _load();
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminError(e.detail))),
      );
    }
  }

  Future<void> _revoke(AdminUser u) async {
    final l10n = AppL10n.of(context);
    try {
      final access = await ref.read(authStorageProvider).loadAccess();
      await ref.read(adminApiProvider).revokePremium(access!, u.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminSnackRevoked(u.email))),
      );
      _load();
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminError(e.detail))),
      );
    }
  }

  Future<void> _confirmAndDelete(AdminUser u) async {
    final l10n = AppL10n.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminDeleteConfirmTitle),
        content: Text(l10n.adminDeleteConfirmBody(u.email)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.adminDeleteConfirmNo),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.adminDeleteConfirmYes),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final access = await ref.read(authStorageProvider).loadAccess();
      await ref.read(adminApiProvider).deleteUser(access!, u.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminSnackDeleted(u.email))),
      );
      _load();
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminError(e.detail))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final me = ref.watch(authControllerProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminTitle),
        leading: smartBackButton(context, fallback: '/profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.adminSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: _onSearch,
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildBody(l10n, me?.id)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppL10n l10n, String? myId) {
    if (_loading && _data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _data == null) {
      return Center(
        child: Text(l10n.adminError(_error.toString())),
      );
    }
    final page = _data!;
    if (page.items.isEmpty) {
      return Center(child: Text(l10n.adminEmptyList));
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text(l10n.adminColEmail)),
                  DataColumn(label: Text(l10n.adminColUsername)),
                  DataColumn(label: Text(l10n.adminColDisplay)),
                  DataColumn(label: Text(l10n.adminColTier)),
                  DataColumn(label: Text(l10n.adminColRoles)),
                  DataColumn(label: Text(l10n.adminColCreated)),
                  DataColumn(label: Text(l10n.adminColActions)),
                ],
                rows: page.items.map((u) => _row(l10n, u, myId == u.id)).toList(),
              ),
            ),
          ),
        ),
        _buildPagination(l10n, page),
      ],
    );
  }

  DataRow _row(AppL10n l10n, AdminUser u, bool isSelf) {
    final dateFmt = DateFormat.yMMMd();
    return DataRow(
      cells: [
        DataCell(Text(u.email)),
        DataCell(Text(u.username)),
        DataCell(Text(u.displayName)),
        DataCell(_tierChip(u, l10n)),
        DataCell(_rolesChips(u, l10n)),
        DataCell(Text(dateFmt.format(u.createdAt.toLocal()))),
        DataCell(_actions(u, l10n, isSelf)),
      ],
    );
  }

  Widget _tierChip(AdminUser u, AppL10n l10n) {
    final scheme = Theme.of(context).colorScheme;
    final label = u.isPremium ? l10n.adminTierPremium : l10n.adminTierFree;
    return Chip(
      label: Text(label),
      backgroundColor: u.isPremium
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _rolesChips(AdminUser u, AppL10n l10n) {
    if (u.roles.isEmpty) return const Text('—');
    return Wrap(
      spacing: 4,
      children: u.roles
          .map((r) => Chip(
                label: Text(r == 'ADMIN' ? l10n.adminRoleAdmin : r),
                visualDensity: VisualDensity.compact,
              ))
          .toList(),
    );
  }

  Widget _actions(AdminUser u, AppL10n l10n, bool isSelf) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (u.isPremium)
          TextButton.icon(
            icon: const Icon(Icons.remove_circle_outline, size: 18),
            label: Text(l10n.adminActionRevoke),
            onPressed: () => _revoke(u),
          )
        else
          TextButton.icon(
            icon: const Icon(Icons.workspace_premium_outlined, size: 18),
            label: Text(l10n.adminActionGrant),
            onPressed: () => _grant(u),
          ),
        IconButton(
          tooltip: l10n.adminActionDelete,
          icon: Icon(Icons.delete_outline,
              color: isSelf
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).colorScheme.error),
          onPressed: isSelf ? null : () => _confirmAndDelete(u),
        ),
      ],
    );
  }

  Widget _buildPagination(AppL10n l10n, AdminUserPage page) {
    final from = page.items.isEmpty ? 0 : page.page * page.pageSize + 1;
    final to = page.page * page.pageSize + page.items.length;
    final hasPrev = page.page > 0;
    final hasNext = to < page.total;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(l10n.adminPaginationOf(from, to, page.total)),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: hasPrev
                ? () {
                    setState(() => _page--);
                    _load();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: hasNext
                ? () {
                    setState(() => _page++);
                    _load();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
