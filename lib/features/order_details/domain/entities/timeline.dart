
import 'package:equatable/equatable.dart';

class TimelineEntity extends Equatable {
  final String status;
  final String timestamp;

  const TimelineEntity({
    required this.status,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        status,
        timestamp,
      ];
}
