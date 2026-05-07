import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/schedule_model.dart';
import '../../../services/notification_service.dart';
import '../../subjects/providers/subject_provider.dart';
import '../../topics/providers/topic_provider.dart';

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, List<ScheduleModel>>((ref) {
  final box = Hive.box<ScheduleModel>('schedules');
  return ScheduleNotifier(box, ref);
});

class ScheduleNotifier extends StateNotifier<List<ScheduleModel>> {
  final Box<ScheduleModel> _box;
  final Ref _ref;

  ScheduleNotifier(this._box, this._ref) : super(_box.values.toList());

  Future<void> addSchedule(String subjectId, String topicId, DateTime date, int durationMinutes) async {
    final newSchedule = ScheduleModel.create(
      subjectId: subjectId,
      topicId: topicId,
      date: date,
      durationMinutes: durationMinutes,
    );
    await _box.put(newSchedule.id, newSchedule);
    state = _box.values.toList();

    // Trigger exact-time notification
    final subjects = _ref.read(subjectProvider);
    final topics = _ref.read(topicProvider);
    final subject = subjects.firstWhere((s) => s.id == subjectId, orElse: () => throw Exception());
    final topic = topics.firstWhere((t) => t.id == topicId, orElse: () => throw Exception());

    // Use schedule's hashCode as a unique int ID for the notification
    NotificationService().scheduleSessionNotification(
      id: newSchedule.id.hashCode,
      title: 'Study Time: ${subject.name}!',
      body: 'It is time to start your scheduled session on ${topic.name}.',
      scheduledTime: date,
    );
  }

  Future<void> updateSchedule(String id, DateTime date, int durationMinutes, bool isCompleted) async {
    final schedule = _box.get(id);
    if (schedule != null) {
      schedule.date = date;
      schedule.durationMinutes = durationMinutes;
      schedule.isCompleted = isCompleted;
      await schedule.save();
      state = _box.values.toList();
    }
  }

  Future<void> toggleScheduleCompletion(String id) async {
    final schedule = _box.get(id);
    if (schedule != null) {
      schedule.isCompleted = !schedule.isCompleted;
      await schedule.save();
      state = _box.values.toList();
    }
  }

  Future<void> deleteSchedule(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }

  Future<void> clearAll() async {
    await _box.clear();
    state = [];
  }
}
