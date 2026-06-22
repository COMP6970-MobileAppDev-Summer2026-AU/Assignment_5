// =============================================================================
// widgets/park_card.dart
// 3 view modes: grid (default), list, compact
// =============================================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/park_model.dart';

enum ParkViewMode { grid, list, compact }

class ParkCard extends StatelessWidget {
  final ParkModel     park;
  final VoidCallback  onTap;
  final ParkViewMode  viewMode;

  const ParkCard({
    super.key,
    required this.park,
    required this.onTap,
    this.viewMode = ParkViewMode.grid,
  });

  @override
  Widget build(BuildContext context) {
    return switch (viewMode) {
      ParkViewMode.grid    => _buildGrid(context),
      ParkViewMode.list    => _buildList(context),
      ParkViewMode.compact => _buildCompact(context),
    };
  }

  // ── Grid ─────────────────────────────────────────────────────────────────
  Widget _buildGrid(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _networkImage(scheme, fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(park.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  _stateRow(scheme),
                  if (park.designation.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _designationBadge(scheme),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── List ─────────────────────────────────────────────────────────────────
  Widget _buildList(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Row(
          children: [
            // Image on left
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft:     Radius.circular(14),
                bottomLeft:  Radius.circular(14),
              ),
              child: SizedBox(
                width: 110,
                height: 110,
                child: _networkImage(scheme, fit: BoxFit.cover),
              ),
            ),
            // Info on right
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(park.fullName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    _stateRow(scheme),
                    if (park.designation.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _designationBadge(scheme),
                    ],
                    if (park.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        park.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            height: 1.4),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  // ── Compact ───────────────────────────────────────────────────────────────
  Widget _buildCompact(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade200)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              // Small thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 52, height: 44,
                  child: _networkImage(scheme, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(park.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 3),
                    // State + designation in separate lines to avoid overflow
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 12, color: scheme.primary),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(park.stateLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600)),
                        ),
                      ],
                    ),
                    if (park.designation.isNotEmpty)
                      Text(
                        park.designation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            color: scheme.primary,
                            fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────
  Widget _networkImage(ColorScheme scheme, {required BoxFit fit}) {
    if (park.primaryImageUrl != null) {
      return CachedNetworkImage(
        imageUrl: park.primaryImageUrl!,
        width: double.infinity,
        fit: fit,
        placeholder: (_, __) => _placeholder(scheme),
        errorWidget: (_, __, ___) => _placeholder(scheme),
      );
    }
    return _placeholder(scheme);
  }

  Widget _placeholder(ColorScheme scheme) => Container(
    color: scheme.primaryContainer,
    child: Center(
      child: Icon(Icons.landscape_outlined,
          color: scheme.primary, size: 28),
    ),
  );

  Widget _stateRow(ColorScheme scheme) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.location_on_outlined,
          size: 12, color: scheme.primary),
      const SizedBox(width: 3),
      Flexible(
        child: Text(
          park.stateLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ),
    ],
  );

  Widget _designationBadge(ColorScheme scheme) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: scheme.primaryContainer.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      park.designation,
      style: TextStyle(
          fontSize: 10,
          color: scheme.primary,
          fontWeight: FontWeight.w500),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}