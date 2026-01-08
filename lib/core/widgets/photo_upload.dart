import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class PhotoUpload extends StatefulWidget {
  final File? file;
  final Function(File?) onFileSelected;
  final bool isRequired;
  final String title;
  final String description;
  final Color primaryColor;
  final bool showSelfieFirst;

  const PhotoUpload({
    super.key,
    required this.file,
    required this.onFileSelected,
    this.isRequired = true,
    this.title = 'Photo',
    this.description = 'Upload photo',
    this.primaryColor = Colors.green,
    this.showSelfieFirst = false,
  });

  @override
  State<PhotoUpload> createState() => _PhotoUploadState();
}

class _PhotoUploadState extends State<PhotoUpload> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _openCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showErrorSnackBar('No camera available');
        return;
      }

      // Select camera based on showSelfieFirst preference
      CameraDescription selectedCamera;
      if (widget.showSelfieFirst) {
        selectedCamera = cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
      } else {
        selectedCamera = cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
      }

      if (!mounted) return;

      // Navigate to camera screen
      final File? imageFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            camera: selectedCamera,
            allCameras: cameras,
          ),
        ),
      );

      if (imageFile != null) {
        widget.onFileSelected(imageFile);
      }
    } catch (e) {
      _showErrorSnackBar('Error opening camera: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null) {
        widget.onFileSelected(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  void _removeImage() {
    widget.onFileSelected(null);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (widget.isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
          ],
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
        if (widget.file == null)
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'Upload ${widget.title}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _openCamera,
                      icon: const Icon(Icons.camera),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.primaryColor,
                        side: BorderSide(color: widget.primaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(widget.file!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _removeImage,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// Custom Camera Screen
class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final List<CameraDescription> allCameras;

  const CameraScreen({
    super.key,
    required this.camera,
    required this.allCameras,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isTakingPicture = false;
  CameraDescription? _currentCamera;

  @override
  void initState() {
    super.initState();
    _currentCamera = widget.camera;
    _initializeCamera(_currentCamera!);
  }

  void _initializeCamera(CameraDescription camera) {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _switchCamera() async {
    final newCamera = widget.allCameras.firstWhere(
          (camera) =>
      camera.lensDirection !=
          (_currentCamera?.lensDirection ?? CameraLensDirection.back),
      orElse: () => widget.allCameras.first,
    );

    await _controller.dispose();
    setState(() {
      _currentCamera = newCamera;
      _initializeCamera(newCamera);
    });
  }

  Future<void> _takePicture() async {
    if (_isTakingPicture) return;

    try {
      setState(() => _isTakingPicture = true);
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      if (!mounted) return;
      Navigator.pop(context, File(image.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTakingPicture = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: CameraPreview(_controller),
                ),
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top bar with close button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 30),
                              onPressed: () => Navigator.pop(context),
                            ),
                            if (widget.allCameras.length > 1)
                              IconButton(
                                icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 30),
                                onPressed: _switchCamera,
                              ),
                          ],
                        ),
                      ),
                      // Bottom bar with capture button
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _isTakingPicture ? null : _takePicture,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: _isTakingPicture
                                    ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                                    : Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
        },
      ),
    );
  }
}