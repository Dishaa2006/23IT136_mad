import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../subjects/providers/subject_provider.dart';
import '../../topics/providers/topic_provider.dart';
import '../../../models/topic_model.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectProvider);
    final topics = ref.watch(topicProvider);

    if (subjects.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Progress Tracking')),
        body: const Center(child: Text('Add subjects to view progress')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Completion',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildOverallPieChart(topics, context),
            const SizedBox(height: 32),
            Text(
              'Subject Wise Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSubjectProgressBars(subjects, topics, context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallPieChart(List<TopicModel> topics, BuildContext context) {
    if (topics.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No topics available for analysis')),
      );
    }

    final completed = topics.where((t) => t.status == TopicStatus.completed).length;
    final inProgress = topics.where((t) => t.status == TopicStatus.inProgress).length;
    final notStarted = topics.where((t) => t.status == TopicStatus.notStarted).length;

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: [
            PieChartSectionData(
              color: Colors.green,
              value: completed.toDouble(),
              title: '$completed',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              color: Colors.orange,
              value: inProgress.toDouble(),
              title: '$inProgress',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              color: Colors.grey,
              value: notStarted.toDouble(),
              title: '$notStarted',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectProgressBars(List subjects, List<TopicModel> topics, BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subjects.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final subjectTopics = topics.where((t) => t.subjectId == subject.id).toList();
        final total = subjectTopics.length;
        final completed = subjectTopics.where((t) => t.status == TopicStatus.completed).length;
        final progress = total == 0 ? 0.0 : completed / total;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subject.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              color: Color(subject.colorValue),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        );
      },
    );
  }
}
