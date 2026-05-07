import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/subject_model.dart';
import '../models/topic_model.dart';
import '../models/schedule_model.dart';

class FirebaseSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();

  FirebaseSyncService() {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        syncDataToFirebase();
      }
    });
  }

  Future<void> syncDataToFirebase() async {
    try {
      final subjectBox = Hive.box<SubjectModel>('subjects');
      final topicBox = Hive.box<TopicModel>('topics');
      final scheduleBox = Hive.box<ScheduleModel>('schedules');

      final batch = _firestore.batch();

      // Sync Subjects
      for (var subject in subjectBox.values) {
        final docRef = _firestore.collection('subjects').doc(subject.id);
        batch.set(docRef, {
          'id': subject.id,
          'name': subject.name,
          'colorValue': subject.colorValue,
          'createdAt': subject.createdAt.toIso8601String(),
        }, SetOptions(merge: true));
      }

      // Sync Topics
      for (var topic in topicBox.values) {
        final docRef = _firestore.collection('topics').doc(topic.id);
        batch.set(docRef, {
          'id': topic.id,
          'subjectId': topic.subjectId,
          'name': topic.name,
          'estimatedMinutes': topic.estimatedMinutes,
          'status': topic.status.index,
          'createdAt': topic.createdAt.toIso8601String(),
        }, SetOptions(merge: true));
      }

      // Sync Schedules
      for (var schedule in scheduleBox.values) {
        final docRef = _firestore.collection('schedules').doc(schedule.id);
        batch.set(docRef, {
          'id': schedule.id,
          'subjectId': schedule.subjectId,
          'topicId': schedule.topicId,
          'date': schedule.date.toIso8601String(),
          'durationMinutes': schedule.durationMinutes,
          'isCompleted': schedule.isCompleted,
        }, SetOptions(merge: true));
      }

      await batch.commit();
      print('Data synced to Firebase successfully.');
    } catch (e) {
      print('Failed to sync data: $e');
    }
  }
}
