import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/saved_split_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/saved_split_model.dart';
import '../../widgets/my_button.dart';
import '../../widgets/my_textfield.dart';

class CreateSavedSplitScreen extends StatefulWidget {
  const CreateSavedSplitScreen({super.key});

  @override
  State<CreateSavedSplitScreen> createState() => _CreateSavedSplitScreenState();
}

class _CreateSavedSplitScreenState extends State<CreateSavedSplitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedSplitType = 'EQUAL';

  final List<String> _splitTypes = ['EQUAL', 'UNEQUAL', 'PERCENTAGE', 'SHARES'];

  void _createSavedSplit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final splitProvider = Provider.of<SavedSplitProvider>(
        context,
        listen: false,
      );

      final savedSplitId = FirebaseFirestore.instance
          .collection('savedSplits')
          .doc()
          .id;

      final savedSplit = SavedSplitModel(
        savedSplitId: savedSplitId,
        userId: authProvider.currentUser!.uid,
        name: _nameController.text,
        splitType: _selectedSplitType,
        participantIds: [],
        splitData: {},
        createdAt: Timestamp.now(),
      );

      await splitProvider.createSavedSplit(savedSplit);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved split created successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Saved Split')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            MyTextfield(
              controller: _nameController,
              hintText: 'Split Name',
              obscureText: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSplitType,
              decoration: const InputDecoration(
                labelText: 'Split Type',
                border: OutlineInputBorder(),
              ),
              items: _splitTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSplitType = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Note: You can configure participants and split amounts when applying this preset to an expense.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),
            MyButton(onPressed: _createSavedSplit, text: 'Create Saved Split'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
