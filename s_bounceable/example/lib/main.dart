import 'package:flutter/material.dart';
import 'package:s_bounceable/s_bounceable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double scaleFactor = 0.95;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(title: const Text('SBounceable Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SizedBox(
              width: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Scale Factor: ${scaleFactor.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: scaleFactor,
                    min: 0.5,
                    max: 1.0,
                    divisions: 50,
                    label: scaleFactor.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        scaleFactor = value;
                      });
                    },
                  ),
                  const SizedBox(height: 40),
                  SBounceable(
                    scaleFactor: scaleFactor,
                    onTap: () {
                      _scaffoldMessengerKey.currentState?.showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Single Tap!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    onDoubleTap: () {
                      _scaffoldMessengerKey.currentState?.showSnackBar(
                        const SnackBar(
                          content: Text('Double Tap!'),
                          backgroundColor: Colors.purple,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Tap or Double Tap Me',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
