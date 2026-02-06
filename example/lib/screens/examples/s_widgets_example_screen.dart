import 'package:flutter/material.dart';
import 'package:s_widgets/s_widgets.dart';

class SWidgetsExampleScreen extends StatelessWidget {
  const SWidgetsExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('s_widgets Example'),
      ),
      body: DismissKeyboard(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Custom widgets & utilities for Flutter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Loading Indicator
                const Text(
                  'Loading Indicator',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  height: 50,
                  width: 50,
                  child: SLoadingIndicator(
                    indicatorType: Indicator.circleStrokeSpin,
                    colors: [Colors.blue, Colors.cyan],
                    scale: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Custom Buttons
                const Text(
                  'Custom Buttons',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                STextButton(
                  buttonTitle: 'Text Button',
                  backgroundColor: Colors.blue,
                  onTap: (offset) {
                    context.showSnackBar(message: 'Button tapped! 🎉');
                  },
                  height: 48,
                  width: 150,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SIconButton(
                      iconData: Icons.home,
                      label: 'Home',
                      color: Colors.blue,
                      onTap: (offset) {
                        context.showSnackBar(message: 'Home tapped!');
                      },
                    ),
                    SIconButton(
                      iconData: Icons.favorite,
                      label: 'Favorite',
                      color: Colors.red,
                      onTap: (offset) {
                        context.showSnackBar(message: 'Favorite tapped!');
                      },
                    ),
                    SIconButton(
                      iconData: Icons.settings,
                      label: 'Settings',
                      color: Colors.green,
                      onTap: (offset) {
                        context.showSnackBar(message: 'Settings tapped!');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Keyboard Management
                const Text(
                  'Keyboard Management',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                TextField(
                  onTap: () {
                    KeyboardOverlay.showDoneButtonOverlay(
                      context: context,
                      onTap: () {
                        context.showSnackBar(message: 'Done tapped!');
                      },
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Tap to show iOS-style Done button',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tap outside text field to dismiss keyboard',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
