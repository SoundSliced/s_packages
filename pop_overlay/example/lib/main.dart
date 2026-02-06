import 'package:flutter/material.dart';
import 'package:pop_overlay/pop_overlay.dart';

void main() {
  runApp(const PopOverlayExampleApp());
}

/// Main example application for pop_overlay package
class PopOverlayExampleApp extends StatelessWidget {
  const PopOverlayExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pop Overlay Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PopOverlayExampleHome(),
    );
  }
}

/// Home screen showcasing pop_overlay features
class PopOverlayExampleHome extends StatelessWidget {
  const PopOverlayExampleHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pop Overlay Examples'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Basic popup button
            ElevatedButton(
              onPressed: () => _showBasicPopup(context),
              child: const Text('Show Basic Popup'),
            ),
            const SizedBox(height: 12),

            // Popup with customization
            ElevatedButton(
              onPressed: () => _showCustomizedPopup(context),
              child: const Text('Show Customized Popup'),
            ),
            const SizedBox(height: 12),

            // Draggable popup
            ElevatedButton(
              onPressed: () => _showDraggablePopup(context),
              child: const Text('Show Draggable Popup'),
            ),
            const SizedBox(height: 12),

            // Popup with frame design (basic)
            ElevatedButton(
              onPressed: () => _showFramedPopup(context),
              child: const Text('Show Framed Popup'),
            ),
            const SizedBox(height: 12),

            // Popup with frame design (with future callbacks)
            ElevatedButton(
              onPressed: () => _showFramedPopupWithFuture(context),
              child: const Text('Show Framed Popup with Async Actions'),
            ),
            const SizedBox(height: 12),

            // Auto-dismissal popup
            ElevatedButton(
              onPressed: () => _showAutoDismissPopup(context),
              child: const Text('Show Auto-Dismiss Popup'),
            ),
            const SizedBox(height: 12),

            // Blurred background popup
            ElevatedButton(
              onPressed: () => _showBlurredPopup(context),
              child: const Text('Show Blurred Background Popup'),
            ),
            const SizedBox(height: 12),

            // Multiple popups
            ElevatedButton(
              onPressed: () => _showMultiplePopups(context),
              child: const Text('Show Multiple Popups'),
            ),
            const SizedBox(height: 32),

            // Information section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Pop Overlay Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('• Display multiple popups simultaneously'),
                    SizedBox(height: 8),
                    Text('• Smooth animations and transitions'),
                    SizedBox(height: 8),
                    Text('• Draggable popups with position tracking'),
                    SizedBox(height: 8),
                    Text('• Background blur effects'),
                    SizedBox(height: 8),
                    Text('• Auto-dismissal with configurable duration'),
                    SizedBox(height: 8),
                    Text('• Tap-to-dismiss functionality'),
                    SizedBox(height: 8),
                    Text('• Keyboard support (Escape key)'),
                    SizedBox(height: 8),
                    Text('• Frame Design system with buttons'),
                    SizedBox(height: 8),
                    Text('• Async action callbacks with validation'),
                    SizedBox(height: 8),
                    Text('• Custom styling and positioning'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show a basic popup
  void _showBasicPopup(BuildContext context) {
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'basic_popup',
        widget: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This is a basic popup notification.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => PopOverlay.removePop('basic_popup'),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
        shouldDismissOnBackgroundTap: true,
      ),
    );
  }

  /// Show a customized popup
  void _showCustomizedPopup(BuildContext context) {
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'custom_popup',
        borderRadius: BorderRadius.circular(20),
        widget: Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Customized Popup',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This popup has a custom gradient background, shadow, and styling.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => PopOverlay.removePop('custom_popup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        shouldDismissOnBackgroundTap: true,
        dismissBarrierColor: Colors.black.withValues(alpha: 0.5),
      ),
    );
  }

  /// Show a draggable popup
  void _showDraggablePopup(BuildContext context) {
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'draggable_popup',
        borderRadius: BorderRadius.circular(12),
        widget: Container(
          width: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎯 Draggable Popup',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Drag me around the screen!',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => PopOverlay.removePop('draggable_popup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
        isDraggeable: true,
        shouldDismissOnBackgroundTap: true,
      ),
    );
  }

  /// Show a popup with design frame
  void _showFramedPopup(BuildContext context) {
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'framed_popup',
        frameDesign: FrameDesign(
          title: 'framed Popup',
          showCloseButton: true,
          info: 'This is a framed popup',
          successButtonTitle: 'Confirm',
          cancelButtonTitle: 'Cancel',
          titleBarHeight: 50,
          bottomBarHeight: 50,
        ),
        widget: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.settings,
                size: 48,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Configure your preferences here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => PopOverlay.removePop('framed_popup'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
        shouldDismissOnBackgroundTap: true,
      ),
    );
  }

  /// Show multiple popups simultaneously
  void _showMultiplePopups(BuildContext context) {
    // First popup
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'multi_popup_1',
        dismissBarrierColor: Colors.red.withValues(alpha: 0.5),
        widget: _buildMultiPopup(
          'Popup 1',
          Colors.red,
          'multi_popup_1',
          dismisseable: true,
        ),
        shouldDismissOnBackgroundTap: true,
      ),
    );

    // Second popup
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'multi_popup_2',
        dismissBarrierColor: Colors.green.withValues(alpha: 0.5),
        widget: _buildMultiPopup(
          'Popup 2',
          Colors.green,
          'multi_popup_2',
        ),
        shouldDismissOnBackgroundTap: false,
      ),
    );

    // Third popup
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'multi_popup_3',
        dismissBarrierColor: Colors.blue.withValues(alpha: 0.5),
        widget: _buildMultiPopup(
          'Popup 3',
          Colors.blue,
          'multi_popup_3',
        ),
        shouldDismissOnBackgroundTap: false,
      ),
    );
  }

  /// Build a multi-popup item
  Widget _buildMultiPopup(String title, Color color, String id,
      {bool dismisseable = false}) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (dismisseable == false) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => PopOverlay.removePop(id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 32),
              ),
              child: Text(
                'Close',
                style: TextStyle(color: color),
              ),
            ),
          ]
        ],
      ),
    );
  }

  /// Show a framed popup with future callbacks for async validation
  void _showFramedPopupWithFuture(BuildContext context) {
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'framed_future_popup',
        frameDesign: FrameDesign(
          title: 'Form Submission',
          showCloseButton: true,
          info: 'This form validates before submitting',
          successButtonTitle: 'Submit',
          cancelButtonTitle: 'Cancel',
          titleBarHeight: 50,
          bottomBarHeight: 50,
          // Validator: checks form state before allowing submission
          onFutureSuccessValidator: () async {
            await Future.delayed(const Duration(milliseconds: 500));
            return true; // Return true to allow submission, false to show error
          },
          // Success callback: executed after validation passes
          onFutureSuccess: () async {
            await Future.delayed(const Duration(seconds: 1));

            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Form submitted successfully!')),
            );

            PopOverlay.removePop('framed_future_popup');
          },
        ),
        widget: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                'Async Operation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This popup demonstrates async callbacks with validation. Click Submit to trigger the async validation and success callbacks.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '✓ onFutureSuccessValidator: Validates before submission\n✓ onFutureSuccess: Executes after validation passes',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show a popup that auto-dismisses after a duration
  void _showAutoDismissPopup(BuildContext context) {
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'auto_dismiss_popup',
        duration: const Duration(seconds: 3),
        shouldDismissOnBackgroundTap: true,
        widget: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              const Text(
                'Success!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This popup will auto-dismiss in 3 seconds',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => PopOverlay.removePop('auto_dismiss_popup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text(
                  'Dismiss Now',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show a popup with blurred background
  void _showBlurredPopup(BuildContext context) {
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'blurred_popup',
        shouldBlurBackground: true,
        dismissBarrierColor: Colors.black54,
        shouldDismissOnBackgroundTap: true,
        widget: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info,
                  size: 48,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Blurred Background',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Notice how the background is blurred, creating focus on this dialog. This is useful for important notifications.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => PopOverlay.removePop('blurred_popup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => PopOverlay.removePop('blurred_popup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      child: const Text('OK'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
