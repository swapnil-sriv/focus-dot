import 'package:flutter/material.dart';
import 'camera_component.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FocusDotApp());
}

class FocusDotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Focus Dot App'),
      ),
      backgroundColor: const Color.fromARGB(255, 2, 30, 73),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CameraSense(),
            SizedBox(height: 20),
            Text(
              'Focus on the white dot.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
