import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text(
          'ऐप जानकारी (App Info)',
          style: TextStyle(
            color: ThemeConfig.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  // App Logo
                  Container(
                    width: double.infinity,
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/avirastra_logo.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.broken_image, size: 32, color: ThemeConfig.textHint),
                            const SizedBox(height: 8),
                            const Text(
                              'Logo Missing (Please save avirastra_logo.png in assets/images/)',
                              style: TextStyle(fontSize: 12, color: ThemeConfig.textHint),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Maru Prajapat',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ThemeConfig.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: ThemeConfig.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Legal Compliance Notice
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeConfig.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ThemeConfig.primary.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: ThemeConfig.primary.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel, color: ThemeConfig.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'निर्माता एवं कानूनी सूचना',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'यह ऐप Avirastra द्वारा विकसित और प्रबंधित किया गया है।\n\nइस ऐप के अंतर्गत, केवल समाज के सत्यापित सदस्यों को ही सीमित डेटा एक्सेस की अनुमति (Permission) है। ऐप में मौजूद सभी जानकारी और डेटा पूरी तरह से समाज के नियंत्रण में है। भविष्य में किसी भी प्रकार की कानूनी कार्यवाही (Legal Case) या अनुपालन (Compliance) से बचाव के लिए, हम स्पष्ट करते हैं कि यह ऐप पूरी तरह से सामुदायिक हित के लिए बनाया गया है और डेटा गोपनीयता का सख्त पालन करता है। कोई भी बाहरी व्यक्ति या संस्था इस डेटा का दावा नहीं कर सकती है।',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeConfig.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Privacy Policy
            _buildSection(
              title: 'प्राइवेसी पॉलिसी (Privacy Policy)',
              icon: Icons.privacy_tip_outlined,
              content: '''प्रस्तावना (Introduction):
हम, Avirastra द्वारा प्रबंधित Maru Prajapat ऐप में, आपकी गोपनीयता और व्यक्तिगत डेटा की सुरक्षा को अत्यधिक महत्व देते हैं। यह प्राइवेसी पॉलिसी (Privacy Policy) स्पष्ट करती है कि हम किस प्रकार समाज के सदस्यों का डेटा एकत्र करते हैं, उसका उपयोग कैसे करते हैं, और उसे सुरक्षित कैसे रखते हैं। ऐप का उपयोग करके, आप इस नीति में वर्णित सभी शर्तों और प्रथाओं से सहमत होते हैं।

डेटा एकत्रीकरण (Data Collection):
जब आप सदस्यता के लिए आवेदन करते हैं, तो हम आपका नाम, पिता का नाम, फ़ोन नंबर, गाँव, जिला, गोत्र और प्रोफ़ाइल फ़ोटो जैसी व्यक्तिगत जानकारी एकत्र करते हैं। यह जानकारी केवल आपके प्रमाणीकरण (Authentication) और समाज के सदस्य के रूप में आपकी पहचान को सत्यापित करने के लिए उपयोग की जाती है। हम कोई भी ऐसी जानकारी एकत्र नहीं करते जो हमारी सेवा प्रदान करने के लिए आवश्यक न हो।

डेटा का उपयोग (Data Usage):
आपके द्वारा प्रदान की गई जानकारी का उपयोग केवल निम्नलिखित उद्देश्यों के लिए किया जाता है:
1. आपको ऐप की सुविधाएँ और सेवाएँ प्रदान करना।
2. समुदाय (समाज) के भीतर अन्य सत्यापित सदस्यों के साथ आपकी पहचान स्थापित करना।
3. ऐप के भीतर सुरक्षा सुनिश्चित करना और फर्जी खातों (Fake Accounts) को रोकना।
4. महत्वपूर्ण सूचनाओं, अपडेट्स और समुदाय की गतिविधियों से आपको अवगत कराना।

तृतीय-पक्ष प्रकटीकरण (Third-Party Disclosure):
हम आपके व्यक्तिगत डेटा को कभी भी किसी तीसरे पक्ष (Third-party), मार्केटिंग एजेंसियों, या विज्ञापनदाताओं को बेचते, किराए पर देते या साझा नहीं करते हैं। आपका सारा डेटा पूरी तरह से गोपनीय रखा जाता है और यह केवल Maru Prajapat समाज के व्यवस्थापकों (Admins) और अधिकृत सदस्यों के लिए ही, वह भी अत्यंत सीमित रूप में, सुलभ होता है। कानूनी मामलों या सरकारी आदेशों के तहत यदि आवश्यक हो, तभी डेटा को कानूनी प्रवर्तन एजेंसियों (Law Enforcement Agencies) के साथ साझा किया जा सकता है।

कुकीज़ और ट्रैकिंग (Cookies and Tracking):
हम ऐप के प्रदर्शन को बेहतर बनाने और तकनीकी समस्याओं को सुलझाने के लिए कुछ सामान्य एनालिटिक्स (Analytics) टूल का उपयोग कर सकते हैं। यह डेटा पूरी तरह से गुमनाम (Anonymous) होता है और इससे आपकी व्यक्तिगत पहचान नहीं होती है।

नीति में परिवर्तन (Changes to Policy):
Avirastra और समाज प्रबंधन को किसी भी समय इस गोपनीयता नीति को अद्यतन (Update) या संशोधित करने का अधिकार सुरक्षित है। किसी भी महत्वपूर्ण बदलाव की स्थिति में, आपको ऐप के माध्यम से सूचित किया जाएगा। आपका निरंतर उपयोग आपकी इस नई नीति पर सहमति माना जाएगा।''',
            ),

            // Terms of Service
            _buildSection(
              title: 'नियम और शर्तें (Terms of Service)',
              icon: Icons.rule,
              content: '''स्वीकृति (Acceptance of Terms):
Maru Prajapat ऐप को डाउनलोड, इंस्टॉल और उपयोग करके, आप निम्नलिखित नियमों और शर्तों (Terms of Service) से पूरी तरह बाध्य होने के लिए सहमति देते हैं। यह एक कानूनी समझौता है, जो आपके और Avirastra (डेवलपर) तथा Maru Prajapat समाज के बीच लागू होता है। यदि आप इन शर्तों से सहमत नहीं हैं, तो कृपया ऐप का उपयोग न करें।

सदस्यता और खाता (Membership and Account):
1. यह ऐप विशेष रूप से Maru Prajapat समाज के सदस्यों के लिए बनाया गया है।
2. खाता बनाने और ऐप की सुविधाओं का उपयोग करने के लिए आपको सत्य और सटीक जानकारी प्रदान करनी होगी।
3. झूठी पहचान (Fake Identity) या गलत जानकारी देने पर आपका खाता बिना पूर्व सूचना के स्थायी रूप से निलंबित (Suspend) किया जा सकता है।
4. अपने खाते की सुरक्षा और पासवर्ड को गुप्त रखने की जिम्मेदारी पूरी तरह से आपकी है। आपके खाते से होने वाली किसी भी गतिविधि के लिए आप स्वयं उत्तरदायी होंगे।

सामुदायिक आचरण (Community Conduct):
यह मंच समाज की एकता, सूचनाओं के आदान-प्रदान और सकारात्मक चर्चा के लिए है। निम्नलिखित गतिविधियाँ पूर्णतः प्रतिबंधित हैं:
1. किसी भी व्यक्ति, जाति, धर्म या समुदाय के खिलाफ अपमानजनक, अभद्र या घृणास्पद सामग्री (Hate Speech) पोस्ट करना।
2. अश्लील, आपत्तिजनक या गैर-कानूनी चित्र/वीडियो साझा करना।
3. स्पैम (Spam), विज्ञापन, या किसी भी प्रकार का भ्रामक प्रचार करना।
4. अन्य सदस्यों को परेशान करना, धमकी देना या उनकी निजता (Privacy) का उल्लंघन करना।
समाज के व्यवस्थापक (Admins) किसी भी पोस्ट या कमेंट को हटाने और नियमों का उल्लंघन करने वाले सदस्य को ब्लॉक करने का पूर्ण अधिकार रखते हैं।

बौद्धिक संपदा (Intellectual Property):
ऐप के डिज़ाइन, लोगो, सोर्स कोड और लेआउट पर Avirastra का पूर्ण कॉपीराइट (Copyright) है। ऐप पर सदस्यों द्वारा पोस्ट की गई सामग्री का अधिकार संबंधित उपयोगकर्ता के पास होता है, लेकिन ऐप को उस सामग्री को मंच पर प्रदर्शित करने का लाइसेंस प्राप्त हो जाता है।

दायित्व की सीमा (Limitation of Liability):
Avirastra या समाज प्रबंधन किसी भी सदस्य द्वारा पोस्ट की गई सामग्री की सत्यता की गारंटी नहीं लेता है। ऐप के उपयोग के दौरान होने वाले किसी भी प्रत्यक्ष, अप्रत्यक्ष, या आकस्मिक नुकसान (Data loss, hardware issue) के लिए हम कानूनी रूप से उत्तरदायी नहीं होंगे। ऐप "जैसी है" (As is) के आधार पर उपलब्ध कराई गई है।

अधिकार क्षेत्र (Jurisdiction):
इन नियमों और शर्तों से संबंधित किसी भी विवाद का समाधान भारतीय कानूनों के तहत किया जाएगा और सभी कानूनी मामले केवल निर्धारित स्थानीय न्यायालय के अधिकार क्षेत्र (Jurisdiction) में ही सुने जाएंगे।''',
            ),

            // Data Privacy
            _buildSection(
              title: 'डेटा गोपनीयता (Data Privacy)',
              icon: Icons.security,
              content: '''डेटा सुरक्षा (Data Security):
आपके डेटा की सुरक्षा हमारी सर्वोच्च प्राथमिकता है। Maru Prajapat ऐप में एकत्र किया गया सभी डेटा अत्याधुनिक एन्क्रिप्शन (Encryption) तकनीकों और सुरक्षित सर्वर इन्फ्रास्ट्रक्चर (Secure Server Infrastructure) पर संग्रहीत किया जाता है। हम अनधिकृत पहुँच (Unauthorized Access), डेटा चोरी (Data Breach) और डेटा के दुरुपयोग को रोकने के लिए उद्योग के सर्वोत्तम सुरक्षा मानकों (Industry Security Standards) का पालन करते हैं।

डेटा एक्सेस और नियंत्रण (Data Access and Control):
1. सीमित पहुँच (Limited Access): ऐप का डेटा केवल उन सदस्यों के लिए सुलभ है जिन्हें समाज के व्यवस्थापकों (Admins) द्वारा सत्यापित (Verified) किया गया है।
2. अतिथि उपयोगकर्ता (Guest Users): जो उपयोगकर्ता सत्यापित नहीं हैं (Guests), वे किसी भी सदस्य की व्यक्तिगत जानकारी, पोस्ट या सुरक्षित डेटा को नहीं देख सकते हैं।
3. कोई बाहरी पहुँच नहीं (No External Access): कोई भी बाहरी व्यक्ति, संस्था या सर्च इंजन (Search Engines) इस ऐप के भीतर रखे गए डेटा को क्रॉल या एक्सेस नहीं कर सकता है। डेटा पूर्ण रूप से बंद नेटवर्क (Closed Network) के रूप में कार्य करता है।

डेटा प्रतिधारण (Data Retention):
हम आपके डेटा को केवल तब तक अपने सर्वर पर सुरक्षित रखते हैं जब तक कि आप समाज के सक्रिय सदस्य बने रहते हैं। यदि आप अपना खाता हटाने (Delete Account) का अनुरोध करते हैं या समाज द्वारा आपकी सदस्यता रद्द कर दी जाती है, तो आपके व्यक्तिगत डेटा को हमारे सिस्टम से स्थायी रूप से हटा दिया जाएगा (कानूनी रूप से आवश्यक डेटा को छोड़कर)।

उपयोगकर्ता के अधिकार (User Rights):
आपको अपने व्यक्तिगत डेटा पर पूर्ण अधिकार प्राप्त है। आप किसी भी समय अपनी प्रोफ़ाइल में जाकर अपनी जानकारी को अपडेट या संपादित (Edit) कर सकते हैं। यदि आपको लगता है कि आपके डेटा का गलत उपयोग हो रहा है, तो आप तुरंत ऐप के व्यवस्थापकों (Admins) से संपर्क कर सकते हैं। आपके पास अपने खाते को स्थायी रूप से हटाने और अपना डेटा मिटाने का अधिकार सुरक्षित है।

सहमति और अनुपालन (Consent and Compliance):
ऐप पर खाता बनाकर, आप स्पष्ट रूप से यह सहमति देते हैं कि आपके डेटा का प्रबंधन इस दस्तावेज़ में वर्णित नियमों के अनुसार Avirastra और Maru Prajapat समाज द्वारा किया जाएगा। हम भविष्य में आने वाले किसी भी राष्ट्रीय डेटा संरक्षण कानून (National Data Protection Laws) के अनुरूप अपनी नीतियों को अद्यतन करने के लिए प्रतिबद्ध हैं।''',
            ),

            const SizedBox(height: 40),
            const Center(
              child: Text(
                '© 2026 Avirastra. All rights reserved.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.textHint,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ThemeConfig.textPrimary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeConfig.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ThemeConfig.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: ThemeConfig.textSecondary,
                height: 1.8, // Increased line height for better readability
                letterSpacing: 0.2, // Slight letter spacing
              ),
            ),
          ),
        ],
      ),
    );
  }
}
