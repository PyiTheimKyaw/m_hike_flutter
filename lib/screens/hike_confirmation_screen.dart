import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import '../database/database_helper.dart';

Future<void> showHikeConfirmationDialog(
  BuildContext context,
  Hike hike,
  bool isEditing,
) async {
  final dateFormat = DateFormat('MMMM dd, yyyy');
  final formattedDate = dateFormat.format(hike.date);
  final lengthInMiles = (hike.length * 0.621371).toStringAsFixed(1);

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Review Hike Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Hike Name', hike.name),
                      _buildDetailRow('Location', hike.location),
                      _buildDetailRow('Date', formattedDate),
                      _buildDetailRow(
                        'Parking Available',
                        hike.parkingAvailable,
                      ),
                      _buildDetailRow('Length', '$lengthInMiles mi'),
                      _buildDetailRow('Difficulty', hike.difficulty),
                      if (hike.description != null &&
                          hike.description!.isNotEmpty)
                        _buildDetailRow('Description', hike.description!),
                      if (hike.weatherCondition != null &&
                          hike.weatherCondition!.isNotEmpty)
                        _buildDetailRow(
                          'Weather Condition',
                          hike.weatherCondition!,
                        ),
                      if (hike.estimatedDuration != null &&
                          hike.estimatedDuration!.isNotEmpty)
                        _buildDetailRow(
                          'Estimated Duration',
                          hike.estimatedDuration!,
                        ),
                    ],
                  ),
                ),
              ),
              // Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Go Back',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _saveHike(context, hike, isEditing),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.white)),
      ],
    ),
  );
}

Future<void> _saveHike(BuildContext context, Hike hike, bool isEditing) async {
  final dbHelper = DatabaseHelper.instance;

  try {
    if (isEditing) {
      await dbHelper.updateHike(hike);
    } else {
      await dbHelper.insertHike(hike);
    }

    if (context.mounted) {
      // Close dialog and pop add/edit screen
      Navigator.pop(context); // Close dialog
      Navigator.pop(context); // Pop add/edit screen

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Hike updated successfully!'
                : 'Hike saved successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context); // Close dialog on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving hike: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
