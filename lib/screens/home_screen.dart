import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import '../database/database_helper.dart';
import 'add_hike_screen.dart';
import 'search_screen.dart';
import 'hike_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Hike> _hikes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHikes();
  }

  Future<void> _loadHikes() async {
    setState(() => _isLoading = true);
    final hikes = await _dbHelper.getAllHikes();
    setState(() {
      _hikes = hikes;
      _isLoading = false;
    });
  }

  Future<void> _deleteAllHikes() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Delete All Hikes'),
        content: const Text(
          'Are you sure you want to delete all hikes? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.deleteAllHikes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All hikes deleted'),
            backgroundColor: Colors.green,
          ),
        );
        _loadHikes();
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.terrain, color: Colors.white),
        title: const Text('My Hikes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              ).then((_) => _loadHikes());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _hikes.isEmpty ? null : _deleteAllHikes,
            tooltip: 'Delete All Hikes',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hikes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.terrain, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 20),
                  Text(
                    'No hikes yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap the + button to add your first hike',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _hikes.length,
              itemBuilder: (context, index) {
                final hike = _hikes[index];
                final status = _getStatus(hike.date);
                final statusIcon = _getStatusIcon(hike.date);
                final dateFormat = DateFormat('MMMM dd, yyyy');
                final formattedDate = dateFormat.format(hike.date);

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
                              builder: (context) =>
                                  HikeDetailScreen(hike: hike),
                            ),
                          ).then((_) => _loadHikes());
                        } else if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddHikeScreen(hike: hike),
                            ),
                          ).then((_) => _loadHikes());
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
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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
                              _loadHikes();
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
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
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
                      ).then((_) => _loadHikes());
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHikeScreen()),
          ).then((_) => _loadHikes());
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
