import 'package:s_packages/s_packages.dart';

class SModalExampleScreen extends StatelessWidget {
  const SModalExampleScreen({super.key});

  void _showBasicSnackbar(BuildContext context) {
    Modal.showSnackbar(
      text: 'This is a basic snackbar!',
      backgroundColor: Colors.blue,
    );
  }

  void _showSuccessSnackbar(BuildContext context) {
    Modal.showSnackbar(
      text: 'Operation successful! ✅',
      backgroundColor: Colors.green,
      prefixIcon: Icons.check_circle,
    );
  }

  void _showErrorSnackbar(BuildContext context) {
    Modal.showSnackbar(
      text: 'Something went wrong! ❌',
      backgroundColor: Colors.red,
      barrierColor: Colors.red.shade100.withValues(alpha: 0.5),
      prefixIcon: Icons.error,
      duration: const Duration(seconds: 3),
    );
  }

  void _showBottomSheet(BuildContext context) {
    Modal.show(
      builder: () => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bottom Sheet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('This is a bottom sheet!'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Modal.dismissBottomSheet(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
      modalType: ModalType.sheet,
      size: 300,
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  void _showDialog(BuildContext context) {
    Modal.show(
      builder: () => Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade400),
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
            const Icon(Icons.info_outline, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Dialog Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This is a modal dialog created with s_modal!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Modal.dismissDialog(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Modal.dismissDialog(),
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
      modalType: ModalType.dialog,
      shouldBlurBackground: true,
      barrierColor: Colors.yellow.shade700.withValues(alpha: 0.3),
    );
  }

  void _showResizingDialog(BuildContext context) {
    Modal.show(
      builder: () => const _ResizableDialogContent(),
      modalType: ModalType.dialog,
      shouldBlurBackground: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SModal Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Snackbars',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showBasicSnackbar(context),
                child: const Text('Show Basic Snackbar'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _showSuccessSnackbar(context),
                child: const Text('Show Success Snackbar'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _showErrorSnackbar(context),
                child: const Text('Show Error Snackbar'),
              ),
              const SizedBox(height: 40),
              const Text(
                'Bottom Sheet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showBottomSheet(context),
                child: const Text('Show Bottom Sheet'),
              ),
              const SizedBox(height: 40),
              const Text(
                'Dialog',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showDialog(context),
                child: const Text('Show Dialog'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _showResizingDialog(context),
                child: const Text('Show Resizing Dialog'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResizableDialogContent extends StatefulWidget {
  const _ResizableDialogContent();

  @override
  State<_ResizableDialogContent> createState() =>
      _ResizableDialogContentState();
}

class _ResizableDialogContentState extends State<_ResizableDialogContent> {
  bool _isCompact = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isCompact ? 240.0 : 380.0,
      height: _isCompact ? 150.0 : 240.0,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resizable Dialog',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _isCompact
                ? 'Compact mode'
                : 'Expanded mode — AnimatedContainer inside a Modal dialog.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () => setState(() {
                  _isCompact = !_isCompact;
                }),
                child: Text(_isCompact ? 'Expand' : 'Shrink'),
              ),
              ElevatedButton(
                onPressed: () => Modal.dismissDialog(),
                child: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
