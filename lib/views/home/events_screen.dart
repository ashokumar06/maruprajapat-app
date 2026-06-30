import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock events
    final List<Map<String, dynamic>> events = [
      {
        'title': 'वार्षिक समाज मिलन समारोह 2026',
        'date': '15 जुलाई 2026',
        'time': 'सुबह 10:00 बजे से',
        'venue': 'सामुदायिक भवन, बालोतरा',
        'desc': 'सभी समाज बंधु सादर आमंत्रित हैं। मिलन समारोह के बाद स्नेह भोज का आयोजन होगा।',
      },
      {
        'title': 'प्रतिभा सम्मान समारोह एवं छात्रवृत्ति वितरण',
        'date': '28 अगस्त 2026',
        'time': 'दोपहर 01:00 बजे से',
        'venue': 'टाउन हॉल, बाड़मेर',
        'desc': 'कक्षा 10वीं और 12वीं में उत्कृष्ट प्रदर्शन करने वाले छात्र-छात्राओं का सम्मान किया जाएगा।',
      },
      {
        'title': 'निःशुल्क चिकित्सा एवं रक्तदान शिविर',
        'date': '05 सितंबर 2026',
        'time': 'सुबह 09:00 बजे से',
        'venue': 'प्रजापत धर्मशाला, जोधपुर',
        'desc': 'विभिन्न विशेषज्ञों द्वारा निःशुल्क परामर्श एवं जांच की जाएगी। रक्तदान भी किया जाएगा।',
      }
    ];

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text('समाज कार्यक्रम (Events)', style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
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
                  Text(
                    event['title']!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: ThemeConfig.primary),
                      const SizedBox(width: 8),
                      Text('${event['date']} | ${event['time']}', style: const TextStyle(fontSize: 13, color: ThemeConfig.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: ThemeConfig.primary),
                      const SizedBox(width: 8),
                      Text(event['venue']!, style: const TextStyle(fontSize: 13, color: ThemeConfig.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: ThemeConfig.divider),
                  const SizedBox(height: 8),
                  Text(
                    event['desc']!,
                    style: const TextStyle(fontSize: 13, color: ThemeConfig.textHint, height: 1.4),
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
