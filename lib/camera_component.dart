import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraSense extends StatefulWidget {
  final CameraDescription camera;

  const CameraSense({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraSenseState createState() => _CameraSenseState();
}

class _CameraSenseState extends State<CameraSense> with WidgetsBindingObserver {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late FaceDetector _faceDetector;
  
  bool _isProcessingImage = false;
  double _dotSize = 20.0;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeFaceDetector();
    _initializeCamera();
  }

  void _initializeFaceDetector() {
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableLandmarks: true,
        enableClassification: true,
      ),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      _controller = CameraController(
        widget.camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,  // Always use yuv420 for ML Kit
      );

      _initializeControllerFuture = _controller.initialize().then((_) {
        if (!mounted) return;
        _startImageStream();
      }).catchError((error) {
        print('Camera initialization error: $error');
      });
    } catch (e) {
      print('Camera setup error: $e');
    }
  }

  void _startImageStream() {
    try {
      _controller.startImageStream((CameraImage image) {
        if (!_isProcessingImage) {
          _processImageStream(image);
        }
      });
    } catch (e) {
      print('Error starting image stream: $e');
    }
  }

  void _processImageStream(CameraImage image) {
    _isProcessingImage = true;

    try {
      _processImage(image).then((_) {
        _isProcessingImage = false;
      }).catchError((error) {
        print('Error processing image: $error');
        _isProcessingImage = false;
      });
    } catch (e) {
      print('Error in image stream processing: $e');
      _isProcessingImage = false;
    }
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      if (!mounted) return;

      final inputImage = _convertToInputImage(image);
      if (inputImage == null) {
        print('Failed to convert camera image');
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);
      
      if (!mounted) return;

      if (faces.isNotEmpty) {
        final face = faces.first;
        final isLooking = _isLookingAtScreen(face);
        
        setState(() {
          if (isLooking) {
            _dotSize = _dotSize + 1.0; // More gradual increase
            if (_dotSize > 200.0) _dotSize = 200.0;
          } else {
            _resetDotSize();
          }
        });
      } else {
        _resetDotSize();
      }
    } catch (e) {
      print('Face detection error: $e');
    }
  }

  InputImage? _convertToInputImage(CameraImage image) {
    try {
      final plane = image.planes[0];
      print('Image format: ${image.format.group}');
      print('Image width: ${image.width}, height: ${image.height}');
      print('Plane bytesPerRow: ${plane.bytesPerRow}');

      // Determine the correct rotation based on the sensor orientation
      final sensorOrientation = widget.camera.sensorOrientation;
      InputImageRotation rotation;
      switch (sensorOrientation) {
        case 90:
          rotation = InputImageRotation.rotation90deg;
          break;
        case 180:
          rotation = InputImageRotation.rotation180deg;
          break;
        case 270:
          rotation = InputImageRotation.rotation270deg;
          break;
        default:
          rotation = InputImageRotation.rotation0deg;
      }

      print('Sensor orientation: $sensorOrientation');
      print('Using rotation: $rotation');

      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation, // Use the correct rotation
          format: InputImageFormat.yuv420, // Always use YUV420 for camera images
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (e) {
      print('Error converting image: $e');
      return null;
    }
  }

  bool _isLookingAtScreen(Face face) {
    const double maxYaw = 30.0;   // More lenient left/right rotation
    const double maxPitch = 25.0; // More lenient up/down rotation
    const double maxRoll = 20.0;  // More lenient tilt

    final double yaw = face.headEulerAngleY?.abs() ?? 90.0;
    final double pitch = face.headEulerAngleX?.abs() ?? 90.0;
    final double roll = face.headEulerAngleZ?.abs() ?? 90.0;

    return yaw < maxYaw && pitch < maxPitch && roll < maxRoll;
  }

  void _resetDotSize() {
    if (!mounted) return;
    
    _resetTimer?.cancel();
    setState(() {
      _dotSize = 20.0;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 4/3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CameraPreview(_controller),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 50), // Even faster animation
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
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resetTimer?.cancel();
    _controller.dispose();
    _faceDetector.close();
    super.dispose();
  }
}