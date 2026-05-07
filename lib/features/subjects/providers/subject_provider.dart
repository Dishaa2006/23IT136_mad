import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/subject_model.dart';

final subjectProvider = StateNotifierProvider<SubjectNotifier, List<SubjectModel>>((ref) {
  final box = Hive.box<SubjectModel>('subjects');
  return SubjectNotifier(box);
});

class SubjectNotifier extends StateNotifier<List<SubjectModel>> {
  final Box<SubjectModel> _box;

  SubjectNotifier(this._box) : super(_box.values.toList());

  Future<void> addSubject(String name, int colorValue) async {
    final newSubject = SubjectModel.create(name: name, colorValue: colorValue);
    await _box.put(newSubject.id, newSubject);
    state = _box.values.toList();
  }

  Future<void> updateSubject(String id, String name, int colorValue) async {
    final subject = _box.get(id);
    if (subject != null) {
      subject.name = name;
      subject.colorValue = colorValue;
      await subject.save();
      state = _box.values.toList();
    }
  }

  Future<void> deleteSubject(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }

  Future<void> clearAll() async {
    await _box.clear();
    state = [];
  }
}
