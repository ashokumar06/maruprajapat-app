import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'event_list_widget.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check permission: verified members and admins can create events, guests can only view
    final authProvider = context.read<AuthProvider>();
    final role = authProvider.currentUserModel?.role;
    final bool canCreate = role == 'member' || role == 'admin' || role == 'superadmin';

    return EventListWidget(
      canCreate: canCreate,
    );
  }
}
