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

  // Helper method to safely convert dynamic value to double
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Remove any currency symbols or commas
      String cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  // Helper method to safely convert dynamic value to bool
  bool _safeToBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return false;
  }

  // Helper method to safely convert dynamic value to DateTime
  DateTime _safeToDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // Helper method to safely convert dynamic value to String
  String _safeToString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  // Safe method to create FinancialReport from JSON with error handling
  FinancialReport? _safeCreateFinancialReport(Map<String, dynamic> data) {
    try {
      // Create a completely safe copy of the data with proper type conversion
      final Map<String, dynamic> safeData = {
        'id': _safeToString(data['id'] ?? ''),
        'title': _safeToString(data['title'] ?? data['name'] ?? ''),
        'description': _safeToString(data['description'] ?? data['desc'] ?? ''),
        'amount': _safeToDouble(data['amount']),
        'isExpense': _safeToBool(data['isExpense'] ?? data['is_expense'] ?? data['type'] == 'expense'),
        'date': _safeToDateTime(data['date'] ?? data['created_at'] ?? data['timestamp']),
        'category': _safeToString(data['category'] ?? ''),
      };
      
      print('Creating FinancialReport with safe data: $safeData'); // Debug log
      
      return FinancialReport.fromJson(safeData);
    } catch (e) {
      print('Error creating FinancialReport from data: $data, Error: $e');
      return null;
    }
  }

  Future<void> _fetchReports() async {
    setState(() => _isLoading = true);
    try {
      // Get the raw reports data
      final dynamic rawData = await _financeApi.getAllFinances();
      
      print('Raw API response: $rawData'); // Debug log
      
      List<FinancialReport> reports = [];
      
      if (rawData is List) {
        // If the API returns a List<Map<String, dynamic>>
        for (var item in rawData) {
          if (item is Map<String, dynamic>) {
            final report = _safeCreateFinancialReport(item);
            if (report != null) {
              reports.add(report);
            }
          }
        }
      } else if (rawData is Map<String, dynamic>) {
        // If the API returns a single Map with a list inside
        List<dynamic> dataList = [];
        
        if (rawData.containsKey('data') && rawData['data'] is List) {
          dataList = rawData['data'];
        } else if (rawData.containsKey('finances') && rawData['finances'] is List) {
          dataList = rawData['finances'];
        } else if (rawData.containsKey('reports') && rawData['reports'] is List) {
          dataList = rawData['reports'];
        } else if (rawData.containsKey('result') && rawData['result'] is List) {
          dataList = rawData['result'];
        } else {
          // If it's a single financial report
          final report = _safeCreateFinancialReport(rawData);
          if (report != null) {
            reports = [report];
          }
        }
        
        // Process the list
        for (var item in dataList) {
          if (item is Map<String, dynamic>) {
            final report = _safeCreateFinancialReport(item);
            if (report != null) {
              reports.add(report);
            }
          }
        }
      } else {
        throw Exception('Unexpected data format from API: ${rawData.runtimeType}');
      }
      
      print('Successfully loaded ${reports.length} reports'); // Debug log
      
      // Filter by date range if provided
      if (widget.startDate != null && widget.endDate != null) {
        final initialCount = reports.length;
        reports = reports.where((report) {
          return report.date.isAfter(widget.startDate!.subtract(const Duration(days: 1))) &&
                 report.date.isBefore(widget.endDate!.add(const Duration(days: 1)));
        }).toList();
        print('Filtered ${initialCount} reports to ${reports.length} based on date range'); // Debug log
      }
      
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() => _isLoading = false);
      print('Error loading reports: $e'); // Debug print
      print('Stack trace: $stackTrace'); // Debug print
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reports: ${e.toString()}')),
        );
      }
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
    // Group by month using Map<String, double> for better type safety
    final Map<String, double> monthlyData = {};
    
    for (var report in _reports) {
      final month = '${report.date.month}/${report.date.year}';
      final value = report.isExpense ? -report.amount : report.amount;
      
      monthlyData[month] = (monthlyData[month] ?? 0.0) + value;
    }

    if (monthlyData.isEmpty) {
      return const Center(child: Text('No data to display'));
    }

    // Find maximum value for scaling the chart properly
    final double maxAmount = monthlyData.values
        .map((e) => e.abs())
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
              final value = monthlyData[key]!;
              return BarTooltipItem(
                '$key: \$${value.abs().toStringAsFixed(2)}',
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
                  '\$${value.toInt()}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
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
          horizontalInterval: maxAmount > 0 ? maxAmount / 5 : 1,
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
            final double amount = monthlyData[month]!;
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
    // Group by month for line chart using Map<String, double>
    final Map<String, double> monthlyData = {};
    
    for (var report in _reports) {
      final month = '${report.date.month}/${report.date.year}';
      final value = report.isExpense ? -report.amount : report.amount;
      
      monthlyData[month] = (monthlyData[month] ?? 0.0) + value;
    }

    if (monthlyData.isEmpty) {
      return const Center(child: Text('No data to display'));
    }

    // Find maximum value for scaling the chart properly
    final double maxAmount = monthlyData.values
        .map((e) => e.abs())
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
                  '$key: \$${spot.y.toStringAsFixed(2)}',
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
                  '\$${value.toInt()}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxAmount > 0 ? maxAmount / 5 : 1,
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
                final double amount = monthlyData.values.elementAt(index);
                return FlSpot(index.toDouble(), amount.abs());
              }
            ),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
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
    // Group by categories for pie chart using Map<String, double>
    final Map<String, double> categoryData = {};
    
    for (var report in _reports) {
      final category = report.isExpense ? 'Expenses' : 'Income';
      
      categoryData[category] = (categoryData[category] ?? 0.0) + report.amount.abs();
    }
    
    if (categoryData.isEmpty) {
      return const Center(child: Text('No data to display'));
    }
    
    // Calculate total for percentages
    final double total = categoryData.values.fold(0.0, (sum, value) => sum + value);
    
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
      final double percentage = (amount / total) * 100;
      sections.add(
        PieChartSectionData(
          color: colors[index % colors.length],
          value: amount,
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
                    final amount = categoryData.values.elementAt(index);
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
                          '$category (\$${amount.toStringAsFixed(2)})',
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