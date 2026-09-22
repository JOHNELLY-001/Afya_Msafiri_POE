import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/design_tokens.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/models/point_of_entry.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../data/poe_repository.dart';
import '../widgets/poe_card.dart';

/// Two-step duty-station picker, mirroring the server's own hierarchy
/// (`hierarchyStructure`: borderType → portOfEntries):
/// 1. border type (Air / Land / Lake / Sea) with live station counts,
/// 2. station within that type (searchable), e.g. JNIA under Air.
class PointOfEntryScreen extends ConsumerStatefulWidget {
  const PointOfEntryScreen({super.key});

  @override
  ConsumerState<PointOfEntryScreen> createState() => _PointOfEntryScreenState();
}

class _PointOfEntryScreenState extends ConsumerState<PointOfEntryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  PoeGroup? _selectedGroup;
  PointOfEntry? _selected;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_selected == null) return;
    ref.read(sessionProvider.notifier).selectPointOfEntry(_selected!);
    context.go(AppRoutes.dashboard);
  }

  IconData _iconFor(String groupName) {
    switch (groupName.toLowerCase()) {
      case 'air':
      case 'airports':
        return Icons.flight_outlined;
      case 'land':
        return Icons.directions_car_outlined;
      case 'lake':
        return Icons.directions_boat_outlined;
      case 'sea':
        return Icons.sailing_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(poeGroupsProvider);
    // When opened via Dashboard → Change, a station is already selected,
    // so offer an explicit way back without forcing a re-pick.
    final canGoBack =
        ref.watch(sessionProvider.select((s) => s.selectedPoe)) != null;

    final dutyLeading = _selectedGroup == null
        ? (canGoBack
            ? IconButton(
                icon: const Icon(Icons.close_outlined),
                tooltip: 'Back',
                onPressed: () => context.pop(),
              )
            : null)
        : IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            tooltip: 'Border types',
            onPressed: () => setState(() {
              _selectedGroup = null;
              _selected = null;
              _searchController.clear();
              _query = '';
            }),
          );

    return Scaffold(
      appBar: AfyaAppBar(
        title: 'Duty Station',
        subtitle: _selectedGroup == null
            ? 'Step 1 • Border type'
            : 'Step 2 • ${_selectedGroup!.name} stations',
        showBack: canGoBack || _selectedGroup != null,
        leadingOverride: dutyLeading,
        showSyncStatus: false,
      ),
      body: SafeArea(
        child: groupsAsync.when(
          loading: () => const AppLoadingState(message: 'Loading stations…'),
          error: (e, _) => AppErrorState(
            message: '$e',
            onRetry: () => ref.invalidate(poeGroupsProvider),
          ),
          data: (groups) {
            // No dummy data: empty means the device never synced stations
            // (offline on first launch or server error) — show an offline
            // empty state with retry instead of fake stations.
            if (groups.isEmpty) {
              return AppErrorState(
                icon: Icons.cloud_off_outlined,
                message:
                    'No duty stations available. Connect to the internet to sync the legitimate stations, then retry.',
                retryLabel: 'Retry sync',
                onRetry: () => ref.invalidate(poeGroupsProvider),
              );
            }
            // A single cached/live group skips straight to its stations.
            final effectiveGroup =
                groups.length == 1 ? groups.first : _selectedGroup;
            if (effectiveGroup == null) {
              return _typeStep(context, groups);
            }
            return _stationStep(context, effectiveGroup,
                showBack: groups.length > 1);
          },
        ),
      ),
    );
  }

  /// Step 1 — border type cards.
  Widget _typeStep(BuildContext context, List<PoeGroup> groups) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Where are you on duty today?', style: text.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'First choose the border type, then your station.',
          style: text.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'Border type'),
        ...groups.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () => setState(() => _selectedGroup = g),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppRadius.base),
                          ),
                          child: Icon(_iconFor(g.name),
                              color: colors.primary, size: 26),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.name, style: text.titleMedium),
                              const SizedBox(height: 2),
                              Text(
                                '${g.stations.length} stations',
                                style: text.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            color: colors.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  /// Step 2 — searchable stations within the chosen border type.
  Widget _stationStep(BuildContext context, PoeGroup group,
      {required bool showBack}) {
    final text = Theme.of(context).textTheme;
    final stations = _query.isEmpty
        ? group.stations
        : group.stations
            .where((s) => s.name.toLowerCase().contains(_query))
            .toList();
    _selected ??= stations.isNotEmpty ? stations.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_iconFor(group.name),
                      size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '${group.name} stations · ${stations.length}',
                      style: text.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppSearchField(
                controller: _searchController,
                hint: 'Search ${group.name.toLowerCase()} stations…',
                onChanged: (v) =>
                    setState(() => _query = v.trim().toLowerCase()),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: stations.isEmpty
              ? Center(
                  child: Text(
                    'No stations match "$_query".',
                    style: text.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0,
                      AppSpacing.lg, AppSpacing.md),
                  itemCount: stations.length,
                  itemBuilder: (context, i) {
                    final poe = stations[i];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: PoeCard(
                        poe: poe,
                        selected: _selected?.code == poe.code,
                        onTap: () => setState(() => _selected = poe),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            label: _selected == null
                ? 'Select a station'
                : 'Confirm · ${_selected!.name}',
            icon: Icons.check_outlined,
            // Disabled until a station is picked (was silently no-op).
            onPressed: _selected == null ? null : _continue,
          ),
        ),
      ],
    );
  }
}
