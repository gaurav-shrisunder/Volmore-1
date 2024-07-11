import 'package:flutter/material.dart';
import 'package:volunterring/Utils/Colors.dart';

class QnAWidget extends StatelessWidget {
  final List<Map<String, String>> qnaList;

  QnAWidget({required this.qnaList});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Column(
      children: qnaList.map((qna) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListTile(
            title: Text(
              qna['question'] ?? '',
              style: TextStyle(
                fontSize: height * 0.025,
                color: headingBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              qna['answer'] ?? '',
              style: TextStyle(
                fontSize: height * 0.019,
                color: headingBlue,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
