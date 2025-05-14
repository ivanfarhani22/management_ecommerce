import 'package:flutter/material.dart';

class DateRangePicker extends StatefulWidget {
  final Function(DateTime?, DateTime?) onDateRangeSelected;

  const DateRangePicker({
    super.key,
    required this.onDateRangeSelected,
  });

  @override
  _DateRangePickerState createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      widget.onDateRangeSelected(_startDate, _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Start Date',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text: _startDate != null
                    ? '${_startDate!.toLocal()}'.split(' ')[0]
                    : '',
              ),
              readOnly: true,
              onTap: _selectDateRange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'End Date',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text: _endDate != null
                    ? '${_endDate!.toLocal()}'.split(' ')[0]
                    : '',
              ),
              readOnly: true,
              onTap: _selectDateRange,
            ),
          ),
        ],
      ),
    );
  }
}