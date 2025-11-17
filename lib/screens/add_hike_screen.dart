import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import '../services/location_service.dart';
import '../widgets/custom_text_form_field.dart';
import 'hike_confirmation_screen.dart' show showHikeConfirmationDialog;

class AddHikeScreen extends StatefulWidget {
  final Hike? hike; // If provided, we're editing; otherwise, we're adding

  const AddHikeScreen({super.key, this.hike});

  @override
  State<AddHikeScreen> createState() => _AddHikeScreenState();
}

class _AddHikeScreenState extends State<AddHikeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _lengthController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weatherConditionController = TextEditingController();
  final _estimatedDurationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _parkingAvailable = true;
  String _difficulty = 'Easy';
  bool _isGettingLocation = false;

  // Error states
  bool _nameError = false;
  bool _locationError = false;
  bool _lengthError = false;
  String? _lengthErrorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.hike != null) {
      // Editing mode - populate fields
      _nameController.text = widget.hike!.name;
      _locationController.text = widget.hike!.location;
      _selectedDate = widget.hike!.date;
      _parkingAvailable = widget.hike!.parkingAvailable == 'Yes';
      _lengthController.text = (widget.hike!.length * 0.621371).toStringAsFixed(
        1,
      ); // Convert km to miles
      _difficulty = widget.hike!.difficulty;
      _descriptionController.text = widget.hike!.description ?? '';
      _weatherConditionController.text = widget.hike!.weatherCondition ?? '';
      _estimatedDurationController.text = widget.hike!.estimatedDuration ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _lengthController.dispose();
    _descriptionController.dispose();
    _weatherConditionController.dispose();
    _estimatedDurationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final address = await LocationService.getCurrentLocationAddress();
      if (address != null && mounted) {
        setState(() {
          _locationController.text = address;
          _isGettingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (mounted) {
          setState(() {
            _isGettingLocation = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Unable to get location. Please check location permissions.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _validateAndSave() async {
    // Reset error states
    setState(() {
      _nameError = false;
      _locationError = false;
      _lengthError = false;
      _lengthErrorMessage = null;
    });

    // Validate required fields
    bool isValid = true;
    List<String> missingFields = [];

    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = true;
      });
      isValid = false;
      missingFields.add('Hike Name');
    }

    if (_locationController.text.trim().isEmpty) {
      setState(() {
        _locationError = true;
      });
      isValid = false;
      missingFields.add('Location');
    }

    if (_lengthController.text.trim().isEmpty) {
      setState(() {
        _lengthError = true;
        _lengthErrorMessage = 'Length is required';
      });
      isValid = false;
      missingFields.add('Length');
    } else {
      // Parse length (convert miles to km for storage)
      final lengthInMiles = double.tryParse(_lengthController.text.trim());
      if (lengthInMiles == null || lengthInMiles <= 0) {
        setState(() {
          _lengthError = true;
          _lengthErrorMessage = 'Please enter a valid length';
        });
        isValid = false;
      }
    }

    if (!isValid) {
      // Show dialog if there are missing required fields
      if (missingFields.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: const Text('Required Fields Missing'),
            content: Text(
              'Please fill all required fields:\n\n• ${missingFields.join('\n• ')}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    final lengthInMiles = double.parse(_lengthController.text.trim());
    final lengthInKm = lengthInMiles / 0.621371; // Convert miles to km

    // Create hike object
    final hike = Hike(
      id: widget.hike?.id,
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      date: _selectedDate,
      parkingAvailable: _parkingAvailable ? 'Yes' : 'No',
      length: lengthInKm,
      difficulty: _difficulty,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      weatherCondition: _weatherConditionController.text.trim().isEmpty
          ? null
          : _weatherConditionController.text.trim(),
      estimatedDuration: _estimatedDurationController.text.trim().isEmpty
          ? null
          : _estimatedDurationController.text.trim(),
    );

    // Show confirmation dialog
    await showHikeConfirmationDialog(context, hike, widget.hike != null);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final formattedDate = dateFormat.format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.hike == null ? 'Plan a New Hike' : 'Edit Hike'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Hike Name (Required)
            const Text(
              'Hike Name*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              controller: _nameController,
              hintText: 'e.g., Lakeview Mountain Trail',
              showError: _nameError,
              errorText: _nameError ? 'Hike name is required' : null,
              onChanged: (value) {
                if (_nameError && value.trim().isNotEmpty) {
                  setState(() {
                    _nameError = false;
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // Location (Required)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Location*',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                TextButton.icon(
                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  icon: _isGettingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.my_location, size: 18),
                  label: Text(
                    _isGettingLocation ? 'Getting...' : 'Use Current',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              controller: _locationController,
              hintText: 'Search for a trailhead or address',
              showError: _locationError,
              errorText: _locationError ? 'Location is required' : null,
              suffixIcon: const Icon(Icons.location_on, color: Colors.white70),
              onChanged: (value) {
                if (_locationError && value.trim().isNotEmpty) {
                  setState(() {
                    _locationError = false;
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // Date (Required)
            const Text(
              'Date*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.white70),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Hike Details (Optional) Section
            const Text(
              'Hike Details (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Length (Required)
            const Text(
              'Length (mi)*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              controller: _lengthController,
              hintText: 'e.g., 5.5',
              keyboardType: TextInputType.number,
              showError: _lengthError,
              errorText:
                  _lengthErrorMessage ??
                  (_lengthError ? 'Length is required' : null),
              onChanged: (value) {
                if (_lengthError && value.trim().isNotEmpty) {
                  final lengthValue = double.tryParse(value.trim());
                  if (lengthValue != null && lengthValue > 0) {
                    setState(() {
                      _lengthError = false;
                      _lengthErrorMessage = null;
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 20),

            // Parking (Required)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Parking*',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _parkingAvailable ? 'Available' : 'Not Available',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _parkingAvailable,
                      onChanged: (value) {
                        setState(() {
                          _parkingAvailable = value;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Difficulty (Required)
            const Text(
              'Difficulty*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildDifficultySegment('Easy')),
                  Expanded(child: _buildDifficultySegment('Moderate')),
                  Expanded(child: _buildDifficultySegment('Hard')),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Weather Condition (Optional - Custom field)
            const Text(
              'Weather Condition',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              controller: _weatherConditionController,
              hintText: 'e.g., Sunny, Cloudy, Rainy',
            ),
            const SizedBox(height: 20),

            // Estimated Duration (Optional - Custom field)
            const Text(
              'Estimated Duration',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              controller: _estimatedDurationController,
              hintText: 'e.g., 3 hours, 2-3 hours',
            ),
            const SizedBox(height: 20),

            // Description/Notes (Optional)
            const Text(
              'Description/Notes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              controller: _descriptionController,
              hintText: 'Add notes about trail conditions, gear, etc.',
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _validateAndSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Hike',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySegment(String difficulty) {
    final isSelected = _difficulty == difficulty;
    return InkWell(
      onTap: () {
        setState(() {
          _difficulty = difficulty;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          difficulty,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
