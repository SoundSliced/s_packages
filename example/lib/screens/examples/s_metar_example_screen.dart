import 'package:flutter/material.dart';
import 'package:s_packages/s_metar/metar_dart.dart';

class SMetarExampleScreen extends StatefulWidget {
  const SMetarExampleScreen({super.key});

  @override
  State<SMetarExampleScreen> createState() => _SMetarExampleScreenState();
}

class _SMetarExampleScreenState extends State<SMetarExampleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('s_metar Interactive Demo'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.cloud), text: 'METAR'),
            Tab(icon: Icon(Icons.air), text: 'TAF'),
            Tab(icon: Icon(Icons.download), text: 'Live Fetch'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [_MetarPage(), _TafPage(), _LiveFetchPage()],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sample reports
// ---------------------------------------------------------------------------

const _defaultMetar =
    'METAR EGLL 181220Z 25015G28KT 220V280 9999 FEW020 BKN080 15/08 Q1012 NOSIG';
const _usMetar = 'METAR KJFK 181220Z 27010KT 10SM FEW020 BKN100 18/10 A2992';
const _winterMetar =
    'METAR EGLL 181220Z 05010KT 2500 -RASN BKN008 OVC015 03/01 Q0992';
const _cavokMetar = 'METAR LFPG 181220Z 00000KT CAVOK 22/12 Q1025';
const _defaultTaf = 'TAF EGLL 181100Z 1812/1918 25015KT 9999 FEW025 '
    'TEMPO 1812/1816 5000 RASN BKN012 '
    'BECMG 1901/1903 30008KT '
    'PROB40 TEMPO 1906/1910 3000 DZ BKN006';

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader(
    this.title, {
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _kv(String key, String? value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 200,
          child: Text(
            '$key:',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
        Expanded(
          child: Text(
            value ?? '—',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ),
      ],
    ),
  );
}

String _fmt(double? v, {int decimals = 2, String unit = ''}) {
  if (v == null) return '—';
  return '${v.toStringAsFixed(decimals)}$unit';
}

Widget _divider() => const Divider(height: 16, thickness: 0.5);

class _ExpandableCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool initiallyExpanded;

  const _ExpandableCard({
    required this.title,
    required this.icon,
    required this.child,
    this.initiallyExpanded = true,
  });

  @override
  State<_ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<_ExpandableCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    widget.icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
              if (_expanded) ...[_divider(), widget.child],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// METAR page
// ---------------------------------------------------------------------------

class _MetarPage extends StatefulWidget {
  const _MetarPage();

  @override
  State<_MetarPage> createState() => _MetarPageState();
}

class _MetarPageState extends State<_MetarPage> {
  String _selectedCode = _defaultMetar;
  late final TextEditingController _controller;
  bool _isCustom = false;
  Metar? _metar;
  String? _parseError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _selectedCode);
    _parse(_selectedCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _parse(String code) {
    try {
      final m = Metar(code, year: 2026, month: 2);
      setState(() {
        _metar = m;
        _parseError = null;
      });
    } catch (e) {
      setState(() {
        _metar = null;
        _parseError = e.toString();
      });
    }
  }

  void _selectPreset(String code) {
    setState(() {
      _selectedCode = code;
      _isCustom = false;
      _controller.text = code;
    });
    _parse(code);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sample METARs',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _PresetChip(
                    label: 'EGLL standard',
                    selected: _selectedCode == _defaultMetar && !_isCustom,
                    onTap: () => _selectPreset(_defaultMetar),
                  ),
                  _PresetChip(
                    label: 'KJFK (US)',
                    selected: _selectedCode == _usMetar && !_isCustom,
                    onTap: () => _selectPreset(_usMetar),
                  ),
                  _PresetChip(
                    label: 'Winter / RASN',
                    selected: _selectedCode == _winterMetar && !_isCustom,
                    onTap: () => _selectPreset(_winterMetar),
                  ),
                  _PresetChip(
                    label: 'LFPG CAVOK',
                    selected: _selectedCode == _cavokMetar && !_isCustom,
                    onTap: () => _selectPreset(_cavokMetar),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _controller,
                maxLines: 2,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'METAR code',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.play_arrow),
                    tooltip: 'Parse',
                    onPressed: () {
                      setState(() => _isCustom = true);
                      _parse(_controller.text.trim());
                    },
                  ),
                ),
                onSubmitted: (v) {
                  setState(() => _isCustom = true);
                  _parse(v.trim());
                },
              ),
            ],
          ),
        ),
        if (_parseError != null)
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _parseError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        if (_metar != null) ...[
          _MetarOverviewCard(metar: _metar!),
          _MetarWindCard(metar: _metar!),
          _MetarVisibilityCard(metar: _metar!),
          _MetarWeatherCard(metar: _metar!),
          _MetarCloudsCard(metar: _metar!),
          _MetarTemperaturesCard(metar: _metar!),
          _MetarPressureCard(metar: _metar!),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

// ---------------------------------------------------------------------------
// METAR detail cards
// ---------------------------------------------------------------------------

class _MetarOverviewCard extends StatelessWidget {
  final Metar metar;

  const _MetarOverviewCard({required this.metar});

  @override
  Widget build(BuildContext context) {
    final flightColor = metar.flightRules == 'VFR'
        ? Colors.green.shade700
        : metar.flightRules == 'MVFR'
            ? Colors.blue.shade700
            : metar.flightRules == 'IFR'
                ? Colors.red.shade700
                : Colors.purple.shade700;

    return _ExpandableCard(
      title: 'Overview',
      icon: Icons.summarize,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('Station', metar.station.code),
          _kv('Time (UTC)', metar.time.toString()),
          _kv('Type', metar.type_.code),
          _kv('Flight rules', metar.flightRules, valueColor: flightColor),
          if (metar.remark.isNotEmpty) _kv('Remark', metar.remark),
        ],
      ),
    );
  }
}

class _MetarWindCard extends StatelessWidget {
  final Metar metar;

  const _MetarWindCard({required this.metar});

  @override
  Widget build(BuildContext context) {
    final wind = metar.wind;

    return _ExpandableCard(
      title: 'Wind',
      icon: Icons.air,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('Raw code', wind.code),
          _kv(
            'Direction',
            '${_fmt(wind.directionInDegrees, decimals: 0)}°'
                ' (${wind.cardinalDirection ?? "—"})',
          ),
          _kv('Is calm', wind.isCalm.toString()),
          _divider(),
          const _SectionHeader('Speed'),
          _kv('Knots', _fmt(wind.speedInKnot, decimals: 1, unit: ' kt')),
          _kv('m/s', _fmt(wind.speedInMps, decimals: 1, unit: ' m/s')),
          _kv('km/h', _fmt(wind.speedInKph, decimals: 1, unit: ' km/h')),
          _divider(),
          const _SectionHeader('Gust'),
          _kv('Gusts (kt)', _fmt(wind.gustInKnot, decimals: 1, unit: ' kt')),
        ],
      ),
    );
  }
}

class _MetarVisibilityCard extends StatelessWidget {
  final Metar metar;

  const _MetarVisibilityCard({required this.metar});

  @override
  Widget build(BuildContext context) {
    final vis = metar.prevailingVisibility;

    return _ExpandableCard(
      title: 'Visibility',
      icon: Icons.visibility,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('CAVOK', vis.cavok.toString()),
          _kv('Meters', _fmt(vis.inMeters, decimals: 0, unit: ' m')),
          _kv('Kilometers', _fmt(vis.inKilometers, decimals: 2, unit: ' km')),
        ],
      ),
    );
  }
}

class _MetarWeatherCard extends StatelessWidget {
  final Metar metar;

  const _MetarWeatherCard({required this.metar});

  @override
  Widget build(BuildContext context) {
    if (metar.weathers.length == 0) {
      return const _ExpandableCard(
        title: 'Weather',
        icon: Icons.thunderstorm,
        initiallyExpanded: false,
        child: Text(
          'No significant weather reported.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      );
    }

    return _ExpandableCard(
      title: 'Weather (${metar.weathers.length} group(s))',
      icon: Icons.thunderstorm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, w) in metar.weathers.items.indexed) ...[
            if (i > 0) _divider(),
            _kv('Raw code', w.code),
            _kv('Intensity', w.intensity),
            _kv('Description', w.description),
            _kv('Precipitation', w.precipitation),
          ],
        ],
      ),
    );
  }
}

class _MetarCloudsCard extends StatelessWidget {
  final Metar metar;

  const _MetarCloudsCard({required this.metar});

  @override
  Widget build(BuildContext context) {
    if (metar.clouds.length == 0) {
      return const _ExpandableCard(
        title: 'Clouds',
        icon: Icons.cloud_outlined,
        initiallyExpanded: false,
        child: Text(
          'No cloud layers reported.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      );
    }

    return _ExpandableCard(
      title: 'Clouds (${metar.clouds.length} layer(s))',
      icon: Icons.cloud,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, c) in metar.clouds.items.indexed) ...[
            if (i > 0) _divider(),
            _SectionHeader('Layer ${i + 1}'),
            _kv('Cover', c.cover),
            _kv('Height (ft)', _fmt(c.heightInFeet, decimals: 0, unit: ' ft')),
            _kv('Height (m)', _fmt(c.heightInMeters, decimals: 0, unit: ' m')),
          ],
        ],
      ),
    );
  }
}

class _MetarTemperaturesCard extends StatelessWidget {
  final Metar metar;

  const _MetarTemperaturesCard({required this.metar});

  @override
  Widget build(BuildContext context) {
    final t = metar.temperatures;

    return _ExpandableCard(
      title: 'Temperatures',
      icon: Icons.thermostat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Temperature'),
          _kv('°C', _fmt(t.temperatureInCelsius, decimals: 1, unit: ' °C')),
          _kv('°F', _fmt(t.temperatureInFahrenheit, decimals: 1, unit: ' °F')),
          _divider(),
          const _SectionHeader('Dewpoint'),
          _kv('°C', _fmt(t.dewpointInCelsius, decimals: 1, unit: ' °C')),
          _kv('°F', _fmt(t.dewpointInFahrenheit, decimals: 1, unit: ' °F')),
          _divider(),
          const _SectionHeader('Derived'),
          _kv(
            'Dewpoint spread',
            _fmt(t.dewpointSpread, decimals: 1, unit: ' °C'),
          ),
          _kv(
            'Relative humidity',
            _fmt(t.relativeHumidity, decimals: 1, unit: ' %'),
          ),
        ],
      ),
    );
  }
}

class _MetarPressureCard extends StatelessWidget {
  final Metar metar;

  const _MetarPressureCard({required this.metar});

  @override
  Widget build(BuildContext context) {
    final p = metar.pressure;

    return _ExpandableCard(
      title: 'Pressure',
      icon: Icons.compress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('hPa', _fmt(p.inHPa, decimals: 1, unit: ' hPa')),
          _kv('inHg', _fmt(p.inInHg, decimals: 2, unit: ' inHg')),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAF page
// ---------------------------------------------------------------------------

class _TafPage extends StatefulWidget {
  const _TafPage();

  @override
  State<_TafPage> createState() => _TafPageState();
}

class _TafPageState extends State<_TafPage> {
  late final TextEditingController _controller;
  Taf? _taf;
  String? _parseError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _defaultTaf);
    _parse(_defaultTaf);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _parse(String code) {
    try {
      final t = Taf(code, year: 2026, month: 2);
      setState(() {
        _taf = t;
        _parseError = null;
      });
    } catch (e) {
      setState(() {
        _taf = null;
        _parseError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: TextField(
            controller: _controller,
            maxLines: 4,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            decoration: InputDecoration(
              labelText: 'TAF code',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Parse',
                onPressed: () => _parse(_controller.text.trim()),
              ),
            ),
            onSubmitted: (v) => _parse(v.trim()),
          ),
        ),
        if (_parseError != null)
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _parseError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        if (_taf != null) ...[
          _TafOverviewCard(taf: _taf!),
          _TafBaseConditionsCard(taf: _taf!),
          if (_taf!.changesForecasted.length > 0) _TafChangesCard(taf: _taf!),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _TafOverviewCard extends StatelessWidget {
  final Taf taf;

  const _TafOverviewCard({required this.taf});

  @override
  Widget build(BuildContext context) {
    return _ExpandableCard(
      title: 'TAF Overview',
      icon: Icons.summarize,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('Station', taf.station.code),
          _kv('Issue time (UTC)', taf.time.toString()),
          _kv('Valid from', taf.valid.periodFrom.toString()),
          _kv('Valid until', taf.valid.periodUntil.toString()),
        ],
      ),
    );
  }
}

class _TafBaseConditionsCard extends StatelessWidget {
  final Taf taf;

  const _TafBaseConditionsCard({required this.taf});

  @override
  Widget build(BuildContext context) {
    return _ExpandableCard(
      title: 'Base Conditions',
      icon: Icons.wb_sunny_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('Flight rules', taf.flightRules),
          _divider(),
          const _SectionHeader('Wind', icon: Icons.air),
          _kv(
            'Direction',
            '${_fmt(taf.wind.directionInDegrees, decimals: 0)}°',
          ),
          _kv(
            'Speed (kt)',
            _fmt(taf.wind.speedInKnot, decimals: 1, unit: ' kt'),
          ),
          _divider(),
          const _SectionHeader('Visibility', icon: Icons.visibility),
          _kv('CAVOK', taf.prevailingVisibility.cavok.toString()),
          _kv(
            'Visibility (m)',
            _fmt(taf.prevailingVisibility.inMeters, decimals: 0, unit: ' m'),
          ),
        ],
      ),
    );
  }
}

class _TafChangesCard extends StatelessWidget {
  final Taf taf;

  const _TafChangesCard({required this.taf});

  @override
  Widget build(BuildContext context) {
    final changes = taf.changesForecasted.items;

    return _ExpandableCard(
      title: 'Change Periods (${changes.length})',
      icon: Icons.compare_arrows,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, cp) in changes.indexed) ...[
            if (i > 0) _divider(),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _changeColor(cp.changeIndicator.code),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    cp.changeIndicator.code ?? '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cp.changeIndicator.translation ?? '',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (cp.wind.code != null)
              _kv(
                'Wind',
                '${_fmt(cp.wind.directionInDegrees, decimals: 0)}° '
                    '${_fmt(cp.wind.speedInKnot, decimals: 0)} kt',
              ),
            if (cp.prevailingVisibility.code != null)
              _kv(
                'Visibility',
                _fmt(cp.prevailingVisibility.inMeters, decimals: 0, unit: ' m'),
              ),
          ],
        ],
      ),
    );
  }

  Color _changeColor(String? code) {
    if (code == null) return Colors.grey;
    if (code.startsWith('TEMPO')) return Colors.orange.shade700;
    if (code.startsWith('BECMG')) return Colors.blue.shade700;
    if (code.startsWith('FM')) return Colors.green.shade700;
    if (code.startsWith('PROB')) return Colors.purple.shade700;
    return Colors.grey.shade700;
  }
}

// ---------------------------------------------------------------------------
// Live Fetch page
// ---------------------------------------------------------------------------

class _LiveFetchPage extends StatefulWidget {
  const _LiveFetchPage();

  @override
  State<_LiveFetchPage> createState() => _LiveFetchPageState();
}

class _LiveFetchPageState extends State<_LiveFetchPage> {
  final TextEditingController _icaoController = TextEditingController(
    text: 'EGLL',
  );
  DateTime _selectedDateTime = DateTime.now().toUtc();
  bool _isLoading = false;
  MetarTafResult? _result;
  String? _fetchError;

  @override
  void dispose() {
    _icaoController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.utc(2020),
      lastDate: DateTime.now().toUtc(),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (!mounted) return;

    setState(() {
      _selectedDateTime = DateTime.utc(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _selectedDateTime.hour,
        time?.minute ?? _selectedDateTime.minute,
      );
    });
  }

  Future<void> _fetch() async {
    final icao = _icaoController.text.trim();
    if (icao.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = null;
      _fetchError = null;
    });

    final result = await MetarTafFetcher.fetch(
      icao: icao,
      dateTime: _selectedDateTime,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _result = result;
        _fetchError = null;
      } else {
        _result = result;
        _fetchError = result.error ?? 'Unknown error';
      }
    });
  }

  String _formatDateTime(DateTime dt) {
    final y = dt.year.toString();
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$y-$mo-$d  $h:${mi}Z';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fetch live METAR & TAF',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _icaoController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 4,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'ICAO code',
                        hintText: 'e.g. EGLL',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _formatDateTime(_selectedDateTime),
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: _pickDateTime,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download),
                  label: Text(_isLoading ? 'Fetching…' : 'Fetch'),
                  onPressed: _isLoading ? null : _fetch,
                ),
              ),
            ],
          ),
        ),
        if (_fetchError != null)
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _fetchError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        if (_result != null && _result!.isSuccess) ...[
          if (_result!.rawMetar != null)
            _ExpandableCard(
              title: 'Raw METAR',
              icon: Icons.code,
              child: Text(
                _result!.rawMetar!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
          if (_result!.rawTaf != null)
            _ExpandableCard(
              title: 'Raw TAF',
              icon: Icons.code,
              initiallyExpanded: false,
              child: Text(
                _result!.rawTaf!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
        ],
        if (_result?.metar != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(
              'Parsed METAR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          _MetarOverviewCard(metar: _result!.metar!),
          _MetarWindCard(metar: _result!.metar!),
          _MetarVisibilityCard(metar: _result!.metar!),
          _MetarWeatherCard(metar: _result!.metar!),
          _MetarCloudsCard(metar: _result!.metar!),
          _MetarTemperaturesCard(metar: _result!.metar!),
          _MetarPressureCard(metar: _result!.metar!),
        ],
        if (_result?.taf != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(
              'Parsed TAF',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          _TafOverviewCard(taf: _result!.taf!),
          _TafBaseConditionsCard(taf: _result!.taf!),
          if (_result!.taf!.changesForecasted.length > 0)
            _TafChangesCard(taf: _result!.taf!),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
