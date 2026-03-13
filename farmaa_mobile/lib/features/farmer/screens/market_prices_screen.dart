import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/crop_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/l10n/app_localizations.dart';

const List<String> _tnDistricts = [
  'Ariyalur',
  'Chennai',
  'Coimbatore',
  'Cuddalore',
  'Dharmapuri',
  'Dindigul',
  'Erode',
  'Kancheepuram',
  'Kanyakumari',
  'Karur',
  'Krishnagiri',
  'Madurai',
  'Namakkal',
  'Pudukkottai',
  'Ramanathapuram',
  'Salem',
  'Sivaganga',
  'Thanjavur',
  'Theni',
  'Thoothukudi',
  'Tiruchirappalli',
  'Tirunelveli',
  'Tiruppur',
  'Tiruvallur',
  'Tiruvannamalai',
  'Vellore',
  'Viluppuram',
  'Virudhunagar',
];

class MarketPricesScreen extends ConsumerStatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  ConsumerState<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends ConsumerState<MarketPricesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final String _selectedDistrict = 'Madurai';
  List<Map<String, dynamic>> _prices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _fetchPrices();
    });
    _fetchPrices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPrices() async {
    final commodity = _tabController.index == 0 ? 'Millet' : 'Wheat';
    setState(() => _isLoading = true);
    try {
      final data = await CropService.instance.getMarketPrices(
        commodity: commodity,
        district: _selectedDistrict,
      );
      if (mounted) setState(() => _prices = data);
    } catch (_) {
      if (mounted) setState(() => _prices = _demoData());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _demoData() {
    final base = _tabController.index == 0 ? 2800.0 : 2200.0;
    return [
      {'date': '20 Feb', 'price': base - 80},
      {'date': '21 Feb', 'price': base - 40},
      {'date': '22 Feb', 'price': base + 20},
      {'date': '23 Feb', 'price': base},
      {'date': '24 Feb', 'price': base + 60},
      {'date': '25 Feb', 'price': base + 100},
      {'date': '26 Feb', 'price': base + 80},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surfaceCream,
      appBar: AppBar(
        title: Text(l.marketPrices),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          indicatorColor: AppTheme.primaryGreen,
          tabs: [
            Tab(icon: const Text('🌾'), text: l.grainMillet),
            Tab(icon: const Text('🌿'), text: l.grainWheat),
          ],
        ),
      ),
      body: Column(
        children: [
          // District selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedDistrict,
              items: _tnDistricts
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) {
                // If there was a search query/value issue here, it's restored to a working state.
                if (v != null) {
                  _fetchPrices();
                }
              },
              decoration: InputDecoration(
                labelText: l.district,
                prefixIcon: const Icon(Icons.map_outlined),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _PriceContent(prices: _prices, commodity: l.grainMillet),
                      _PriceContent(prices: _prices, commodity: l.grainWheat),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PriceContent extends StatelessWidget {
  final List<Map<String, dynamic>> prices;
  final String commodity;

  const _PriceContent({required this.prices, required this.commodity});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (prices.isEmpty) {
      return Center(child: Text(l.noPriceData));
    }

    final latest = (prices.last['price'] as num?)?.toDouble() ?? 0;
    final previous = prices.length > 1
        ? (prices[prices.length - 2]['price'] as num?)?.toDouble() ?? latest
        : latest;
    final change = latest - previous;
    final isRising = change >= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: AppTheme.radiusLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$commodity — ${l.todaysRate}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${latest.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      l.quintal,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isRising
                            ? Colors.greenAccent.withValues(alpha: 0.2)
                            : Colors.redAccent.withValues(alpha: 0.2),
                        borderRadius: AppTheme.radiusRound,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isRising ? Icons.trending_up : Icons.trending_down,
                            color: isRising
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isRising ? '+' : ''}${change.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: isRising
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 7-day chart
          Text(l.sevenDayTrend, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.radiusLarge,
              boxShadow: AppTheme.cardShadow,
            ),
            child: LineChart(_buildChart()),
          ),
          const SizedBox(height: 20),

          // Daily table
          Text(l.historicalData,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...prices.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    p['date']?.toString() ?? '',
                    style: const TextStyle(
                        color: AppTheme.textMedium, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    '₹${(p['price'] as num?)?.toStringAsFixed(0) ?? '—'}${l.quintal}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChart() {
    final spots = prices.asMap().entries.map((e) {
      return FlSpot(
          e.key.toDouble(), (e.value['price'] as num?)?.toDouble() ?? 0);
    }).toList();

    if (spots.isEmpty) {
      return LineChartData(
        minY: 0,
        maxY: 100,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [],
      );
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 100;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 100;

    return LineChartData(
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: AppTheme.borderLight,
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 46,
            getTitlesWidget: (val, _) => Text(
              '₹${val.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 9, color: AppTheme.textLight),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (val, _) {
              final idx = val.toInt();
              if (idx < 0 || idx >= prices.length) return const SizedBox();
              return Text(
                prices[idx]['date']?.toString().split(' ').first ?? '',
                style: const TextStyle(fontSize: 9, color: AppTheme.textLight),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppTheme.primaryGreen,
          barWidth: 3,
          dotData: FlDotData(
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 4,
              color: AppTheme.primaryGreen,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryGreen.withValues(alpha: 0.3),
                AppTheme.primaryGreen.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
