import 'package:s_packages/s_packages.dart';

class SLiquidPullToRefreshExampleScreen extends StatefulWidget {
  const SLiquidPullToRefreshExampleScreen({super.key});

  @override
  State<SLiquidPullToRefreshExampleScreen> createState() =>
      _SLiquidPullToRefreshExampleScreenState();
}

class _SLiquidPullToRefreshExampleScreenState
    extends State<SLiquidPullToRefreshExampleScreen> {
  final List<int> _items = List.generate(15, (index) => index);
  int _refreshCount = 0;

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _refreshCount++;
      _items.insert(0, _refreshCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SLiquidPullToRefresh Example'),
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pull down to refresh • Refreshed $_refreshCount times',
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),

          // Basic example
          Expanded(
            child: SLiquidPullToRefresh(
              onRefresh: _handleRefresh,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${_items[index]}'),
                      ),
                      title: Text('Item ${_items[index]}'),
                      subtitle: const Text('Pull to refresh'),
                    ),
                  );
                },
              ),
            ),
          ),

          const Divider(height: 1),

          // Custom colors example
          Expanded(
            child: SLiquidPullToRefresh(
              onRefresh: _handleRefresh,
              color: Theme.of(context).colorScheme.secondary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              height: 120,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade100, Colors.purple.shade50],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Custom styled item ${index + 1}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
