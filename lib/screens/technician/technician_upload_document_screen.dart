import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/technician_auth_provider.dart';
import '../../services/storage_service.dart';
import '../../services/technician_document_service.dart';

class TechnicianUploadDocumentScreen extends StatefulWidget {
  final String partyId;
  final String partyName;

  const TechnicianUploadDocumentScreen({
    super.key,
    required this.partyId,
    required this.partyName,
  });

  @override
  State<TechnicianUploadDocumentScreen> createState() =>
      _TechnicianUploadDocumentScreenState();
}

class _TechnicianUploadDocumentScreenState
    extends State<TechnicianUploadDocumentScreen> {
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  final TechnicianDocumentService _documentService = TechnicianDocumentService();

  List<File> _selectedImages = [];
  bool _isUploading = false;
  int _uploadProgress = 0;
  int _totalToUpload = 0;

  Future<void> _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage(
          imageQuality: 50,
        );
        if (images.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(images.map((e) => File(e.path)));
          });
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: source,
          imageQuality: 50,
        );
        if (image != null) {
          setState(() {
            _selectedImages.add(File(image.path));
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick images: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;

    final techId = context.read<TechnicianAuthProvider>().technicianId;

    setState(() {
      _isUploading = true;
      _totalToUpload = _selectedImages.length;
      _uploadProgress = 0;
    });

    int successCount = 0;

    for (int i = 0; i < _selectedImages.length; i++) {
      setState(() {
        _uploadProgress = i + 1;
      });

      try {
        final file = _selectedImages[i];
        final uploadResult = await _storageService.uploadPartyDocument(
          file: file,
          partyId: widget.partyId,
          technicianId: techId,
        );

        await _documentService.saveDocumentMetadata(
          partyId: widget.partyId,
          fileName: uploadResult['fileName']!,
          url: uploadResult['url']!,
          storagePath: uploadResult['storagePath']!,
          type: 'image/jpeg',
        );

        successCount++;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to upload image ${i + 1}: $e')),
          );
        }
      }
    }

    if (!mounted) return;

    setState(() {
      _isUploading = false;
    });

    if (successCount > 0) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Success'),
          content: Text('$successCount images uploaded successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // close dialog
                Navigator.of(context).pop(); // close screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Upload: ${widget.partyName}'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUploading
                            ? null
                            : () => _pickImages(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUploading
                            ? null
                            : () => _pickImages(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_selectedImages.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No images selected',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      itemCount: _selectedImages.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImages[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: _isUploading
                                    ? null
                                    : () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isUploading || _selectedImages.isEmpty
                      ? null
                      : _uploadImages,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Upload Images',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 20),
                        Text(
                          'Uploading $_uploadProgress of $_totalToUpload...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
