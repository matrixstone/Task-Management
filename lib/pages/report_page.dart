import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

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

class ReportPage extends StatefulWidget {
  Map<Project, Map<DateTime, double>> projectsToTime;

  ReportPage({super.key, required this.projectsToTime});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    var isCardView = true;
    return ListView(
      children: [
        SfCartesianChart(
            // Initialize category axis
            primaryXAxis: CategoryAxis(),
            // primaryYAxis: NumericAxis(),
            legend: const Legend(isVisible: true),
            series:
                // Initialize line series
                _getCartesianChartData()),
        SfCircularChart(
          title: ChartTitle(
              text: isCardView
                  ? ''
                  : 'Various countries population density and area'),
          legend: Legend(
              isVisible: !isCardView,
              overflowMode: LegendItemOverflowMode.wrap),
          series: _getRadiusPieSeries(),
          onTooltipRender: (TooltipArgs args) {
            final NumberFormat format = NumberFormat.decimalPattern();
            args.text =
                args.dataPoints![args.pointIndex!.toInt()].x.toString() +
                    ' : ' +
                    format.format(args.dataPoints![args.pointIndex!.toInt()].y);
          },
          tooltipBehavior: TooltipBehavior(enable: true),
        )
      ],
    );
  }

  // LineSeries<ChartData, String> _getCartesianChartData() {
  List<CartesianSeries> _getCartesianChartData() {
    List<CartesianSeries> series = <CartesianSeries>[];
    widget.projectsToTime.forEach((project, value) {
      Map<String, double> dateTimeMap = {};
      value.entries.forEach((entry) {
        String dateKey = DateFormat('yyyy-MM-dd').format(entry.key);
        if (dateTimeMap.containsKey(dateKey)) {
          dateTimeMap[dateKey] = dateTimeMap[dateKey]! + entry.value;
        } else {
          dateTimeMap[dateKey] = entry.value;
        }
      });
      List<ChartData> dateAndSpendTime =
          dateTimeMap.entries.map((e) => ChartData(e.key, e.value)).toList();
      dateAndSpendTime.sort((a, b) => a.x.compareTo(b.x));
      series.add(LineSeries<ChartData, String>(
          dataSource: dateAndSpendTime,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          isVisibleInLegend: true,
          name: project.title));
    });
    return series;

    // return LineSeries<ChartData, String>(
    //     dataSource: [
    //       // Bind data source
    //       ChartData('2024-01-06', 35),
    //       ChartData('2024-01-07', 28),
    //       ChartData('2024-01-08', 34),
    //       ChartData('2024-01-09', 32),
    //       ChartData('2024-01-10', 40)
    //     ],
    //     xValueMapper: (ChartData data, _) => data.x,
    //     yValueMapper: (ChartData data, _) => data.y,
    //     dataLabelSettings: const DataLabelSettings(isVisible: true),
    //     isVisibleInLegend: true,
    //     name: 'Series 1');
  }

  List<PieSeries<ChartData, String>> _getRadiusPieSeries() {
    List<ChartData> projectTime = widget.projectsToTime.entries.map((entry) {
      double accumulativeTime = 0;
      entry.value.forEach((date, time) {
        accumulativeTime += time;
      });
      // return MapEntry(project, accumulativeTime);
      return ChartData(entry.key.title, accumulativeTime);
    }).toList();

    print('Testing loading projectsToTime argument: ${widget.projectsToTime}');
    print('Testing loading projectsToTime: ${projectTime}');
    return <PieSeries<ChartData, String>>[
      PieSeries<ChartData, String>(
          // dataSource: <ChartData>[
          //   ChartData(
          //     'Argentina',
          //     505370,
          //   ),
          //   ChartData('Belgium', 551500),
          //   ChartData('Cuba', 312685),
          // ],
          dataSource: projectTime,
          xValueMapper: (ChartData data, _) => data.x as String,
          yValueMapper: (ChartData data, _) => data.y,
          dataLabelMapper: (ChartData data, _) => data.x as String,
          startAngle: 100,
          endAngle: 100,
          // pointRadiusMapper: (ChartData data, _) => data.text,
          dataLabelSettings: const DataLabelSettings(
              isVisible: true, labelPosition: ChartDataLabelPosition.outside))
    ];
  }
}
