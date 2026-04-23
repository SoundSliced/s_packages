import 'package:s_packages/s_packages.dart';

class PopOverlayExampleScreen extends StatelessWidget {
  const PopOverlayExampleScreen({super.key});

  void _showResizingPopup(BuildContext context) {
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'resizing_popup',
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        shouldDismissOnBackgroundTap: true,
        widget: const _ResizablePopupContent(
          popId: 'resizing_popup',
          title: 'Resizable Popup',
          subtitle:
              'Tap shrink/expand to animate this popup size using AnimatedContainer.',
        ),
      ),
    );
  }

  void _showResizingFramedPopup(BuildContext context) {
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'resizing_framed_popup',
        shouldDismissOnBackgroundTap: true,
        frameDesign: const FrameDesign(
          title: 'Resizable Framed Popup',
          subtitle: 'FrameDesign + reusable resizing content',
          titlePrefixIcon: Icons.aspect_ratio,
          showCloseButton: true,
          showBottomButtonBar: false,
          // Keep both null so the frame follows child size changes.
          width: null,
          height: null,
        ),
        widget: const _ResizablePopupContent(
          popId: 'resizing_framed_popup',
          title: 'Reusable Content',
          subtitle: 'Same stateful content widget as the non-framed example.',
          useInnerDecoration: false,
          compactWidth: 280,
          expandedWidth: 380,
          compactHeight: 160,
          expandedHeight: 210,
        ),
      ),
    );
  }

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
      titleBarColor: Colors.blue.shade900.darken(),
      bottomBarColor: Colors.grey.shade100,
      headerTrailingWidgets: [
        IconButton(
          icon: const Icon(
            Icons.help_outline,
            size: 20,
            color: Colors.white,
          ),
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
              ElevatedButton(
                onPressed: () => _showResizingPopup(context),
                child: const Text('Show Resizing Popup'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showResizingFramedPopup(context),
                child: const Text('Show Resizing Framed Popup'),
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

class _ResizablePopupContent extends StatefulWidget {
  final String popId;
  final String title;
  final String subtitle;
  final bool useInnerDecoration;
  final double compactWidth;
  final double expandedWidth;
  final double compactHeight;
  final double expandedHeight;

  const _ResizablePopupContent({
    required this.popId,
    required this.title,
    required this.subtitle,
    this.useInnerDecoration = true,
    this.compactWidth = 280,
    this.expandedWidth = 360,
    this.compactHeight = 180,
    this.expandedHeight = 220,
  });

  @override
  State<_ResizablePopupContent> createState() => _ResizablePopupContentState();
}

class _ResizablePopupContentState extends State<_ResizablePopupContent> {
  bool _isCompact = false;

  @override
  Widget build(BuildContext context) {
    final panel = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isCompact ? widget.compactWidth : widget.expandedWidth,
      height: _isCompact ? widget.compactHeight : widget.expandedHeight,
      padding: const EdgeInsets.all(16),
      decoration: widget.useInnerDecoration
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isCompact = !_isCompact;
                  });
                },
                child: Text(_isCompact ? 'Expand' : 'Shrink'),
              ),
              ElevatedButton(
                onPressed: () => PopOverlay.removePop(widget.popId),
                child: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );

    if (!widget.useInnerDecoration) {
      return panel;
    }

    return panel;
  }
}
