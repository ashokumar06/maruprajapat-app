import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> schemes = [
      {
        'title': 'प्रजापत मेधावी छात्रवृत्ति योजना',
        'benefit': '₹5,000 - ₹20,000 वार्षिक',
        'eligibility': 'कक्षा 10वीं/12वीं में 75%+ अंक प्राप्त करने वाले छात्र-छात्राएं।',
        'desc': 'समाज के होनहार विद्यार्थियों को उच्च शिक्षा हेतु वित्तीय सहायता प्रदान करना।'
      },
      {
        'title': 'भामाशाह चिकित्सा सहायता योजना',
        'benefit': 'इलाज में 50% तक आर्थिक सहायता',
        'eligibility': 'आर्थिक रूप से कमजोर परिवार के बीमार सदस्य।',
        'desc': 'गंभीर बीमारियों के इलाज के लिए समाज के भामाशाहों के सहयोग से वित्तीय मदद दी जाती है।'
      },
      {
        'title': 'महिला स्वरोजगार प्रोत्साहन योजना',
        'benefit': 'ब्याज मुक्त लघु उद्योग ऋण (up to ₹50,000)',
        'eligibility': 'स्वयं का व्यवसाय शुरू करने की इच्छुक समाज की महिलाएं।',
        'desc': 'सिलाई, गृह उद्योग, ब्यूटी पार्लर आदि शुरू करने के लिए आर्थिक एवं प्रशिक्षण सहयोग।'
      }
    ];

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text('समाज योजनाएं (Schemes)', style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schemes.length,
        itemBuilder: (context, index) {
          final item = schemes[index];
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
                    item['title']!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  _buildMetaRow('सहायता/लाभ:', item['benefit']!, ThemeConfig.primary),
                  const SizedBox(height: 6),
                  _buildMetaRow('पात्रता:', item['eligibility']!, ThemeConfig.textSecondary),
                  const SizedBox(height: 12),
                  const Divider(color: ThemeConfig.divider),
                  const SizedBox(height: 8),
                  Text(
                    item['desc']!,
                    style: const TextStyle(fontSize: 13, color: ThemeConfig.textHint, height: 1.45),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, Color valColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: ThemeConfig.textHint, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: valColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
