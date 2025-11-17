import 'package:flutter/material.dart';
import '../models/hike.dart';
import '../models/observation.dart';
import '../database/database_helper.dart';
import 'observation_detail_screen.dart';

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
    final observations = await _dbHelper.getObservationsByHikeId(
      widget.hike.id!,
    );
    setState(() {
      _observations = observations;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Observations - ${widget.hike.name}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _observations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility_off, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 20),
                  Text(
                    'No observations yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _observations.length,
              itemBuilder: (context, index) {
                final observation = _observations[index];
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
                      child: const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      observation.observation,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${observation.time.day}/${observation.time.month}/${observation.time.year}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ObservationDetailScreen(
                            observation: observation,
                            hike: widget.hike,
                          ),
                        ),
                      ).then((_) => _loadObservations());
                    },
                  ),
                );
              },
            ),
    );
  }
}
