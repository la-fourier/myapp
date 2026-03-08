import 'package:flutter/material.dart';

class SortableColumn<T> {
  final String label;
  final String? tooltip;
  final bool numeric;
  final Comparable Function(T item) getField;
  final Widget Function(T item) cellBuilder;
  double? width;
  Alignment alignment;

  SortableColumn({
    required this.label,
    this.tooltip,
    this.numeric = false,
    required this.getField,
    required this.cellBuilder,
    this.width,
    this.alignment = Alignment.centerLeft,
  });
}

class DataCard<T> extends StatefulWidget {
  final List<T> data;
  final List<SortableColumn<T>> columns;
  final String? filterText;
  final void Function(T item)? onRowTap;

  const DataCard({
    super.key,
    required this.data,
    required this.columns,
    this.filterText,
    this.onRowTap,
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
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _sortedData = List.from(widget.data);
    _columnVisibility = {for (var col in widget.columns) col.label: true};
    _orderedColumns = List.from(widget.columns);
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DataCard<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      setState(() {
        _sortedData = List.from(widget.data);
        if (_sortColumnIndex != null) {
          _sort(
            _orderedColumns[_sortColumnIndex!].getField,
            _sortColumnIndex!,
            _sortAscending,
          );
        }
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

  void _showColumnOptions(BuildContext context, SortableColumn<T> column, Offset position) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect positionRect = RelativeRect.fromRect(
      position & const Size(40, 40),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: positionRect,
      elevation: 8,
      items: [
        PopupMenuItem(
          value: 'hide',
          child: const Row(children: [Icon(Icons.visibility_off, size: 20), SizedBox(width: 8), Text('Hide Column')]),
        ),
        PopupMenuItem(
          value: 'sort_asc',
          child: const Row(children: [Icon(Icons.arrow_upward, size: 20), SizedBox(width: 8), Text('Sort Ascending')]),
        ),
        PopupMenuItem(
          value: 'sort_desc',
          child: const Row(children: [Icon(Icons.arrow_downward, size: 20), SizedBox(width: 8), Text('Sort Descending')]),
        ),
        PopupMenuItem(
          value: 'align_left',
          child: const Row(children: [Icon(Icons.format_align_left, size: 20), SizedBox(width: 8), Text('Align Left')]),
        ),
        PopupMenuItem(
          value: 'align_right',
          child: const Row(children: [Icon(Icons.format_align_right, size: 20), SizedBox(width: 8), Text('Align Right')]),
        ),
      ],
    ).then((value) {
      if (value == null) return;
      setState(() {
        switch (value) {
          case 'hide':
            _columnVisibility[column.label] = false;
            break;
          case 'sort_asc':
            _sort(column.getField, _orderedColumns.indexOf(column), true);
            break;
          case 'sort_desc':
            _sort(column.getField, _orderedColumns.indexOf(column), false);
            break;
          case 'align_left':
            column.alignment = Alignment.centerLeft;
            break;
          case 'align_right':
            column.alignment = Alignment.centerRight;
            break;
        }
      });
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
          } else {
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dataTableTheme: DataTableThemeData(
                        headingRowColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4)
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          showCheckboxColumn: false,
                          sortColumnIndex: _sortColumnIndex != null && _sortColumnIndex! < visibleColumns.length ? _sortColumnIndex : null,
                          sortAscending: _sortAscending,
                          headingRowHeight: 56,
                          dataRowMinHeight: 52,
                          dataRowMaxHeight: 52,
                          horizontalMargin: 24,
                          columnSpacing: 0,
                          columns: visibleColumns.map((column) {
                            return DataColumn(
                              label: SizedBox(
                                width: column.width ?? 150,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onSecondaryTapDown: (details) => _showColumnOptions(context, column, details.globalPosition),
                                          child: Builder(
                                            builder: (ctx) => InkWell(
                                              onTap: () {
                                                final RenderBox box = ctx.findRenderObject() as RenderBox;
                                                final Offset position = box.localToGlobal(Offset.zero);
                                                _showColumnOptions(ctx, column, position + const Offset(0, 40));
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      column.label, 
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(Icons.arrow_drop_down, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onHorizontalDragUpdate: (details) {
                                        setState(() {
                                          column.width = (column.width ?? 150) + details.delta.dx;
                                          if (column.width! < 50) column.width = 50;
                                        });
                                      },
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.resizeLeftRight,
                                        child: Container(
                                          width: 10,
                                          height: 24,
                                          color: Colors.transparent,
                                          child: Center(
                                            child: Container(
                                              width: 1,
                                              height: 16,
                                              color: Theme.of(context).dividerColor.withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              tooltip: column.tooltip ?? 'Click for options',
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
                              onSelectChanged: widget.onRowTap != null ? (_) => widget.onRowTap!(item) : null,
                              cells: visibleColumns.map((column) {
                                return DataCell(
                                  SizedBox(
                                    width: column.width ?? 150,
                                    child: Align(
                                      alignment: column.alignment,
                                      child: column.cellBuilder(item)
                                    ),
                                  )
                                );
                              }).toList(),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
