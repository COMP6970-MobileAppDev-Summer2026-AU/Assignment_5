// =============================================================================
// screens/park_detail_screen.dart
// Full park detail: image gallery, map, description, activities, hours, fees
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/park_model.dart';

class ParkDetailScreen extends StatefulWidget {
  final ParkModel park;

  const ParkDetailScreen({super.key, required this.park});

  @override
  State<ParkDetailScreen> createState() => _ParkDetailScreenState();
}

class _ParkDetailScreenState extends State<ParkDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController  _tabCtrl;
  late PageController _pageCtrl;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl  = TabController(length: 4, vsync: this);
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _prevImage() {
    if (_imageIndex > 0) {
      _pageCtrl.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    }
  }

  void _nextImage(int total) {
    if (_imageIndex < total - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final park   = widget.park;
    final scheme = Theme.of(context).colorScheme;
    final lat    = double.tryParse(park.latitude  ?? '');
    final lng    = double.tryParse(park.longitude ?? '');
    final hasMap = lat != null && lng != null;
    final total  = park.images.length;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Image PageView ──────────────────────────────────
                  if (park.images.isNotEmpty)
                    PageView.builder(
                      controller: _pageCtrl,
                      itemCount: total,
                      onPageChanged: (i) =>
                          setState(() => _imageIndex = i),
                      itemBuilder: (_, i) => CachedNetworkImage(
                        imageUrl: park.images[i].url,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                            color: scheme.primaryContainer),
                        errorWidget: (_, __, ___) => Container(
                            color: scheme.primaryContainer,
                            child: Icon(Icons.landscape_outlined,
                                color: scheme.primary, size: 48)),
                      ),
                    )
                  else
                    Container(
                      color: scheme.primaryContainer,
                      child: Icon(Icons.landscape_outlined,
                          color: scheme.primary, size: 64),
                    ),

                  // Bottom gradient
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // ── Prev / Next arrow buttons ───────────────────────
                  if (total > 1) ...[
                    Positioned(
                      left: 8, top: 0, bottom: 0,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _imageIndex > 0 ? 1.0 : 0.25,
                          duration: const Duration(milliseconds: 200),
                          child: _ArrowButton(
                            icon: Icons.chevron_left_rounded,
                            onTap: _prevImage,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8, top: 0, bottom: 0,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _imageIndex < total - 1 ? 1.0 : 0.25,
                          duration: const Duration(milliseconds: 200),
                          child: _ArrowButton(
                            icon: Icons.chevron_right_rounded,
                            onTap: () => _nextImage(total),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ── Dot indicators + counter ────────────────────────
                  if (total > 1)
                    Positioned(
                      bottom: 12, left: 0, right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(total, (i) {
                              return AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 3),
                                width:  _imageIndex == i ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _imageIndex == i
                                      ? Colors.white
                                      : Colors.white54,
                                  borderRadius:
                                  BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_imageIndex + 1} / $total',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Park name + meta ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(park.fullName,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 15, color: scheme.primary),
                      const SizedBox(width: 4),
                      Text(park.stateLabel,
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 10),
                      if (park.designation.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(park.designation,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Tab bar ──────────────────────────────────────────────────
            TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Activities'),
                Tab(text: 'Hours & Fees'),
                Tab(text: 'Map'),
              ],
            ),

            // ── Tab content ──────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _OverviewTab(park: park),
                  _ActivitiesTab(park: park),
                  _HoursFeesTab(park: park),
                  _MapTab(lat: lat, lng: lng, hasMap: hasMap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Tab: Overview
// =============================================================================

class _OverviewTab extends StatelessWidget {
  final ParkModel park;
  const _OverviewTab({required this.park});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Description
        const Text('About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          park.description.isNotEmpty
              ? park.description
              : 'No description available.',
          style: const TextStyle(fontSize: 15, height: 1.6),
        ),

        if (park.weatherInfo != null && park.weatherInfo!.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(icon: Icons.wb_sunny_outlined, title: 'Weather'),
          const SizedBox(height: 8),
          Text(park.weatherInfo!,
              style: const TextStyle(fontSize: 15, height: 1.6)),
        ],

        if (park.directionsInfo != null &&
            park.directionsInfo!.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(
              icon: Icons.directions_outlined, title: 'Getting There'),
          const SizedBox(height: 8),
          Text(park.directionsInfo!,
              style: const TextStyle(fontSize: 15, height: 1.6)),
        ],

        if (park.topics.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(icon: Icons.label_outline, title: 'Topics'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: park.topics
                .map((t) => _Chip(label: t.name))
                .toList(),
          ),
        ],

        if (park.url != null && park.url!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.language_outlined,
                  size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text(park.url!,
                  style: const TextStyle(
                      color: Colors.blue, fontSize: 13)),
            ],
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}

// =============================================================================
// Tab: Activities
// =============================================================================

class _ActivitiesTab extends StatelessWidget {
  final ParkModel park;
  const _ActivitiesTab({required this.park});

  @override
  Widget build(BuildContext context) {
    if (park.activities.isEmpty) {
      return const _EmptyTab(
          icon: Icons.hiking_outlined,
          message: 'No activities listed for this park.');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('${park.activities.length} Activities',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: park.activities
              .map((a) => _ActivityChip(name: a.name))
              .toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// =============================================================================
// Tab: Hours & Fees
// =============================================================================

class _HoursFeesTab extends StatelessWidget {
  final ParkModel park;
  const _HoursFeesTab({required this.park});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Entrance fees
        _SectionHeader(
            icon: Icons.attach_money_outlined, title: 'Entrance Fees'),
        const SizedBox(height: 12),
        if (park.entranceFees.isEmpty)
          const Text('No entrance fee information available.')
        else
          ...park.entranceFees.map((fee) => _FeeCard(fee: fee)),

        const SizedBox(height: 24),

        // Operating hours
        _SectionHeader(
            icon: Icons.access_time_outlined, title: 'Operating Hours'),
        const SizedBox(height: 12),
        if (park.operatingHours.isEmpty)
          const Text('No operating hours information available.')
        else
          ...park.operatingHours.map((h) => _HoursCard(hour: h)),

        const SizedBox(height: 32),
      ],
    );
  }
}

// =============================================================================
// Tab: Map
// =============================================================================

class _MapTab extends StatefulWidget {
  final double? lat;
  final double? lng;
  final bool    hasMap;

  const _MapTab({
    required this.lat,
    required this.lng,
    required this.hasMap,
  });

  @override
  State<_MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<_MapTab> {
  final MapController _mapCtrl = MapController();
  double _zoom = 9;

  static const double _minZoom = 3;
  static const double _maxZoom = 18;
  static const double _zoomStep = 1;

  void _zoomIn() {
    if (_zoom < _maxZoom) {
      setState(() => _zoom = (_zoom + _zoomStep).clamp(_minZoom, _maxZoom));
      _mapCtrl.move(_mapCtrl.camera.center, _zoom);
    }
  }

  void _zoomOut() {
    if (_zoom > _minZoom) {
      setState(() => _zoom = (_zoom - _zoomStep).clamp(_minZoom, _maxZoom));
      _mapCtrl.move(_mapCtrl.camera.center, _zoom);
    }
  }

  void _resetView() {
    setState(() => _zoom = 9);
    _mapCtrl.move(LatLng(widget.lat!, widget.lng!), 9);
  }

  /// Launch directions in Google Maps, Apple Maps, or fallback browser
  Future<void> _launchDirections(BuildContext context) async {
    final lat = widget.lat!;
    final lng = widget.lng!;

    // Show app picker sheet
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DirectionPickerSheet(lat: lat, lng: lng),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hasMap) {
      return const _EmptyTab(
          icon: Icons.map_outlined,
          message: 'Map location is not available for this park.');
    }

    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: Icons.location_pin, title: 'Location'),
          const SizedBox(height: 8),
          Text(
            '${widget.lat!.toStringAsFixed(4)}°N, '
                '${widget.lng!.toStringAsFixed(4)}°W',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 12),

          // ── Map with zoom controls overlay ──────────────────────────
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Map
                  FlutterMap(
                    mapController: _mapCtrl,
                    options: MapOptions(
                      initialCenter: LatLng(widget.lat!, widget.lng!),
                      initialZoom: _zoom,
                      minZoom: _minZoom,
                      maxZoom: _maxZoom,
                      onMapEvent: (event) {
                        // Keep zoom state in sync when user pinches
                        if (event is MapEventMove) {
                          setState(() => _zoom = event.camera.zoom);
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.nationalparks',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(widget.lat!, widget.lng!),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // ── Zoom + Reset controls ─────────────────────────
                  Positioned(
                    right: 12,
                    bottom: 24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Zoom In
                        _MapButton(
                          icon: Icons.add,
                          onTap: _zoomIn,
                          enabled: _zoom < _maxZoom,
                          scheme: scheme,
                        ),
                        const SizedBox(height: 2),
                        // Zoom level indicator
                        Container(
                          width: 40,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          color: Colors.white,
                          child: Text(
                            '${_zoom.toStringAsFixed(0)}x',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Zoom Out
                        _MapButton(
                          icon: Icons.remove,
                          onTap: _zoomOut,
                          enabled: _zoom > _minZoom,
                          scheme: scheme,
                        ),
                        const SizedBox(height: 8),
                        // Reset / re-center button
                        _MapButton(
                          icon: Icons.my_location,
                          onTap: _resetView,
                          enabled: true,
                          scheme: scheme,
                        ),
                      ],
                    ),
                  ),

                  // ── Attribution ────────────────────────────────────
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '© OpenStreetMap contributors',
                        style: TextStyle(fontSize: 9, color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Get Directions button ───────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              onPressed: () => _launchDirections(context),
              icon: const Icon(Icons.directions_rounded, size: 22),
              label: const Text(
                'Get Directions',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Direction picker sheet ────────────────────────────────────────────────────

class _DirectionPickerSheet extends StatelessWidget {
  final double lat;
  final double lng;

  const _DirectionPickerSheet({required this.lat, required this.lng});

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (context.mounted) Navigator.pop(context);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App not available on this device'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // URL schemes for each app
    final googleUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
    final appleMapsUrl =
        'http://maps.apple.com/?daddr=$lat,$lng&dirflg=d';
    final wazeUrl =
        'https://waze.com/ul?ll=$lat,$lng&navigate=yes';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Icon(Icons.directions_car_rounded,
                  color: scheme.primary, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Get Directions via',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Choose your preferred maps app',
            style: TextStyle(
                color: Colors.grey.shade500, fontSize: 13),
          ),

          const SizedBox(height: 20),

          // Google Maps
          _AppOption(
            icon: Icons.map_rounded,
            iconColor: const Color(0xFF4285F4),
            label: 'Google Maps',
            subtitle: 'Opens in Google Maps with driving directions',
            onTap: () => _open(context, googleUrl),
          ),

          const SizedBox(height: 10),

          // Apple Maps (iOS)
          _AppOption(
            icon: Icons.map_outlined,
            iconColor: const Color(0xFF34AADC),
            label: 'Apple Maps',
            subtitle: 'Opens in Apple Maps with driving directions',
            onTap: () => _open(context, appleMapsUrl),
          ),

          const SizedBox(height: 10),

          // Waze
          _AppOption(
            icon: Icons.navigation_rounded,
            iconColor: const Color(0xFF33CCFF),
            label: 'Waze',
            subtitle: 'Opens in Waze with live traffic navigation',
            onTap: () => _open(context, wazeUrl),
          ),

          const SizedBox(height: 12),

          // Coordinates display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.location_pin,
                    color: scheme.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${lat.toStringAsFixed(5)}°N, '
                      '${lng.toStringAsFixed(5)}°W',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppOption extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   label;
  final String   subtitle;
  final VoidCallback onTap;

  const _AppOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ── Map control button ────────────────────────────────────────────────────────

class _MapButton extends StatelessWidget {
  final IconData    icon;
  final VoidCallback onTap;
  final bool        enabled;
  final ColorScheme scheme;

  const _MapButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? Colors.black87 : Colors.grey.shade300,
        ),
      ),
    );
  }
}

// =============================================================================
// Shared helper widgets
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String   title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20,
            color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              color: scheme.primary,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _ActivityChip extends StatelessWidget {
  final String name;
  const _ActivityChip({required this.name});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline,
              size: 14, color: scheme.primary),
          const SizedBox(width: 6),
          Text(name,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _FeeCard extends StatelessWidget {
  final EntranceFee fee;
  const _FeeCard({required this.fee});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fee.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600)),
                if (fee.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(fee.description,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '\$${fee.cost}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoursCard extends StatelessWidget {
  final OperatingHour hour;
  const _HoursCard({required this.hour});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hour.name.isNotEmpty)
            Text(hour.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          if (hour.name.isNotEmpty) const SizedBox(height: 4),
          Text(hour.description,
              style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final IconData icon;
  final String   message;
  const _EmptyTab({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// =============================================================================
// Arrow button for image gallery navigation
// =============================================================================

class _ArrowButton extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}