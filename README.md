# National Parks Explorer - Extended By Jahidul Arafat
### Assignment 4 — Remote Data & APIs
### COMP 6970 — Mobile Applications Development

---

[![🏞️ Flutter CI](https://github.com/COMP6970-MobileAppDev-Summer2026-AU/Assignment_4/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/COMP6970-MobileAppDev-Summer2026-AU/Assignment_4/actions/workflows/flutter_ci.yml)
[![🔎 PR Check](https://github.com/COMP6970-MobileAppDev-Summer2026-AU/Assignment_4/actions/workflows/pr_check.yml/badge.svg)](https://github.com/COMP6970-MobileAppDev-Summer2026-AU/Assignment_4/actions/workflows/pr_check.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.44.0-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![Tests](https://img.shields.io/badge/Tests-51%20passing-brightgreen?logo=checkmarx)
![API](https://img.shields.io/badge/API-NPS%20Developer-4CAF50?logo=leaf)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey?logo=apple)

---

## 🎬 App Demo Video

[![National Parks Explorer — App Demo](https://img.youtube.com/vi/wuk2r05u_LE/maxresdefault.jpg)](https://youtu.be/wuk2r05u_LE)

> **▶️ [Watch Full Demo on YouTube](https://youtu.be/wuk2r05u_LE)**
>
> Complete walkthrough: Home → Search by State → Grid/List/Compact Results → Park Detail (Overview · Activities · Hours & Fees · Map + Directions)
---

## 👨‍💻 Developer Information

| Field | Details |
|---|---|
| **Name** | Jahidul Arafat |
| **Username** | JAJI |
| **Title** | PhD Student, Department of Computer Science & Software Engineering |
| **Fellowship** | Presidential & Woltosz Graduate Research Fellow |
| **Industry** | Former L3 Senior Solution Architect (MLOps), Oracle (Singapore) |
| **Course** | COMP 6910 — Mobile Applications Development |
| **Module** | M4 — Remote Data & APIs |
| **Assignment** | Assignment 4 |
| **API** | National Park Service (NPS) Developer API |
| **Track** | Flutter / Dart |
| **Version** | 1.0.0+1 |

---

## 📱 App Overview

**National Parks Explorer** is a polished Flutter app that retrieves live data from the **National Park Service API** and lets users discover parks, monuments, and recreation areas across all 50 US states. It extends the base sample project with significant UX, data, and navigation enhancements — all directly aligned to the Assignment 4 grading criteria.

---

## 🔑 API Key Setup

1. Register for a free NPS API key at: https://www.nps.gov/subjects/developer/get-started.htm
2. Open `lib/services/park_service.dart`
3. Replace the placeholder:

```dart
// Before
static const String _apiKey = 'DEMO_KEY';

// After
static const String _apiKey = 'YOUR_KEY_HERE';
```

> **Note:** The `DEMO_KEY` works for testing but is rate-limited to 40 requests/hour per IP.

---

## ⚙️ Setup & Installation

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Xcode (iOS) or Android Studio (Android)

### Clone & Run

```bash
# 1. Clone the repository
git clone https://github.com/COMP6970-MobileAppDev-Summer2026-AU/Assignment_4.git
cd Assignment_4

# 2. Add your NPS API key in lib/services/park_service.dart

# 3. Install dependencies
flutter pub get

# 4. Run analysis
flutter analyze

# 5. Run tests
flutter test --reporter expanded

# 6. Run the app
flutter run
```

### Dependencies

```yaml
provider: ^6.1.5            # Shared state (ChangeNotifier)
http: ^1.4.0                # NPS API requests
flutter_map: ^7.0.2         # Interactive map display
latlong2: ^0.9.1            # Lat/Lng coordinate support
cached_network_image: ^3.4.1 # Cached park images
shared_preferences: ^2.2.3  # Local preferences
url_launcher: ^6.3.1        # Launch Google Maps / Apple Maps / Waze
```

---

## 🗂 Project Structure

```
NationalParks-flutter/
├── lib/
│   ├── main.dart                          # App entry, green theme
│   ├── models/
│   │   └── park_model.dart                # ParkModel, ParkResponse, all sub-models
│   ├── providers/
│   │   └── nationalparks_provider.dart    # LoadingState, search, filter, parks list
│   ├── services/
│   │   └── park_service.dart              # NPS API fetch by state / park code
│   ├── screens/
│   │   ├── intro_screen.dart              # JAJI-style splash with carousel
│   │   ├── park_search_screen.dart        # State dropdown + popular chips + search
│   │   ├── park_results_screen.dart       # Grid/List/Compact with search + filter
│   │   └── park_detail_screen.dart        # 4-tab detail + image gallery + map + directions
│   └── widgets/
│       └── park_card.dart                 # ParkCard with 3 view modes
└── assets/
    └── images/
        └── 1.jpg … 15.jpg                 # 15 intro carousel images
```

---

## 📋 Assignment 4 Grading Criteria — Full Coverage

### ✅ Criterion 1 — Interface Layout & Design (20 pts)

| Requirement | Implementation |
|---|---|
| Clean layout, proper spacing | Consistent `16px` padding, rounded cards, `Material3` |
| Readable text | Bold titles, grey subtitles, `TextOverflow.ellipsis` everywhere |
| Images or visual elements | `CachedNetworkImage` with shimmer placeholder + error fallback |
| Polished design matching the app theme | Green `ColorScheme.fromSeed` throughout all screens |

**Evidence:**
- `ParkCard` adapts to all 3 view modes (Grid / List / Compact) without overflow
- `ParkDetailScreen` uses `NestedScrollView` + `SliverAppBar` with image gallery
- All loading, error, and empty states have dedicated UI
- `_FilterChip` with animated color transition for designation filter

---

### ✅ Criterion 2 — API Request & JSON Models (20 pts)

| Requirement | Implementation |
|---|---|
| At least one public API | NPS Developer API — `https://developer.nps.gov/api/v1/parks` |
| Data from a network request | `http.get()` with 15-second timeout in `ParkService` |
| Model classes for API response | `ParkModel`, `ParkResponse`, `ParkImageModel`, `Activity`, `Topic`, `OperatingHour`, `EntranceFee`, `Contact`, `Address` |
| JSON converted to objects before display | `ParkModel.fromJson()` with full null-safety on every field |

**Code example:**
```dart
// services/park_service.dart
final uri = Uri.parse('$_baseUrl?stateCode=$stateCode&limit=50&api_key=$_apiKey');
final response = await http.get(uri).timeout(const Duration(seconds: 15));
final parkResponse = ParkResponse.fromJson(jsonDecode(response.body));
```

**Model coverage:**

| Model Class | API Fields Parsed |
|---|---|
| `ParkModel` | id, fullName, states, designation, description, lat, lng, url, directionsInfo, weatherInfo |
| `ParkImageModel` | url, altText, caption |
| `Activity` | id, name |
| `Topic` | id, name |
| `OperatingHour` | name, description |
| `EntranceFee` | cost, title, description |
| `Contact` | phoneNumber, type |
| `Address` | line1, city, stateCode, postalCode, type |

---

### ✅ Criterion 3 — Results List or Grid (20 pts)

| Requirement | Implementation |
|---|---|
| Scrollable list or grid | `GridView.builder` (grid) and `ListView.builder` (list/compact) |
| Each item shows useful information | Name, state, designation badge, description preview (list mode) |
| Clear and useful fields from API | `park.fullName`, `park.stateLabel`, `park.designation`, `park.primaryImageUrl` |

**Three view modes available:**

| Mode | Layout | Columns | Shows |
|---|---|---|---|
| **Grid** | `GridView` 2-column | 2 | Image + name + state + badge |
| **List** | `ListView` full-width | 1 | Image left + name + state + badge + description |
| **Compact** | `ListView` thin rows | 1 | Thumbnail + name + state + designation |

---

### ✅ Criterion 4 — Detail Screen & Navigation (20 pts)

| Requirement | Implementation |
|---|---|
| Select item from list/grid | `InkWell.onTap` → `Navigator.push` → `ParkDetailScreen` |
| Detail screen with additional info | 4-tab layout: Overview · Activities · Hours & Fees · Map |
| Navigation between screens | `Navigator.push` (list → detail), `Navigator.pop` (detail → list) |

**Detail screen tabs:**

| Tab | Content |
|---|---|
| **Overview** | Description, weather info, directions, topics chips, website URL |
| **Activities** | Activity chips (e.g. Hiking, Camping, Swimming) with count |
| **Hours & Fees** | Entrance fee cards with cost badge, operating hours cards |
| **Map** | Interactive OpenStreetMap with zoom +/- controls, re-center button, Get Directions |

---

### ✅ Criterion 5 — Error, Empty State & Code Organization (20 pts)

| Requirement | Implementation |
|---|---|
| Handle API errors | `try/catch` → `LoadingState.error` → SnackBar + inline error card |
| Handle empty results | `_emptyState()` widget with "Clear filters" button |
| Handle missing fields | Every `fromJson()` field uses `as Type? ?? defaultValue` |
| Code organized into files | `models/` · `providers/` · `services/` · `screens/` · `widgets/` |
| Readable and separated | `ParkCard` is a reusable widget, `_FilterChip` is extracted, detail tabs are separate classes |

---

## 📊 Sample vs Enhanced — Comparison Table

### screens/intro_screen.dart

| Feature | Sample Project | This Implementation | Criterion |
|---|---|---|---|
| Carousel | ✅ Basic PageView | ✅ + animated dot indicators, captions + subtitle | Layout & Design |
| Developer info | ❌ Not present | ✅ JAJI-style developer + app info cards | Layout & Design |
| Animation | ❌ None | ✅ Fade + scale elasticOut on load | Layout & Design |
| Navigation | ✅ Button only | ✅ Tap anywhere OR button | Layout & Design |

---

### screens/park_search_screen.dart

| Feature | Sample Project | This Implementation | Criterion |
|---|---|---|---|
| State picker | ✅ Basic dropdown | ✅ Styled dropdown with full state names (AL — Alabama) | Layout & Design |
| Quick pick | ❌ None | ✅ 10 popular state chips (CA, WY, UT, CO…) | Layout & Design |
| Error display | ❌ None | ✅ Inline error card with red border | Error Handling |
| Loading state | ❌ None | ✅ Spinner replaces button icon while loading | Layout & Design |
| Search button | ✅ Plain button | ✅ Disabled during loading, full-width styled | Layout & Design |

---

### screens/park_results_screen.dart

| Feature | Sample Project | This Implementation | Criterion |
|---|---|---|---|
| View mode | ✅ Grid only | ✅ Grid + List + Compact — toggled via AppBar button | Results List/Grid |
| Live search | ❌ Not present | ✅ TextField filters by name, designation, description | Results List/Grid |
| Filter chips | ❌ Not present | ✅ Horizontal designation chips (National Park, Monument…) | Results List/Grid |
| Result count | ❌ Not present | ✅ "11 results" shown in AppBar subtitle | Results List/Grid |
| Empty state | ❌ App shows blank | ✅ Icon + message + "Clear filters" button | Error Handling |
| Clear filter | ❌ Not present | ✅ Button resets search + designation filter | Error Handling |

---

### widgets/park_card.dart

| Feature | Sample Project | This Implementation | Criterion |
|---|---|---|---|
| View modes | ✅ Grid only | ✅ Grid / List / Compact with different layouts | Results List/Grid |
| Image loading | ✅ `Image.network` | ✅ `CachedNetworkImage` + shimmer placeholder + error fallback | Layout & Design |
| Designation badge | ❌ Not present | ✅ Colour-matched badge below state | Results List/Grid |
| Description preview | ❌ Not present | ✅ Shown in List mode (2 lines) | Results List/Grid |
| Overflow handling | ❌ Text may overflow | ✅ `maxLines` + `TextOverflow.ellipsis` everywhere | Error Handling |

---

### screens/park_detail_screen.dart

| Feature | Sample Project | This Implementation | Criterion |
|---|---|---|---|
| Layout | ✅ Single scroll | ✅ `NestedScrollView` + 4-tab layout | Detail Screen |
| Image gallery | ✅ Single image | ✅ Swipeable gallery with ‹ › arrows + dot indicators + counter | Layout & Design |
| Map | ✅ Basic flutter_map | ✅ + Zoom in/out buttons + zoom level display + re-center | Detail Screen |
| Get Directions | ❌ Not present | ✅ Bottom sheet → Google Maps / Apple Maps / Waze | Detail Screen |
| Topics | ❌ Not present | ✅ Topic chips in Overview tab | Detail Screen |
| Website URL | ❌ Not present | ✅ Shown in Overview tab | Detail Screen |
| Entrance fees | ✅ List | ✅ Cards with green cost badge + description | Detail Screen |
| Activities | ✅ Horizontal chips | ✅ Wrapped activity chips with count header | Detail Screen |
| Operating hours | ✅ Text list | ✅ Cards with name + description | Detail Screen |
| Empty tab states | ❌ Blank | ✅ Icon + message per tab | Error Handling |
| Null safety | ❌ Can crash on null | ✅ Every field null-checked in `fromJson()` | Error Handling |

---

### providers/nationalparks_provider.dart

| Feature | Sample Project | This Implementation | Criterion |
|---|---|---|---|
| Loading state | ✅ Basic bool-like | ✅ `LoadingState` enum (idle/loading/success/error) | Error Handling |
| Search | ❌ Not present | ✅ `searchQuery` filters parks by name + designation + description | Results List/Grid |
| Filter | ❌ Not present | ✅ `filterDesignation` filters by park type | Results List/Grid |
| Designations list | ❌ Not present | ✅ Computed from live results for chip generation | Results List/Grid |
| Error message | ✅ String? | ✅ User-friendly message + reset on new search | Error Handling |

---

### models/park_model.dart

| Feature | Sample Project | This Implementation | Criterion |
|---|---|---|---|
| Core fields | ✅ id, fullName, states, designation, images | ✅ All sample fields + | API & JSON Models |
| Additional fields | ❌ | ✅ `topics`, `url`, `addresses`, `contacts` | API & JSON Models |
| Null safety | ✅ Partial | ✅ Every field uses `as Type? ?? default` | Error Handling |
| Helper getters | ❌ | ✅ `primaryImageUrl`, `stateLabel` | Code Organisation |
| IntroPage model | ✅ caption only | ✅ + subtitle field | Layout & Design |

---

## 🏗 Architecture

```
┌──────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                      │
│  IntroScreen · ParkSearchScreen · ParkResultsScreen       │
│  ParkDetailScreen                                         │
│  Widgets: ParkCard (Grid / List / Compact)                │
└──────────────────────────┬───────────────────────────────┘
                           │  context.watch / context.read
                           ▼
┌──────────────────────────────────────────────────────────┐
│                    STATE LAYER                            │
│  NationalParksProvider (ChangeNotifier)                   │
│  LoadingState: idle → loading → success / error          │
│  State: parks, searchQuery, filterDesignation            │
└──────────────────────────┬───────────────────────────────┘
                           │  async await
                           ▼
┌──────────────────────────────────────────────────────────┐
│                    SERVICE LAYER                          │
│  ParkService                                             │
│  GET /parks?stateCode=XX&limit=50&api_key=KEY            │
└──────────────────────────┬───────────────────────────────┘
                           │  fromJson()
                           ▼
┌──────────────────────────────────────────────────────────┐
│                    DATA LAYER                             │
│  ParkModel · ParkImageModel · Activity · Topic           │
│  OperatingHour · EntranceFee · Contact · Address         │
└──────────────────────────────────────────────────────────┘
```

---

## 🔄 App Navigation Flow

```
IntroScreen
    └─[tap anywhere / button]──▶ ParkSearchScreen
                                      │
                               Select state
                               + tap Search
                                      │
                              API call → NPS
                                      │
                           ┌──────────▼──────────┐
                           │  ParkResultsScreen   │
                           │  Grid / List /       │
                           │  Compact view        │
                           │  Search + Filter     │
                           └──────────┬──────────┘
                                      │ tap any park
                                      ▼
                           ┌──────────────────────┐
                           │  ParkDetailScreen     │
                           │  ┌─────────────────┐  │
                           │  │ Overview tab    │  │
                           │  │ Activities tab  │  │
                           │  │ Hours & Fees    │  │
                           │  │ Map tab         │  │
                           │  │  ├── Zoom +/-   │  │
                           │  │  └── Directions │  │
                           │  │       ├── Google│  │
                           │  │       ├── Apple │  │
                           │  │       └── Waze  │  │
                           │  └─────────────────┘  │
                           └──────────────────────┘
```

---

## 📡 NPS API Reference

**Base URL:** `https://developer.nps.gov/api/v1/parks`

**Query parameters used:**

| Parameter | Value | Purpose |
|---|---|---|
| `stateCode` | e.g. `CA` | Filter parks by US state |
| `limit` | `50` | Max results per request |
| `api_key` | your key | Authentication |

**Sample response structure:**
```json
{
  "data": [
    {
      "id": "...",
      "fullName": "Yosemite National Park",
      "states": "CA",
      "designation": "National Park",
      "description": "...",
      "latitude": "37.84883288",
      "longitude": "-119.5571873",
      "images": [{ "url": "...", "altText": "..." }],
      "activities": [{ "id": "...", "name": "Hiking" }],
      "entranceFees": [{ "cost": "35.00", "title": "..." }],
      "operatingHours": [{ "name": "...", "description": "..." }]
    }
  ]
}
```

---

## 📱 Screen Guide

### 1. Intro Screen
- Photo carousel with 4 randomly selected nature images
- Animated dot indicators + caption + subtitle per page
- Developer card: Jahidul Arafat, title, fellowship, industry
- App info card: course, module, assignment, API, version
- "Start Exploring" button + tap-anywhere gesture

### 2. Park Search Screen
- Styled full-name state dropdown (`AL — Alabama`)
- 10 popular state quick-pick chips (CA, WY, UT, CO, AZ, MT, WA, FL, AK, HI)
- Search button with loading spinner during API call
- Inline error card if request fails

### 3. Park Results Screen
- AppBar shows state code + result count
- Live search bar filters by name / designation / description
- Designation filter chips (All · National Park · Monument · etc.)
- **3 view modes** toggled via AppBar button:
  - **Grid** — 2-column image cards
  - **List** — full-width with image + description preview
  - **Compact** — thin rows for quick scanning
- Empty state with "Clear filters" option

### 4. Park Detail Screen
- Swipeable image gallery with ‹ › arrow buttons + dot indicators + `1/5` counter
- Park name, state label, designation badge
- **4 tabs:**
  - **Overview** — description, weather, directions, topics, website
  - **Activities** — wrapped chips with total count
  - **Hours & Fees** — entrance fee cards + operating hours cards
  - **Map** — OpenStreetMap with zoom +/− controls, zoom level indicator, re-center, **Get Directions** button
- Get Directions sheet → Google Maps / Apple Maps / Waze with coordinates

---

## 🧪 Test Coverage — 51 Tests / 10 Groups

```bash
flutter test --reporter expanded
```

### Run

```bash
# All tests
flutter test --reporter expanded

# With coverage
flutter test --coverage
```

### Test Groups

| # | Group | Tests | What Is Tested |
|---|---|---|---|
| 1 | **ParkModel — fromJson parsing** | 10 | All required fields, optional fields, missing fields, null safety, image list |
| 2 | **ParkResponse — list parsing** | 4 | Multi-park list, empty list, first park access, type checking |
| 3 | **Sub-models** | 8 | `Activity`, `Topic`, `EntranceFee`, `OperatingHour`, `Address` — parse + null safety + `formatted` getter |
| 4 | **ParkModel helper getters** | 4 | `primaryImageUrl` (present/absent), `stateLabel` (single/multi-state `CA · NV`) |
| 5 | **Provider — state management** | 8 | Initial state, `isLoading`, `setSearch`, `notifyListeners` |
| 6 | **Provider — search filter** | 5 | `setSearch`, `setFilterDesignation`, `clearFilter`, listener notifications |
| 7 | **Provider — designation filter** | 4 | Null filter, clear resets, empty before fetch |
| 8 | **App launch & intro screen** | 4 | App launches, "Start Exploring" button, developer name, "About This App" header |
| 9 | **ParkCard — 3 view modes** | 6 | Grid/List/Compact show name, Grid shows badge, `onTap` fires, List shows description |
| 10 | **IntroPage + loadIntroPages** | 4 | Model fields, exactly 4 pages created, captions non-empty, idempotent |
| | **Total** | **51** | **All passing ✅** |

### Test Design Notes

- **No HTTP mocking needed** — model and provider tests are pure Dart using fixture JSON; no network calls made
- **`buildWithProvider()`** — wraps any widget in `ChangeNotifierProvider` + `MaterialApp` for isolated widget tests
- **Null safety coverage** — every `fromJson()` tested with both full data and `null` values via `_nullFieldsParkJson()`
- **Explicit type annotations** — all fixture maps use `<String, dynamic>{...}` to prevent `Map<dynamic, dynamic>` cast errors
- **`loadIntroPages` idempotency** — verified calling twice still produces exactly 4 pages

### Test Fixtures

```dart
// Minimal park — only required fields
Map<String, dynamic> _minimalParkJson()   // 12 fields, all lists empty

// Full park — all optional fields populated
Map<String, dynamic> _fullParkJson()      // All fields + 1 image, 2 activities, fees, hours

// Null park — every field explicitly null
Map<String, dynamic> _nullFieldsParkJson() // Verifies fromJson never crashes on null API response
```

---