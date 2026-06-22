// =============================================================================
// screens/park_results_screen.dart
// 3 view modes: Grid / List / Compact — toggled via AppBar icon
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/nationalparks_provider.dart';
import '../widgets/park_card.dart';
import 'park_detail_screen.dart';

class ParkResultsScreen extends StatefulWidget {
  const ParkResultsScreen({super.key});

  @override
  State<ParkResultsScreen> createState() => _ParkResultsScreenState();
}

class _ParkResultsScreenState extends State<ParkResultsScreen> {
  ParkViewMode _viewMode = ParkViewMode.grid;

  void _cycleView() {
    HapticFeedback.lightImpact();
    setState(() {
      _viewMode = switch (_viewMode) {
        ParkViewMode.grid    => ParkViewMode.list,
        ParkViewMode.list    => ParkViewMode.compact,
        ParkViewMode.compact => ParkViewMode.grid,
      };
    });
  }

  IconData get _viewIcon => switch (_viewMode) {
    ParkViewMode.grid    => Icons.view_list_rounded,
    ParkViewMode.list    => Icons.view_agenda_outlined,
    ParkViewMode.compact => Icons.grid_view_rounded,
  };

  String get _viewTooltip => switch (_viewMode) {
    ParkViewMode.grid    => 'Switch to List',
    ParkViewMode.list    => 'Switch to Compact',
    ParkViewMode.compact => 'Switch to Grid',
  };

  String get _viewLabel => switch (_viewMode) {
    ParkViewMode.grid    => 'Grid',
    ParkViewMode.list    => 'List',
    ParkViewMode.compact => 'Compact',
  };

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<NationalParksProvider>();
    final parks  = prov.parks;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${prov.selectedState} — Parks',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 17)),
            Text('${parks.length} result${parks.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          // View mode toggle button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Tooltip(
              message: _viewTooltip,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: scheme.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor:
                  scheme.primaryContainer.withValues(alpha: 0.4),
                ),
                onPressed: _cycleView,
                icon: Icon(_viewIcon, size: 18),
                label: Text(_viewLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search parks…',
                suffixIcon: prov.searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => context
                      .read<NationalParksProvider>()
                      .setSearch(''),
                )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                isDense: true,
              ),
              onChanged: (v) =>
                  context.read<NationalParksProvider>().setSearch(v),
            ),
          ),

          // ── Designation filter chips ───────────────────────────────────
          if (prov.designations.length > 1) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: prov.filterDesignation == null,
                    onTap: () => context
                        .read<NationalParksProvider>()
                        .setFilterDesignation(null),
                  ),
                  ...prov.designations.map((d) => _FilterChip(
                    label: d,
                    selected: prov.filterDesignation == d,
                    onTap: () => context
                        .read<NationalParksProvider>()
                        .setFilterDesignation(d),
                  )),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),

          // ── Results ─────────────────────────────────────────────────────
          Expanded(
            child: parks.isEmpty
                ? _emptyState(context, prov)
                : _viewMode == ParkViewMode.grid
                ? GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: parks.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (_, i) => ParkCard(
                park: parks[i],
                viewMode: _viewMode,
                onTap: () => _openDetail(context, parks[i]),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: parks.length,
              itemBuilder: (_, i) => ParkCard(
                park: parks[i],
                viewMode: _viewMode,
                onTap: () => _openDetail(context, parks[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, park) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParkDetailScreen(park: park),
      ),
    );
  }

  Widget _emptyState(BuildContext context, NationalParksProvider prov) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.landscape_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No parks found',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            prov.searchQuery.isNotEmpty
                ? 'No parks match "${prov.searchQuery}"'
                : 'No parks found for ${prov.selectedState}',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          if (prov.searchQuery.isNotEmpty ||
              prov.filterDesignation != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () =>
                  context.read<NationalParksProvider>().clearFilter(),
              icon: const Icon(Icons.refresh),
              label: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String       label;
  final bool         selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary
              : scheme.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: selected ? Colors.white : scheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}