import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'core/providers/theme_provider.dart';
import 'models/subject_model.dart';
import 'models/topic_model.dart';
import 'models/schedule_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(SubjectModelAdapter());
  Hive.registerAdapter(TopicStatusAdapter());
  Hive.registerAdapter(TopicModelAdapter());
  Hive.registerAdapter(ScheduleModelAdapter());
  
  // Open Boxes
  await Hive.openBox<SubjectModel>('subjects');
  await Hive.openBox<TopicModel>('topics');
  await Hive.openBox<ScheduleModel>('schedules');

  runApp(
    const ProviderScope(
      child: SmartStudyApp(),
    ),
  );
}

class SmartStudyApp extends ConsumerWidget {
  const SmartStudyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Smart Study Planner',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
