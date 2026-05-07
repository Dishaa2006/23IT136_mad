import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'General',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark themes'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme toggle requires a ThemeProvider implementation')),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Daily Reminders'),
            subtitle: const Text('Receive notifications for study schedules'),
            value: true,
            onChanged: (value) {
              // Toggle reminders setting
            },
          ),
          const Divider(height: 32),
          const Text(
            'Data Sync',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.cloud_sync),
            title: const Text('Sync to Firebase'),
            subtitle: const Text('Manually sync offline data to the cloud'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Syncing data...')),
              );
            },
          ),
          const Divider(height: 32),
          const Text(
            'About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version 1.0.0'),
            subtitle: Text('Smart Study Planner'),
          ),
        ],
      ),
    );
  }
}
