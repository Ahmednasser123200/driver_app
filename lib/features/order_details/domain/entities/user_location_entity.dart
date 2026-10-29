class UserLocationEntity {
  const UserLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy = 0.0,
    this.altitude = 0.0,
    this.speed = 0.0,
    this.heading = 0.0,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double accuracy;
  final double altitude;
  final double speed;
  final double heading;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLocationEntity &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          timestamp == other.timestamp &&
          accuracy == other.accuracy &&
          altitude == other.altitude &&
          speed == other.speed &&
          heading == other.heading;

  @override
  int get hashCode => Object.hash(
    latitude,
    longitude,
    timestamp,
    accuracy,
    altitude,
    speed,
    heading,
  );

  @override
  String toString() =>
      'UserLocationEntity(latitude: $latitude, longitude: $longitude, timestamp: $timestamp, accuracy: $accuracy, altitude: $altitude, speed: $speed, heading: $heading)';
}
