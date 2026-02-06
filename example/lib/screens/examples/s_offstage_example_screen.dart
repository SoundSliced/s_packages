import 'package:s_packages/s_packages.dart';

class SOffstageExampleScreen extends StatefulWidget {
  const SOffstageExampleScreen({super.key});

  @override
  State<SOffstageExampleScreen> createState() => _SOffstageExampleScreenState();
}

class _SOffstageExampleScreenState extends State<SOffstageExampleScreen> {
  bool _isLoading = true;
  SOffstageTransition _transition = SOffstageTransition.fadeAndScale;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOffstage Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Transition selector
            const Text(
              'Transition Type:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: SOffstageTransition.values.map((type) {
                  final isSelected = _transition == type;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_getTransitionName(type)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _transition = type;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Content with SOffstage
            Expanded(
              child: Center(
                child: SOffstage(
                  isOffstage: _isLoading,
                  transition: _transition,
                  showLoadingIndicator: true,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 64,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Content Loaded!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Counter: $_counter',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _counter++;
                            });
                          },
                          child: const Text('Increment'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Control buttons
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = !_isLoading;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading ? Colors.green : Colors.orange,
                  ),
                  icon: Icon(
                      _isLoading ? Icons.visibility : Icons.visibility_off),
                  label: Text(_isLoading ? 'Show Content' : 'Hide Content'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _counter = 0;
                    });
                  },
                  child: const Text('Reset Counter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTransitionName(SOffstageTransition type) {
    switch (type) {
      case SOffstageTransition.fade:
        return 'Fade';
      case SOffstageTransition.scale:
        return 'Scale';
      case SOffstageTransition.fadeAndScale:
        return 'Fade & Scale';
      case SOffstageTransition.slide:
        return 'Slide';
      case SOffstageTransition.rotation:
        return 'Rotation';
    }
  }
}
