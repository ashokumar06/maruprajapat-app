import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../services/api_client.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool _isLoading = true;
  int _totalMembers = 4200;
  int _totalVillages = 180;
  int _totalDistricts = 45;
  int _totalEducated = 350;
  int _totalBusinesses = 120;
  int _totalSocialWorkers = 80;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final response = await ApiClient().dio.get('/api/v1/users/community-stats');
      if (response.data != null && response.data['success'] == true) {
        setState(() {
          _totalMembers = response.data['total_members'] ?? 4200;
          _totalVillages = response.data['total_villages'] ?? 180;
          _totalDistricts = response.data['total_districts'] ?? 45;
          _totalEducated = response.data['total_educated'] ?? 350;
          _totalBusinesses = response.data['total_businesses'] ?? 120;
          _totalSocialWorkers = response.data['total_social_workers'] ?? 80;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching community stats: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    // Gotras list of Maru Prajapat
    final List<String> gotras = [
      'किरोड़ीवाल (Kirodiwal)',
      'जिंजलोदिया (Jinjalodiya)',
      'वाटलिया (Wataliya)',
      'इणिया / एणिया',
      'रेडवाल / रेडीवाल',
      'गढ़वाल / गरवाल',
      'मोरवाल',
      'जगरवाल',
      'कूकड़वाल',
      'ऊंटवाल',
      'गोटवाल',
      'भरवाल',
      'आदिवाल',
      'नांदीवाल',
      'सींगरवाल',
      'लिम्बीवाल',
      'छापरवाल',
      'आसीवाल',
      'कांकरवाल',
      'गोयल',
      'रेणवाल',
      'सुरजाणिया',
      'ओडिया',
      'बालूदिया',
      'कवाड़िया',
      'कमाड़िया',
      'हरकिया',
      'साणेचा',
      'मावरिया',
      'मेवाड़ा',
      'परमार',
      'नगरिया',
      'गोला',
      'मंगलिया',
      'चांदोरा',
      'बिलपानिया',
      'बोरावड़',
      'सोतवाल',
      'खटोड़',
      'टांक',
      'मानवाल',
      'मानधन्या',
      'सिवोटा',
      'सांगर',
      'कपूरपुरा',
      'साड़ीवाल',
      'दादरवाल',
      'नोकवाल',
      'कारगवाल',
      'खराटिया',
      'खरांटिया'
    ];

    // States list
    final List<Map<String, dynamic>> states = [
      {'name': isEnglish ? 'Rajasthan' : 'राजस्थान', 'type': 'fort'},
      {'name': isEnglish ? 'Gujarat' : 'गुजरात', 'type': 'fort'},
      {'name': isEnglish ? 'Madhya Pradesh' : 'मध्य प्रदेश', 'type': 'fort'},
      {'name': isEnglish ? 'Haryana' : 'हरियाणा', 'type': 'tower'},
      {'name': isEnglish ? 'Delhi' : 'दिल्ली', 'type': 'arch'},
      {'name': isEnglish ? 'Maharashtra' : 'महाराष्ट्र', 'type': 'arch'},
      {'name': isEnglish ? 'Punjab' : 'पंजाब', 'type': 'tower'},
      {'name': isEnglish ? 'Other States' : 'अन्य राज्य', 'type': 'fort'},
    ];

    // Occupations list
    final List<Map<String, dynamic>> occupations = [
      {
        'name': isEnglish ? 'Clay Art' : 'मिट्टी कला',
        'icon': null,
        'color': const Color(0xFF8D6E63),
        'bgColor': const Color(0xFFEFEBE9),
      },
      {
        'name': isEnglish ? 'Education' : 'शिक्षा',
        'icon': Icons.menu_book,
        'color': const Color(0xFFFF9800),
        'bgColor': const Color(0xFFFFF3E0),
      },
      {
        'name': isEnglish ? 'Govt Service' : 'सरकारी सेवा',
        'icon': Icons.account_balance,
        'color': const Color(0xFFE91E63),
        'bgColor': const Color(0xFFFCE4EC),
      },
      {
        'name': isEnglish ? 'Business' : 'व्यवसाय',
        'icon': Icons.trending_up,
        'color': const Color(0xFF4CAF50),
        'bgColor': const Color(0xFFE8F5E9),
      },
      {
        'name': isEnglish ? 'Agriculture' : 'कृषि',
        'icon': Icons.agriculture,
        'color': const Color(0xFFFFEB3B),
        'bgColor': const Color(0xFFFFFDE7),
      },
      {
        'name': isEnglish ? 'Engineering' : 'इंजीनियरिंग',
        'icon': Icons.handyman,
        'color': const Color(0xFF00BCD4),
        'bgColor': const Color(0xFFE0F7FA),
      },
      {
        'name': isEnglish ? 'Medical' : 'चिकित्सा',
        'icon': Icons.local_hospital,
        'color': const Color(0xFFF44336),
        'bgColor': const Color(0xFFFFEBEE),
      },
      {
        'name': isEnglish ? 'Law' : 'कानून',
        'icon': Icons.gavel,
        'color': const Color(0xFF607D8B),
        'bgColor': const Color(0xFFECEFF1),
      },
      {
        'name': isEnglish ? 'Defense' : 'सेना',
        'icon': Icons.shield,
        'color': const Color(0xFF3F51B5),
        'bgColor': const Color(0xFFE8EAF6),
      },
    ];

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Maru Prajapat Samaj' : 'मारू प्रजापत समाज',
          style: const TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Banner Card using samaj.png (Replacing old pot banner)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/samaj.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Section: Samaj ke Mahatvapurna Aankde (Stats styled as Grid)
            _buildSectionHeader(isEnglish ? 'Samaj Key Statistics' : 'समाज के महत्वपूर्ण आंकड़े'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: ThemeConfig.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: ThemeConfig.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              Icons.people_alt,
                              _isLoading ? '4.2K+' : '$_totalMembers',
                              isEnglish ? 'Total Members' : 'कुल सदस्य',
                            ),
                          ),
                          _buildVerticalDivider(),
                          Expanded(
                            child: _buildStatItem(
                              Icons.location_city,
                              _isLoading ? '180+' : '$_totalVillages',
                              isEnglish ? 'Villages/Towns' : 'ग्राम / शहर',
                            ),
                          ),
                          _buildVerticalDivider(),
                          Expanded(
                            child: _buildStatItem(
                              Icons.domain,
                              _isLoading ? '45+' : '$_totalDistricts',
                              isEnglish ? 'Districts' : 'जिले',
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: ThemeConfig.border, height: 24, thickness: 1),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              Icons.school,
                              _isLoading ? '350+' : '$_totalEducated',
                              isEnglish ? 'Educated' : 'शिक्षित सदस्य',
                            ),
                          ),
                          _buildVerticalDivider(),
                          Expanded(
                            child: _buildStatItem(
                              Icons.business_center,
                              _isLoading ? '120+' : '$_totalBusinesses',
                              isEnglish ? 'Businesses' : 'व्यवसाय',
                            ),
                          ),
                          _buildVerticalDivider(),
                          Expanded(
                            child: _buildStatItem(
                              Icons.volunteer_activism,
                              _isLoading ? '80+' : '$_totalSocialWorkers',
                              isEnglish ? 'Social Workers' : 'समाज सेवक',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Section: Samaj Parichay
            _buildSectionHeader(isEnglish ? 'Samaj Introduction' : 'समाज परिचय'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: ThemeConfig.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: ThemeConfig.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    isEnglish
                        ? 'Maru Prajapat community is a major branch of the Kumhar (Prajapati) clan. Our heritage is rooted in clay arts, pottery, architecture, and dedicated social service. Over time, the community has made notable strides in education, administration, business, science, engineering, and technology.\n\nToday, members serve as educators, engineers, medical professionals, administrators, lawyers, defense personnel, and scientists.'
                        : 'मारू प्रजापत समाज कुम्भकार (प्रजापति) समुदाय की एक प्रमुख शाखा है। हमारी परंपरा मिट्टी की कला, कुम्भ निर्माण, शिल्पकला, स्थापत्य और सेवा भावना से जुड़ी रही है। समय के साथ समाज ने शिक्षा, प्रशासन, व्यापार, उद्योग, विज्ञान, तकनीकी और सामाजिक क्षेत्रों में उल्लेखनीय प्रगति की है।\n\nआज समाज के सदस्य शिक्षक, अभियंता, चिकित्सक, प्रशासनिक अधिकारी, उद्यमी, वकील, सैनिक, वैज्ञानिक सहित विभिन्न क्षेत्रों में देश और समाज की सेवा कर रहे हैं।',
                    style: const TextStyle(fontSize: 13, color: ThemeConfig.textSecondary, height: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. NEW Section: Kuldevi Shri Shriyade Mata
            _buildSectionHeader(isEnglish ? 'Kuldevi - Shri Shriyade Mata' : 'समाज की कुलदेवी – श्री श्रीयादे माता'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: ThemeConfig.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: ThemeConfig.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Kuldevi Images side-by-side
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/kuldevi.png',
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/kuldevi1.png',
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isEnglish
                            ? 'Shri Shriyade Mata is revered as the patron deity (Kuldevi) of the Maru Prajapat, Prajapati, and Kumhar community.'
                            : 'श्री श्रीयादे माता (श्री यादे माता) मारू प्रजापत, प्रजापति एवं कुम्हार समाज की आराध्य कुलदेवी मानी जाती हैं। समाज की धार्मिक, सांस्कृतिक एवं पारिवारिक परंपराओं में श्रीयादे माता का विशेष स्थान है।',
                        style: const TextStyle(fontSize: 13, color: ThemeConfig.textPrimary, height: 1.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: ThemeConfig.border),
                      const SizedBox(height: 8),
                      // History and folklore of Kuldevi
                      Text(
                        isEnglish ? 'History & Legend:' : 'इतिहास एवं लोक परंपरा:',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ThemeConfig.primary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isEnglish
                            ? 'According to folklore, Shri Shriyade Mata showed the path of truth, righteousness, and devotion. Her legends connect her deeply to the protection of Bhakt Prahalad and the divine manifestation of Lord Narsingh.'
                            : 'लोक परंपराओं के अनुसार श्री श्रीयादे माता ने धर्म, सत्य और भक्ति का मार्ग दिखाया। अनेक कथाओं में उनका संबंध भक्त प्रह्लाद की भक्ति तथा भगवान श्री नरसिंह की कथा से जोड़ा जाता है। इन कथाओं में श्रीयादे माता को धर्म की प्रेरणा देने वाली और ईश्वर-भक्ति का संदेश फैलाने वाली दिव्य शक्ति के रूप में वर्णित किया गया है।',
                        style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      // Importance of Kuldevi in Samaj
                      Text(
                        isEnglish ? 'Cultural Importance:' : 'समाज में महत्व:',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ThemeConfig.primary),
                      ),
                      const SizedBox(height: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBulletPoint(isEnglish ? 'Worshipped before weddings and auspicious events.' : 'विवाह से पहले कुलदेवी का पूजन।'),
                          _buildBulletPoint(isEnglish ? 'Blessings for newlyweds and infants.' : 'नवविवाहित दंपत्ति द्वारा दर्शन एवं आशीर्वाद।'),
                          _buildBulletPoint(isEnglish ? 'Worship during name ceremonies and home entry.' : 'नामकरण एवं शुभ कार्यों में पूजा।'),
                          _buildBulletPoint(isEnglish ? 'Special invocations in collective community events.' : 'समाज के सामूहिक धार्मिक आयोजनों में विशेष आराधना।'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Major Temples
                      Text(
                        isEnglish ? 'Major Shri Shriyade Mata Temples:' : 'श्री श्रीयादे माता के प्रमुख मंदिर:',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ThemeConfig.primary),
                      ),
                      const SizedBox(height: 8),
                      _buildTempleItem(
                        '1',
                        isEnglish ? 'Shri Shriyade Mata Dham' : 'श्री श्रीयादे माता पावन धाम',
                        isEnglish ? 'Jhalamand, Jodhpur' : 'झालामंड, जोधपुर (राजस्थान)',
                        isEnglish ? 'Most prominent temple. Annual fair held on Magh Shukla Dwitiya.' : 'प्रजापति समाज का सबसे प्रमुख एवं विशाल मंदिर। जन्मोत्सव पर भव्य मेला आयोजित होता है।',
                      ),
                      const SizedBox(height: 8),
                      _buildTempleItem(
                        '2',
                        isEnglish ? 'Shri Shriyade Mata Temple' : 'श्री श्रीयादे माता मंदिर',
                        isEnglish ? 'Bagher, Jhalawar' : 'बाघेर, जिला झालावाड़ (राजस्थान)',
                        isEnglish ? 'Major center for religious activities in Hadoti region.' : 'हाड़ौती क्षेत्र का प्रमुख मंदिर, जहाँ विभिन्न आयोजन होते हैं।',
                      ),
                      const SizedBox(height: 8),
                      _buildTempleItem(
                        '3',
                        isEnglish ? 'Shri Shriyade Mata Temple' : 'श्री श्रीयादे माता मंदिर',
                        isEnglish ? 'Beri Village, Gudamalani, Barmer' : 'बेरी गाँव, गुडामालानी (बाड़मेर)',
                        isEnglish ? 'Grand temple built by the local Maru Prajapat community. Center for festivals like Shriyade Jayanti, Navratri, and community gatherings.' : 'बेरी गाँव के मारू प्रजापत समाज द्वारा निर्मित भव्य मंदिर। यहाँ श्रीयादे जयंती, नवरात्रि उत्सव और सामाजिक धार्मिक कार्यक्रम धूमधाम से आयोजित होते हैं।',
                      ),
                      const SizedBox(height: 8),
                      _buildTempleItem(
                        '4',
                        isEnglish ? 'Other Regional Temples' : 'राजस्थान के अन्य मंदिर',
                        isEnglish ? 'Barmer, Jaisalmer, Pali, Nagaur, Bikaner, Jalore' : 'बाड़मेर, जैसलमेर, पाली, नागौर, बीकानेर, जालौर',
                        isEnglish ? 'Local community shrines supporting regular prayers.' : 'स्थानीय प्रजापति समाज द्वारा स्थापित एवं नियमित रूप से पूजित धाम।',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 5. Section: History (5 Paragraphs/Sections Timeline)
            _buildSectionHeader(isEnglish ? 'Chronological History' : 'इतिहास'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildTimelineItem(
                    isEnglish ? 'Ancient Era & Mythological Origins' : 'प्राचीन काल एवं पौराणिक उत्पत्ति',
                    isEnglish
                        ? 'The history of the Prajapati community is ancient. In the Vedas, Prajapati is revered as the creator. Members trace their ancestry to Sage Daksha Prajapati, a spiritual pioneer of creation.'
                        : 'प्रजापति समुदाय का इतिहास अत्यंत प्राचीन है। वेदों में प्रजापति को सृष्टि के रचयिता के रूप में पूजा गया है। समाज के सदस्य पौराणिक ऋषि महाराज दक्ष प्रजापति के वंशज माने जाते हैं, जिन्होंने सृष्टि निर्माण में महत्वपूर्ण भूमिका निभाई थी।',
                    true,
                  ),
                  _buildTimelineItem(
                    isEnglish ? 'Origin from Marwar & "Maru" Identity' : 'मारवाड़ क्षेत्र से उद्गम व "मारू" पहचान',
                    isEnglish
                        ? 'The Maru Prajapat community originated from the historic Marwar region of Rajasthan. Through hard work and honesty in desert terrains, they forged their distinct "Maru" identity.'
                        : 'मारू प्रजापत समाज का मूल उद्गम ऐतिहासिक मारवाड़ (जोधपुर, राजस्थान) क्षेत्र से है। मरुस्थलीय विषम परिस्थितियों में अपनी कर्मठता, साहस और ईमानदारी के बल पर समाज ने अपनी एक विशिष्ट \'मारू\' पहचान स्थापित की।',
                    true,
                  ),
                  _buildTimelineItem(
                    isEnglish ? 'Ancestral Pottery & Wheel Invention' : 'पारंपरिक कुम्भ कला एवं चक्र का आविष्कार',
                    isEnglish
                        ? 'The community played a crucial role in human evolution. The invention of the pottery wheel (Chak) by their ancestors is recognized as the world\'s first industrial craft.'
                        : 'मानव सभ्यता के विकास में समाज का अतुलनीय योगदान रहा है। चाक (मिट्टी का पहिया) का आविष्कार समाज के पूर्वजों द्वारा किया गया था, जिसे विश्व के प्रथम उद्योग और मिट्टी शिल्प कला का आधार माना जाता है।',
                    true,
                  ),
                  _buildTimelineItem(
                    isEnglish ? 'Migration & Geographical Expansion' : 'प्रवास एवं भौगोलिक विस्तार',
                    isEnglish
                        ? 'In pursuit of craft and trade, the community migrated from Rajasthan to other states including Gujarat, MP, Maharashtra, Haryana, and Punjab, keeping their culture alive.'
                        : 'कला और रोजगार के अवसरों की खोज में मारू समाज का राजस्थान से देश के अन्य राज्यों जैसे गुजरात, मध्य प्रदेश, महाराष्ट्र, हरियाणा और पंजाब में प्रवास हुआ। नए स्थानों पर जाकर समाज ने अपनी कला को जीवित रखा और सामाजिक एकता को मजबूत किया।',
                    true,
                  ),
                  _buildTimelineItem(
                    isEnglish ? 'Modern Era & Social Upliftment' : 'आधुनिक काल और सामाजिक उत्थान',
                    isEnglish
                        ? 'Today, the community is highly progressive. The youth are establishing benchmarks in education, administrative services, healthcare, engineering, business, and modern agriculture.'
                        : 'आज का मारू प्रजापत समाज अत्यंत जागरूक और प्रगतिशील है। समाज के युवा शिक्षा, प्रशासनिक सेवाओं (IAS/IPS), चिकित्सा, इंजीनियरिंग, राजनीति, व्यवसाय और उन्नत कृषि के क्षेत्रों में राष्ट्रीय और अंतर्राष्ट्रीय स्तर पर कीर्तिमान स्थापित कर रहे हैं।',
                    false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 6. Section: Major Gotras (Customized Gotra list)
            _buildSectionHeader(isEnglish ? 'Major Gotras of Samaj' : 'समाज के प्रमुख गोत्र'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: gotras.map((gotra) => _buildTag(gotra)).toList(),
              ),
            ),
            const SizedBox(height: 24),


            // 8. Section: Major Occupations
            _buildSectionHeader(isEnglish ? 'Major Occupations' : 'समाज के प्रमुख व्यवसाय'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemCount: occupations.length,
                itemBuilder: (context, index) {
                  final occ = occupations[index];
                  final color = occ['color'] as Color;
                  final bgColor = occ['bgColor'] as Color;
                  return Container(
                    decoration: BoxDecoration(
                      color: ThemeConfig.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ThemeConfig.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: bgColor,
                            shape: BoxShape.circle,
                          ),
                          child: occ['icon'] == null
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CustomPaint(painter: MiniClayPotPainter(color: color)),
                                )
                              : Icon(occ['icon'] as IconData, color: color, size: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          occ['name'] as String,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // 9. Slogan Flag Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flag, color: Colors.orange, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEnglish
                            ? '"Unity is our Identity, Education is our Pride, Service is our Goal"'
                            : '"एकता हमारी पहचान, शिक्षा हमारा अभिमान, सेवा हमारा लक्ष्य"',
                        style: const TextStyle(
                          color: Color(0xFFD35400),
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.orange, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: ThemeConfig.textSecondary),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: ThemeConfig.border.withOpacity(0.8),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Icon(Icons.brightness_1, size: 6, color: Colors.orange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempleItem(String num, String name, String location, String feature) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ThemeConfig.primaryLight.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ThemeConfig.border.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.orange,
            child: Text(
              num,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  feature,
                  style: const TextStyle(fontSize: 11, color: ThemeConfig.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String body, bool showLine) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange, width: 3),
                ),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.orange.withOpacity(0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ThemeConfig.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ThemeConfig.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: ThemeConfig.surface,
        border: Border.all(color: ThemeConfig.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: ThemeConfig.textPrimary,
        ),
      ),
    );
  }
}

class MonumentFortPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD35400).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTRB(0, size.height * 0.8, size.width, size.height * 0.95))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTRB(size.width * 0.05, size.height * 0.35, size.width * 0.28, size.height * 0.8),
        const Radius.circular(3),
      ))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTRB(size.width * 0.72, size.height * 0.35, size.width * 0.95, size.height * 0.8),
        const Radius.circular(3),
      ))
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.45),
        radius: size.width * 0.18,
      ))
      ..addRect(Rect.fromLTRB(size.width * 0.32, size.height * 0.45, size.width * 0.68, size.height * 0.8))
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.165, size.height * 0.32),
        radius: size.width * 0.08,
      ))
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.835, size.height * 0.32),
        radius: size.width * 0.08,
      ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MonumentArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD35400).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTRB(0, size.height * 0.8, size.width, size.height * 0.95))
      ..addRect(Rect.fromLTRB(size.width * 0.12, size.height * 0.25, size.width * 0.35, size.height * 0.8))
      ..addRect(Rect.fromLTRB(size.width * 0.65, size.height * 0.25, size.width * 0.88, size.height * 0.8))
      ..addRect(Rect.fromLTRB(size.width * 0.06, size.height * 0.1, size.width * 0.94, size.height * 0.25))
      ..arcTo(
        Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.48), radius: size.width * 0.16),
        3.1415,
        3.1415,
        false,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MonumentTowerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD35400).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTRB(size.width * 0.15, size.height * 0.8, size.width * 0.85, size.height * 0.95))
      ..moveTo(size.width * 0.22, size.height * 0.8)
      ..lineTo(size.width * 0.3, size.height * 0.5)
      ..lineTo(size.width * 0.7, size.height * 0.5)
      ..lineTo(size.width * 0.78, size.height * 0.8)
      ..close()
      ..moveTo(size.width * 0.3, size.height * 0.5)
      ..lineTo(size.width * 0.36, size.height * 0.24)
      ..lineTo(size.width * 0.64, size.height * 0.24)
      ..lineTo(size.width * 0.7, size.height * 0.5)
      ..close()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.16),
        radius: size.width * 0.1,
      ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MiniClayPotPainter extends CustomPainter {
  final Color color;
  MiniClayPotPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addOval(Rect.fromLTRB(size.width * 0.22, size.height * 0.08, size.width * 0.78, size.height * 0.23))
      ..moveTo(size.width * 0.32, size.height * 0.18)
      ..lineTo(size.width * 0.32, size.height * 0.32)
      ..lineTo(size.width * 0.68, size.height * 0.32)
      ..lineTo(size.width * 0.68, size.height * 0.18)
      ..close()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.62),
        radius: size.width * 0.36,
      ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
