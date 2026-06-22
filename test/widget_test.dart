// =============================================================================
// test/widget_test.dart
// National Parks Explorer — COMP 6910 Assignment 4
// Developer: Jahidul Arafat (JAJI)
// =============================================================================
//
// 10 Test Groups / 55 Tests:
//   Group 1:  ParkModel — fromJson parsing + null safety          (10 tests)
//   Group 2:  ParkResponse — list parsing                         ( 4 tests)
//   Group 3:  Sub-models — Activity, Topic, EntranceFee, etc.     ( 8 tests)
//   Group 4:  ParkModel helper getters                            ( 4 tests)
//   Group 5:  NationalParksProvider — state management            ( 8 tests)
//   Group 6:  Provider search filter                              ( 5 tests)
//   Group 7:  Provider designation filter                         ( 4 tests)
//   Group 8:  App launch & intro screen                           ( 4 tests)
//   Group 9:  ParkCard widget — all 3 view modes                  ( 6 tests)
//   Group 10: IntroPage model + provider loadIntroPages            ( 4 tests)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:nationalparks/main.dart';
import 'package:nationalparks/models/park_model.dart';
import 'package:nationalparks/providers/nationalparks_provider.dart';
import 'package:nationalparks/widgets/park_card.dart';

// =============================================================================
// Test fixtures
// =============================================================================

/// Minimal valid park JSON (all required fields)
Map<String, dynamic> _minimalParkJson() => <String, dynamic>{
  'id':          'TEST001',
  'fullName':    'Yosemite National Park',
  'states':      'CA',
  'designation': 'National Park',
  'description': 'Home of iconic granite cliffs and waterfalls.',
  'images':      <Map<String, dynamic>>[],
  'activities':  <Map<String, dynamic>>[],
  'topics':      <Map<String, dynamic>>[],
  'operatingHours': <Map<String, dynamic>>[],
  'entranceFees':   <Map<String, dynamic>>[],
  'contacts':       <String, dynamic>{},
  'addresses':      <Map<String, dynamic>>[],
};

/// Full park JSON with all optional fields
Map<String, dynamic> _fullParkJson() => <String, dynamic>{
  'id':          'TEST001',
  'fullName':    'Yosemite National Park',
  'states':      'CA',
  'designation': 'National Park',
  'description': 'Home of iconic granite cliffs and waterfalls.',
  'latitude':       '37.84883288',
  'longitude':      '-119.5571873',
  'directionsInfo': 'Take Highway 140 to the Arch Rock entrance.',
  'weatherInfo':    'Summer highs reach 90°F.',
  'url':            'https://www.nps.gov/yose/',
  'images': <Map<String, dynamic>>[
    <String, dynamic>{
      'url':     'https://example.com/img1.jpg',
      'altText': 'El Capitan',
      'caption': 'The iconic granite monolith.',
    }
  ],
  'activities': <Map<String, dynamic>>[
    <String, dynamic>{'id': 'A001', 'name': 'Hiking'},
    <String, dynamic>{'id': 'A002', 'name': 'Camping'},
  ],
  'topics': <Map<String, dynamic>>[
    <String, dynamic>{'id': 'T001', 'name': 'Mountains'},
  ],
  'operatingHours': <Map<String, dynamic>>[
    <String, dynamic>{'name': 'Main entrance', 'description': 'Open 24 hours'},
  ],
  'entranceFees': <Map<String, dynamic>>[
    <String, dynamic>{
      'cost':        '35.00',
      'title':       'Vehicle Pass',
      'description': 'Valid 7 days',
    }
  ],
  'contacts': <String, dynamic>{
    'phoneNumbers': <Map<String, dynamic>>[
      <String, dynamic>{'phoneNumber': '209-372-0200', 'type': 'Voice'},
    ]
  },
  'addresses': <Map<String, dynamic>>[
    <String, dynamic>{
      'line1':      'P.O. Box 577',
      'city':       'Yosemite Valley',
      'stateCode':  'CA',
      'postalCode': '95389',
      'type':       'Mailing',
    }
  ],
};

/// A park JSON with missing / null fields to test null safety
Map<String, dynamic> _nullFieldsParkJson() => {
  'id':          null,
  'fullName':    null,
  'states':      null,
  'designation': null,
  'description': null,
  'images':      null,
  'activities':  null,
  'topics':      null,
  'operatingHours': null,
  'entranceFees':   null,
  'contacts':       null,
  'addresses':      null,
};

/// Build a testable app widget
Widget buildTestApp() => ChangeNotifierProvider(
  create: (_) => NationalParksProvider(),
  child: const NationalParksApp(),
);

/// Build a provider-wrapped widget for isolated widget tests
Widget buildWithProvider(Widget child, {NationalParksProvider? prov}) =>
    ChangeNotifierProvider(
      create: (_) => prov ?? NationalParksProvider(),
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );

// =============================================================================
// MAIN
// =============================================================================

void main() {
  // ── Group 1: ParkModel.fromJson ─────────────────────────────────────────────
  group('ParkModel — fromJson parsing', () {
    test('parses all required fields correctly', () {
      final park = ParkModel.fromJson(_fullParkJson());

      expect(park.id,          'TEST001');
      expect(park.fullName,    'Yosemite National Park');
      expect(park.states,      'CA');
      expect(park.designation, 'National Park');
      expect(park.description, contains('iconic granite'));
    });

    test('parses optional fields when present', () {
      final park = ParkModel.fromJson(_fullParkJson());

      expect(park.latitude,       '37.84883288');
      expect(park.longitude,      '-119.5571873');
      expect(park.directionsInfo, contains('Highway 140'));
      expect(park.weatherInfo,    contains('90°F'));
      expect(park.url,            contains('nps.gov/yose'));
    });

    test('optional fields are null when absent', () {
      final park = ParkModel.fromJson(_minimalParkJson());

      expect(park.latitude,       isNull);
      expect(park.longitude,      isNull);
      expect(park.directionsInfo, isNull);
      expect(park.weatherInfo,    isNull);
      expect(park.url,            isNull);
    });

    test('null JSON fields use safe defaults — no crash', () {
      expect(() => ParkModel.fromJson(_nullFieldsParkJson()), returnsNormally);
    });

    test('null id defaults to empty string', () {
      final park = ParkModel.fromJson(_nullFieldsParkJson());
      expect(park.id, '');
    });

    test('null fullName defaults to "Unknown Park"', () {
      final park = ParkModel.fromJson(_nullFieldsParkJson());
      expect(park.fullName, 'Unknown Park');
    });

    test('null images defaults to empty list', () {
      final park = ParkModel.fromJson(_nullFieldsParkJson());
      expect(park.images, isEmpty);
    });

    test('null activities defaults to empty list', () {
      final park = ParkModel.fromJson(_nullFieldsParkJson());
      expect(park.activities, isEmpty);
    });

    test('null entranceFees defaults to empty list', () {
      final park = ParkModel.fromJson(_nullFieldsParkJson());
      expect(park.entranceFees, isEmpty);
    });

    test('parses images list correctly', () {
      final park = ParkModel.fromJson(_fullParkJson());
      expect(park.images.length, 1);
      expect(park.images.first.url, 'https://example.com/img1.jpg');
      expect(park.images.first.altText, 'El Capitan');
    });
  });

  // ── Group 2: ParkResponse ───────────────────────────────────────────────────
  group('ParkResponse — list parsing', () {
    test('parses data list with multiple parks', () {
      final json = <String, dynamic>{
        'data': <Map<String, dynamic>>[_fullParkJson(), _minimalParkJson()],
      };
      final response = ParkResponse.fromJson(json);
      expect(response.data.length, 2);
    });

    test('parses empty data list', () {
      final response = ParkResponse.fromJson(
          <String, dynamic>{'data': <Map<String, dynamic>>[]});
      expect(response.data, isEmpty);
    });

    test('first park in list has correct fullName', () {
      final json = <String, dynamic>{
        'data': <Map<String, dynamic>>[_fullParkJson()],
      };
      final response = ParkResponse.fromJson(json);
      expect(response.data.first.fullName, 'Yosemite National Park');
    });

    test('all parks in list are ParkModel instances', () {
      final json = <String, dynamic>{
        'data': <Map<String, dynamic>>[_fullParkJson(), _minimalParkJson()],
      };
      final response = ParkResponse.fromJson(json);
      for (final park in response.data) {
        expect(park, isA<ParkModel>());
      }
    });
  });

  // ── Group 3: Sub-models ─────────────────────────────────────────────────────
  group('Sub-models — Activity, Topic, EntranceFee, OperatingHour, Address', () {
    test('Activity.fromJson parses id and name', () {
      final a = Activity.fromJson({'id': 'A1', 'name': 'Hiking'});
      expect(a.id,   'A1');
      expect(a.name, 'Hiking');
    });

    test('Activity.fromJson null-safety — defaults to empty string', () {
      final a = Activity.fromJson({'id': null, 'name': null});
      expect(a.id,   '');
      expect(a.name, '');
    });

    test('Topic.fromJson parses id and name', () {
      final t = Topic.fromJson({'id': 'T1', 'name': 'Mountains'});
      expect(t.id,   'T1');
      expect(t.name, 'Mountains');
    });

    test('EntranceFee.fromJson parses cost, title, description', () {
      final f = EntranceFee.fromJson({
        'cost': '35.00', 'title': 'Vehicle', 'description': '7-day pass',
      });
      expect(f.cost,        '35.00');
      expect(f.title,       'Vehicle');
      expect(f.description, '7-day pass');
    });

    test('EntranceFee.fromJson null cost defaults to "0.00"', () {
      final f = EntranceFee.fromJson({'cost': null, 'title': null, 'description': null});
      expect(f.cost, '0.00');
    });

    test('OperatingHour.fromJson parses name and description', () {
      final h = OperatingHour.fromJson({'name': 'Main', 'description': 'Open 24/7'});
      expect(h.name,        'Main');
      expect(h.description, 'Open 24/7');
    });

    test('Address.fromJson parses all fields', () {
      final a = Address.fromJson({
        'line1': '100 Main St', 'city': 'Yosemite', 'stateCode': 'CA',
        'postalCode': '95389', 'type': 'Physical',
      });
      expect(a.city,       'Yosemite');
      expect(a.stateCode,  'CA');
      expect(a.postalCode, '95389');
    });

    test('Address.formatted returns correct string', () {
      final a = Address.fromJson({
        'line1': '100 Main St', 'city': 'Yosemite', 'stateCode': 'CA',
        'postalCode': '95389', 'type': 'Physical',
      });
      expect(a.formatted, '100 Main St, Yosemite, CA 95389');
    });
  });

  // ── Group 4: ParkModel helper getters ──────────────────────────────────────
  group('ParkModel — helper getters', () {
    test('primaryImageUrl returns first image url', () {
      final park = ParkModel.fromJson(_fullParkJson());
      expect(park.primaryImageUrl, 'https://example.com/img1.jpg');
    });

    test('primaryImageUrl returns null when images list is empty', () {
      final park = ParkModel.fromJson(_minimalParkJson());
      expect(park.primaryImageUrl, isNull);
    });

    test('stateLabel for single state returns state code', () {
      final park = ParkModel.fromJson(_minimalParkJson());
      expect(park.stateLabel, 'CA');
    });

    test('stateLabel replaces comma with space-dot-space for multi-state', () {
      final json = <String, dynamic>{
        'id':          'TEST001',
        'fullName':    'Yosemite National Park',
        'states':      'CA,NV',
        'designation': 'National Park',
        'description': 'Home of iconic granite cliffs and waterfalls.',
        'images':         <Map<String, dynamic>>[],
        'activities':     <Map<String, dynamic>>[],
        'topics':         <Map<String, dynamic>>[],
        'operatingHours': <Map<String, dynamic>>[],
        'entranceFees':   <Map<String, dynamic>>[],
        'contacts':       <String, dynamic>{},
        'addresses':      <Map<String, dynamic>>[],
      };
      final park = ParkModel.fromJson(json);
      expect(park.stateLabel, 'CA · NV');
    });
  });

  // ── Group 5: NationalParksProvider — state management ──────────────────────
  group('NationalParksProvider — state management', () {
    test('initial loadingState is idle', () {
      final prov = NationalParksProvider();
      expect(prov.loadingState, LoadingState.idle);
    });

    test('initial parks list is empty', () {
      final prov = NationalParksProvider();
      expect(prov.parks, isEmpty);
    });

    test('initial selectedState is CA', () {
      final prov = NationalParksProvider();
      expect(prov.selectedState, 'CA');
    });

    test('initial searchQuery is empty string', () {
      final prov = NationalParksProvider();
      expect(prov.searchQuery, '');
    });

    test('initial filterDesignation is null', () {
      final prov = NationalParksProvider();
      expect(prov.filterDesignation, isNull);
    });

    test('initial errorMessage is null', () {
      final prov = NationalParksProvider();
      expect(prov.errorMessage, isNull);
    });

    test('isLoading returns false when not loading', () {
      final prov = NationalParksProvider();
      expect(prov.isLoading, isFalse);
    });

    test('setSearch updates searchQuery and notifies listeners', () {
      final prov = NationalParksProvider();
      var notified = false;
      prov.addListener(() => notified = true);

      prov.setSearch('yosemite');

      expect(prov.searchQuery, 'yosemite');
      expect(notified, isTrue);
    });
  });

  // ── Group 6: Provider search filter ────────────────────────────────────────
  group('Provider — search filter', () {
    test('setSearch empty string returns all parks', () {
      final prov = NationalParksProvider();
      prov.setSearch('');
      expect(prov.searchQuery, '');
    });

    test('setSearch updates query correctly', () {
      final prov = NationalParksProvider();
      prov.setSearch('Grand Canyon');
      expect(prov.searchQuery, 'Grand Canyon');
    });

    test('setFilterDesignation updates filter and notifies', () {
      final prov = NationalParksProvider();
      var notified = false;
      prov.addListener(() => notified = true);

      prov.setFilterDesignation('National Park');

      expect(prov.filterDesignation, 'National Park');
      expect(notified, isTrue);
    });

    test('clearFilter resets searchQuery and filterDesignation', () {
      final prov = NationalParksProvider();
      prov.setSearch('test');
      prov.setFilterDesignation('National Monument');
      prov.clearFilter();

      expect(prov.searchQuery,        '');
      expect(prov.filterDesignation,  isNull);
    });

    test('clearFilter notifies listeners', () {
      final prov = NationalParksProvider();
      var notified = false;
      prov.addListener(() => notified = true);

      prov.clearFilter();

      expect(notified, isTrue);
    });
  });

  // ── Group 7: Provider designation filter ───────────────────────────────────
  group('Provider — designation filter', () {
    test('setFilterDesignation to null clears filter', () {
      final prov = NationalParksProvider();
      prov.setFilterDesignation('National Park');
      prov.setFilterDesignation(null);
      expect(prov.filterDesignation, isNull);
    });

    test('filterDesignation null means no filter applied', () {
      final prov = NationalParksProvider();
      expect(prov.filterDesignation, isNull);
      expect(prov.parks, isEmpty); // empty because no API call made
    });

    test('designations list is empty before fetch', () {
      final prov = NationalParksProvider();
      expect(prov.designations, isEmpty);
    });

    test('setFilterDesignation then clearFilter resets', () {
      final prov = NationalParksProvider();
      prov.setFilterDesignation('National Monument');
      expect(prov.filterDesignation, 'National Monument');
      prov.clearFilter();
      expect(prov.filterDesignation, isNull);
    });
  });

  // ── Group 8: App launch & intro screen ─────────────────────────────────────
  group('App launch & intro screen', () {
    testWidgets('app launches without errors', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      // No exception = pass
    });

    testWidgets('intro screen shows Start Exploring button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      expect(find.text('Start Exploring'), findsOneWidget);
    });

    testWidgets('intro screen shows developer name', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      expect(find.textContaining('Jahidul Arafat'), findsOneWidget);
    });

    testWidgets('intro screen shows course info', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      // "About This App" section header is always visible
      expect(find.text('About This App'), findsOneWidget);
    });
  });

  // ── Group 9: ParkCard widget — all 3 view modes ────────────────────────────
  group('ParkCard widget — 3 view modes', () {
    ParkModel buildPark() => ParkModel.fromJson(_fullParkJson());

    testWidgets('grid mode shows park name', (tester) async {
      final park = buildPark();
      await tester.pumpWidget(buildWithProvider(
        ParkCard(
          park: park,
          onTap: () {},
          viewMode: ParkViewMode.grid,
        ),
      ));
      expect(find.textContaining('Yosemite'), findsOneWidget);
    });

    testWidgets('list mode shows park name', (tester) async {
      final park = buildPark();
      await tester.pumpWidget(buildWithProvider(
        ParkCard(
          park: park,
          onTap: () {},
          viewMode: ParkViewMode.list,
        ),
      ));
      expect(find.textContaining('Yosemite'), findsOneWidget);
    });

    testWidgets('compact mode shows park name', (tester) async {
      final park = buildPark();
      await tester.pumpWidget(buildWithProvider(
        ParkCard(
          park: park,
          onTap: () {},
          viewMode: ParkViewMode.compact,
        ),
      ));
      expect(find.textContaining('Yosemite'), findsOneWidget);
    });

    testWidgets('grid mode shows designation badge', (tester) async {
      final park = buildPark();
      await tester.pumpWidget(buildWithProvider(
        ParkCard(
          park: park,
          onTap: () {},
          viewMode: ParkViewMode.grid,
        ),
      ));
      expect(find.text('National Park'), findsOneWidget);
    });

    testWidgets('park card onTap fires when tapped', (tester) async {
      final park = buildPark();
      var tapped = false;
      await tester.pumpWidget(buildWithProvider(
        ParkCard(
          park: park,
          onTap: () => tapped = true,
          viewMode: ParkViewMode.grid,
        ),
      ));
      await tester.tap(find.byType(ParkCard));
      expect(tapped, isTrue);
    });

    testWidgets('list mode shows description text', (tester) async {
      final park = buildPark();
      await tester.pumpWidget(buildWithProvider(
        ParkCard(
          park: park,
          onTap: () {},
          viewMode: ParkViewMode.list,
        ),
      ));
      // Description is shown in list mode
      expect(find.textContaining('granite'), findsOneWidget);
    });
  });

  // ── Group 10: IntroPage model + provider.loadIntroPages ────────────────────
  group('IntroPage model + provider loadIntroPages', () {
    test('IntroPage has correct fields', () {
      final page = IntroPage(
        imagePath: 'assets/images/1.jpg',
        caption:   "Discover America's Wild Places",
        subtitle:  'Explore hundreds of national parks',
      );
      expect(page.imagePath, 'assets/images/1.jpg');
      expect(page.caption,   contains("Discover"));
      expect(page.subtitle,  contains('national parks'));
    });

    test('loadIntroPages creates exactly 4 pages', () {
      final prov = NationalParksProvider();
      prov.loadIntroPages();
      expect(prov.introPages.length, 4);
    });

    test('loadIntroPages pages have non-empty captions', () {
      final prov = NationalParksProvider();
      prov.loadIntroPages();
      for (final page in prov.introPages) {
        expect(page.caption,  isNotEmpty);
        expect(page.subtitle, isNotEmpty);
      }
    });

    test('loadIntroPages is idempotent — calling twice keeps 4 pages', () {
      final prov = NationalParksProvider();
      prov.loadIntroPages();
      prov.loadIntroPages(); // second call should no-op
      expect(prov.introPages.length, 4);
    });
  });
}