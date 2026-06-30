import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of Gotras
    final List<String> gotras = [
      'परमार', 'चौहान', 'राठौड़', 'सोलंकी', 'गहलोत', 
      'देवड़ा', 'भाटी', 'सिसौदिया', 'पवार', 'जादौन'
    ];

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text('समाज विवरण', style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner/Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ThemeConfig.primary, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'श्री मारू प्रजापत समाज',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'संगठन, शिक्षा, और उन्नति ही हमारे समाज का मुख्य आधार है।',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(label: 'कुल सदस्य', value: '4.2K+'),
                _StatItem(label: 'पंजीकृत व्यवसाय', value: '180+'),
                _StatItem(label: 'कुल गाँव/शहर', value: '45+'),
              ],
            ),
            const SizedBox(height: 24),

            // History Section
            const Text(
              'समाज का संक्षिप्त इतिहास (Brief History)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
            ),
            const SizedBox(height: 10),
            Card(
              color: ThemeConfig.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: ThemeConfig.border),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'मारू प्रजापत समाज एक अत्यंत समृद्ध और गौरवशाली विरासत रखता है। हमारे पूर्वजों ने कला, स्थापत्य, और शिल्प कला में असाधारण योगदान दिया है। आज हमारा समाज संगठित होकर नई ऊंचाइयों को छू रहा है।',
                  style: TextStyle(fontSize: 14, color: ThemeConfig.textSecondary, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Gotras Section
            const Text(
              'समाज के प्रमुख गोत्र (Gotras List)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              itemCount: gotras.length,
              itemBuilder: (context, index) {
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ThemeConfig.primaryLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ThemeConfig.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    gotras[index],
                    style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeConfig.primary, fontSize: 13),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ThemeConfig.primary),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary),
        ),
      ],
    );
  }
}
