import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:task_management/provider/data_provider.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

import '../model/project.dart';

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
  @override
  String toString() {
    return 'ChartData{x: $x, y: $y}';
  }
}

// Shows projects analytics information.
class ReportPage extends StatefulWidget {
  Map<Project, Map<DateTime, double>> projectsToTime;
  int viewLastXDays = 7;
  final DataProvider dataProvider;

  ReportPage(
      {super.key, required this.projectsToTime, required this.dataProvider});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // Map<Project, Map<DateTime, double>>? newProjectsToTime;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        buildLastXDaysSelector(),
        const SizedBox(height: 20),
        // Shows timeseries chart of how many hours spent on each project in last 7 days.
        SfCartesianChart(
            // // Initialize category axis
            // primaryXAxis: const CategoryAxis(),
            // primaryYAxis: NumericAxis(),
            title: const ChartTitle(text: 'Daily Focus Timeseries'),
            legend: const Legend(isVisible: true),
            zoomPanBehavior: ZoomPanBehavior(
                // Enables pinch zooming
                enablePanning: true,
                enablePinching: true,
                zoomMode: ZoomMode.x),
            primaryXAxis: const CategoryAxis(
              majorGridLines: MajorGridLines(width: 0),
              labelIntersectAction: AxisLabelIntersectAction.hide,
              autoScrollingDelta: 7,
              labelRotation: 320,
              labelAlignment: LabelAlignment.end,
              // minimum: 3,
              // maximum: 10,
              // initialVisibleMinimum:
              //     3, // set the visible minimum as the 15 chart data index from the last value.
              // initialVisibleMaximum:
              //     20, // set the visible minimum as the last value's chart data index.
              // maximumLabels: 10,
            ),
            primaryYAxis: const NumericAxis(
              majorGridLines: MajorGridLines(width: 0),
              labelStyle: TextStyle(color: Color(0xFF71AF99), fontSize: 16),
              minimum: 0,
            ),
            series:
                // Initialize line series
                _getTimeseriesCartesianChartData()),
        // Shows pie chart of how many hours spent on each project in total
        SfCircularChart(
          title: const ChartTitle(text: 'Accumulated Focus Time'),
          legend: const Legend(
              isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
          series: _getRadiusPieSeries(),
          onTooltipRender: (TooltipArgs args) {
            final NumberFormat format = NumberFormat.decimalPattern();
            args.text =
                '${args.dataPoints![args.pointIndex!.toInt()].x.toString()}'
                ' : ${format.format(args.dataPoints![args.pointIndex!.toInt()].y)}';
          },
          tooltipBehavior: TooltipBehavior(enable: true),
        )
      ],
    );
  }

  Widget buildLastXDaysSelector() {
    List<int> days = [7, 14, 30];
    return DropdownMenu<int>(
      initialSelection: 7,
      helperText: 'Past X days',
      requestFocusOnTap: true,
      label: const Text('Historical Days'),
      // Rounded selection box
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
      ),
      onSelected: (int? value) {
        // This is called when the user selects an item.
        setState(() {
          widget.viewLastXDays = value!;
        });
      },
      width: 150,
      dropdownMenuEntries: days.map<DropdownMenuEntry<int>>((int day) {
        return DropdownMenuEntry<int>(
          // value: Container(color: Colors.blue, child: Text(item.name)),
          value: day,
          label: '$day Days',
        );
      }).toList(),
    );
  }

  List<CartesianSeries> _getTimeseriesCartesianChartData() {
    List<CartesianSeries> series = <CartesianSeries>[];
    widget.projectsToTime.forEach((project, value) {
      // For each project, sum up the time spent on each day into dateTimeMap.
      Map<String, double> dateTimeMap = {};
      // Initialize dateTimeMap
      for (int i = 0; i < widget.viewLastXDays; i++) {
        DateTime datePointer = DateTime.now().subtract(Duration(days: i));
        String dateKey = DateFormat('yyyy-MM-dd').format(datePointer);
        dateTimeMap[dateKey] = 0;
      }

      // Set start date
      DateTime startDate =
          DateTime.now().subtract(Duration(days: widget.viewLastXDays));
      DateTime startDateOnlyFormat =
          DateTime(startDate.year, startDate.month, startDate.day);
      for (MapEntry<DateTime, double> entry in value.entries) {
        if (entry.key.isBefore(startDateOnlyFormat)) {
          continue;
        }
        String dateKey = DateFormat('yyyy-MM-dd').format(entry.key);
        if (dateTimeMap.containsKey(dateKey)) {
          dateTimeMap[dateKey] = dateTimeMap[dateKey]! + entry.value;
        }
      }
      List<ChartData> dateAndSpendTime =
          dateTimeMap.entries.map((e) => ChartData(e.key, e.value)).toList();
      dateAndSpendTime.sort((a, b) => a.x.compareTo(b.x));
      series.add(SplineSeries<ChartData, String>(
          dataSource: dateAndSpendTime,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          isVisibleInLegend: true,
          color: project.color,
          name: project.title));
    });
    return series;
  }

  List<PieSeries<ChartData, String>> _getRadiusPieSeries() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime beginDate = today.subtract(Duration(days: widget.viewLastXDays));

    List<ChartData> projectTime = widget.projectsToTime.entries.map((entry) {
      double accumulativeTime = 0;
      entry.value.forEach((toDate, time) {
        if (toDate.isAfter(beginDate)) {
          accumulativeTime += time;
        }
      });
      // return MapEntry(project, accumulativeTime);
      return ChartData(entry.key.title, accumulativeTime);
    }).toList();

    Map<String, Color> projectColors = widget.projectsToTime
        .map((key, value) => MapEntry(key.title, key.color));

    return <PieSeries<ChartData, String>>[
      PieSeries<ChartData, String>(
          dataSource: projectTime,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          pointColorMapper: (ChartData data, _) => projectColors[data.x],
          dataLabelMapper: (ChartData data, _) => data.x,
          startAngle: 100,
          endAngle: 100,
          // pointRadiusMapper: (ChartData data, _) => data.text,
          dataLabelSettings: const DataLabelSettings(
              isVisible: true, labelPosition: ChartDataLabelPosition.outside))
    ];
  }
}
