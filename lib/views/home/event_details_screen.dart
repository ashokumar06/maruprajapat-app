import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../config/theme_config.dart';
import '../../models/event_model.dart';

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
    final String link = 'maruprajapat://events/${event.id}';
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'कार्यक्रम शेयर करें',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShareOption(
                    icon: Icons.chat,
                    label: 'WhatsApp',
                    color: Colors.green,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildShareOption(
                    icon: Icons.facebook,
                    label: 'Facebook',
                    color: Colors.blue.shade800,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildShareOption(
                    icon: Icons.send,
                    label: 'Telegram',
                    color: Colors.blue.shade500,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: ThemeConfig.divider),
              const SizedBox(height: 12),
              
              // Copy Link Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: ThemeConfig.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ThemeConfig.border),
                      ),
                      child: Text(
                        link,
                        style: const TextStyle(fontSize: 13, color: ThemeConfig.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('लिंक कॉपी कर लिया गया है!'),
                          backgroundColor: ThemeConfig.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('कॉपी करें', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
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
          'कार्यक्रम विवरण (Details)',
          style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header Card
          Container(
            decoration: BoxDecoration(
              color: ThemeConfig.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ThemeConfig.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Banner image or icon box
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    color: ThemeConfig.primary.withOpacity(0.08),
                    child: event.coverImageUrl != null && event.coverImageUrl!.isNotEmpty
                        ? Image.network(event.coverImageUrl!, fit: BoxFit.cover)
                        : Center(
                            child: Icon(typeIcon, color: ThemeConfig.primary, size: 60),
                          ),
                  ),
                ),
                
                // Title and Metadata Details
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ThemeConfig.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          typeText,
                          style: const TextStyle(
                            color: ThemeConfig.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: ThemeConfig.divider),
                      const SizedBox(height: 16),
                      
                      // Date & Time row
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: ThemeConfig.primary, size: 20),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary)),
                              const SizedBox(height: 4),
                              Text('$timeStr से', style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Location row
                      if (event.location != null && event.location!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: ThemeConfig.primary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('कार्यक्रम स्थल', style: TextStyle(fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary)),
                                  const SizedBox(height: 4),
                                  Text(event.location!, style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Description Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ThemeConfig.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ThemeConfig.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'कार्यक्रम का विवरण',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  event.description ?? 'कोई विवरण प्रदान नहीं किया गया है।',
                  style: const TextStyle(fontSize: 14, color: ThemeConfig.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Bottom Action Button: Share Only
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _showShareSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              icon: const Icon(Icons.share, color: Colors.white, size: 20),
              label: const Text(
                'कार्यक्रम शेयर करें',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
