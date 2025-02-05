import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_component.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure cameras are initialized
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(FocusDotApp(camera: firstCamera));
}

class FocusDotApp extends StatelessWidget {
  final CameraDescription camera;

  FocusDotApp({required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomePage(camera: camera),
    );
  }
}

class HomePage extends StatelessWidget {
  final CameraDescription camera;

  HomePage({required this.camera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Focus Dot App'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu actions
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'settings',
                  child: Text('Settings'),
                ),
              ];
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 2, 30, 73),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CameraSense(camera: camera),
            SizedBox(height: 20),
            Text(
              'focus on the white dot.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.circle_outlined),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 0, // Default index
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}
