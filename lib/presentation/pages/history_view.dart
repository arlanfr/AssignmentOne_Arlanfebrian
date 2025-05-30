import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../managers/geo_bloc.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
        centerTitle: true,
        elevation: 2,
      ),
      body: BlocBuilder<GeoBloc, GeoState>(
        builder: (context, state) {
          if (state is GeoLoaded) {
            final history = state.history;
            if (history.isEmpty) {
              return const Center(
                child: Text(
                  'No history available.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final route = history[index];
                final start = route.first;
                final _ = route.last;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(
                      'Trip ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${route.length} points • Start: ${start.latitude.toStringAsFixed(4)}, ${start.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    leading: const Icon(Icons.route, color: Colors.blue),
                    children:
                        route
                            .map(
                              (geo) => ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.location_on,
                                  color: Colors.redAccent,
                                ),
                                title: Text(
                                  'Lat: ${geo.latitude.toStringAsFixed(6)}, Lon: ${geo.longitude.toStringAsFixed(6)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                );
              },
            );
          } else if (state is GeoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GeoError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            return const Center(
              child: Text('Loading...', style: TextStyle(fontSize: 16)),
            );
          }
        },
      ),
    );
  }
}
