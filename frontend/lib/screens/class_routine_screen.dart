import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/class_routine_model.dart';
import '../services/hive_service.dart';
import '../utils/constants.dart';

class ClassRoutineScreen extends StatefulWidget {
  const ClassRoutineScreen({super.key});

  @override
  State<ClassRoutineScreen> createState() => _ClassRoutineScreenState();
}

class _ClassRoutineScreenState extends State<ClassRoutineScreen> {
  final HiveService _hiveService = HiveService();
  ClassRoutine? _routine;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutine();
  }

  Future<void> _loadRoutine() async {
    setState(() => _isLoading = true);
    try {
      final routines = await _hiveService.getClassRoutines();
      if (routines.isNotEmpty) {
        setState(() => _routine = routines.first);
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);

      if (image != null) {
        final routine = ClassRoutine(
          userId: 'local',
          imagePath: image.path,
          uploadedAt: DateTime.now(),
        );

        await _hiveService.addClassRoutine(routine);
        await _loadRoutine();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Routine')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _routine == null
          ? _buildEmptyState()
          : _buildRoutineView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.upload, color: Colors.white),
        onPressed: () => _showImageSourceDialog(),
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

  Widget _buildRoutineView() {
    return Column(
      children: [
        Expanded(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.file(File(_routine!.imagePath), fit: BoxFit.contain),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showImageSourceDialog(),
                icon: const Icon(Icons.refresh),
                label: const Text('Replace'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await _hiveService.deleteClassRoutine(_routine!.id!);
                  await _loadRoutine();
                },
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

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Class Routine'),
        content: const Text('Choose image source:'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
          ),
        ],
      ),
    );
  }
}
