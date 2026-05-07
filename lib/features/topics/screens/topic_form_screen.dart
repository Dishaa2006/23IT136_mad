import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/topic_provider.dart';
import '../../subjects/providers/subject_provider.dart';
import '../../../models/topic_model.dart';

class TopicFormScreen extends ConsumerStatefulWidget {
  final TopicModel? topicToEdit;

  const TopicFormScreen({super.key, this.topicToEdit});

  @override
  ConsumerState<TopicFormScreen> createState() => _TopicFormScreenState();
}

class _TopicFormScreenState extends ConsumerState<TopicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _durationController;
  String? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.topicToEdit?.name ?? '');
    _durationController = TextEditingController(
        text: widget.topicToEdit?.estimatedMinutes.toString() ?? '');
    _selectedSubjectId = widget.topicToEdit?.subjectId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSubjectId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a subject')),
        );
        return;
      }

      final name = _nameController.text;
      final duration = int.parse(_durationController.text);

      if (widget.topicToEdit == null) {
        ref.read(topicProvider.notifier).addTopic(_selectedSubjectId!, name, duration);
      } else {
        ref.read(topicProvider.notifier).updateTopic(
              widget.topicToEdit!.id,
              name,
              duration,
              widget.topicToEdit!.status,
            );
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicToEdit == null ? 'Add Topic' : 'Edit Topic'),
      ),
      body: subjects.isEmpty
          ? const Center(child: Text('Please add a subject first.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedSubjectId,
                      decoration: const InputDecoration(
                        labelText: 'Select Subject',
                        border: OutlineInputBorder(),
                      ),
                      items: subjects.map((subject) {
                        return DropdownMenuItem(
                          value: subject.id,
                          child: Text(subject.name),
                        );
                      }).toList(),
                      onChanged: widget.topicToEdit == null
                          ? (value) {
                              setState(() {
                                _selectedSubjectId = value;
                              });
                            }
                          : null, // Disable changing subject when editing
                      validator: (value) => value == null ? 'Required field' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Topic Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a topic name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Estimated Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter estimated duration';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveForm,
                      child: Text(widget.topicToEdit == null ? 'Add Topic' : 'Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
