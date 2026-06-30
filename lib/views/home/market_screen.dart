import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {
        'title': 'हस्तनिर्मित पारंपरिक मिट्टी के बर्तन',
        'shop': 'मारू मिट्टी कला उद्योग',
        'price': '₹150 - ₹500',
        'location': 'बालोतरा',
        'contact': '98290xxxxx',
        'desc': 'प्राकृतिक रूप से तैयार किए गए उत्तम श्रेणी के मटके, सुराही, और सजावटी बर्तन उपलब्ध हैं।'
      },
      {
        'title': 'मारवाड़ी पारंपरिक लाख की चूड़ियाँ',
        'shop': 'जय श्री कला केंद्र',
        'price': '₹250 से शुरू',
        'location': 'बाड़मेर',
        'contact': '94142xxxxx',
        'desc': 'शुद्ध लाख से बनी सुंदर और कलात्मक चूड़ियाँ एवं कंगन ऑर्डर पर भी तैयार किए जाते हैं।'
      },
      {
        'title': 'प्रजापत सीमेंट ब्लॉग्स एवं ईंट उद्योग',
        'shop': 'श्री विनायक इंडस्ट्रीज',
        'price': 'थोक दर पर उपलब्ध',
        'location': 'जोधपुर रोड, बालोतरा',
        'contact': '96605xxxxx',
        'desc': 'सभी प्रकार की इंटरलॉकिंग टाइल्स, सीमेंट ब्लॉक, और उच्च गुणवत्ता वाली लाल ईंटें थोक दाम पर मिलती हैं।'
      }
    ];

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text('समाज बाजार (Market)', style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final item = products[index];
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
                      Expanded(
                        child: Text(
                          item['title']!,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item['price']!,
                        style: const TextStyle(color: ThemeConfig.primary, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['shop']!,
                    style: const TextStyle(fontSize: 13, color: ThemeConfig.primary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: ThemeConfig.textSecondary),
                      const SizedBox(width: 4),
                      Text(item['location']!, style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary)),
                      const SizedBox(width: 16),
                      const Icon(Icons.phone, size: 16, color: ThemeConfig.success),
                      const SizedBox(width: 4),
                      Text(item['contact']!, style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: ThemeConfig.divider),
                  const SizedBox(height: 8),
                  Text(
                    item['desc']!,
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
