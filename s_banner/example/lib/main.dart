import 'package:flutter/material.dart';
import 'package:s_banner/s_banner.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 's_banner Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('s_banner Example')),
        body: const ExampleHome(),
      ),
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  bool _active = true;
  bool _isCircular = false;
  SBannerPosition _position = SBannerPosition.topRight;

  @override
  void initState() {
    super.initState();
    // Allow setting initial state via URL query params such as:
    //  - ?position=topLeft|topRight|bottomLeft|bottomRight
    //  - ?active=true|false
    final params = Uri.base.queryParameters;
    final pos = params['position'];
    if (pos != null) {
      switch (pos.toLowerCase()) {
        case 'topleft':
        case 'top_left':
        case 'top-left':
          _position = SBannerPosition.topLeft;
          break;
        case 'topright':
        case 'top_right':
        case 'top-right':
          _position = SBannerPosition.topRight;
          break;
        case 'bottomleft':
        case 'bottom_left':
        case 'bottom-left':
          _position = SBannerPosition.bottomLeft;
          break;
        case 'bottomright':
        case 'bottom_right':
        case 'bottom-right':
          _position = SBannerPosition.bottomRight;
          break;
      }
    }

    final active = params['active'];
    if (active != null) {
      _active = active.toLowerCase() == 'true';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SBanner(
              bannerPosition: _position,
              isActive: _active,
              isChildCircular: _isCircular,
              bannerContent: /* Text(
                'NEW Banner',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ) */
                  Icon(
                Icons.star,
                color: Colors.yellow.shade400,
                size: 20,
              ),
              bannerColor: Colors.purple,
              child: Container(
                width: _isCircular ? 200 : 200,
                height: _isCircular ? 200 : 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: _isCircular ? BoxShape.circle : BoxShape.rectangle,
                ),
                child: const Center(
                  child: Text('Product Card'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Active'),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            SwitchListTile(
              title: const Text('Circular Child'),
              value: _isCircular,
              onChanged: (v) => setState(() => _isCircular = v),
            ),
            const Divider(),
            const Text('Position:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: SBannerPositionTopLevel().positions.map((p) {
                return ChoiceChip(
                  label: Text(p.name),
                  selected: _position == p.position,
                  onSelected: (_) => setState(() => _position = p.position),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper type to get a list of positions with human-readable names
class SBannerPositionTopLevel {
  List<_NamedPosition> get positions => const [
        _NamedPosition('TopLeft', SBannerPosition.topLeft),
        _NamedPosition('TopRight', SBannerPosition.topRight),
        _NamedPosition('BottomLeft', SBannerPosition.bottomLeft),
        _NamedPosition('BottomRight', SBannerPosition.bottomRight),
      ];
}

class _NamedPosition {
  final String name;
  final SBannerPosition position;
  const _NamedPosition(this.name, this.position);
}
