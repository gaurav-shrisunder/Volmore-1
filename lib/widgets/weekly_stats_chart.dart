import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyStatsChart extends StatefulWidget {
  final List<String> xAxisList;
  final String xAxisName;
  final List<double> yAxisList;
  final String yAxisName;
  final double interval;
  const WeeklyStatsChart(
      {super.key,
      required this.xAxisList,
      required this.yAxisList,
      required this.xAxisName,
      required this.yAxisName,
      required this.interval});

  @override
  State<WeeklyStatsChart> createState() => _WeeklyStatsChartState();
}

class _WeeklyStatsChartState extends State<WeeklyStatsChart> {
  late List<String> xAxisList;
  late List<double> yAxisList;
  late String xAxisName;
  late String yAxisName;
  late double interval;

  @override
  void initState() {
    super.initState();
    xAxisList = widget.xAxisList;
    yAxisList = widget.yAxisList;
    xAxisName = widget.xAxisName;
    yAxisName = widget.yAxisName;
    interval = widget.interval;
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) =>
                  bottomTitles(value, meta, xAxisList),
              reservedSize: 60,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: interval,
              getTitlesWidget: leftTitles,
            ),
          ),
        ),
        borderData: FlBorderData(
          border: const Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(width: 1),
            bottom: BorderSide(width: 1),
          ),
        ),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(
          xAxisList.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                  toY: yAxisList[index],
                  width: 20,
                  color: Colors.blue.shade500,
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10))),
            ],
          ),
        ).toList(),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blue,
          width: 16,
        ),
      ],
    );
  }
}

Widget bottomTitles(
    double value, TitleMeta meta, List<String> bottomTilesData) {
  final Widget text = Text(
    bottomTilesData[value.toInt()],
    style: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
  );

  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 16,
    child: text,
  );
}

Widget leftTitles(double value, TitleMeta meta) {
  final formattedValue = (value).toStringAsFixed(0);
  final Widget text = Text(
    formattedValue,
    style: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
  );

  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 16,
    child: text,
  );
}
