import 'package:hive/hive.dart';

part 'schedule_model.g.dart';

@HiveType(typeId: 3)
class ScheduleModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subjectId;

  @HiveField(2)
  String topicId;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  int durationMinutes;

  @HiveField(5)
  bool isCompleted;

  ScheduleModel({
    required this.id,
    required this.subjectId,
    required this.topicId,
    required this.date,
    required this.durationMinutes,
    this.isCompleted = false,
  });

  factory ScheduleModel.create({
    required String subjectId,
    required String topicId,
    required DateTime date,
    required int durationMinutes,
  }) {
    return ScheduleModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subjectId: subjectId,
      topicId: topicId,
      date: date,
      durationMinutes: durationMinutes,
    );
  }
}
