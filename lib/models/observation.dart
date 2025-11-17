class Observation {
  final int? id;
  final int hikeId;
  final String observation;
  final DateTime time;
  final String category;
  final String location;
  final String? additionalComments;
  final String? photoPath;

  Observation({
    this.id,
    required this.hikeId,
    required this.observation,
    required this.time,
    required this.category,
    required this.location,
    this.additionalComments,
    this.photoPath,
  });

  // Convert Observation to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hikeId': hikeId,
      'observation': observation,
      'time': time.toIso8601String(),
      'category': category,
      'location': location,
      'additionalComments': additionalComments,
      'photoPath': photoPath,
    };
  }

  // Create Observation from Map
  factory Observation.fromMap(Map<String, dynamic> map) {
    return Observation(
      id: map['id'] as int?,
      hikeId: map['hikeId'] as int,
      observation: map['observation'] as String,
      time: DateTime.parse(map['time'] as String),
      category: map['category'] as String? ?? 'General',
      location: map['location'] as String? ?? 'Unknown location',
      additionalComments: map['additionalComments'] as String?,
      photoPath: map['photoPath'] as String?,
    );
  }

  // Create a copy of Observation with updated fields
  Observation copyWith({
    int? id,
    int? hikeId,
    String? observation,
    DateTime? time,
    String? category,
    String? location,
    String? additionalComments,
    String? photoPath,
  }) {
    return Observation(
      id: id ?? this.id,
      hikeId: hikeId ?? this.hikeId,
      observation: observation ?? this.observation,
      time: time ?? this.time,
      category: category ?? this.category,
      location: location ?? this.location,
      additionalComments: additionalComments ?? this.additionalComments,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
