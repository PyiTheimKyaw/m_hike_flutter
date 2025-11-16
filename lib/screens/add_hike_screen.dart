import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import 'hike_confirmation_screen.dart';

class AddHikeScreen extends StatefulWidget {
  final Hike? hike;

  const AddHikeScreen({super.key, this.hike});

  @override
  State<AddHikeScreen> createState() => _AddHikeScreenState();
}

class _AddHikeScreenState extends State<AddHikeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _lengthController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weatherConditionsController = TextEditingController();
  final _estimatedDurationController = TextEditingController();

  // State variables
  DateTime? _selectedDate;
  String? _parkingAvailable;
  String? _difficulty;

  // Difficulty options
  final List<String> _difficultyOptions = [
    'Easy',
    'Moderate',
    'Hard',
    'Very Hard',
  ];

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with existing hike data
    if (widget.hike != null) {
      final hike = widget.hike!;
      _nameController.text = hike.name;
      _locationController.text = hike.location;
      _selectedDate = hike.date;
      _parkingAvailable = hike.parkingAvailable;
      _lengthController.text = hike.length;
      _difficulty = hike.difficulty;
      _descriptionController.text = hike.description ?? '';
      _weatherConditionsController.text = hike.weatherConditions ?? '';
      _estimatedDurationController.text = hike.estimatedDuration ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _lengthController.dispose();
    _descriptionController.dispose();
    _weatherConditionsController.dispose();
    _estimatedDurationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check if all required fields are filled
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date for the hike'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_parkingAvailable == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select parking availability'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_difficulty == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select difficulty level'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create Hike object
      final hike = Hike(
        id: widget.hike?.id,
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        date: _selectedDate!,
        parkingAvailable: _parkingAvailable!,
        length: _lengthController.text.trim(),
        difficulty: _difficulty!,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        weatherConditions: _weatherConditionsController.text.trim().isEmpty
            ? null
            : _weatherConditionsController.text.trim(),
        estimatedDuration: _estimatedDurationController.text.trim().isEmpty
            ? null
            : _estimatedDurationController.text.trim(),
      );

      // Navigate to confirmation screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HikeConfirmationScreen(hike: hike),
        ),
      );
      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hike == null ? 'Add New Hike' : 'Edit Hike'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name of Hike *',
                hintText: 'e.g., Snowdon, Trosley Country Park',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.landscape),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the name of the hike';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Location field
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location *',
                hintText: 'Enter the location of the hike',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date field
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date of the Hike *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Select date'
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  style: TextStyle(
                    color: _selectedDate == null
                        ? Colors.grey.shade600
                        : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Parking available field
            DropdownButtonFormField<String>(
              value: _parkingAvailable,
              decoration: const InputDecoration(
                labelText: 'Parking Available *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_parking),
              ),
              items: const [
                DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                DropdownMenuItem(value: 'No', child: Text('No')),
              ],
              onChanged: (value) {
                setState(() {
                  _parkingAvailable = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select parking availability';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Length field
            TextFormField(
              controller: _lengthController,
              decoration: const InputDecoration(
                labelText: 'Length of Hike *',
                hintText: 'e.g., 5 km, 3.2 miles',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.straighten),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the length of the hike';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Difficulty field
            DropdownButtonFormField<String>(
              value: _difficulty,
              decoration: const InputDecoration(
                labelText: 'Level of Difficulty *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.trending_up),
              ),
              items: _difficultyOptions.map((String difficulty) {
                return DropdownMenuItem<String>(
                  value: difficulty,
                  child: Text(difficulty),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _difficulty = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select difficulty level';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description field (Optional)
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter a description of the hike',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Weather Conditions field (Optional - Creative field 1)
            TextFormField(
              controller: _weatherConditionsController,
              decoration: const InputDecoration(
                labelText: 'Weather Conditions (Optional)',
                hintText: 'e.g., Sunny, Cloudy, Rainy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wb_sunny),
              ),
            ),
            const SizedBox(height: 16),

            // Estimated Duration field (Optional - Creative field 2)
            TextFormField(
              controller: _estimatedDurationController,
              decoration: const InputDecoration(
                labelText: 'Estimated Duration (Optional)',
                hintText: 'e.g., 2 hours, 3-4 hours',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continue to Confirmation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
