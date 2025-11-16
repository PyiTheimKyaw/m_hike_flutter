import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import '../models/observation.dart';
import '../database/database_helper.dart';
import 'add_observation_screen.dart';

class ObservationsListScreen extends StatefulWidget {
  final Hike hike;

  const ObservationsListScreen({super.key, required this.hike});

  @override
  State<ObservationsListScreen> createState() => _ObservationsListScreenState();
}

class _ObservationsListScreenState extends State<ObservationsListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Observation> _observations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadObservations();
  }

  Future<void> _loadObservations() async {
    setState(() => _isLoading = true);
    final observations = await _dbHelper.getObservationsForHike(
      widget.hike.id!,
    );
    setState(() {
      _observations = observations;
      _isLoading = false;
    });
  }

  Future<void> _deleteObservation(Observation observation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Observation'),
        content: const Text(
          'Are you sure you want to delete this observation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbHelper.deleteObservation(observation.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Observation deleted successfully'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        _loadObservations();
      }
    }
  }

  void _editObservation(Observation observation) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddObservationScreen(hike: widget.hike, observation: observation),
      ),
    );
    if (result == true) {
      _loadObservations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Observations - ${widget.hike.name}'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddObservationScreen(hike: widget.hike),
            ),
          );
          if (result == true) {
            _loadObservations();
          }
        },
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _observations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_off,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No observations yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add an observation',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadObservations,
              child: ListView.builder(
                itemCount: _observations.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final observation = _observations[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        if (observation.photoPath != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            child: Image.file(
                              File(observation.photoPath!),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade700,
                            child: const Icon(
                              Icons.visibility,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            observation.observation,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time: ${DateFormat('yyyy-MM-dd HH:mm').format(observation.time)}',
                              ),
                              if (observation.comments != null &&
                                  observation.comments!.isNotEmpty)
                                Text('Comments: ${observation.comments}'),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editObservation(observation);
                              } else if (value == 'delete') {
                                _deleteObservation(observation);
                              }
                            },
                          ),
                          onTap: () {
                            _editObservation(observation);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
