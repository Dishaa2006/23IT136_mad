import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/schedule_model.dart';

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, List<ScheduleModel>>((ref) {
  final box = Hive.box<ScheduleModel>('schedules');
  return ScheduleNotifier(box);
});

class ScheduleNotifier extends StateNotifier<List<ScheduleModel>> {
  final Box<ScheduleModel> _box;

  ScheduleNotifier(this._box) : super(_box.values.toList());

  Future<void> addSchedule(String subjectId, String topicId, DateTime date, int durationMinutes) async {
    final newSchedule = ScheduleModel.create(
      subjectId: subjectId,
      topicId: topicId,
      date: date,
      durationMinutes: durationMinutes,
    );
    await _box.put(newSchedule.id, newSchedule);
    state = _box.values.toList();
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
}
