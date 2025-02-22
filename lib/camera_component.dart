import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraSense extends StatefulWidget {
  @override
  _CameraSenseState createState() => _CameraSenseState();
}

class _CameraSenseState extends State<CameraSense> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isLookingAtScreen = false;
  double _dotSize = 20.0;
  bool _isCameraInitialized = false;
  bool _isProcessingFrame = false;
  FaceDetector? _faceDetector;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true, // Detect if eyes are open
        enableTracking: true, // Track faces
        minFaceSize: 0.2,  // Adjusts the minimum face size (0.1 = more sensitive, 0.5 = less sensitive)
        performanceMode: FaceDetectorMode.accurate, // Change to `fast` if laggy
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _controller?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print("No cameras available.");
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      _startImageStream();
    } catch (e) {
      print('Camera initialization error: $e');
      setState(() {
        _isCameraInitialized = false;
      });
    }
  }

  int _faceDetectedFrames = 0;  // Counter for frames with a face
int _faceLostFrames = 0;  // Counter for frames without a face
final int _framesToConfirm = 5;  // Number of frames to confirm detection

 void _startImageStream() {
  if (!_isCameraInitialized || _controller == null) return;

  _controller!.startImageStream((CameraImage image) async {
    if (!mounted || _isProcessingFrame) return;
    _isProcessingFrame = true;

    try {
      InputImage inputImage = _convertCameraImage(image);
      List<Face> faces = await _faceDetector!.processImage(inputImage);

      if (faces.isNotEmpty) {
        _faceLostFrames = 0;  // Reset lost face counter
        _faceDetectedFrames++;

       
         // Only grow after 5 stable frames
          if (mounted) {
            setState(() {
              _isLookingAtScreen = true;
              _dotSize = (_dotSize < 200.0) ? _dotSize + 5.0 : 200.0;
            });
          }
        
      } else {
        _faceDetectedFrames = 0;  // Reset detected frames
        _faceLostFrames++;

        if (_faceLostFrames >= _framesToConfirm) {  // Only reset after 5 missing frames
          if (mounted) {
            setState(() {
              _isLookingAtScreen = false;
              _dotSize = 20.0;
            });
          }
        }
      }
    } catch (e) {
      print('Error in face detection: $e');
    } finally {
      _isProcessingFrame = false;
    }
  });
}

  InputImage _convertCameraImage(CameraImage image) {
    return InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation90deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 4 / 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CameraPreview(_controller!),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: _dotSize,
            height: _dotSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.stopImageStream();
    _controller?.dispose();
    _faceDetector?.close();
    super.dispose();
  }
}
