import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ocr/receipt_scanner.dart';
import 'split_screen.dart';

class SplitScanScreen extends StatefulWidget {
  const SplitScanScreen({super.key});

  @override
  State<SplitScanScreen> createState() => _SplitScanScreenState();
}

class _SplitScanScreenState extends State<SplitScanScreen> {
  CameraController? _controller;
  bool _loading = false;
  bool _cameraInitialized = false;
  XFile? _capturedFile;
  bool _showPreview = false;
  bool _processing = false;

  Future<void> _initCamera() async {
    try {
      final List<CameraDescription> cameras = await availableCameras();
      final CameraDescription cam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.isNotEmpty ? cameras.first : throw Exception('No camera'),
      );
      _controller = CameraController(cam, ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _cameraInitialized = true);
    } catch (e) {
      // ignore camera errors, fall back to gallery
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Camera error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      await _initCamera();
      if (_controller == null || !_controller!.value.isInitialized) return;
    }
    setState(() => _loading = true);
    try {
      final XFile file = await _controller!.takePicture();
      // Show preview first
      if (!mounted) return;
      setState(() {
        _capturedFile = file;
        _showPreview = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _acceptPhoto() async {
    if (_capturedFile == null) return;
    setState(() {
      _processing = true;
    });
    try {
  final receipt = await ReceiptScanner.scanReceiptFromXFile(_capturedFile!);
      if (receipt != null) {
        if (!mounted) return;
        // If OCR found nothing useful, show raw text for debugging and allow user to continue
        if ((receipt.total == 0.0 || receipt.items.isEmpty) && (receipt.rawText.isNotEmpty)) {
          await showDialog<void>(
            context: context,
            builder: (BuildContext ctx) => AlertDialog(
              title: const Text('Hasil OCR (preview)'),
              content: SingleChildScrollView(child: Text(receipt.rawText)),
              actions: <Widget>[
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kembali')),
                ElevatedButton(onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SplitScreen(initialReceipt: receipt)));
                }, child: const Text('Lanjutkan')),
              ],
            ),
          );
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => SplitScreen(initialReceipt: receipt)));
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membaca struk')));
        // allow retake
        setState(() {
          _showPreview = false;
          _capturedFile = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() {
        _showPreview = false;
        _capturedFile = null;
      });
    } finally {
      if (mounted) setState(() {
        _processing = false;
      });
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedFile = null;
      _showPreview = false;
    });
  }

  Future<void> _pickFromGallery() async {
    setState(() => _loading = true);
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
  final receipt = await ReceiptScanner.scanReceiptFromXFile(image);
      if (receipt != null) {
        if (!mounted) return;
        if ((receipt.total == 0.0 || receipt.items.isEmpty) && (receipt.rawText.isNotEmpty)) {
          await showDialog<void>(
            context: context,
            builder: (BuildContext ctx) => AlertDialog(
              title: const Text('Hasil OCR (preview)'),
              content: SingleChildScrollView(child: Text(receipt.rawText)),
              actions: <Widget>[
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                ElevatedButton(onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SplitScreen(initialReceipt: receipt)));
                }, child: const Text('Lanjutkan')),
              ],
            ),
          );
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => SplitScreen(initialReceipt: receipt)));
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membaca struk')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Top controls
            // Top-right help button only
            Positioned(
              right: 16,
              top: 16,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.help_outline, color: AppTheme.primary),
                  onPressed: () {},
                ),
              ),
            ),

            // Center: camera preview
            Positioned.fill(
              top: 0,
              bottom: 140,
              child: _cameraInitialized && _controller != null
                  ? CameraPreview(_controller!)
                  : Container(color: Colors.black),
            ),

            // Tip overlay above shutter
            Positioned(
              left: 20,
              right: 20,
              bottom: 140,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Biar hasilnya optimal, pastiin struknya kebaca dan difoto di tempat terang.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            // Preview overlay after capture
            if (_showPreview && _capturedFile != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Image.file(File(_capturedFile!.path), fit: BoxFit.contain),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Reject (white circular)
                            GestureDetector(
                              onTap: _retakePhoto,
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.white,
                                child: const Icon(Icons.close, color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Accept (green circular)
                            GestureDetector(
                              onTap: _acceptPhoto,
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: const Color(0xFF24C35E),
                                child: const Icon(Icons.check, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom controls: cancel (left), shutter (center), gallery/flash (right)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: SizedBox(
                height: 120,
                child: Stack(
                  children: [
                    // Cancel (bottom-left)
                    Positioned(
                      left: 16,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: IconButton(
                          tooltip: 'Batal',
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    // Center shutter
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: _loading ? null : _takePhoto,
                          child: Container(
                            width: 84,
                            height: 84,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Right side controls
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _loading ? null : _pickFromGallery,
                            icon: const Icon(Icons.photo, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.flash_on, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_loading || _processing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
