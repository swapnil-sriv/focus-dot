import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart'; // Use the main ML Kit package

class CameraSense extends StatefulWidget {
  final CameraDescription camera;

  const CameraSense({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraSenseState createState() => _CameraSenseState();
}

class _CameraSenseState extends State<CameraSense> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector();
  bool _isLookingAtScreen = false;
  double _dotSize = 20.0; // Initial size of the dot

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();

    _controller.startImageStream((CameraImage image) async {
      final inputImage = _convertToInputImage(image);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        setState(() {
          _isLookingAtScreen = true;
          _dotSize = _dotSize < 200.0 ? _dotSize + 5.0 : _dotSize;
        });
      } else {
        setState(() {
          _isLookingAtScreen = false;
          _dotSize = 20.0;
        });
      }
    });
  }

  InputImage _convertToInputImage(CameraImage image) {
    // Validate image planes
    if (image.planes.isEmpty) {
      throw ArgumentError('Camera image has no planes');
    }

    // Get the first plane (usually the Y plane in YUV formats)
    final plane = image.planes[0];

    // Create InputImageMetadata
    final inputImageData = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation0deg, // Adjust if needed
      format: InputImageFormat.bgra8888, // Most common format, adjust if different
      bytesPerRow: plane.bytesPerRow,
    );

    // Create InputImage
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: inputImageData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CameraPreview(_controller),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _faceDetector.close();
    super.dispose();
  }
}