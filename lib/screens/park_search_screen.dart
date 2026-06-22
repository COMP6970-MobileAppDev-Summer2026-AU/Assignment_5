// =============================================================================
// screens/park_search_screen.dart
// State picker + search button — navigates to results on success
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nationalparks_provider.dart';
import 'park_results_screen.dart';

class ParkSearchScreen extends StatefulWidget {
  const ParkSearchScreen({super.key});

  @override
  State<ParkSearchScreen> createState() => _ParkSearchScreenState();
}

class _ParkSearchScreenState extends State<ParkSearchScreen> {
  String _selectedState = 'CA';

  // Full US state map: code → full name
  static const Map<String, String> _states = {
    'AL': 'Alabama',       'AK': 'Alaska',         'AZ': 'Arizona',
    'AR': 'Arkansas',      'CA': 'California',     'CO': 'Colorado',
    'CT': 'Connecticut',   'DE': 'Delaware',        'FL': 'Florida',
    'GA': 'Georgia',       'HI': 'Hawaii',          'ID': 'Idaho',
    'IL': 'Illinois',      'IN': 'Indiana',         'IA': 'Iowa',
    'KS': 'Kansas',        'KY': 'Kentucky',        'LA': 'Louisiana',
    'ME': 'Maine',         'MD': 'Maryland',        'MA': 'Massachusetts',
    'MI': 'Michigan',      'MN': 'Minnesota',       'MS': 'Mississippi',
    'MO': 'Missouri',      'MT': 'Montana',         'NE': 'Nebraska',
    'NV': 'Nevada',        'NH': 'New Hampshire',   'NJ': 'New Jersey',
    'NM': 'New Mexico',    'NY': 'New York',        'NC': 'North Carolina',
    'ND': 'North Dakota',  'OH': 'Ohio',            'OK': 'Oklahoma',
    'OR': 'Oregon',        'PA': 'Pennsylvania',    'RI': 'Rhode Island',
    'SC': 'South Carolina','SD': 'South Dakota',    'TN': 'Tennessee',
    'TX': 'Texas',         'UT': 'Utah',            'VT': 'Vermont',
    'VA': 'Virginia',      'WA': 'Washington',      'WV': 'West Virginia',
    'WI': 'Wisconsin',     'WY': 'Wyoming',
  };

  // Popular parks states shown as quick chips
  static const List<String> _popular = [
    'CA', 'WY', 'UT', 'CO', 'AZ', 'MT', 'WA', 'FL', 'AK', 'HI',
  ];

  Future<void> _search() async {
    final prov      = context.read<NationalParksProvider>();
    final navigator = Navigator.of(context);

    await prov.fetchParksByState(_selectedState);

    if (!mounted) return;

    if (prov.errorMessage == null) {
      navigator.push(
        MaterialPageRoute(builder: (_) => const ParkResultsScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.errorMessage!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<NationalParksProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find National Parks'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero text ──────────────────────────────────────────────
              Text(
                'Explore by State',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary),
              ),
              const SizedBox(height: 4),
              Text(
                'Select a US state to discover national parks, monuments, and recreation areas.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),

              const SizedBox(height: 28),

              // ── State dropdown ─────────────────────────────────────────
              const Text('Select State',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: scheme.outline.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(14),
                  color: scheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedState,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: scheme.primary),
                    items: _states.entries.map((e) {
                      return DropdownMenuItem<String>(
                        value: e.key,
                        child: Text('${e.key} — ${e.value}'),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => _selectedState = v!),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Popular states quick pick ──────────────────────────────
              const Text('Popular States',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popular.map((code) {
                  final selected = _selectedState == code;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedState = code),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? scheme.primary
                            : scheme.primaryContainer
                                .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? scheme.primary
                              : scheme.outline
                                  .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '$code — ${_states[code]}',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : scheme.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 36),

              // ── Search button ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  onPressed: prov.isLoading ? null : _search,
                  icon: prov.isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white))
                      : const Icon(Icons.search_rounded),
                  label: Text(
                    prov.isLoading
                        ? 'Loading parks…'
                        : 'Search Parks in $_selectedState',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Error message ──────────────────────────────────────────
              if (prov.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade400, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(prov.errorMessage!,
                            style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
