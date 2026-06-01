import 'package:s_packages/s_packages.dart';

class SSpreadsheetExampleScreen extends StatefulWidget {
  const SSpreadsheetExampleScreen({super.key});

  @override
  State<SSpreadsheetExampleScreen> createState() =>
      _SSpreadsheetExampleScreenState();
}

class _SSpreadsheetExampleScreenState extends State<SSpreadsheetExampleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _advancedVerticalController = ScrollController();

  bool _showHeader = true;
  bool _rowRepaintBoundary = true;
  bool _addAutomaticKeepAlives = false;
  bool _animateRowExtent = true;

  double _horizontalOffset = 0;
  double _horizontalMaxExtent = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _advancedVerticalController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('s_spreadsheet Example'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Basic'),
            Tab(text: 'Advanced'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicExample(context),
          _buildAdvancedExample(context),
        ],
      ),
    );
  }

  Widget _buildBasicExample(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Text(
            'Basic spreadsheet: fixed top header + fixed left row header + synchronized horizontal rows.',
          ),
        ),
        Expanded(
          child: SSpreadsheet(
            rowCount: 30,
            columnCount: 14,
            rowHeaderWidth: 72,
            headerHeight: 44,
            showColumnHeader: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            rowHeaderBuilder: (context, rowIndex) {
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  border: Border.all(color: Colors.blueGrey.shade100),
                ),
                child: Text('${rowIndex + 1}'),
              );
            },
            columnHeaderBuilder: (context, columnIndex) {
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  border: Border.all(color: Colors.blueGrey.shade200),
                ),
                child: Text('Col ${columnIndex + 1}'),
              );
            },
            cornerBuilder: (context) => Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade200,
                border: Border.all(color: Colors.blueGrey.shade300),
              ),
              child: const Text('↕'),
            ),
            cellBuilder: (context, rowIndex, columnIndex) {
              final isEven = (rowIndex + columnIndex).isEven;
              return Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isEven ? Colors.white : Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text('R${rowIndex + 1} · C${columnIndex + 1}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedExample(BuildContext context) {
    final infoTextStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              FilterChip(
                label: const Text('Show Header'),
                selected: _showHeader,
                onSelected: (v) => setState(() => _showHeader = v),
              ),
              FilterChip(
                label: const Text('Row RepaintBoundary'),
                selected: _rowRepaintBoundary,
                onSelected: (v) => setState(() => _rowRepaintBoundary = v),
              ),
              FilterChip(
                label: const Text('Keep Alive Rows'),
                selected: _addAutomaticKeepAlives,
                onSelected: (v) => setState(() => _addAutomaticKeepAlives = v),
              ),
              FilterChip(
                label: const Text('Animate Row Extent'),
                selected: _animateRowExtent,
                onSelected: (v) => setState(() => _animateRowExtent = v),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'horizontal: ${_horizontalOffset.toStringAsFixed(1)} / ${_horizontalMaxExtent.toStringAsFixed(1)}',
                  style: infoTextStyle,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _advancedVerticalController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                  );
                },
                icon: const Icon(Icons.vertical_align_top),
                label: const Text('Top'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SSpreadsheet(
            rowCount: 120,
            columnCount: 26,
            rowHeaderWidth: 86,
            headerHeight: 48,
            showColumnHeader: _showHeader,
            padding: const EdgeInsets.all(8),
            rowPadding: const EdgeInsets.symmetric(vertical: 1),
            verticalController: _advancedVerticalController,
            verticalPhysics: const BouncingScrollPhysics(),
            horizontalPhysics: const ClampingScrollPhysics(),
            backgroundColor: Theme.of(context).colorScheme.surface,
            repaintBoundaryPerRow: _rowRepaintBoundary,
            addAutomaticKeepAlives: _addAutomaticKeepAlives,
            rowExtentAnimationDuration: _animateRowExtent
                ? const Duration(milliseconds: 220)
                : Duration.zero,
            rowHeightBuilder: (rowIndex) => rowIndex % 5 == 0 ? 56 : 44,
            columnWidthBuilder: (columnIndex) {
              if (columnIndex == 0) return 180;
              if (columnIndex % 4 == 0) return 140;
              return 110;
            },
            onHorizontalMetricsChanged: (offset, maxExtent, _) {
              if (!mounted) return;
              if ((offset - _horizontalOffset).abs() < 0.5 &&
                  (maxExtent - _horizontalMaxExtent).abs() < 0.5) {
                return;
              }
              setState(() {
                _horizontalOffset = offset;
                _horizontalMaxExtent = maxExtent;
              });
            },
            rowHeaderBuilder: (context, rowIndex) => Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rowIndex % 2 == 0
                    ? Colors.indigo.shade50
                    : Colors.indigo.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('Item ${rowIndex + 1}'),
            ),
            columnHeaderBuilder: (context, columnIndex) => Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade200,
                    Colors.deepPurple.shade300,
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Field ${columnIndex + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            cornerBuilder: (context) => Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
              child:
                  const Icon(Icons.table_chart, color: Colors.white, size: 18),
            ),
            cellBuilder: (context, rowIndex, columnIndex) {
              final colorBand = (rowIndex + columnIndex) % 3;
              final bgColor = switch (colorBand) {
                0 => Colors.white,
                1 => Colors.teal.shade50,
                _ => Colors.amber.shade50,
              };

              return Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  'r${rowIndex + 1} c${columnIndex + 1} · ${(rowIndex + 1) * (columnIndex + 1)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
