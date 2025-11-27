import 'package:flutter/material.dart';
import '../widgets/empty_state.dart';

class SchedulesScreen extends StatelessWidget {
  const SchedulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmptyState(
        icon: Icons.schedule,
        title: 'Manajemen Jadwal',
        message: 'Fitur manajemen jadwal sedang dalam pengembangan',
        actionLabel: 'Buat Jadwal',
        onAction: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Coming soon!')));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
