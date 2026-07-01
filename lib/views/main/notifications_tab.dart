import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    // Mock notification data
    final notifications = [
      {
        'title': isEnglish ? 'Welcome to Shree Maru Prajapat!' : 'श्री मारू प्रजापत समाज ऐप में आपका स्वागत है!',
        'body': isEnglish 
            ? 'Your application has been received. Our admins will verify it soon.'
            : 'आपका सदस्यता आवेदन प्राप्त हो गया है। हमारे व्यवस्थापक जल्द ही इसकी पुष्टि करेंगे।',
        'time': isEnglish ? '2 hours ago' : '2 घंटे पहले',
        'icon': Icons.waving_hand_outlined,
        'color': ThemeConfig.primary,
        'isRead': false,
      },
      {
        'title': isEnglish ? 'New Notice Issued' : 'नया नोटिस जारी',
        'body': isEnglish
            ? 'General body meeting notice has been published by the secretary.'
            : 'महासचिव द्वारा महासभा की बैठक का नया नोटिस प्रकाशित किया गया है।',
        'time': isEnglish ? '1 day ago' : '1 दिन पहले',
        'icon': Icons.campaign_outlined,
        'color': Colors.orange,
        'isRead': false,
      },
      {
        'title': isEnglish ? 'Document Correction Needed' : 'दस्तावेज़ सुधार आवश्यक',
        'body': isEnglish
            ? 'Please re-upload a clear copy of your Aadhaar card for membership.'
            : 'कृपया सदस्यता के लिए अपने आधार कार्ड की स्पष्ट प्रति पुनः अपलोड करें।',
        'time': isEnglish ? '3 days ago' : '3 दिन पहले',
        'icon': Icons.edit_note_outlined,
        'color': ThemeConfig.error,
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Notifications' : 'सूचनाएं',
          style: const TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: ThemeConfig.textHint.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    isEnglish ? 'No notifications yet' : 'अभी कोई सूचना नहीं है',
                    style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final isRead = notif['isRead'] as bool;
                final color = notif['color'] as Color;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isRead ? ThemeConfig.surface : ThemeConfig.surface.withOpacity(0.95),
                  elevation: isRead ? 0 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isRead ? ThemeConfig.border.withOpacity(0.3) : color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(notif['icon'] as IconData, color: color, size: 24),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif['title'] as String,
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 14,
                              color: ThemeConfig.textPrimary,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          notif['body'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ThemeConfig.textSecondary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notif['time'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            color: ThemeConfig.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
