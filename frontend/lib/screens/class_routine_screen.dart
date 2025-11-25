import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/user_provider.dart';
import '../utils/constants.dart';

class ClassRoutineScreen extends StatefulWidget {
  const ClassRoutineScreen({super.key});

  @override
  State<ClassRoutineScreen> createState() => _ClassRoutineScreenState();
}

class _ClassRoutineScreenState extends State<ClassRoutineScreen> {
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);

      if (image != null) {
        if (!mounted) return;

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final updatedUser = userProvider.user;
        updatedUser.classRoutinePath = image.path;

        await userProvider.updateUser(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Class routine uploaded!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteRoutine(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Routine"),
        content: const Text(
          "Are you sure you want to delete the class routine?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final updatedUser = userProvider.user;
      updatedUser.classRoutinePath = null;

      await userProvider.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Class routine deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Routine')),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final routinePath = userProvider.user.classRoutinePath;

          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return routinePath == null
              ? _buildEmptyState()
              : _buildRoutineView(context, routinePath);
        },
      ),
      floatingActionButton: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.user.classRoutinePath != null)
            return const SizedBox.shrink();
          return FloatingActionButton(
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.upload, color: Colors.white),
            onPressed: () => _showImageSourceDialog(context),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text("No class routine uploaded", style: AppTextStyles.body),
          const SizedBox(height: 8),
          const Text(
            "Tap + to upload your routine",
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineView(BuildContext context, String path) {
    return Column(
      children: [
        Expanded(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(child: Image.file(File(path), fit: BoxFit.contain)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showImageSourceDialog(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Replace'),
              ),
              OutlinedButton.icon(
                onPressed: () => _deleteRoutine(context),
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Class Routine'),
        content: const Text('Choose image source:'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(context, ImageSource.camera);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(context, ImageSource.gallery);
            },
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
          ),
        ],
      ),
    );
  }
}
