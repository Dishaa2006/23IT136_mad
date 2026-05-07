import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/topic_provider.dart';
import '../../subjects/providers/subject_provider.dart';
import '../../../models/topic_model.dart';

class TopicListScreen extends ConsumerStatefulWidget {
  const TopicListScreen({super.key});

  @override
  ConsumerState<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends ConsumerState<TopicListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedSubjectId;
  TopicStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTopics = ref.watch(topicProvider);
    final subjects = ref.watch(subjectProvider);

    // Apply filters
    final filteredTopics = allTopics.where((topic) {
      final matchesSearch = topic.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSubject = _selectedSubjectId == null || topic.subjectId == _selectedSubjectId;
      final matchesStatus = _selectedStatus == null || topic.status == _selectedStatus;
      return matchesSearch && matchesSubject && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics & Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/topics/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search topics...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Subject Filter
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSubjectId,
                    hint: const Text('All Subjects'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Subjects')),
                      ...subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedSubjectId = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                
                // Status Filter
                DropdownButtonHideUnderline(
                  child: DropdownButton<TopicStatus>(
                    value: _selectedStatus,
                    hint: const Text('All Statuses'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Statuses')),
                      DropdownMenuItem(value: TopicStatus.notStarted, child: Text('Not Started')),
                      DropdownMenuItem(value: TopicStatus.inProgress, child: Text('In Progress')),
                      DropdownMenuItem(value: TopicStatus.completed, child: Text('Completed')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedStatus = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Results List
          Expanded(
            child: filteredTopics.isEmpty
                ? const Center(child: Text('No topics match your search/filters.'))
                : ListView.builder(
                    itemCount: filteredTopics.length,
                    itemBuilder: (context, index) {
                      final topic = filteredTopics[index];
                      final subject = subjects.firstWhere((s) => s.id == topic.subjectId, 
                          orElse: () => throw Exception('Subject missing'));

                      Color statusColor;
                      switch (topic.status) {
                        case TopicStatus.notStarted:
                          statusColor = Colors.grey;
                          break;
                        case TopicStatus.inProgress:
                          statusColor = Colors.orange;
                          break;
                        case TopicStatus.completed:
                          statusColor = Colors.green;
                          break;
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(subject.colorValue),
                            child: const Icon(Icons.topic, color: Colors.white, size: 20),
                          ),
                          title: Text(topic.name),
                          subtitle: Text('${subject.name} • ${topic.estimatedMinutes} mins'),
                          trailing: PopupMenuButton<TopicStatus>(
                            icon: Icon(Icons.circle, color: statusColor),
                            tooltip: 'Change Status',
                            onSelected: (newStatus) {
                              ref.read(topicProvider.notifier).updateTopicStatus(topic.id, newStatus);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: TopicStatus.notStarted,
                                child: Text('Not Started'),
                              ),
                              PopupMenuItem(
                                value: TopicStatus.inProgress,
                                child: Text('In Progress'),
                              ),
                              PopupMenuItem(
                                value: TopicStatus.completed,
                                child: Text('Completed'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
