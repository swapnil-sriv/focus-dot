import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter/widgets.dart';

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

   @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);  // Now this will work
    _initializeCamera();
    _loadModel();
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



  Future<void> _loadModel() async {
  try {
    await Tflite.loadModel(
      model: "assets/blazeface.tflite",
      numThreads: 1, // Add this
      isAsset: true, // Add this
      useGpuDelegate: false // Add this
    );
    print('Model loaded successfully');
  } catch (e) {
    print('Failed to load model: $e');
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
      imageFormatGroup: ImageFormatGroup.yuv420,
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



void _startImageStream() {
  if (!_isCameraInitialized || _controller == null) return;

  try {
    _controller!.startImageStream((CameraImage image) async {
      if (!mounted) return;

      // Prevent multiple simultaneous inference calls
      if (_isProcessingFrame) return;
      _isProcessingFrame = true;

      try {
        var recognitions = await Tflite.runModelOnFrame(
          bytesList: image.planes.map((plane) => plane.bytes).toList(),
          imageHeight: image.height,
          imageWidth: image.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 1,
          threshold: 0.1,
          asynch: true
        );

        if (mounted) {
          setState(() {
            if (recognitions != null && recognitions.isNotEmpty) {
              _isLookingAtScreen = true;
              _dotSize = (_dotSize < 200.0) ? _dotSize + 5.0 : 200.0;
            } else {
              _isLookingAtScreen = false;
              _dotSize = 20.0;
            }
          });
        }
      } catch (e) {
        print('Error in inference: $e');
      } finally {
        _isProcessingFrame = false;
      }
    });
  } catch (e) {
    print('Error starting image stream: $e');
  }
}


  @override
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
    height: MediaQuery.of(context).size.width * 4/3, // Maintain aspect ratio
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
  
  if (_controller != null) {
    _controller!.stopImageStream();
    _controller!.dispose();
    _controller = null;
  }

  Tflite.close();
  super.dispose();
}

}