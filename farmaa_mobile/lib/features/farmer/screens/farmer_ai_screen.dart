import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/l10n/app_localizations.dart';

class FarmerAIScreen extends ConsumerStatefulWidget {
  const FarmerAIScreen({super.key});

  @override
  ConsumerState<FarmerAIScreen> createState() => _FarmerAIScreenState();
}

class _FarmerAIScreenState extends ConsumerState<FarmerAIScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surfaceCream,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('✨ ${l.aiAssistant}'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          indicatorColor: AppTheme.primaryGreen,
          isScrollable: true,
          tabs: [
            Tab(text: '🌾 ${l.yieldPrediction}'),
            Tab(text: '♻️ ${l.sustainability}'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _YieldPredictionTab(),
          _SustainabilityTab(),
        ],
      ),
    );
  }
}

// ── Tab 1: Yield Prediction ────────────────────────────────────────────────────

class _YieldPredictionTab extends StatefulWidget {
  const _YieldPredictionTab();

  @override
  State<_YieldPredictionTab> createState() => _YieldPredictionTabState();
}

class _YieldPredictionTabState extends State<_YieldPredictionTab> {
  final _areaCtrl = TextEditingController(text: '1');
  String _crop = 'Millet';
  String _season = 'Kharif';
  String _soil = 'Red';
  String _irrigation = 'Drip';
  bool _loading = false;
  Map<String, dynamic>? _result;

  Future<void> _predict() async {
    setState(() {
      _loading = true;
      _result = null;
    });
    await Future.delayed(const Duration(seconds: 1)); // simulate API call
    final area = double.tryParse(_areaCtrl.text) ?? 1.0;
    final baseYield = _crop == 'Millet' ? 2200.0 : 3100.0;
    final irrigationFactor =
        _irrigation == 'Drip' ? 1.25 : (_irrigation == 'Canal' ? 1.10 : 0.85);
    final predicted = (baseYield * area * irrigationFactor).round();
    setState(() {
      _result = {
        'predicted_kg': predicted,
        'confidence': 0.83,
        'suggestions': [
          'Use certified HHB 67 seeds for 15% better yield',
          '$_soil soil — apply phosphorus fertilizer before sowing',
          'Ideal sowing time: June 15 – July 15',
        ],
      };
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(
              l.crop,
              Row(
                  children: ['Millet', 'Wheat']
                      .map((c) => Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('${c == 'Millet' ? '🌾' : '🌿'} $c'),
                              selected: _crop == c,
                              onSelected: (_) => setState(() => _crop = c),
                              selectedColor: AppTheme.primaryGreen,
                              labelStyle: TextStyle(
                                  color: _crop == c
                                      ? Colors.white
                                      : AppTheme.textDark),
                            ),
                          )))
                      .toList())),
          const SizedBox(height: 12),
          _row(
              l.area,
              TextFormField(
                controller: _areaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(suffixText: 'hectares'),
              )),
          const SizedBox(height: 12),
          _row(
              l.season,
              _dropdown(['Kharif', 'Rabi', 'Zaid'], _season,
                  (v) => setState(() => _season = v!))),
          const SizedBox(height: 12),
          _row(
              l.soilType,
              _dropdown(['Red', 'Black', 'Sandy', 'Loamy'], _soil,
                  (v) => setState(() => _soil = v!))),
          const SizedBox(height: 12),
          _row(
              l.irrigation,
              _dropdown(['Drip', 'Canal', 'Rainfed'], _irrigation,
                  (v) => setState(() => _irrigation = v!))),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _predict,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(l.predictYieldBtn),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: AppTheme.radiusLarge,
              ),
              child: Column(
                children: [
                  Text('🌾 ${l.predictedYield}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(
                    '${_result!['predicted_kg']} kg',
                    style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                  Text(
                    l.confidence(((_result!['confidence'] as double) * 100)
                        .toStringAsFixed(0)),
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...(_result!['suggestions'] as List<String>).map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 16, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(s, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 6),
          child,
        ],
      );

  Widget _dropdown(
          List<String> items, String value, ValueChanged<String?> onChanged) =>
      DropdownButtonFormField<String>(
        initialValue: value,
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
        onChanged: onChanged,
        decoration: const InputDecoration(),
      );
}

// ── Tab 3: Sustainability Score ────────────────────────────────────────────────

class _SustainabilityTab extends StatefulWidget {
  const _SustainabilityTab();

  @override
  State<_SustainabilityTab> createState() => _SustainabilityTabState();
}

class _SustainabilityTabState extends State<_SustainabilityTab> {
  String _irrigation = 'Drip';
  String _fertilizer = 'Organic';
  bool _cropRotation = true;
  int? _score;
  List<String> _tips = [];

  void _calculate() {
    int s = 40;
    if (_irrigation == 'Drip') {
      s += 30;
    } else if (_irrigation == 'Canal') {
      s += 15;
    }
    if (_fertilizer == 'Organic') {
      s += 20;
    } else if (_fertilizer == 'Chemical') {
      s += 5;
    }
    if (_cropRotation) s += 10;

    final tips = <String>[];
    if (_irrigation == 'Rainfed') {
      tips.add('Switch to drip irrigation to save 40% water');
    }
    if (_fertilizer == 'Chemical') {
      tips.add('Use organic compost to boost soil health');
    }
    if (!_cropRotation) {
      tips.add('Practise crop rotation to prevent soil depletion');
    }

    setState(() {
      _score = s.clamp(0, 100);
      _tips = tips;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scoreColor = _score == null
        ? AppTheme.textLight
        : _score! >= 75
            ? AppTheme.successGreen
            : _score! >= 50
                ? AppTheme.warningAmber
                : AppTheme.errorRed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.sustainabilityDesc,
              style: const TextStyle(color: AppTheme.textMedium, height: 1.4)),
          const SizedBox(height: 16),
          _buildDropdownRow(l.irrigationMethod, ['Drip', 'Canal', 'Rainfed'],
              _irrigation, (v) => setState(() => _irrigation = v!)),
          const SizedBox(height: 12),
          _buildDropdownRow(l.fertilizerType, ['Organic', 'Mixed', 'Chemical'],
              _fertilizer, (v) => setState(() => _fertilizer = v!)),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _cropRotation,
            onChanged: (v) => setState(() => _cropRotation = v),
            title: Text(l.cropRotationPracticed,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            activeThumbColor: AppTheme.primaryGreen,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              child: Text(l.calculateScoreBtn),
            ),
          ),
          if (_score != null) ...[
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text(
                    '$_score',
                    style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        color: scoreColor),
                  ),
                  Text(
                    '/100 — ${_score! >= 75 ? l.excellent : _score! >= 50 ? l.good : l.needsImprovement}',
                    style: TextStyle(
                        fontSize: 16,
                        color: scoreColor,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (_tips.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(l.improvementTips,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ..._tips.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Text('💡 ', style: TextStyle(fontSize: 16)),
                        Expanded(
                            child: Text(t,
                                style: const TextStyle(
                                    color: AppTheme.textMedium))),
                      ],
                    ),
                  )),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, List<String> items, String value,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}
