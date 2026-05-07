import 'package:hive/hive.dart';

part 'topic_model.g.dart';

@HiveType(typeId: 1)
enum TopicStatus {
  @HiveField(0)
  notStarted,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
}

@HiveType(typeId: 2)
class TopicModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subjectId;

  @HiveField(2)
  String name;

  @HiveField(3)
  int estimatedMinutes;

  @HiveField(4)
  TopicStatus status;

  @HiveField(5)
  DateTime createdAt;

  TopicModel({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.estimatedMinutes,
    this.status = TopicStatus.notStarted,
    required this.createdAt,
  });

  factory TopicModel.create({
    required String subjectId,
    required String name,
    required int estimatedMinutes,
  }) {
    return TopicModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subjectId: subjectId,
      name: name,
      estimatedMinutes: estimatedMinutes,
      createdAt: DateTime.now(),
    );
  }
}
