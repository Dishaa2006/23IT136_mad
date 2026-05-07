import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';
import '../../subjects/providers/subject_provider.dart';
import '../../topics/providers/topic_provider.dart';
import '../../../models/schedule_model.dart';

class ScheduleCalendarScreen extends ConsumerStatefulWidget {
  const ScheduleCalendarScreen({super.key});

  @override
  ConsumerState<ScheduleCalendarScreen> createState() => _ScheduleCalendarScreenState();
}

class _ScheduleCalendarScreenState extends ConsumerState<ScheduleCalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddScheduleDialog() {
    final subjects = ref.read(subjectProvider);
    final topics = ref.read(topicProvider);

    if (subjects.isEmpty || topics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add subjects and topics first.')),
      );
      return;
    }

    String? selectedSubjectId;
    String? selectedTopicId;
    DateTime selectedTime = DateTime.now();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final availableTopics = selectedSubjectId == null
                ? []
                : topics.where((t) => t.subjectId == selectedSubjectId).toList();

            return AlertDialog(
              title: const Text('Schedule Session'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedSubjectId,
                      hint: const Text('Select Subject'),
                      items: subjects.map((s) {
                        return DropdownMenuItem(value: s.id, child: Text(s.name));
                      }).toList(),
                      onChanged: (val) {
                        setStateDialog(() {
                          selectedSubjectId = val;
                          selectedTopicId = null; // Reset topic when subject changes
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedTopicId,
                      hint: const Text('Select Topic'),
                      items: availableTopics.map((t) {
                        return DropdownMenuItem(value: t.id, child: Text(t.name));
                      }).toList(),
                      onChanged: selectedSubjectId == null
                          ? null
                          : (val) {
                              setStateDialog(() {
                                selectedTopicId = val;
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Time: ${DateFormat.jm().format(selectedTime)}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedTime),
                        );
                        if (time != null) {
                          setStateDialog(() {
                            selectedTime = DateTime(
                              _selectedDate.year,
                              _selectedDate.month,
                              _selectedDate.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedSubjectId != null &&
                        selectedTopicId != null &&
                        durationController.text.isNotEmpty) {
                      final duration = int.parse(durationController.text);
                      // Adjust selectedTime to ensure it falls on _selectedDate
                      final finalDateTime = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      ref.read(scheduleProvider.notifier).addSchedule(
                            selectedSubjectId!,
                            selectedTopicId!,
                            finalDateTime,
                            duration,
                          );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedules = ref.watch(scheduleProvider);
    final subjects = ref.watch(subjectProvider);
    final topics = ref.watch(topicProvider);

    final selectedDateSchedules = schedules.where((s) =>
        s.date.year == _selectedDate.year &&
        s.date.month == _selectedDate.month &&
        s.date.day == _selectedDate.day).toList();

    selectedDateSchedules.sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMMd().format(_selectedDate),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime.now();
                    });
                  },
                  icon: const Icon(Icons.today, size: 18),
                  label: const Text('Today'),
                )
              ],
            ),
          ),
          Expanded(
            child: selectedDateSchedules.isEmpty
                ? const Center(child: Text('No sessions scheduled for this date.'))
                : ListView.builder(
                    itemCount: selectedDateSchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = selectedDateSchedules[index];
                      final subject = subjects.firstWhere(
                          (s) => s.id == schedule.subjectId,
                          orElse: () => throw Exception('Subject not found'));
                      final topic = topics.firstWhere(
                          (t) => t.id == schedule.topicId,
                          orElse: () => throw Exception('Topic not found'));

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(subject.colorValue),
                            child: Icon(Icons.book, color: Colors.white),
                          ),
                          title: Text('${subject.name} - ${topic.name}'),
                          subtitle: Text(
                              '${DateFormat.jm().format(schedule.date)} (${schedule.durationMinutes} mins)'),
                          trailing: IconButton(
                            icon: Icon(
                              schedule.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                              color: schedule.isCompleted ? Colors.green : Colors.grey,
                            ),
                            onPressed: () {
                              ref.read(scheduleProvider.notifier).toggleScheduleCompletion(schedule.id);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddScheduleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
