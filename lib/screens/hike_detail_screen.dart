import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import '../models/observation.dart';
import '../database/database_helper.dart';
import 'add_observation_screen.dart';
import 'observations_list_screen.dart';
import 'observation_detail_screen.dart';
import 'map_screen.dart';

class HikeDetailScreen extends StatefulWidget {
  final Hike hike;

  const HikeDetailScreen({super.key, required this.hike});

  @override
  State<HikeDetailScreen> createState() => _HikeDetailScreenState();
}

class _HikeDetailScreenState extends State<HikeDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Observation> _observations = [];
  bool _isLoading = true;
  bool _descriptionExpanded = false;
  bool _routeDetailsExpanded = false;
  bool _parkingInfoExpanded = false;

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

  String _getDifficultyText() {
    switch (widget.hike.difficulty) {
      case 'Easy':
        return 'Easy';
      case 'Moderate':
        return 'Moderate';
      case 'Hard':
        return 'Hard';
      default:
        return widget.hike.difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lengthInMiles = (widget.hike.length * 0.621371).toStringAsFixed(1);
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final formattedDate = dateFormat.format(widget.hike.date);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(widget.hike.name),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                child: Image.asset(
                  'assets/images/hike_hero.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      child: const Icon(
                        Icons.terrain,
                        size: 100,
                        color: Colors.white70,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Distance', '$lengthInMiles mi'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Time',
                          widget.hike.estimatedDuration ?? 'N/A',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Difficulty',
                          _getDifficultyText(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Parking',
                          widget.hike.parkingAvailable,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  _buildExpandableSection(
                    title: 'Description',
                    isExpanded: _descriptionExpanded,
                    onTap: () {
                      setState(() {
                        _descriptionExpanded = !_descriptionExpanded;
                      });
                    },
                    child: Text(
                      widget.hike.description ?? 'No description provided.',
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Route Details Section
                  _buildExpandableSection(
                    title: 'Route Details',
                    isExpanded: _routeDetailsExpanded,
                    onTap: () {
                      setState(() {
                        _routeDetailsExpanded = !_routeDetailsExpanded;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildDetailRow(
                                'Location',
                                widget.hike.location,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.map,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapScreen(
                                      locationName: widget.hike.location,
                                      title: widget.hike.name,
                                    ),
                                  ),
                                );
                              },
                              tooltip: 'View on Map',
                            ),
                          ],
                        ),
                        _buildDetailRow('Date', formattedDate),
                        if (widget.hike.weatherCondition != null)
                          _buildDetailRow(
                            'Weather',
                            widget.hike.weatherCondition!,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Parking Information Section
                  _buildExpandableSection(
                    title: 'Parking Information',
                    isExpanded: _parkingInfoExpanded,
                    onTap: () {
                      setState(() {
                        _parkingInfoExpanded = !_parkingInfoExpanded;
                      });
                    },
                    child: Text(
                      widget.hike.parkingAvailable == 'Yes'
                          ? 'Parking is available at the trailhead.'
                          : 'Parking is not available. Please plan accordingly.',
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Observations Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Observations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (_observations.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ObservationsListScreen(hike: widget.hike),
                              ),
                            ).then((_) => _loadObservations());
                          },
                          child: const Text('View All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_observations.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No observations yet.\nTap the camera button to add one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _observations.length > 3
                            ? 3
                            : _observations.length,
                        itemBuilder: (context, index) {
                          final observation = _observations[index];
                          return _buildObservationCard(observation);
                        },
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddObservationScreen(hike: widget.hike),
            ),
          ).then((_) => _loadObservations());
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
            onTap: onTap,
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationCard(Observation observation) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final formattedDate = dateFormat.format(observation.time);
    final previewText = observation.observation.length > 30
        ? '${observation.observation.substring(0, 30)}...'
        : observation.observation;

    return InkWell(
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
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child:
                  observation.photoPath != null &&
                      File(observation.photoPath!).existsSync()
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.file(
                        File(observation.photoPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image, color: Colors.white70);
                        },
                      ),
                    )
                  : const Icon(Icons.image, size: 50, color: Colors.white70),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    previewText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
