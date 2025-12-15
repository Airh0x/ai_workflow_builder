import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:ai_workflow_builder/utils/responsive_design.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  final List<XFile> _capturedImages = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0], // Use the first available camera
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (!mounted) return;
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (e is CameraException) {
        debugPrint('Camera Error: ${e.code}\nError Message: ${e.description}');
      } else {
        debugPrint('Error initializing camera: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onTakePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    try {
      final XFile file = await _controller!.takePicture();
      setState(() {
        _capturedImages.add(file);
      });
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  void _onDone() {
    Navigator.of(context).pop(_capturedImages);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black,
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(child: CameraPreview(_controller!)),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    final imageSize = MediaQuery.of(context).size.width > 600 ? 80.0 : 70.0;
    final buttonSize = MediaQuery.of(context).size.width > 600 ? 80.0 : 70.0;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveDesign.sectionSpacing(context) * 1.25,
        horizontal: ResponsiveDesign.sectionSpacing(context),
      ),
      child: Column(
        children: [
          SizedBox(
            height: imageSize + 20,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _capturedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: ResponsiveDesign.sectionSpacing(context) * 0.5,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      ResponsiveDesign.borderRadius(context) * 0.7,
                    ),
                    child: Image.file(
                      File(_capturedImages[index].path),
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: ResponsiveDesign.sectionSpacing(context) * 1.25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: buttonSize + 20), // Spacer
              GestureDetector(
                onTap: _onTakePicture,
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: CupertinoColors.white, width: 5),
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveDesign.buttonHeight(context),
                child: CupertinoButton(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveDesign.sectionSpacing(context),
                    vertical: 12,
                  ),
                  onPressed: _capturedImages.isEmpty ? null : _onDone,
                  color: CupertinoColors.white,
                  disabledColor: CupertinoColors.quaternarySystemFill,
                  child: Text(
                    '完了',
                    style: TextStyle(
                      fontSize: ResponsiveDesign.bodyFontSize(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
