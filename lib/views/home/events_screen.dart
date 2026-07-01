import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import 'event_list_widget.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Verified members, admins, and superadmins can create events; guest users can only see
    final authProvider = context.read<AuthProvider>();
    final role = authProvider.currentUserModel?.role;
    final bool canCreate = role == 'member' || role == 'admin' || role == 'superadmin';

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text(
          'समाज कार्यक्रम (Events)',
          style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: EventListWidget(
        canCreate: canCreate,
      ),
    );
  }
}
