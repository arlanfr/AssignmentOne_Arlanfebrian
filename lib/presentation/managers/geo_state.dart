// lib/manager/geo_state.dart
part of 'geo_bloc.dart';

@immutable
sealed class GeoState {}

final class GeoInitial extends GeoState {}

final class GeoLoading extends GeoState {}

final class GeoLoaded extends GeoState {
  GeoLoaded({
    required this.geo,
    this.points = const <Geo>[],
    this.isRecording = false,
    this.history = const [],
  });

  final Geo geo;
  final List<Geo> points;
  final bool isRecording;
  final List<List<Geo>> history;

  GeoLoaded copywith({
    Geo? geo,
    List<Geo>? points,
    bool? isRecording,
    List<List<Geo>>? history,
  }) {
    return GeoLoaded(
      geo: geo ?? this.geo,
      points: points ?? this.points,
      isRecording: isRecording ?? this.isRecording,
      history: history ?? this.history,
    );
  }
}

final class GeoError extends GeoState {
  GeoError({this.message});
  final String? message;
}
