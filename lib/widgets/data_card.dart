import 'package:flutter/material.dart';

// A helper class to define a column, its data, and its sorting behavior.
class SortableColumn<T> {
  final String label;
  final String? tooltip;
  final bool numeric;
  final Comparable Function(T item) getField;
  final Widget Function(T item) cellBuilder;

  SortableColumn({
    required this.label,
    this.tooltip,
    this.numeric = false,
    required this.getField,
    required this.cellBuilder,
  });
}

class DataCard<T> extends StatefulWidget {
  final String title;
  final List<T> data;
  final List<SortableColumn<T>> columns;

  const DataCard({
    super.key,
    required this.title,
    required this.data,
    required this.columns,
  });

  @override
  State<DataCard<T>> createState() => _DataCardState<T>();
}

class _DataCardState<T> extends State<DataCard<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<T> _sortedData;

  @override
  void initState() {
    super.initState();
    _sortedData = List.from(widget.data);
  }

  @override
  void didUpdateWidget(covariant DataCard<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the data from the parent widget changes, we need to update our local copy.
    if (widget.data != oldWidget.data) {
      setState(() {
        _sortedData = List.from(widget.data);
        // Reset sorting when data changes
        _sortColumnIndex = null;
        _sortAscending = true;
      });
    }
  }

  void _sort(int columnIndex, bool ascending) {
    final column = widget.columns[columnIndex];
    _sortedData.sort((a, b) {
      final aValue = column.getField(a);
      final bValue = column.getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: List.generate(
                  widget.columns.length,
                  (index) {
                    final column = widget.columns[index];
                    return DataColumn(
                      label: Text(column.label),
                      tooltip: column.tooltip,
                      numeric: column.numeric,
                      onSort: (columnIndex, ascending) => _sort(columnIndex, ascending),
                    );
                  },
                ),
                rows: _sortedData.map((item) {
                  return DataRow(
                    cells: widget.columns.map((column) {
                      return DataCell(column.cellBuilder(item));
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}