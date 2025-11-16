import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import 'observations_list_screen.dart';
import 'add_hike_screen.dart';

class HikeDetailScreen extends StatelessWidget {
  final Hike hike;

  const HikeDetailScreen({super.key, required this.hike});

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hike.name),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddHikeScreen(hike: hike),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hike Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildInfoRow('Name of Hike', hike.name, Icons.landscape),
                    _buildInfoRow('Location', hike.location, Icons.location_on),
                    _buildInfoRow(
                      'Date',
                      DateFormat('yyyy-MM-dd').format(hike.date),
                      Icons.calendar_today,
                    ),
                    _buildInfoRow(
                      'Parking Available',
                      hike.parkingAvailable,
                      Icons.local_parking,
                    ),
                    _buildInfoRow('Length', hike.length, Icons.straighten),
                    _buildInfoRow(
                      'Difficulty',
                      hike.difficulty,
                      Icons.trending_up,
                    ),
                    if (hike.description != null &&
                        hike.description!.isNotEmpty)
                      _buildInfoRow(
                        'Description',
                        hike.description!,
                        Icons.description,
                      ),
                    if (hike.weatherConditions != null &&
                        hike.weatherConditions!.isNotEmpty)
                      _buildInfoRow(
                        'Weather Conditions',
                        hike.weatherConditions!,
                        Icons.wb_sunny,
                      ),
                    if (hike.estimatedDuration != null &&
                        hike.estimatedDuration!.isNotEmpty)
                      _buildInfoRow(
                        'Estimated Duration',
                        hike.estimatedDuration!,
                        Icons.access_time,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ObservationsListScreen(hike: hike),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View Observations'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
