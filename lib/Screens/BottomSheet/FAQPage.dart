import 'package:flutter/material.dart';
import '../../Utils/Colors.dart';
import '../../widgets/QnA.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  static const List<Map<String, String>> qnaList = [
    {
      "question":
          "How do I log hours for a volunteering event I did in the past?",
      "answer":
          "Tap the “Log Past Hours” button. You can verify the event with a signature, but not your current geolocation.",
    },
    {
      "question":
          "What if the volunteer organization or person I helped couldn't sign at the event?",
      "answer":
          "No problem! Go to the Past Events tab and tap on Verify to get it signed later.",
    },
    {
      "question": "How do I reset my password?",
      "answer":
          "Go to Settings > Manage My Account to reset your password, update your profile, or delete your account.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'FAQs',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: qnaList.length,
        itemBuilder: (context, index) {
          final qna = qnaList[index];
          return _buildQnACard(
            question: qna["question"]!,
            answer: qna["answer"]!,
            context: context,
          );
        },
      ),
    );
  }

  Widget _buildQnACard({
    required String question,
    required String answer,
    required BuildContext context,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
