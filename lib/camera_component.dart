import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

class CameraSense extends StatefulWidget {
  @override
  _CameraSenseState createState() => _CameraSenseState();
}

class _CameraSenseState extends State<CameraSense> {
  late CameraController _controller;
  bool _isLookingAtScreen = false;
  double _dotSize = 20.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/blazeface.tflite",
        labels: "assets/blazeface.txt", // Optional labels file
      );
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
      );

      await _controller.initialize();
      _startImageStream();
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  void _startImageStream() {
    _controller.startImageStream((CameraImage image) async {
      final inputImage = _convertToInputImage(image);
      if (inputImage == null) return;

      final faces = await Tflite.runModelOnFrame(
        bytesList: inputImage.planes.map((plane) => plane.bytes).toList(),
        imageHeight: inputImage.height,
        imageWidth: inputImage.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90, // Adjust rotation as needed
        numResults: 1,
        threshold: 0.5,
        asynch: true,
      );

      if (faces != null && faces.isNotEmpty) {
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

  InputImage? _convertToInputImage(CameraImage image) {
    try {
      return InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation90deg, // Adjust rotation as needed
          format: InputImageFormat.yuv420,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (e) {
      print('Error converting image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

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
  }

  @override
  void dispose() {
    _controller.dispose();
    Tflite.close();
    super.dispose();
  }
}