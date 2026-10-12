
import 'package:equatable/equatable.dart';

class ReportDriverLocationParams extends Equatable {
  final double lat;
  final double lng;
  final String recordedAt;

  const ReportDriverLocationParams({
    required this.lat,
    required this.lng,
    required this.recordedAt,
  });

  @override
  List<Object?> get props => [
        lat,
        lng,
        recordedAt,
      ];
}
