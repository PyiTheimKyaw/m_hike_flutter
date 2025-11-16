class Hike {
  final int? id;
  final String name;
  final String location;
  final DateTime date;
  final String parkingAvailable; // "Yes" or "No"
  final String length;
  final String difficulty;
  final String? description; // Optional
  final String? weatherConditions; // Optional - creative field 1
  final String? estimatedDuration; // Optional - creative field 2

  Hike({
    this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.parkingAvailable,
    required this.length,
    required this.difficulty,
    this.description,
    this.weatherConditions,
    this.estimatedDuration,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'location': location,
      'date': date.toIso8601String(),
      'parkingAvailable': parkingAvailable,
      'length': length,
      'difficulty': difficulty,
      'description': description,
      'weatherConditions': weatherConditions,
      'estimatedDuration': estimatedDuration,
    };
  }

  // Create from Map
  factory Hike.fromMap(Map<String, dynamic> map) {
    return Hike(
      id: map['id'] as int?,
      name: map['name'] as String,
      location: map['location'] as String,
      date: DateTime.parse(map['date'] as String),
      parkingAvailable: map['parkingAvailable'] as String,
      length: map['length'] as String,
      difficulty: map['difficulty'] as String,
      description: map['description'] as String?,
      weatherConditions: map['weatherConditions'] as String?,
      estimatedDuration: map['estimatedDuration'] as String?,
    );
  }

  // Create a copy with updated fields
  Hike copyWith({
    int? id,
    String? name,
    String? location,
    DateTime? date,
    String? parkingAvailable,
    String? length,
    String? difficulty,
    String? description,
    String? weatherConditions,
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
      weatherConditions: weatherConditions ?? this.weatherConditions,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    );
  }
}
