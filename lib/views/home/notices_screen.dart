import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notices = [
      {
        'title': 'छात्रावास प्रवेश हेतु आवेदन प्रारम्भ',
        'category': 'शिक्षा',
        'date': '28/06/2026',
        'content': 'शैक्षणिक वर्ष 2026-27 के लिए प्रजापत छात्रवास जोधपुर एवं बाड़मेर में प्रवेश हेतु आवेदन शुरू हो गए हैं। अंतिम तिथि 20 जुलाई है। संपर्क करें: 98765xxxxx.'
      },
      {
        'title': 'समाज कार्यकारिणी की मासिक बैठक',
        'category': 'बैठक',
        'date': '29/06/2026',
        'content': 'समाज की मासिक बैठक आगामी रविवार को प्रजापत धर्मशाला बालोतरा में आयोजित की जाएगी। सभी कार्यकारिणी सदस्यों की उपस्थिति अनिवार्य है।'
      },
      {
        'title': 'रक्तदान शिविर - बाड़मेर',
        'category': 'रक्तदान',
        'date': '30/06/2026',
        'content': 'आगामी 5 सितम्बर को वीर तेजाजी मंदिर परिसर में विशाल रक्तदान शिविर का आयोजन किया जा रहा है। रक्तदाता अपना पंजीकरण करवाएं।'
      }
    ];

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text('समाज सूचनाएं (Notices)', style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final item = notices[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: ThemeConfig.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: ThemeConfig.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ThemeConfig.primaryLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['category']!,
                          style: const TextStyle(color: ThemeConfig.primary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(item['date']!, style: const TextStyle(fontSize: 12, color: ThemeConfig.textHint)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['title']!,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['content']!,
                    style: const TextStyle(fontSize: 13, color: ThemeConfig.textSecondary, height: 1.45),
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
