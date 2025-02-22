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
    actions: [
      PopupMenuButton<String>(
        onSelected: (value) {
          // Handle menu actions
        },
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
              value: 'help',
              child: Text('Help'),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Text('Settings'),
            ),
            PopupMenuItem(
              value: 'about',
              child: Text('About'),
            ),
            PopupMenuItem(
              value: 'exit',
              child: Text('Exit'),
            ),
          ];
        },
      ),
    ],
  ),
  backgroundColor: const Color.fromARGB(255, 2, 25, 59), // Change the background color here
  body: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Expanded( // Pushes everything else upwards
      child: CameraSense(),
    ),
    SizedBox(height: 40), // Adjust space as needed
    Text(
      'Focus on the white dot...',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 50), // Space below text
  ],
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
