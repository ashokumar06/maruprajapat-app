import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../config/theme_config.dart';
import '../../models/event_model.dart';
import 'package:dio/dio.dart';
import '../../services/api_client.dart';
import 'create_event_screen.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  String _getEventTypeText(String type) {
    switch (type.toLowerCase()) {
      case 'meeting':
        return 'बैठक';
      case 'ceremony':
        return 'समारोह';
      case 'conference':
        return 'सम्मेलन';
      case 'sports':
        return 'खेलकूद';
      case 'festival':
        return 'उत्सव';
      default:
        return 'सामान्य कार्यक्रम';
    }
  }

  IconData _getEventTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'meeting':
        return Icons.groups;
      case 'ceremony':
        return Icons.military_tech;
      case 'conference':
        return Icons.co_present;
      case 'sports':
        return Icons.emoji_events;
      case 'festival':
        return Icons.celebration;
      default:
        return Icons.event;
    }
  }

  void _showShareSheet(BuildContext context) {
    final appUrl = 'https://play.google.com/store/apps/details?id=com.maruprajapat.app';
    final eventLink = 'maruprajapat://events/${event.id}';
    final textToShare = 'इस बेहतरीन कार्यक्रम को श्री मारू प्रजापत समाज ऐप पर देखें!\\n\\nकार्यक्रम लिंक: $eventLink\\nऐप डाउनलोड करें: $appUrl';
    Share.share(textToShare);
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary)),
        ],
      ),
    );
  }

  void _deleteEvent(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('इवेंट डिलीट करें'),
        content: const Text('क्या आप वाकई इस इवेंट को पूरी तरह से डिलीट करना चाहते हैं? यह वापस नहीं आएगा और इसकी इमेज भी डिलीट हो जाएगी।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('रद्द करें')),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('डिलीट करें', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final dio = ApiClient().dio;
      await dio.delete('/api/v1/events/${event.id}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('इवेंट डिलीट कर दिया गया है')));
        Navigator.pop(context, true); // Pop with true to refresh list
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('डिलीट करने में त्रुटि: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeText = _getEventTypeText(event.eventType);
    final typeIcon = _getEventTypeIcon(event.eventType);
    final dateStr = DateFormat('dd MMMM yyyy').format(event.startDate);
    final timeStr = DateFormat('hh:mm a').format(event.startDate);

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text(
          'इवेंट विवरण',
          style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: ThemeConfig.textPrimary),
            onPressed: () => _showShareSheet(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: ThemeConfig.textPrimary),
            onSelected: (val) {
              if (val == 'edit') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreateEventScreen(existingEvent: event))).then((val) {
                  if (val == true) Navigator.pop(context, true);
                });
              } else if (val == 'delete') {
                _deleteEvent(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('एडिट करें')),
              const PopupMenuItem(value: 'delete', child: Text('डिलीट करें', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 90.0),
            children: [
              // Top cover image banner
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  height: 180,
                  color: ThemeConfig.primary.withOpacity(0.08),
                  child: event.coverImageUrl != null && event.coverImageUrl!.isNotEmpty
                      ? Image.network(event.coverImageUrl!, fit: BoxFit.cover)
                      : Center(
                          child: Icon(typeIcon, color: ThemeConfig.primary, size: 54),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeConfig.textPrimary,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.startDate.isAfter(DateTime.now()) ? 'आगामी' : 'बीता',
                      style: TextStyle(
                        color: event.startDate.isAfter(DateTime.now())
                            ? Colors.green.shade700
                            : ThemeConfig.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Info box details (Screen 2 style)
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: ThemeConfig.primary, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    '$dateStr | सुबह $timeStr से',
                    style: const TextStyle(fontSize: 13, color: ThemeConfig.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (event.location != null && event.location!.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: ThemeConfig.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: const TextStyle(fontSize: 13, color: ThemeConfig.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  const Icon(Icons.business_center_outlined, color: ThemeConfig.primary, size: 18),
                  const SizedBox(width: 10),
                  const Text(
                    'आयोजक: मारू प्रजापत समाज समिति',
                    style: TextStyle(fontSize: 13, color: ThemeConfig.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: ThemeConfig.divider),
              const SizedBox(height: 16),

              // Description section
              const Text(
                'कार्यक्रम का विवरण',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
              ),
              const SizedBox(height: 8),
              HtmlWidget(
                event.description ?? 'कोई विवरण प्रदान नहीं किया गया है।',
                textStyle: const TextStyle(fontSize: 13, color: ThemeConfig.textSecondary, height: 1.45),
              ),

            ],
          ),

          // Bottom full-width outlined share button (No Register button, as requested)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _showShareSheet(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: ThemeConfig.primary, width: 1.5),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.share, color: ThemeConfig.primary, size: 20),
                label: const Text(
                  'शेयर करें',
                  style: TextStyle(color: ThemeConfig.primary, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: ThemeConfig.primary, size: 18),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: ThemeConfig.textPrimary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
