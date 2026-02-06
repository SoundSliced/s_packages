import 'package:s_packages/s_packages.dart';

class SBannerExampleScreen extends StatefulWidget {
  const SBannerExampleScreen({super.key});

  @override
  State<SBannerExampleScreen> createState() => _SBannerExampleScreenState();
}

class _SBannerExampleScreenState extends State<SBannerExampleScreen> {
  bool _isActive = true;
  SBannerPosition _position = SBannerPosition.topRight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SBanner Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Basic banner example
              const Text(
                'Basic Banner:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              SBanner(
                bannerPosition: _position,
                isActive: _isActive,
                bannerContent: Builder(
                  builder: (context) => Text(
                    'NEW',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                bannerColor: Colors.red,
                child: Container(
                  width: 200,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Product Card'),
                ),
              ),
              const SizedBox(height: 32),

              // Icon banner example
              const Text(
                'Banner with Icon:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              SBanner(
                bannerPosition: _position,
                isActive: _isActive,
                bannerContent: Icon(
                  Icons.star,
                  color: Colors.yellow.shade300,
                  size: 20,
                ),
                bannerColor: Colors.purple,
                child: Container(
                  width: 200,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Featured Item'),
                ),
              ),
              const SizedBox(height: 32),

              // Circular banner example
              const Text(
                'Circular Child:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              SBanner(
                bannerPosition: _position,
                isActive: _isActive,
                isChildCircular: true,
                bannerContent: Builder(
                  builder: (context) => Text(
                    'HOT',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                bannerColor: Colors.orange,
                child: Container(
                  width: 150,
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 64),
                ),
              ),
              const SizedBox(height: 32),

              // Controls
              const Divider(),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Banner Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              const Text('Position:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Top Right'),
                    selected: _position == SBannerPosition.topRight,
                    onSelected: (_) {
                      setState(() {
                        _position = SBannerPosition.topRight;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Top Left'),
                    selected: _position == SBannerPosition.topLeft,
                    onSelected: (_) {
                      setState(() {
                        _position = SBannerPosition.topLeft;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Bottom Right'),
                    selected: _position == SBannerPosition.bottomRight,
                    onSelected: (_) {
                      setState(() {
                        _position = SBannerPosition.bottomRight;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Bottom Left'),
                    selected: _position == SBannerPosition.bottomLeft,
                    onSelected: (_) {
                      setState(() {
                        _position = SBannerPosition.bottomLeft;
                      });
                    },
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
