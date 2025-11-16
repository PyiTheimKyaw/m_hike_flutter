import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import '../database/database_helper.dart';

class HikeConfirmationScreen extends StatefulWidget {
  final Hike hike;

  const HikeConfirmationScreen({super.key, required this.hike});

  @override
  State<HikeConfirmationScreen> createState() => _HikeConfirmationScreenState();
}

class _HikeConfirmationScreenState extends State<HikeConfirmationScreen> {
  late Hike _hike;

  @override
  void initState() {
    super.initState();
    _hike = widget.hike;
  }

  void _editHike() {
    // Navigate back to edit
    Navigator.pop(context);
  }

  Future<void> _confirmHike() async {
    final dbHelper = DatabaseHelper.instance;
    try {
      if (_hike.id == null) {
        // New hike
        await dbHelper.insertHike(_hike);
      } else {
        // Update existing hike
        await dbHelper.updateHike(_hike);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _hike.id == null
                  ? 'Hike saved successfully!'
                  : 'Hike updated successfully!',
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving hike: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
        title: const Text('Confirm Hike Details'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade700,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Please review your hike details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Hike Details Card
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
                    _buildInfoRow('Name of Hike', _hike.name, Icons.landscape),
                    _buildInfoRow(
                      'Location',
                      _hike.location,
                      Icons.location_on,
                    ),
                    _buildInfoRow(
                      'Date',
                      DateFormat('yyyy-MM-dd').format(_hike.date),
                      Icons.calendar_today,
                    ),
                    _buildInfoRow(
                      'Parking Available',
                      _hike.parkingAvailable,
                      Icons.local_parking,
                    ),
                    _buildInfoRow('Length', _hike.length, Icons.straighten),
                    _buildInfoRow(
                      'Difficulty',
                      _hike.difficulty,
                      Icons.trending_up,
                    ),
                    if (_hike.description != null &&
                        _hike.description!.isNotEmpty)
                      _buildInfoRow(
                        'Description',
                        _hike.description!,
                        Icons.description,
                      ),
                    if (_hike.weatherConditions != null &&
                        _hike.weatherConditions!.isNotEmpty)
                      _buildInfoRow(
                        'Weather Conditions',
                        _hike.weatherConditions!,
                        Icons.wb_sunny,
                      ),
                    if (_hike.estimatedDuration != null &&
                        _hike.estimatedDuration!.isNotEmpty)
                      _buildInfoRow(
                        'Estimated Duration',
                        _hike.estimatedDuration!,
                        Icons.access_time,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _editHike,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.green.shade700, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Edit Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirmHike,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirm & Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
