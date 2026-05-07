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
    // ✅ VALIDATION: Restrict date picker to today onwards (no past dates selectable)
    final today = DateTime.now();
    final firstAllowedDate = DateTime(today.year, today.month, today.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(firstAllowedDate) ? firstAllowedDate : _selectedDate,
      firstDate: firstAllowedDate, // ← Cannot pick a past date at all
      lastDate: DateTime(2030),
      helpText: 'Select a Future Session Date',
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

    // ✅ VALIDATION: Ensure subjects exist before opening dialog
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            Icon(Icons.warning_amber, color: Colors.white),
            SizedBox(width: 8),
            Text('Please add at least one Subject first!'),
          ]),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ VALIDATION: Ensure topics exist before opening dialog
    if (topics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            Icon(Icons.warning_amber, color: Colors.white),
            SizedBox(width: 8),
            Text('Please add at least one Topic first!'),
          ]),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? selectedSubjectId;
    String? selectedTopicId;
    DateTime selectedTime = DateTime.now().add(const Duration(minutes: 5)); // Default: 5 min ahead
    final durationController = TextEditingController();

    // Error state variables for inline field validation
    String? subjectError;
    String? topicError;
    String? durationError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final availableTopics = selectedSubjectId == null
                ? []
                : topics.where((t) => t.subjectId == selectedSubjectId).toList();

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.schedule, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text('Schedule Session'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Subject Dropdown ──
                    DropdownButtonFormField<String>(
                      value: selectedSubjectId,
                      hint: const Text('Select Subject'),
                      decoration: InputDecoration(
                        errorText: subjectError,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.book),
                      ),
                      items: subjects.map<DropdownMenuItem<String>>((s) {
                        return DropdownMenuItem<String>(value: s.id, child: Text(s.name));
                      }).toList(),
                      onChanged: (val) {
                        setStateDialog(() {
                          selectedSubjectId = val;
                          selectedTopicId = null;
                          subjectError = null; // Clear error on selection
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Topic Dropdown ──
                    DropdownButtonFormField<String>(
                      value: selectedTopicId,
                      hint: Text(selectedSubjectId == null
                          ? 'Select a subject first'
                          : availableTopics.isEmpty
                              ? 'No topics for this subject'
                              : 'Select Topic'),
                      decoration: InputDecoration(
                        errorText: topicError,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.topic),
                      ),
                      items: availableTopics.map<DropdownMenuItem<String>>((t) {
                        return DropdownMenuItem<String>(value: t.id, child: Text(t.name));
                      }).toList(),
                      onChanged: (selectedSubjectId == null || availableTopics.isEmpty)
                          ? null
                          : (val) {
                              setStateDialog(() {
                                selectedTopicId = val;
                                topicError = null; // Clear error on selection
                              });
                            },
                    ),
                    const SizedBox(height: 16),

                    // ── Time Picker ──
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.access_time, color: Colors.deepPurple),
                        title: Text('Session Time: ${DateFormat.jm().format(selectedTime)}'),
                        subtitle: const Text('Tap to change time'),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedTime),
                            helpText: 'Pick Session Start Time',
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
                    ),
                    const SizedBox(height: 16),

                    // ── Duration Field ──
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Duration (minutes)',
                        hintText: 'e.g. 30, 60, 90',
                        prefixIcon: const Icon(Icons.timer),
                        border: const OutlineInputBorder(),
                        errorText: durationError,
                      ),
                      onChanged: (_) {
                        // Clear error as user types
                        if (durationError != null) {
                          setStateDialog(() => durationError = null);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Session'),
                  onPressed: () {
                    bool hasError = false;

                    // ── Field Validation ──
                    if (selectedSubjectId == null) {
                      setStateDialog(() => subjectError = 'Please select a subject');
                      hasError = true;
                    }
                    if (selectedTopicId == null) {
                      setStateDialog(() => topicError = 'Please select a topic');
                      hasError = true;
                    }
                    if (durationController.text.trim().isEmpty) {
                      setStateDialog(() => durationError = 'Duration cannot be empty');
                      hasError = true;
                    } else {
                      final parsed = int.tryParse(durationController.text.trim());
                      if (parsed == null || parsed <= 0) {
                        setStateDialog(() => durationError = 'Enter a valid duration (e.g. 30)');
                        hasError = true;
                      } else if (parsed > 720) {
                        setStateDialog(() => durationError = 'Duration cannot exceed 720 minutes (12h)');
                        hasError = true;
                      }
                    }

                    if (hasError) return;

                    final duration = int.parse(durationController.text.trim());
                    final finalDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    // ── Past Date/Time Validation ──
                    if (finalDateTime.isBefore(DateTime.now())) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Past Date/Time'),
                            ],
                          ),
                          content: const Text(
                            'You cannot schedule a session in the past.\n\n'
                            'Please select a future date and time so we can remind you!',
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('OK, Got it!'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    // ── All Validations Passed — Save ──
                    ref.read(scheduleProvider.notifier).addSchedule(
                          selectedSubjectId!,
                          selectedTopicId!,
                          finalDateTime,
                          duration,
                        );
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Session scheduled! Reminder set.'),
                        ]),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
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
