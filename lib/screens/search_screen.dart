import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import '../database/database_helper.dart';
import '../widgets/custom_text_field.dart';
import 'hike_detail_screen.dart';
import 'add_hike_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  double _minLength = 2.0;
  double _maxLength = 16.0;
  DateTime? _startDate;
  DateTime? _endDate;

  List<Hike> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_nameController.text.trim().isEmpty &&
        _locationController.text.trim().isEmpty &&
        _startDate == null &&
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one search criteria'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSearching = true);

    final results = await _dbHelper.advancedSearch(
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      minLength: _minLength,
      maxLength: _maxLength,
      startDate: _startDate,
      endDate: _endDate,
    );

    setState(() {
      _searchResults = results;
      _isSearching = false;
      _hasSearched = true;
    });
  }

  void _resetFilters() {
    setState(() {
      _nameController.clear();
      _locationController.clear();
      _minLength = 2.0;
      _maxLength = 16.0;
      _startDate = null;
      _endDate = null;
      _searchResults = [];
      _hasSearched = false;
    });
  }

  String _getStatus(DateTime date) {
    final now = DateTime.now();
    if (date.isBefore(now)) {
      return 'Completed';
    } else {
      return 'Planned';
    }
  }

  IconData _getStatusIcon(DateTime date) {
    final now = DateTime.now();
    if (date.isBefore(now)) {
      return Icons.hiking;
    } else {
      return Icons.flag;
    }
  }

  Future<void> _refreshResults() async {
    await _performSearch();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
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
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
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
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.terrain, color: Colors.white),
        title: const Text('Find a Hike'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search by Name
          CustomTextField(
            controller: _nameController,
            hintText: 'Search by hike name...',
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
          ),
          const SizedBox(height: 16),

          // Location
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _locationController,
            hintText: 'Enter a city, park or region',
          ),
          const SizedBox(height: 20),

          // Hike Length Slider
          const Text(
            'Hike Length',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${_minLength.toStringAsFixed(0)}km',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              Expanded(
                child: RangeSlider(
                  values: RangeValues(_minLength, _maxLength),
                  min: 2.0,
                  max: 20.0,
                  divisions: 18,
                  labels: RangeLabels(
                    '${_minLength.toStringAsFixed(0)}km',
                    '${_maxLength.toStringAsFixed(0)}km',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _minLength = values.start;
                      _maxLength = values.end;
                    });
                  },
                ),
              ),
              Text(
                '${_maxLength.toStringAsFixed(0)}km',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Date Range
          const Text(
            'Date Range',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectStartDate,
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
                          _startDate == null
                              ? 'Select Date'
                              : dateFormat.format(_startDate!),
                          style: TextStyle(
                            color: _startDate == null
                                ? Colors.grey[500]
                                : Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'From',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _selectEndDate,
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
                          _endDate == null
                              ? 'Select Date'
                              : dateFormat.format(_endDate!),
                          style: TextStyle(
                            color: _endDate == null
                                ? Colors.grey[500]
                                : Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'To',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[700]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSearching ? null : _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSearching
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Apply Filters',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search Results
          if (_isSearching)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_hasSearched && _searchResults.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey[600]),
                    const SizedBox(height: 20),
                    Text(
                      'No results found',
                      style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Try adjusting your search criteria',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_hasSearched && _searchResults.isNotEmpty) ...[
            Text(
              'Search Results (${_searchResults.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ..._searchResults.map((hike) {
              final status = _getStatus(hike.date);
              final statusIcon = _getStatusIcon(hike.date);
              final dateFormatFull = DateFormat('MMMM dd, yyyy');
              final formattedDate = dateFormatFull.format(hike.date);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(statusIcon, color: Colors.white, size: 28),
                  ),
                  title: Text(
                    hike.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '$formattedDate • $status',
                      style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    color: Theme.of(context).colorScheme.surface,
                    onSelected: (value) async {
                      if (value == 'view') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HikeDetailScreen(hike: hike),
                          ),
                        ).then((_) => _refreshResults());
                      } else if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddHikeScreen(hike: hike),
                          ),
                        ).then((_) => _refreshResults());
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            title: const Text('Delete Hike'),
                            content: Text(
                              'Are you sure you want to delete "${hike.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await _dbHelper.deleteHike(hike.id!);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Hike deleted'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _refreshResults();
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 8),
                            Text('View'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HikeDetailScreen(hike: hike),
                      ),
                    ).then((_) => _refreshResults());
                  },
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
