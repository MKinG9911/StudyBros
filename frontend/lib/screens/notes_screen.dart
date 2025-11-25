import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import '../providers/notes_provider.dart';
import '../models/note_model.dart';
import '../utils/constants.dart';
import '../services/file_attachment_service.dart';
import '../widgets/theme_toggle_button.dart';
import 'note_detail_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesProvider>(context, listen: false).fetchNotes();
    });
  }

  Future<void> _openFile(String path) async {
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not open file: ${result.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageGallery(
    BuildContext context,
    List<String> imagePaths,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              itemCount: imagePaths.length,
              controller: PageController(initialPage: initialIndex),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(
                    File(imagePaths[index]),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 48,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Image not found",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Notes'),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          if (notesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notesProvider.notes.isEmpty) {
            return _buildEmptyState();
          }

          return MasonryGridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: notesProvider.notes.length,
            itemBuilder: (context, index) {
              return _buildNoteCard(notesProvider.notes[index], index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddNoteDialog(context),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text("No notes yet", style: AppTextStyles.body),
          const SizedBox(height: 8),
          Text("Tap + to create a quick note", style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note, int index) {
    final color = note.colorValue != 0 ? Color(note.colorValue) : Colors.white;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteDetailScreen(
              note: note,
              onEdit: () => _showEditNoteDialog(context, note),
            ),
          ),
        );
      },
      child: Hero(
        tag: 'note_${note.key}',
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: AppTextStyles.heading2.copyWith(fontSize: 18),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _showEditNoteDialog(context, note),
                          child: const Icon(
                            Icons.edit,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Provider.of<NotesProvider>(
                              context,
                              listen: false,
                            ).toggleFavorite(note);
                          },
                          child: Icon(
                            note.isFavorite ? Icons.star : Icons.star_border,
                            color: note.isFavorite
                                ? Colors.orange
                                : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note.content,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    color: AppColors.textPrimary.withOpacity(0.8),
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
                if (note.imagePaths.isNotEmpty || note.pdfPaths.isNotEmpty)
                  const SizedBox(height: 12),
                if (note.imagePaths.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () => _showImageGallery(context, note.imagePaths, 0),
                    child: Row(
                      children: [
                        const Icon(Icons.image, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          "${note.imagePaths.length} image${note.imagePaths.length > 1 ? 's' : ''}",
                          style: AppTextStyles.caption.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (note.pdfPaths.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: note.pdfPaths.map((pdfPath) {
                      return GestureDetector(
                        onTap: () => _openFile(pdfPath),
                        child: Chip(
                          avatar: const Icon(Icons.picture_as_pdf, size: 12),
                          label: Text(
                            FileAttachmentService.getFileName(pdfPath),
                            style: const TextStyle(fontSize: 10),
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    int selectedColorValue = 0xFFFFFFFF;
    List<String> selectedImagePaths = [];
    List<String> selectedPdfPaths = [];

    final colors = [
      const Color(0xFFFFFFFF), // White
      const Color(0xFFFFF8E1), // Light Yellow
      const Color(0xFFE1F5FE), // Light Blue
      const Color(0xFFF3E5F5), // Light Purple
      const Color(0xFFE8F5E9), // Light Green
      const Color(0xFFFFEBEE), // Light Red
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("New Note"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  hintText: "e.g., Physics Formulas",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Content",
                  hintText: "Write your note here...",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Attachments", style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final paths = await FileAttachmentService.pickImages();
                      setState(() {
                        selectedImagePaths.addAll(paths);
                      });
                    },
                    icon: const Icon(Icons.image, size: 18),
                    label: const Text("Images"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final paths = await FileAttachmentService.pickPDFs();
                      setState(() {
                        selectedPdfPaths.addAll(paths);
                      });
                    },
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text("PDFs"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              if (selectedImagePaths.isNotEmpty || selectedPdfPaths.isNotEmpty)
                const SizedBox(height: 8),
              if (selectedImagePaths.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: selectedImagePaths.map((path) {
                    return Chip(
                      avatar: const Icon(Icons.image, size: 16),
                      label: Text(
                        FileAttachmentService.getFileName(path),
                        style: const TextStyle(fontSize: 12),
                      ),
                      onDeleted: () {
                        setState(() {
                          selectedImagePaths.remove(path);
                        });
                      },
                      deleteIconColor: Colors.red,
                    );
                  }).toList(),
                ),
              if (selectedPdfPaths.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: selectedPdfPaths.map((path) {
                    return Chip(
                      avatar: const Icon(Icons.picture_as_pdf, size: 16),
                      label: Text(
                        FileAttachmentService.getFileName(path),
                        style: const TextStyle(fontSize: 12),
                      ),
                      onDeleted: () {
                        setState(() {
                          selectedPdfPaths.remove(path);
                        });
                      },
                      deleteIconColor: Colors.red,
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              const Text("Color", style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: colors.map((color) {
                    final isSelected = color.value == selectedColorValue;
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedColorValue = color.value);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    contentController.text.isNotEmpty) {
                  final newNote = Note(
                    userId: 'local',
                    title: titleController.text,
                    content: contentController.text,
                    createdAt: DateTime.now(),
                    colorValue: selectedColorValue,
                    imagePaths: selectedImagePaths,
                    pdfPaths: selectedPdfPaths,
                  );
                  Provider.of<NotesProvider>(
                    context,
                    listen: false,
                  ).addNote(newNote);
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context, Note note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);
    int selectedColorValue = note.colorValue;
    List<String> selectedImagePaths = List.from(note.imagePaths);
    List<String> selectedPdfPaths = List.from(note.pdfPaths);

    final colors = [
      const Color(0xFFFFFFFF), // White
      const Color(0xFFFFF8E1), // Light Yellow
      const Color(0xFFE1F5FE), // Light Blue
      const Color(0xFFF3E5F5), // Light Purple
      const Color(0xFFE8F5E9), // Light Green
      const Color(0xFFFFEBEE), // Light Red
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Edit Note"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    hintText: "e.g., Physics Formulas",
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Content",
                    hintText: "Write your note here...",
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Attachments", style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final paths = await FileAttachmentService.pickImages();
                        setState(() {
                          selectedImagePaths.addAll(paths);
                        });
                      },
                      icon: const Icon(Icons.image, size: 18),
                      label: const Text("Images"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final paths = await FileAttachmentService.pickPDFs();
                        setState(() {
                          selectedPdfPaths.addAll(paths);
                        });
                      },
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: const Text("PDFs"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (selectedImagePaths.isNotEmpty ||
                    selectedPdfPaths.isNotEmpty)
                  const SizedBox(height: 8),
                if (selectedImagePaths.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: selectedImagePaths.map((path) {
                      return Chip(
                        avatar: const Icon(Icons.image, size: 16),
                        label: Text(
                          FileAttachmentService.getFileName(path),
                          style: const TextStyle(fontSize: 12),
                        ),
                        onDeleted: () {
                          setState(() {
                            selectedImagePaths.remove(path);
                          });
                        },
                        deleteIconColor: Colors.red,
                      );
                    }).toList(),
                  ),
                if (selectedPdfPaths.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: selectedPdfPaths.map((path) {
                      return Chip(
                        avatar: const Icon(Icons.picture_as_pdf, size: 16),
                        label: Text(
                          FileAttachmentService.getFileName(path),
                          style: const TextStyle(fontSize: 12),
                        ),
                        onDeleted: () {
                          setState(() {
                            selectedPdfPaths.remove(path);
                          });
                        },
                        deleteIconColor: Colors.red,
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                const Text("Color", style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: colors.map((color) {
                      final isSelected = color.value == selectedColorValue;
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedColorValue = color.value);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    contentController.text.isNotEmpty) {
                  note.title = titleController.text;
                  note.content = contentController.text;
                  note.colorValue = selectedColorValue;
                  note.imagePaths = selectedImagePaths;
                  note.pdfPaths = selectedPdfPaths;

                  Provider.of<NotesProvider>(
                    context,
                    listen: false,
                  ).updateNote(note);
                  Navigator.pop(context);
                }
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
