// =============================================================================
// providers/nationalparks_provider.dart
// Shared state: parks list, loading, error, search filter, intro pages
// =============================================================================

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/park_model.dart';
import '../services/park_service.dart';

enum LoadingState { idle, loading, success, error }

class NationalParksProvider extends ChangeNotifier {
  final ParkService _service = ParkService();

  // ── State ─────────────────────────────────────────────────────────────────
  LoadingState loadingState = LoadingState.idle;
  List<ParkModel> _parks    = [];
  String? errorMessage;
  String  selectedState     = 'CA';
  String  searchQuery       = '';
  String? _filterDesignation;

  // ── Intro pages ───────────────────────────────────────────────────────────
  List<IntroPage> introPages = [];

  // ── Computed ──────────────────────────────────────────────────────────────
  List<ParkModel> get parks {
    var result = List<ParkModel>.from(_parks);

    // Filter by designation if set
    if (_filterDesignation != null && _filterDesignation!.isNotEmpty) {
      result = result
          .where((p) => p.designation == _filterDesignation)
          .toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where((p) =>
              p.fullName.toLowerCase().contains(q) ||
              p.designation.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q))
          .toList();
    }

    return result;
  }

  /// All unique designations in the current result set
  List<String> get designations {
    final d = _parks.map((p) => p.designation).toSet().toList();
    d.sort();
    return d;
  }

  String? get filterDesignation => _filterDesignation;

  bool get isLoading => loadingState == LoadingState.loading;

  // ── Actions ───────────────────────────────────────────────────────────────
  Future<void> fetchParksByState(String stateCode) async {
    selectedState    = stateCode;
    loadingState     = LoadingState.loading;
    errorMessage     = null;
    searchQuery      = '';
    _filterDesignation = null;
    notifyListeners();

    try {
      _parks      = await _service.fetchParksByState(stateCode);
      loadingState = LoadingState.success;
    } catch (e) {
      errorMessage = 'Failed to load parks. Please check your connection.';
      loadingState = LoadingState.error;
    }

    notifyListeners();
  }

  void setSearch(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setFilterDesignation(String? designation) {
    _filterDesignation = designation;
    notifyListeners();
  }

  void clearFilter() {
    _filterDesignation = null;
    searchQuery        = '';
    notifyListeners();
  }

  // ── Intro pages ───────────────────────────────────────────────────────────
  void loadIntroPages() {
    if (introPages.isNotEmpty) return;

    const captions = [
      ("Discover America's Wild Places",    "Explore hundreds of national parks across every state"),
      ("Plan Your Perfect Park Day",        "Find activities, operating hours, and entrance fees"),
      ("Navigate with Confidence",          "Interactive maps show you exactly where each park is"),
      ("Start Exploring Today",             "Search by state and find parks waiting to be discovered"),
    ];

    final imagePaths = List.generate(15, (i) => 'assets/images/${i + 1}.jpg')
      ..shuffle(Random());

    introPages = List.generate(4, (i) => IntroPage(
      imagePath: imagePaths[i],
      caption:   captions[i].$1,
      subtitle:  captions[i].$2,
    ));

    notifyListeners();
  }
}
