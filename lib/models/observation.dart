class Observation {
  final int? id;
  final int hikeId;
  final String observation;
  final DateTime time;
  final String? comments; // Optional
  final String? photoPath; // Path to observation photo

  Observation({
    this.id,
    required this.hikeId,
    required this.observation,
    required this.time,
    this.comments,
    this.photoPath,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'hikeId': hikeId,
      'observation': observation,
      'time': time.toIso8601String(),
      'comments': comments,
      'photoPath': photoPath,
    };
  }

  // Create from Map
  factory Observation.fromMap(Map<String, dynamic> map) {
    return Observation(
      id: map['id'] as int?,
      hikeId: map['hikeId'] as int,
      observation: map['observation'] as String,
      time: DateTime.parse(map['time'] as String),
      comments: map['comments'] as String?,
      photoPath: map['photoPath'] as String?,
    );
  }

  // Create a copy with updated fields
  Observation copyWith({
    int? id,
    int? hikeId,
    String? observation,
    DateTime? time,
    String? comments,
    String? photoPath,
  }) {
    return Observation(
      id: id ?? this.id,
      hikeId: hikeId ?? this.hikeId,
      observation: observation ?? this.observation,
      time: time ?? this.time,
      comments: comments ?? this.comments,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
