class Observation {
  final int? id;
  final int hikeId; // Foreign key to Hike
  final String observation;
  final DateTime time;
  final String? additionalComments; // Optional
  final String? photoPath; // Path to photo file

  Observation({
    this.id,
    required this.hikeId,
    required this.observation,
    required this.time,
    this.additionalComments,
    this.photoPath,
  });

  // Convert Observation to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hikeId': hikeId,
      'observation': observation,
      'time': time.toIso8601String(),
      'additionalComments': additionalComments,
      'photoPath': photoPath,
    };
  }

  // Create Observation from Map (from database)
  factory Observation.fromMap(Map<String, dynamic> map) {
    return Observation(
      id: map['id'] as int?,
      hikeId: map['hikeId'] as int,
      observation: map['observation'] as String,
      time: DateTime.parse(map['time'] as String),
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
    String? additionalComments,
    String? photoPath,
  }) {
    return Observation(
      id: id ?? this.id,
      hikeId: hikeId ?? this.hikeId,
      observation: observation ?? this.observation,
      time: time ?? this.time,
      additionalComments: additionalComments ?? this.additionalComments,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
