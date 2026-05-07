import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/subjects/screens/subject_list_screen.dart';
import '../features/topics/screens/topic_form_screen.dart';
import '../features/topics/screens/topic_list_screen.dart';
import '../features/scheduling/screens/schedule_calendar_screen.dart';
import '../features/progress/screens/progress_screen.dart';
import '../features/settings/screens/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/subjects',
      builder: (context, state) => const SubjectListScreen(),
    ),
    GoRoute(
      path: '/topics',
      builder: (context, state) => const TopicListScreen(),
    ),
    GoRoute(
      path: '/topics/add',
      builder: (context, state) => const TopicFormScreen(),
    ),
    GoRoute(
      path: '/schedule',
      builder: (context, state) => const ScheduleCalendarScreen(),
    ),
    GoRoute(
      path: '/progress',
      builder: (context, state) => const ProgressScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
