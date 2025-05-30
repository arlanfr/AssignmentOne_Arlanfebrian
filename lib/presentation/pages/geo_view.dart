import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as l2;
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

import '../../model/geo.dart';
import '../managers/geo_bloc.dart';
import 'auth_page.dart';
import 'history_view.dart';
import 'nfc_reader_screen.dart';

class GeoView extends StatefulWidget {
  const GeoView({super.key});

  @override
  State<GeoView> createState() => _GeoViewState();
}

class _GeoViewState extends State<GeoView> {
  late final CameraPosition cameraPosition;
  final _mapAltController = fmap.MapController();
  bool _isMapAltAvailable = false;

  @override
  void initState() {
    cameraPosition = const CameraPosition(target: LatLng(0, 0), zoom: 15);
    super.initState();
  }

  void _updateCameraPosition(Geo geo) {
    if (_isMapAltAvailable) {
      _mapAltController.move(l2.LatLng(geo.latitude, geo.longitude), 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GeoBloc, GeoState>(
      listener: (context, state) {
        if (state is GeoLoaded) {
          _updateCameraPosition(state.geo);
        }
      },
      builder: (context, state) {
        final isRecording = (state is GeoLoaded) ? state.isRecording : false;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Geo Tracking'),
            centerTitle: true,
            elevation: 2,
            actions: [
              IconButton(
                icon: const Icon(Icons.history, size: 28),
                tooltip: 'History',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HistoryView(),
                    ),
                  );
                },
              ),
              // NFC Menu Button
              PopupMenuButton<String>(
                icon: const Icon(Icons.nfc),
                onSelected: (value) {
                  if (value == 'read_nfc') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NfcReaderScreen(),
                      ),
                    );
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem<String>(
                        value: 'read_nfc',
                        child: Row(
                          children: [
                            Icon(Icons.nfc, color: Colors.black87),
                            SizedBox(width: 8),
                            Text('Read NFC Tag'),
                          ],
                        ),
                      ),
                    ],
              ),

              // Logout Button
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () {
                  // Navigasi ke AuthPage dan hapus semua rute sebelumnya
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: switch (state) {
                  GeoInitial() => _buildInitialView(),
                  GeoLoading() => _buildLoadingView(),
                  GeoLoaded() => fmap.FlutterMap(
                    mapController: _mapAltController,
                    options: fmap.MapOptions(
                      initialZoom: 16,
                      onMapReady: () {
                        setState(() {
                          _isMapAltAvailable = true;
                        });
                      },
                      initialCenter: l2.LatLng(
                        state.geo.latitude,
                        state.geo.longitude,
                      ),
                    ),
                    children: [
                      fmap.TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      fmap.MarkerLayer(
                        markers: [
                          fmap.Marker(
                            width: 48,
                            height: 48,
                            point: l2.LatLng(
                              state.geo.latitude,
                              state.geo.longitude,
                            ),
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.redAccent,
                              size: 48,
                            ),
                          ),
                          if (state.points.isNotEmpty)
                            fmap.Marker(
                              width: 60,
                              point: l2.LatLng(
                                state.points.first.latitude,
                                state.points.first.longitude,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.flag,
                                        color: Colors.green,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'Start',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (state.points.isNotEmpty)
                        fmap.PolylineLayer(
                          polylines: [
                            fmap.Polyline(
                              points:
                                  state.points
                                      .map(
                                        (e) =>
                                            l2.LatLng(e.latitude, e.longitude),
                                      )
                                      .toList(),
                              strokeWidth: 5.0,
                              color: Colors.blueAccent.withOpacity(0.8),
                            ),
                          ],
                        ),
                    ],
                  ),
                  GeoError() => _buildErrorView(
                    state.message ?? 'Error occurred',
                  ),
                },
              ),
              if (state is GeoLoaded)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _buildStatusCard(state),
                ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButtons(
            isRecording,
            context,
          ),
        );
      },
    );
  }

  Widget _buildInitialView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map, size: 64, color: Colors.blueGrey),
          SizedBox(height: 16),
          Text(
            'Press the location button to start',
            style: TextStyle(fontSize: 18, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'Getting location...',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<GeoBloc>().add(GeoGetLocationEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Retry', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(GeoLoaded state) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.95),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.gps_fixed, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  'Your Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
                const Spacer(),
                if (state.isRecording)
                  const Icon(
                    Icons.fiber_manual_record,
                    color: Colors.red,
                    size: 18,
                  ),
              ],
            ),
            const Divider(height: 16),
            Text('Latitude: ${state.geo.latitude.toStringAsFixed(6)}'),
            Text('Longitude: ${state.geo.longitude.toStringAsFixed(6)}'),
            if (state.isRecording)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timeline,
                      size: 20,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(width: 6),
                    Text('Points recorded: ${state.points.length}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons(bool isRecording, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'locationBtn',
          onPressed: () {
            context.read<GeoBloc>().add(GeoGetLocationEvent());
          },
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 6,
          child: const Icon(Icons.my_location, color: Colors.blue),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: 'recordBtn',
          onPressed: () {
            final bloc = context.read<GeoBloc>();
            isRecording
                ? bloc.add(GeoStopRecordingEvent())
                : bloc.add(GeoStartRecordingEvent());
          },
          backgroundColor: isRecording ? Colors.redAccent : Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 6,
          icon: Icon(isRecording ? Icons.stop : Icons.fiber_manual_record),
          label: Text(
            isRecording ? 'STOP' : 'RECORD',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
