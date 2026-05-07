import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../subjects/providers/subject_provider.dart';
import '../topics/providers/topic_provider.dart';
import '../scheduling/providers/schedule_provider.dart';
import '../../../models/topic_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectProvider);
    final topics = ref.watch(topicProvider);
    final schedules = ref.watch(scheduleProvider);

    final totalSubjects = subjects.length;
    final totalTopics = topics.length;
    final completedTopics = topics.where((t) => t.status == TopicStatus.completed).length;

    final today = DateTime.now();
    final todaySchedules = schedules.where((s) =>
        s.date.year == today.year &&
        s.date.month == today.month &&
        s.date.day == today.day).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Study Planner'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => context.pop(),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Manage Subjects'),
              onTap: () {
                context.pop();
                context.push('/subjects');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Study Schedule'),
              onTap: () {
                context.pop();
                context.push('/schedule');
              },
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart),
              title: const Text('Progress Tracking'),
              onTap: () {
                context.pop();
                context.push('/progress');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(context, totalSubjects, totalTopics, completedTopics),
            const SizedBox(height: 24),
            Text(
              'Today\'s Study Sessions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildTodaySessions(todaySchedules),
            const SizedBox(height: 24),
            Text(
              'Recommended Next Topic',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildRecommendationCard(context, ref),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('Add Subject'),
                      onTap: () {
                        context.pop();
                        context.push('/subjects');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.topic),
                      title: const Text('Add Topic'),
                      onTap: () {
                        context.pop();
                        context.push('/topics/add');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('Schedule Session'),
                      onTap: () {
                        context.pop();
                        context.push('/schedule');
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, int totalSubjects, int totalTopics, int completedTopics) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            'Total Subjects',
            totalSubjects.toString(),
            Icons.book,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Topics Completed',
            '$completedTopics/$totalTopics',
            Icons.check_circle,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySessions(List todaySchedules) {
    if (todaySchedules.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No study sessions scheduled for today.'),
          ),
        ),
      );
    }
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: todaySchedules.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final schedule = todaySchedules[index];
          // In a real app we'd look up subject/topic names
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(0.2),
              child: const Icon(Icons.science, color: Colors.purple),
            ),
            title: Text('Session ${index + 1}'),
            subtitle: Text('Duration: ${schedule.durationMinutes} mins'),
            trailing: Icon(
              schedule.isCompleted ? Icons.check_circle : Icons.play_circle_fill,
              color: schedule.isCompleted ? Colors.green : Colors.purple,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(topicProvider);
    final pendingTopics = topics.where((t) => t.status != TopicStatus.completed).toList();
    
    if (pendingTopics.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('All caught up! No recommendations.'),
          ),
        ),
      );
    }

    final recommendedTopic = pendingTopics.first; // Simple logic: pick first pending

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.amber, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendedTopic.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Next pending topic',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
