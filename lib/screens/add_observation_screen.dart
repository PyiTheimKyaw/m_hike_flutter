import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/hike.dart';
import '../models/observation.dart';
import '../database/database_helper.dart';
import '../services/location_service.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/custom_text_field.dart';

class AddObservationScreen extends StatefulWidget {
  final Hike hike;
  // has data edit mode,no data add mode
  final Observation? observation;

  const AddObservationScreen({super.key, required this.hike, this.observation});

  @override
  State<AddObservationScreen> createState() => _AddObservationScreenState();
}

class _AddObservationScreenState extends State<AddObservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _observationController = TextEditingController();
  final _commentsController = TextEditingController();
  final _customCategoryController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  DateTime _selectedDateTime = DateTime.now();
  final TextEditingController _locationController = TextEditingController();
  String? _photoPath;
  final ImagePicker _picker = ImagePicker();
  bool _isGettingLocation = false;
  bool _customCategoryError = false;
  bool _observationError = false;
  final List<String> _categories = [
    'Wildlife',
    'Weather',
    'Trail',
    'Safety',
    'Scenery',
    'Other',
  ];
  String _selectedCategory = 'Wildlife';

  @override
  void initState() {
    super.initState();
    _locationController.text = '40.7128° N, 74.0060° W';
    if (widget.observation != null) {
      // Editing mode
      _observationController.text = widget.observation!.observation;
      _selectedDateTime = widget.observation!.time;
      _commentsController.text = widget.observation!.additionalComments ?? '';
      _photoPath = widget.observation!.photoPath;
      if (_categories.contains(widget.observation!.category)) {
        _selectedCategory = widget.observation!.category;
      } else {
        _selectedCategory = 'Other';
        _customCategoryController.text = widget.observation!.category;
      }
      _locationController.text = widget.observation!.location;
      // get location from observation
      _isGettingLocation = false;
    } else {
      // New observation get location automatically
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _observationController.dispose();
    _commentsController.dispose();
    _customCategoryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
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

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
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

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        // get address first
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (mounted) {
          setState(() {
            _locationController.text =
                address ??
                LocationService.formatCoordinates(
                  position.latitude,
                  position.longitude,
                );
            _isGettingLocation = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isGettingLocation = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _addPhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.camera);
              },
            ),
            if (_photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _photoPath = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        // Copy image to app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            'observation_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final savedImage = File(
          path.join(appDir.path, 'observations', fileName),
        );

        // Create directory if not have
        await savedImage.parent.create(recursive: true);

        // Copy the file
        await File(image.path).copy(savedImage.path);

        setState(() {
          _photoPath = savedImage.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveObservation() async {
    // reset error states
    setState(() {
      _observationError = false;
      _customCategoryError = false;
    });

    // validate required fields
    bool isValid = true;
    List<String> missingFields = [];

    if (_observationController.text.trim().isEmpty) {
      setState(() {
        _observationError = true;
      });
      isValid = false;
      missingFields.add('Observation');
    }

    if (_selectedCategory == 'Other' &&
        _customCategoryController.text.trim().isEmpty) {
      setState(() {
        _customCategoryError = true;
      });
      isValid = false;
      missingFields.add('Category name (for "Other")');
    }

    if (!isValid) {
      // Show validation error dialog
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

    final categoryValue = _selectedCategory == 'Other'
        ? _customCategoryController.text.trim()
        : _selectedCategory;

    final observation = Observation(
      id: widget.observation?.id,
      hikeId: widget.hike.id!,
      observation: _observationController.text.trim(),
      time: _selectedDateTime,
      category: categoryValue.isEmpty ? 'Other' : categoryValue,
      location: _locationController.text.trim().isEmpty
          ? 'Unknown location'
          : _locationController.text.trim(),
      additionalComments: _commentsController.text.trim().isEmpty
          ? null
          : _commentsController.text.trim(),
      photoPath: _photoPath,
    );

    try {
      if (widget.observation != null) {
        await _dbHelper.updateObservation(observation);
      } else {
        await _dbHelper.insertObservation(observation);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.observation != null
                  ? 'Observation updated successfully!'
                  : 'Observation saved successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy, hh:mm a');
    final formattedDateTime = dateFormat.format(_selectedDateTime);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.observation == null ? 'New Observation' : 'Edit Observation',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Observation Input
            const Text(
              'Observation*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              controller: _observationController,
              hintText: 'Saw a red-tailed hawk...',
              maxLines: 3,
              showError: _observationError,
              errorMessage: _observationError
                  ? 'Observation is required'
                  : null,
              onChanged: (value) {
                if (_observationError && value.trim().isNotEmpty) {
                  setState(() {
                    _observationError = false;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Category Selection
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final bool isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category;
                        if (category != 'Other') {
                          _customCategoryController.clear();
                          _customCategoryError = false;
                        }
                      });
                    }
                  },
                  backgroundColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey[800]!,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            if (_selectedCategory == 'Other') ...[
              CustomTextField(
                controller: _customCategoryController,
                labelText: 'Custom Category',
                showError: _customCategoryError,
                errorMessage: _customCategoryError
                    ? 'Please enter a category name'
                    : null,
                onChanged: (value) {
                  if (_customCategoryError && value.trim().isNotEmpty) {
                    setState(() {
                      _customCategoryError = false;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
            ],

            // Photo Section
            if (_photoPath != null) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_photoPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.red, size: 50),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addPhoto,
                icon: Icon(_photoPath != null ? Icons.edit : Icons.camera_alt),
                label: Text(_photoPath != null ? 'Change Photo' : 'Add Photo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Date & Time
            const Text(
              'Date & Time*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDateTime,
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
                      formattedDateTime,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.white70),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Location
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Location',
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
                    _isGettingLocation ? 'Getting...' : 'Update',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _locationController,
              hintText: 'Enter location or coordinates',
              maxLines: 2,
              suffixIcon: const Icon(Icons.location_on, color: Colors.white70),
            ),
            const SizedBox(height: 20),

            // Additional Comments
            const Text(
              'Additional Comments',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              controller: _commentsController,
              hintText: 'Optional notes...',
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveObservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Observation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
