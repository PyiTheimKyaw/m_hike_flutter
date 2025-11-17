class Hike {
  final int? id;
  final String name;
  final String location;
  final DateTime date;
  final String parkingAvailable; // "Yes" or "No"
  final double length; // in km
  final String difficulty; // e.g., "Easy", "Medium", "Hard"
  final String? description; // Optional
  final String? weatherCondition; // Custom field 1
  final String? estimatedDuration; // Custom field 2 (e.g., "3 hours")

  Hike({
    this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.parkingAvailable,
    required this.length,
    required this.difficulty,
    this.description,
    this.weatherCondition,
    this.estimatedDuration,
  });

  // Convert Hike to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'date': date.toIso8601String(),
      'parkingAvailable': parkingAvailable,
      'length': length,
      'difficulty': difficulty,
      'description': description,
      'weatherCondition': weatherCondition,
      'estimatedDuration': estimatedDuration,
    };
  }

  // Create Hike from Map (from database)
  factory Hike.fromMap(Map<String, dynamic> map) {
    return Hike(
      id: map['id'] as int?,
      name: map['name'] as String,
      location: map['location'] as String,
      date: DateTime.parse(map['date'] as String),
      parkingAvailable: map['parkingAvailable'] as String,
      length: map['length'] as double,
      difficulty: map['difficulty'] as String,
      description: map['description'] as String?,
      weatherCondition: map['weatherCondition'] as String?,
      estimatedDuration: map['estimatedDuration'] as String?,
    );
  }

  // Create a copy of Hike with updated fields
  Hike copyWith({
    int? id,
    String? name,
    String? location,
    DateTime? date,
    String? parkingAvailable,
    double? length,
    String? difficulty,
    String? description,
    String? weatherCondition,
    String? estimatedDuration,
  }) {
    return Hike(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      date: date ?? this.date,
      parkingAvailable: parkingAvailable ?? this.parkingAvailable,
      length: length ?? this.length,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    );
  }
}
