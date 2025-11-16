import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import '../models/observation.dart';
import '../database/database_helper.dart';

class AddObservationScreen extends StatefulWidget {
  final Hike hike;
  final Observation? observation;

  const AddObservationScreen({super.key, required this.hike, this.observation});

  @override
  State<AddObservationScreen> createState() => _AddObservationScreenState();
}

class _AddObservationScreenState extends State<AddObservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _observationController = TextEditingController();
  final _commentsController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.observation != null) {
      final obs = widget.observation!;
      _observationController.text = obs.observation;
      _commentsController.text = obs.comments ?? '';
      _selectedDateTime = obs.time;
    }
  }

  @override
  void dispose() {
    _observationController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveObservation() async {
    if (_formKey.currentState!.validate()) {
      final dbHelper = DatabaseHelper.instance;
      final observation = Observation(
        id: widget.observation?.id,
        hikeId: widget.hike.id!,
        observation: _observationController.text.trim(),
        time: _selectedDateTime,
        comments: _commentsController.text.trim().isEmpty
            ? null
            : _commentsController.text.trim(),
      );

      try {
        if (observation.id == null) {
          await dbHelper.insertObservation(observation);
        } else {
          await dbHelper.updateObservation(observation);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                observation.id == null
                    ? 'Observation added successfully!'
                    : 'Observation updated successfully!',
              ),
              backgroundColor: Colors.green.shade700,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving observation: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.observation == null ? 'Add Observation' : 'Edit Observation',
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Hike info card
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.landscape, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.hike.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.hike.location,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Observation field
            TextFormField(
              controller: _observationController,
              decoration: const InputDecoration(
                labelText: 'Observation *',
                hintText: 'e.g., Saw a deer, Beautiful sunset, Trail was muddy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.visibility),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an observation';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Time field
            InkWell(
              onTap: () => _selectDateTime(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time of Observation *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                child: Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Comments field (Optional)
            TextFormField(
              controller: _commentsController,
              decoration: const InputDecoration(
                labelText: 'Additional Comments (Optional)',
                hintText: 'Enter any additional comments',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.comment),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: _saveObservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                widget.observation == null
                    ? 'Save Observation'
                    : 'Update Observation',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
