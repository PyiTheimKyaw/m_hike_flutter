import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import '../database/database_helper.dart';
import 'hike_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _simpleSearchController = TextEditingController();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _lengthController = TextEditingController();
  DateTime? _selectedDate;

  List<Hike> _searchResults = [];
  bool _isSearching = false;
  bool _showAdvancedSearch = false;

  @override
  void dispose() {
    _simpleSearchController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  Future<void> _simpleSearch() async {
    final query = _simpleSearchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a search term'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await _dbHelper.searchHikesByName(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });

    if (results.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No hikes found')));
    }
  }

  Future<void> _advancedSearch() async {
    setState(() {
      _isSearching = true;
    });

    final results = await _dbHelper.advancedSearch(
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      length: _lengthController.text.trim().isEmpty
          ? null
          : _lengthController.text.trim(),
      date: _selectedDate,
    );

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });

    if (results.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No hikes found')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _simpleSearchController.clear();
      _nameController.clear();
      _locationController.clear();
      _lengthController.clear();
      _selectedDate = null;
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Hikes'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showAdvancedSearch ? Icons.search : Icons.tune),
            onPressed: () {
              setState(() {
                _showAdvancedSearch = !_showAdvancedSearch;
                if (!_showAdvancedSearch) {
                  _searchResults = [];
                }
              });
            },
            tooltip: _showAdvancedSearch ? 'Simple Search' : 'Advanced Search',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search form
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade100,
            child: _showAdvancedSearch
                ? _buildAdvancedSearch()
                : _buildSimpleSearch(),
          ),

          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final hike = _searchResults[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade700,
                            child: const Icon(
                              Icons.landscape,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            hike.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location: ${hike.location}'),
                              Text(
                                'Date: ${DateFormat('yyyy-MM-dd').format(hike.date)}',
                              ),
                              Text('Difficulty: ${hike.difficulty}'),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HikeDetailScreen(hike: hike),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleSearch() {
    return Column(
      children: [
        TextField(
          controller: _simpleSearchController,
          decoration: InputDecoration(
            labelText: 'Search by Name',
            hintText: 'Enter hike name (partial match supported)',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _simpleSearchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _simpleSearchController.clear();
                        _searchResults = [];
                      });
                    },
                  )
                : null,
          ),
          onSubmitted: (_) => _simpleSearch(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _simpleSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Search'),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSearch() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name (Optional)',
            hintText: 'Enter hike name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.landscape),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Location (Optional)',
            hintText: 'Enter location',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _lengthController,
          decoration: const InputDecoration(
            labelText: 'Length (Optional)',
            hintText: 'Enter length',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.straighten),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Date (Optional)',
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clearSearch,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Clear'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _advancedSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Search'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
