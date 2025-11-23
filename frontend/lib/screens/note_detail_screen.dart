import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import '../models/note_model.dart';
import '../utils/constants.dart';
import '../services/file_attachment_service.dart';
import '../providers/notes_provider.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  final VoidCallback? onEdit;

  const NoteDetailScreen({super.key, required this.note, this.onEdit});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
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
    final color = widget.note.colorValue != 0
        ? Color(widget.note.colorValue)
        : Colors.white;
    // Calculate a contrasting text color (simple version)
    final isDark = color.computeLuminance() < 0.5;
    final textColor = isDark ? Colors.white : Colors.black87;
    final iconColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: textColor),
            onPressed: () {
              Navigator.pop(
                context,
              ); // Close detail to show edit dialog in parent
              if (widget.onEdit != null) widget.onEdit!();
            },
          ),
          Consumer<NotesProvider>(
            builder: (context, provider, child) {
              // We need to find the latest version of the note from provider to get correct favorite status
              // because widget.note might be stale if updated elsewhere
              final currentNote = provider.notes.firstWhere(
                (n) => n.key == widget.note.key,
                orElse: () => widget.note,
              );

              return IconButton(
                icon: Icon(
                  currentNote.isFavorite ? Icons.star : Icons.star_border,
                  color: currentNote.isFavorite ? Colors.orange : iconColor,
                ),
                onPressed: () {
                  provider.toggleFavorite(currentNote);
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Hero(
        tag: 'note_${widget.note.key}',
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.note.title,
                  style: AppTextStyles.heading1.copyWith(
                    color: textColor,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.note.content,
                  style: AppTextStyles.body.copyWith(
                    color: textColor.withOpacity(0.9),
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Images Section
                if (widget.note.imagePaths.isNotEmpty) ...[
                  Text(
                    "Images",
                    style: AppTextStyles.heading2.copyWith(
                      color: textColor,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemCount: widget.note.imagePaths.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showImageGallery(
                          context,
                          widget.note.imagePaths,
                          index,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(widget.note.imagePaths[index]),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.black12,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // PDFs Section
                if (widget.note.pdfPaths.isNotEmpty) ...[
                  Text(
                    "Documents",
                    style: AppTextStyles.heading2.copyWith(
                      color: textColor,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.note.pdfPaths.map(
                    (path) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => _openFile(path),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? Colors.white24 : Colors.black12,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  FileAttachmentService.getFileName(path),
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.open_in_new,
                                size: 18,
                                color: iconColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),
                Text(
                  "Created on ${widget.note.createdAt?.toString().split(' ')[0] ?? 'Unknown'}",
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
