

import 'package:flutter/material.dart';
import 'package:volunterring/widgets/weekly_stats_chart.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: WeeklyStatsChart(xAxisList: ["Mon","Tues","Wed"], yAxisList: [1,2,3,4,5], xAxisName: "", yAxisName: "", interval: 5),
      ),
    );
  }
}
