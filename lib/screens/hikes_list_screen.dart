import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import '../database/database_helper.dart';
import 'hike_detail_screen.dart';
import 'add_hike_screen.dart';

class HikesListScreen extends StatefulWidget {
  const HikesListScreen({super.key});

  @override
  State<HikesListScreen> createState() => _HikesListScreenState();
}

class _HikesListScreenState extends State<HikesListScreen> {
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

  Future<void> _deleteHike(Hike hike) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hike'),
        content: Text('Are you sure you want to delete "${hike.name}"?'),
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
      await _dbHelper.deleteHike(hike.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${hike.name}" deleted successfully'),
            backgroundColor: const Color(0xFF2E7D32), // green.shade700
          ),
        );
        _loadHikes();
      }
    }
  }

  Future<void> _deleteAllHikes() async {
    if (_hikes.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No hikes to delete')));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database'),
        content: const Text(
          'Are you sure you want to delete ALL hikes? This action cannot be undone.',
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

    if (confirmed == true) {
      await _dbHelper.deleteAllHikes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All hikes deleted successfully'),
            backgroundColor: const Color(0xFF2E7D32), // green.shade700
          ),
        );
        _loadHikes();
      }
    }
  }

  void _editHike(Hike hike) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddHikeScreen(hike: hike)),
    );
    if (result == true) {
      _loadHikes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Hikes'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_hikes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Delete All',
              onPressed: _deleteAllHikes,
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
                  Icon(Icons.landscape, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No hikes yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first hike to get started!',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadHikes,
              child: ListView.builder(
                itemCount: _hikes.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final hike = _hikes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(
                          0xFF2E7D32,
                        ), // green.shade700
                        child: const Icon(Icons.landscape, color: Colors.white),
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
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility),
                                SizedBox(width: 8),
                                Text('View Details'),
                              ],
                            ),
                          ),
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
                          if (value == 'view') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HikeDetailScreen(hike: hike),
                              ),
                            ).then((_) => _loadHikes());
                          } else if (value == 'edit') {
                            _editHike(hike);
                          } else if (value == 'delete') {
                            _deleteHike(hike);
                          }
                        },
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
            ),
    );
  }
}
