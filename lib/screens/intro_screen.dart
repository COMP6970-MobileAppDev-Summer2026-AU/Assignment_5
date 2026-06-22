// =============================================================================
// screens/intro_screen.dart
// App landing — mirrors JAJI Assignment 2/3 home screen style
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nationalparks_provider.dart';
import 'park_search_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _scaleAnim;
  final PageController     _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NationalParksProvider>().loadIntroPages();
      _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _goToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ParkSearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<NationalParksProvider>();
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _goToSearch,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer,
              scheme.primaryContainer.withValues(alpha: 0.5),
              Colors.white.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // ── Park photo carousel ──────────────────────────
                      if (prov.introPages.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            height: 220,
                            child: Stack(
                              children: [
                                PageView.builder(
                                  controller: _pageCtrl,
                                  itemCount: prov.introPages.length,
                                  onPageChanged: (i) =>
                                      setState(() => _currentPage = i),
                                  itemBuilder: (_, i) => Image.asset(
                                    prov.introPages[i].imagePath,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                                // Dot indicator
                                Positioned(
                                  bottom: 10, left: 0, right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      prov.introPages.length,
                                      (i) => AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.symmetric(horizontal: 3),
                                        width:  _currentPage == i ? 20 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _currentPage == i
                                              ? Colors.white
                                              : Colors.white54,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Caption
                        Text(
                          prov.introPages[_currentPage].caption,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: scheme.primary),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          prov.introPages[_currentPage].subtitle,
                          style: TextStyle(
                              fontSize: 13,
                              color: scheme.primary.withValues(alpha: 0.7)),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Developer card ───────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: scheme.primary.withValues(alpha: 0.3),
                              width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.person_outline,
                                color: scheme.primary, size: 26),
                            const SizedBox(height: 6),
                            const Text('Developed by',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            Text('Jahidul Arafat',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: scheme.primary)),
                            const SizedBox(height: 6),
                            _infoRow(context, Icons.school_outlined,
                                'PhD Student, Dept. of Computer Science & Software Engineering'),
                            _infoRow(context, Icons.star_outline,
                                'Presidential & Woltosz Graduate Research Fellow'),
                            _infoRow(context, Icons.work_outline,
                                'Former L3 Senior Solution Architect (MLOps), Oracle (Singapore)'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── App info card ────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text('About This App',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _appInfoRow('App',        'National Parks Explorer'),
                            _appInfoRow('Course',     'COMP 6910 — Mobile App Development'),
                            _appInfoRow('Module',     'M4 — Remote Data & APIs'),
                            _appInfoRow('Assignment', 'Assignment 4'),
                            _appInfoRow('API',        'NPS Developer API'),
                            _appInfoRow('Track',      'Flutter / Dart'),
                            _appInfoRow('Version',    '1.0.0'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Enter button ─────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.explore, color: Colors.white),
                            SizedBox(width: 10),
                            Text('Start Exploring',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Text('Tap anywhere to continue',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 15, color: primary.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Expanded(child: Text(text,
              style: const TextStyle(fontSize: 12, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _appInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
          Flexible(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
