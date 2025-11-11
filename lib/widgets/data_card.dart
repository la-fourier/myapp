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
  final List<T> data;
  final List<SortableColumn<T>> columns;
  final String? filterText;

  const DataCard({
    super.key,
    required this.data,
    required this.columns,
    this.filterText,
  });

  @override
  State<DataCard<T>> createState() => _DataCardState<T>();
}

class _DataCardState<T> extends State<DataCard<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<T> _sortedData;
  late Map<String, bool> _columnVisibility;
  late List<SortableColumn<T>> _orderedColumns;

  @override
  void initState() {
    super.initState();
    _sortedData = List.from(widget.data);
    _columnVisibility = {for (var col in widget.columns) col.label: true};
    _orderedColumns = List.from(widget.columns);
  }

  @override
  void didUpdateWidget(covariant DataCard<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      setState(() {
        _sortedData = List.from(widget.data);
        _sortColumnIndex = null;
        _sortAscending = true;
      });
    }
    if (widget.columns != oldWidget.columns) {
      setState(() {
        _columnVisibility = {for (var col in widget.columns) col.label: true};
        _orderedColumns = List.from(widget.columns);
      });
    }
  }

  void _sort(
    Comparable Function(T item) getField,
    int columnIndex,
    bool ascending,
  ) {
    _sortedData.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
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
    final visibleColumns = _orderedColumns
        .where((c) => _columnVisibility[c.label] ?? true)
        .toList();

    List<T> filteredData = _sortedData;
    if (widget.filterText != null && widget.filterText!.isNotEmpty) {
      final filter = widget.filterText!.toLowerCase();
      filteredData = _sortedData.where((item) {
        for (var column in visibleColumns) {
          final cellWidget = column.cellBuilder(item);
          if (cellWidget is Text) {
            if (cellWidget.data!.toLowerCase().contains(filter)) {
              return true;
            }
          } else if (cellWidget is Icon) {
            // Cannot filter on icon, so we skip
          } else {
            // For other widgets, we can try a generic toString()
            // This is not ideal but a fallback
            try {
              if (item.toString().toLowerCase().contains(filter)) {
                return true;
              }
            } catch (e) {
              /* ignore */
            }
          }
        }
        return false;
      }).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton<String>(
                onSelected: (String value) {
                  setState(() {
                    _columnVisibility[value] = !_columnVisibility[value]!;
                  });
                },
                itemBuilder: (context) {
                  return widget.columns.map((column) {
                    return CheckedPopupMenuItem<String>(
                      value: column.label,
                      checked: _columnVisibility[column.label] ?? true,
                      child: Text(column.label),
                    );
                  }).toList();
                },
                child: IconButton(
                  tooltip: 'Set visible columns',
                  onPressed: null,
                  icon: const Icon(Icons.view_column_outlined),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: visibleColumns.map((column) {
                  return DataColumn(
                    label: DragTarget<SortableColumn<T>>(
                      builder: (context, candidateData, rejectedData) {
                        return Draggable<SortableColumn<T>>(
                          data: column,
                          feedback: Material(
                            elevation: 4.0,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant,
                              child: Text(column.label),
                            ),
                          ),
                          child: Text(column.label),
                        );
                      },
                      onWillAcceptWithDetails: (data) => data != null,
                      onAcceptWithDetails: (details) {
                        setState(() {
                          final draggedColumn = details.data;
                          final draggedIndex = _orderedColumns.indexOf(
                            draggedColumn,
                          );
                          final targetIndex = _orderedColumns.indexOf(column);
                          if (draggedIndex != -1 && targetIndex != -1) {
                            final item = _orderedColumns.removeAt(draggedIndex);
                            _orderedColumns.insert(targetIndex, item);
                          }
                        });
                      },
                    ),
                    tooltip: column.tooltip,
                    numeric: column.numeric,
                    onSort: (columnIndex, ascending) {
                      _sort(
                        column.getField,
                        visibleColumns.indexOf(column),
                        ascending,
                      );
                    },
                  );
                }).toList(),
                rows: filteredData.map((item) {
                  return DataRow(
                    cells: visibleColumns.map((column) {
                      return DataCell(column.cellBuilder(item));
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
