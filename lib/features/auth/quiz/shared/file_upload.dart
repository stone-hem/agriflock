// lib/features/auth/quiz/shared/file_upload.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileUpload extends StatefulWidget {
  final List<PlatformFile> uploadedFiles;
  final Function(List<PlatformFile>) onFilesSelected;
  final Function(int) onFileRemoved;
  final String title;
  final String description;
  final List<String> allowedExtensions;
  final bool allowMultiple;
  final Color primaryColor;

  const FileUpload({
    super.key,
    required this.uploadedFiles,
    required this.onFilesSelected,
    required this.onFileRemoved,
    this.title = 'Upload Files',
    this.description = 'Upload your documents',
    this.allowedExtensions = const ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    this.allowMultiple = true,
    this.primaryColor =  Colors.green,
  });

  @override
  State<FileUpload> createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload> {
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: widget.allowMultiple,
      );

      if (result != null) {
        widget.onFilesSelected(result.files);
      }
    } catch (e) {
      _showErrorSnackBar('Error picking files: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _getFileIcon(PlatformFile file) {
    final extension = file.extension?.toLowerCase();
    if (extension == 'pdf') {
      return const Icon(Icons.picture_as_pdf, color: Colors.red);
    } else if (['doc', 'docx'].contains(extension)) {
      return const Icon(Icons.description, color: Colors.blue);
    } else if (['jpg', 'jpeg', 'png'].contains(extension)) {
      return const Icon(Icons.image, color: Colors.green);
    }
    return const Icon(Icons.insert_drive_file, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Upload Button
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: InkWell(
            onTap: _pickFiles,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to upload files',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${widget.allowedExtensions.join(', ').toUpperCase()} files supported',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Uploaded Files List
        if (widget.uploadedFiles.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Uploaded Files:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.uploadedFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: _getFileIcon(file),
                title: Text(
                  file.name,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${(file.size / 1024).toStringAsFixed(1)} KB',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => widget.onFileRemoved(index),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}