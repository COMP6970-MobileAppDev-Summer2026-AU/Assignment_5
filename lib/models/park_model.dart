// =============================================================================
// models/park_model.dart
// Full NPS API response model
// =============================================================================

class ParkResponse {
  final List<ParkModel> data;

  ParkResponse({required this.data});

  factory ParkResponse.fromJson(Map<String, dynamic> json) {
    return ParkResponse(
      data: (json['data'] as List)
          .map((p) => ParkModel.fromJson(p))
          .toList(),
    );
  }
}

class ParkModel {
  final String id;
  final String fullName;
  final String states;
  final String designation;
  final String description;
  final String? latitude;
  final String? longitude;
  final String? directionsInfo;
  final String? weatherInfo;
  final String? url;
  final List<ParkImageModel> images;
  final List<Activity> activities;
  final List<Topic> topics;
  final List<OperatingHour> operatingHours;
  final List<EntranceFee> entranceFees;
  final List<Contact> contacts;
  final List<Address> addresses;

  ParkModel({
    required this.id,
    required this.fullName,
    required this.states,
    required this.designation,
    required this.description,
    this.latitude,
    this.longitude,
    this.directionsInfo,
    this.weatherInfo,
    this.url,
    required this.images,
    required this.activities,
    required this.topics,
    required this.operatingHours,
    required this.entranceFees,
    required this.contacts,
    required this.addresses,
  });

  factory ParkModel.fromJson(Map<String, dynamic> json) {
    return ParkModel(
      id:           json['id']          as String? ?? '',
      fullName:     json['fullName']     as String? ?? 'Unknown Park',
      states:       json['states']       as String? ?? '',
      designation:  json['designation']  as String? ?? '',
      description:  json['description']  as String? ?? '',
      latitude:     json['latitude']     as String?,
      longitude:    json['longitude']    as String?,
      directionsInfo: json['directionsInfo'] as String?,
      weatherInfo:    json['weatherInfo']    as String?,
      url:            json['url']            as String?,
      images: (json['images'] as List? ?? [])
          .map((i) => ParkImageModel.fromJson(i))
          .toList(),
      activities: (json['activities'] as List? ?? [])
          .map((a) => Activity.fromJson(a))
          .toList(),
      topics: (json['topics'] as List? ?? [])
          .map((t) => Topic.fromJson(t))
          .toList(),
      operatingHours: (json['operatingHours'] as List? ?? [])
          .map((h) => OperatingHour.fromJson(h))
          .toList(),
      entranceFees: (json['entranceFees'] as List? ?? [])
          .map((f) => EntranceFee.fromJson(f))
          .toList(),
      contacts: (json['contacts'] as Map<String, dynamic>? ?? {})
              .containsKey('phoneNumbers')
          ? (json['contacts']['phoneNumbers'] as List? ?? [])
              .map((c) => Contact.fromJson(c))
              .toList()
          : [],
      addresses: (json['addresses'] as List? ?? [])
          .map((a) => Address.fromJson(a))
          .toList(),
    );
  }

  /// First image URL or null
  String? get primaryImageUrl =>
      images.isNotEmpty ? images.first.url : null;

  /// Short state list label
  String get stateLabel => states.replaceAll(',', ' · ');
}

class ParkImageModel {
  final String url;
  final String altText;
  final String? caption;

  ParkImageModel({required this.url, required this.altText, this.caption});

  factory ParkImageModel.fromJson(Map<String, dynamic> json) {
    return ParkImageModel(
      url:     json['url']     as String? ?? '',
      altText: json['altText'] as String? ?? '',
      caption: json['caption'] as String?,
    );
  }
}

class Activity {
  final String id;
  final String name;

  Activity({required this.id, required this.name});

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id:   json['id']   as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class Topic {
  final String id;
  final String name;

  Topic({required this.id, required this.name});

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id:   json['id']   as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class OperatingHour {
  final String name;
  final String description;

  OperatingHour({required this.name, required this.description});

  factory OperatingHour.fromJson(Map<String, dynamic> json) {
    return OperatingHour(
      name:        json['name']        as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class EntranceFee {
  final String cost;
  final String title;
  final String description;

  EntranceFee({
    required this.cost,
    required this.title,
    required this.description,
  });

  factory EntranceFee.fromJson(Map<String, dynamic> json) {
    return EntranceFee(
      cost:        json['cost']        as String? ?? '0.00',
      title:       json['title']       as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class Contact {
  final String phoneNumber;
  final String type;

  Contact({required this.phoneNumber, required this.type});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      phoneNumber: json['phoneNumber'] as String? ?? '',
      type:        json['type']        as String? ?? '',
    );
  }
}

class Address {
  final String line1;
  final String city;
  final String stateCode;
  final String postalCode;
  final String type;

  Address({
    required this.line1,
    required this.city,
    required this.stateCode,
    required this.postalCode,
    required this.type,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      line1:      json['line1']      as String? ?? '',
      city:       json['city']       as String? ?? '',
      stateCode:  json['stateCode']  as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      type:       json['type']       as String? ?? '',
    );
  }

  String get formatted => '$line1, $city, $stateCode $postalCode';
}

// =============================================================================
// Intro page model (for onboarding carousel)
// =============================================================================

class IntroPage {
  final String imagePath;
  final String caption;
  final String subtitle;

  IntroPage({
    required this.imagePath,
    required this.caption,
    required this.subtitle,
  });
}
