import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../model/geo.dart';
import '../../service.dart/geo_service.dart';

part 'geo_event.dart';
part 'geo_state.dart';

class GeoBloc extends Bloc<GeoEvent, GeoState> {
  final GeoService service;
  StreamSubscription<Geo>? _subscription;

  GeoBloc({required this.service}) : super(GeoInitial()) {
    on<GeoInitEvent>((event, emit) async {
      try {
        emit(GeoLoading());
        final isGranted = await service.handlePermission();
        if (isGranted) {
          add(GeoGetLocationEvent());
          add(GeoStartRealtimeEvent());
        }
      } catch (e) {
        emit(GeoError(message: e.toString()));
      }
    });

    on<GeoGetLocationEvent>((event, emit) async {
      try {
        emit(GeoLoading());
        final geo = await service.getLocation();
        emit(GeoLoaded(geo: geo, points: [], isRecording: false, history: []));
      } catch (e) {
        emit(GeoError(message: e.toString()));
      }
    });

    on<GeoStartRealtimeEvent>((event, emit) {
      _subscription = service.getLocationStream().listen((geo) {
        add(GeoUpdateLocationEvent(geo));
      });
    });

    on<GeoUpdateLocationEvent>((event, emit) {
      if (state is GeoLoaded) {
        final currState = state as GeoLoaded;
        List<Geo> updatedPoints = currState.points;
        if (currState.isRecording) {
          updatedPoints = [...currState.points, event.geo];
        }
        emit(currState.copywith(geo: event.geo, points: updatedPoints));
      }
    });

    on<GeoStartRecordingEvent>((event, emit) {
      if (state is GeoLoaded) {
        final currState = state as GeoLoaded;
        // emit(currState.copywith(isRecording: true));
        emit(currState.copywith(isRecording: true, points: []));
      }
    });

    on<GeoStopRecordingEvent>((event, emit) {
      if (state is GeoLoaded) {
        final currState = state as GeoLoaded;
        final newHistory = List<List<Geo>>.from(currState.history);
        newHistory.add(currState.points);
        emit(
          currState.copywith(
            isRecording: false,
            history: newHistory,
            points: [],
            // Biarkan polyline tetap ada
          ),
        );
      }
    });

    add(GeoInitEvent());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
