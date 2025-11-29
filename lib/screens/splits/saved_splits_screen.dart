import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/saved_split_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/saved_split_model.dart';
import 'create_saved_split_screen.dart';

class SavedSplitsScreen extends StatefulWidget {
  const SavedSplitsScreen({super.key});

  @override
  State<SavedSplitsScreen> createState() => _SavedSplitsScreenState();
}

class _SavedSplitsScreenState extends State<SavedSplitsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final provider = Provider.of<SavedSplitProvider>(context, listen: false);
      provider.loadUserSavedSplits(authProvider.currentUser!.uid);
    });
  }

  void _showDeleteDialog(SavedSplitModel split) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Saved Split'),
        content: Text('Are you sure you want to delete "${split.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final provider = Provider.of<SavedSplitProvider>(
                context,
                listen: false,
              );
              provider.deleteSavedSplit(split.savedSplitId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved split deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getSplitTypeDisplay(String splitType) {
    switch (splitType) {
      case 'EQUAL':
        return 'Equal Split';
      case 'UNEQUAL':
        return 'Unequal Split';
      case 'PERCENTAGE':
        return 'Percentage Split';
      case 'SHARES':
        return 'Shares Split';
      default:
        return splitType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Splits')),
      body: Consumer<SavedSplitProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.savedSplits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No saved splits',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save frequently used split configurations',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.savedSplits.length,
            itemBuilder: (context, index) {
              final split = provider.savedSplits[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.pie_chart)),
                  title: Text(
                    split.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(_getSplitTypeDisplay(split.splitType)),
                      Text('${split.participantIds.length} participants'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(split),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateSavedSplitScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
