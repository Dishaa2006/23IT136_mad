import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/topic_model.dart';

final topicProvider = StateNotifierProvider<TopicNotifier, List<TopicModel>>((ref) {
  final box = Hive.box<TopicModel>('topics');
  return TopicNotifier(box);
});

class TopicNotifier extends StateNotifier<List<TopicModel>> {
  final Box<TopicModel> _box;

  TopicNotifier(this._box) : super(_box.values.toList());

  Future<void> addTopic(String subjectId, String name, int estimatedMinutes) async {
    final newTopic = TopicModel.create(
      subjectId: subjectId,
      name: name,
      estimatedMinutes: estimatedMinutes,
    );
    await _box.put(newTopic.id, newTopic);
    state = _box.values.toList();
  }

  Future<void> updateTopic(String id, String name, int estimatedMinutes, TopicStatus status) async {
    final topic = _box.get(id);
    if (topic != null) {
      topic.name = name;
      topic.estimatedMinutes = estimatedMinutes;
      topic.status = status;
      await topic.save();
      state = _box.values.toList();
    }
  }

  Future<void> updateTopicStatus(String id, TopicStatus status) async {
    final topic = _box.get(id);
    if (topic != null) {
      topic.status = status;
      await topic.save();
      state = _box.values.toList();
    }
  }

  Future<void> deleteTopic(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }

  Future<void> clearAll() async {
    await _box.clear();
    state = [];
  }
}
