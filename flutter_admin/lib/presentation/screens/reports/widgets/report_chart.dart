import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../data/api/finance_api.dart';
import '../../../../data/models/financial_report.dart';
import '../../../../data/api/service_locator.dart';

class ReportChart extends StatefulWidget {
  final String title;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? chartType; // 'line', 'bar', 'pie'

  const ReportChart({
    Key? key,
    required this.title,
    this.startDate,
    this.endDate,
    this.chartType = 'bar',
  }) : super(key: key);

  @override
  _ReportChartState createState() => _ReportChartState();
}

class _ReportChartState extends State<ReportChart> {
  final FinanceApi _financeApi = ServiceLocator.get<FinanceApi>();
  List<FinancialReport> _reports = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  @override
  void didUpdateWidget(ReportChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate || 
        oldWidget.endDate != widget.endDate ||
        oldWidget.chartType != widget.chartType) {
      _fetchReports();
    }
  }

  Future<void> _fetchReports() async {
    setState(() => _isLoading = true);
    try {
      // Get the raw reports data
      final List<Map<String, dynamic>> rawReports = await _financeApi.getAllFinances();
      
      // Convert raw data to FinancialReport objects
      final reports = rawReports.map((data) => FinancialReport.fromJson(data)).toList();
      
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reports: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_reports.isEmpty)
              const Center(child: Text('No data available'))
            else
              SizedBox(
                height: 300,
                child: _buildChart(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (widget.chartType) {
      case 'line':
        return _buildLineChart();
      case 'pie':
        return _buildPieChart();
      case 'bar':
      default:
        return _buildBarChart();
    }
  }

  Widget _buildBarChart() {
    // Group by month using Map<String, dynamic>
    final Map<String, dynamic> monthlyData = {};
    
    for (var report in _reports) {
      final month = '${report.date.month}/${report.date.year}';
      final value = report.isExpense ? -report.amount : report.amount;
      
      if (monthlyData.containsKey(month)) {
        monthlyData[month] = (monthlyData[month] as double) + value;
      } else {
        monthlyData[month] = value;
      }
    }

    // Find maximum value for scaling the chart properly
    final double maxAmount = monthlyData.values
        .map((e) => (e as double).abs())
        .fold(0.0, (prev, element) => element > prev ? element : prev) * 1.2;
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxAmount,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final keys = monthlyData.keys.toList();
              final key = keys[group.x.toInt()];
              final value = monthlyData[key] as double;
              return BarTooltipItem(
                '${key}: ${value.abs().toStringAsFixed(2)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final keys = monthlyData.keys.toList();
                if (value.toInt() >= 0 && value.toInt() < keys.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      keys[value.toInt()],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
            left: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxAmount / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        barGroups: List.generate(
          monthlyData.length, 
          (index) {
            final String month = monthlyData.keys.elementAt(index);
            final double amount = monthlyData[month] as double;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: amount.abs(),
                  color: amount >= 0 ? Colors.green : Colors.red,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    // Group by month for line chart using Map<String, dynamic>
    final Map<String, dynamic> monthlyData = {};
    
    for (var report in _reports) {
      final month = '${report.date.month}/${report.date.year}';
      final value = report.isExpense ? -report.amount : report.amount;
      
      if (monthlyData.containsKey(month)) {
        monthlyData[month] = (monthlyData[month] as double) + value;
      } else {
        monthlyData[month] = value;
      }
    }

    // Find maximum value for scaling the chart properly
    final double maxAmount = monthlyData.values
        .map((e) => (e as double).abs())
        .fold(0.0, (prev, element) => element > prev ? element : prev) * 1.2;
    
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: monthlyData.length - 1.0,
        minY: 0,
        maxY: maxAmount,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final keys = monthlyData.keys.toList();
                final key = keys[spot.x.toInt()];
                return LineTooltipItem(
                  '${key}: ${spot.y.toStringAsFixed(2)}',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final keys = monthlyData.keys.toList();
                if (value.toInt() >= 0 && value.toInt() < keys.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      keys[value.toInt()],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxAmount / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
            left: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              monthlyData.length, 
              (index) {
                final double amount = monthlyData.values.elementAt(index) as double;
                return FlSpot(index.toDouble(), amount.abs());
              }
            ),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    // Group by categories for pie chart using Map<String, dynamic>
    final Map<String, dynamic> categoryData = {};
    
    for (var report in _reports) {
      final category = report.isExpense ? 'Expense' : 'Income'; // You should use actual categories
      
      if (categoryData.containsKey(category)) {
        categoryData[category] = (categoryData[category] as double) + report.amount;
      } else {
        categoryData[category] = report.amount;
      }
    }
    
    // Calculate total for percentages
    final double total = categoryData.values
        .map((e) => e as double)
        .fold(0.0, (sum, value) => sum + value);
    
    final List<PieChartSectionData> sections = [];
    int index = 0;
    
    // Colors for different sections
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];
    
    categoryData.forEach((category, amount) {
      final double value = amount as double;
      final double percentage = (value / total) * 100;
      sections.add(
        PieChartSectionData(
          color: colors[index % colors.length],
          value: value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });
    
    return Stack(
      children: [
        PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 40,
            sectionsSpace: 2,
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                // Handle touch events if needed
              },
            ),
          ),
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(
                  categoryData.length,
                  (index) {
                    final category = categoryData.keys.elementAt(index);
                    final color = colors[index % colors.length];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          category,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}