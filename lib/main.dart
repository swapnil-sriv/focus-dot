import 'package:flutter/material.dart';

void main() {
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
              value: 'settings',
              child: Text('Settings'),
            ),
          ];
        },
      ),
    ],
  ),
  backgroundColor: const Color.fromARGB(255, 2, 25, 59), // Change the background color here
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FocusDot(),
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

class FocusDot extends StatefulWidget {
  @override
  _FocusDotState createState() => _FocusDotState();
}

class _FocusDotState extends State<FocusDot> {
  double _dotSize = 20.0; // Initial size of the dot

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: _dotSize,
      height: _dotSize,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  // Add camera functionality and dot size adjustment logic here later
}
