import 'package:s_packages/s_packages.dart';

class PopOverlayExampleScreen extends StatelessWidget {
  const PopOverlayExampleScreen({super.key});

  void _showBasicPopup(BuildContext context) {
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'basic_popup',
        borderRadius: BorderRadius.circular(16),
        widget: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Basic Popup!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => PopOverlay.removePop('basic_popup'),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
        shouldDismissOnBackgroundTap: true,
      ),
    );
  }

  void _showDraggablePopup(BuildContext context) {
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'draggable_popup',
        borderRadius: BorderRadius.circular(16),
        isDraggeable: true,
        shouldDismissOnEscapeKey: false,
        dragBounds:
            Rect.fromCenter(center: Offset.zero, width: 600, height: 800),
        onDragStart: () => debugPrint('Drag started'),
        onDragEnd: () => debugPrint('Drag ended'),
        onMadeVisible: () => debugPrint('Popup visible'),
        widget: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.drag_indicator, size: 32),
              const SizedBox(height: 16),
              const Text(
                'Drag me around!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bounded drag • Escape disabled',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => PopOverlay.removePop('draggable_popup'),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFramedPopup(BuildContext context) {
    final template = FrameDesign(
      title: 'Settings',
      subtitle: 'App preferences',
      showCloseButton: true,
      titlePrefixIcon: Icons.settings,
      titleBarColor: Colors.indigo.shade50,
      bottomBarColor: Colors.grey.shade100,
      headerTrailingWidgets: [
        IconButton(
          icon: const Icon(Icons.help_outline, size: 20),
          onPressed: () {},
        ),
      ],
      successButtonTitle: 'Save',
      cancelButtonTitle: 'Cancel',
      onSuccess: () {
        PopOverlay.removePop('framed_popup');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved!')),
        );
        return null;
      },
    );

    PopOverlay.addPop(
      PopOverlayContent(
        id: 'framed_popup',
        frameDesign: template,
        widget: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notifications'),
                trailing: Icon(Icons.chevron_right),
              ),
              ListTile(
                leading: Icon(Icons.security),
                title: Text('Privacy'),
                trailing: Icon(Icons.chevron_right),
              ),
              ListTile(
                leading: Icon(Icons.color_lens),
                title: Text('Theme'),
                trailing: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        shouldDismissOnBackgroundTap: true,
      ),
    );
  }

  void _showAnimatedFromOffsetPopup(BuildContext context, Offset startOffset) {
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'animated_offset_popup',
        offsetToPopFrom: startOffset,
        popPositionAnimationCurve: Curves.easeOutBack,
        popPositionAnimationDuration: const Duration(milliseconds: 600),
        widget: Container(
          width: 250,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.animation, size: 48, color: Colors.purple),
              SizedBox(height: 16),
              Text(
                'I popped from the button!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'This popup animated from the button position to the center.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        shouldDismissOnBackgroundTap: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PopOverlay Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _showBasicPopup(context),
                child: const Text('Show Basic Popup'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showDraggablePopup(context),
                child: const Text('Show Draggable Popup'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showFramedPopup(context),
                child: const Text('Show Framed Popup'),
              ),
              const SizedBox(height: 16),
              SButton(
                onTap: (position) {
                  _showAnimatedFromOffsetPopup(context, position);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Show Animated Popup from Here',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _showBasicPopup(context);
                  _showDraggablePopup(context);
                  Future.delayed(const Duration(seconds: 2), () {
                    PopOverlay.dismissAllPops();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Visible: ${PopOverlay.visibleCount} popups — dismissing all in 2s',
                      ),
                    ),
                  );
                },
                child: const Text('Dismiss All (after 2s)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
