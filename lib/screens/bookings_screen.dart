import 'package:flutter/material.dart';
import '../widgets/empty_state.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmptyState(
        icon: Icons.receipt_long,
        title: 'Monitor Booking',
        message: 'Belum ada booking masuk',
        actionLabel: 'Refresh',
        onAction: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Refreshing...')));
        },
      ),
    );
  }
}
