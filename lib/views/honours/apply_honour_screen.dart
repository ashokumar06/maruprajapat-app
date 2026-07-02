import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import 'package:provider/provider.dart';
import '../../providers/honours_provider.dart';

class ApplyHonourScreen extends StatefulWidget {
  final bool isAdminOrMember;
  final bool isBhamashah;
  
  const ApplyHonourScreen({
    super.key, 
    this.isAdminOrMember = false,
    this.isBhamashah = false,
  });

  @override
  State<ApplyHonourScreen> createState() => _ApplyHonourScreenState();
}

class _ApplyHonourScreenState extends State<ApplyHonourScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Category (Only for Pratibha)
  String _selectedCategory = 'Anya';
  final List<Map<String, dynamic>> _categories = [
    {'id': 'Shiksha', 'icon': Icons.school, 'color': Colors.blue, 'label': 'शिक्षा'},
    {'id': 'Sarkari Seva', 'icon': Icons.account_balance, 'color': Colors.red, 'label': 'सरकारी सेवा'},
    {'id': 'Pratiyogi Pariksha', 'icon': Icons.military_tech, 'color': Colors.orange, 'label': 'प्रतियोगी परीक्षा'},
    {'id': 'Khel', 'icon': Icons.emoji_events, 'color': Colors.yellow.shade700, 'label': 'खेल'},
    {'id': 'Seva', 'icon': Icons.favorite, 'color': Colors.pink, 'label': 'सेवा / समाज'},
    {'id': 'Kala', 'icon': Icons.palette, 'color': Colors.deepOrange, 'label': 'कला / संस्कृति'},
    {'id': 'Vyavsay', 'icon': Icons.business_center, 'color': Colors.brown, 'label': 'व्यवसाय'},
    {'id': 'Anya', 'icon': Icons.more_horiz, 'color': Colors.grey, 'label': 'अन्य'},
  ];

  // Info fields
  final _nameCtrl = TextEditingController();
  final _fatherNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Achievement fields (Pratibha)
  final _achievementCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _instituteCtrl = TextEditingController();
  final _rankCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  
  // Details (Both)
  final _detailsCtrl = TextEditingController();
  
  // Donation fields (Bhamashah)
  final _donationAmountCtrl = TextEditingController();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = context.read<HonoursProvider>();
    bool success = false;
    
    if (widget.isBhamashah) {
      success = await provider.applyBhamashah({
        'name': _nameCtrl.text,
        'father_husband_name': _fatherNameCtrl.text,
        'dob': _dobCtrl.text,
        'address': _addressCtrl.text,
        'district': _districtCtrl.text,
        'mobile_number': _mobileCtrl.text,
        'email': _emailCtrl.text,
        'donation_amount': double.tryParse(_donationAmountCtrl.text),
        'details': _detailsCtrl.text,
      });
    } else {
      success = await provider.applyPratibha({
        'name': _nameCtrl.text,
        'father_husband_name': _fatherNameCtrl.text,
        'dob': _dobCtrl.text,
        'address': _addressCtrl.text,
        'district': _districtCtrl.text,
        'mobile_number': _mobileCtrl.text,
        'email': _emailCtrl.text,
        'category': _selectedCategory,
        'achievement': _achievementCtrl.text,
        'year': _yearCtrl.text,
        'institute_dept': _instituteCtrl.text,
        'rank_place': _rankCtrl.text,
        'location': _locationCtrl.text,
        'details': _detailsCtrl.text,
      });
    }

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isAdminOrMember 
            ? (widget.isBhamashah ? 'भामाशाह सफलतापूर्वक जोड़ दिया गया है।' : 'प्रतिभा सफलतापूर्वक जोड़ दी गई है।') 
            : 'आवेदन सफलतापूर्वक जमा कर दिया गया है।'),
          backgroundColor: ThemeConfig.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('विफल रहा। पुनः प्रयास करें।'), backgroundColor: ThemeConfig.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdminOrMember 
          ? (widget.isBhamashah ? 'नए भामाशाह जोड़ें' : 'नई प्रतिभा जोड़ें') 
          : (widget.isBhamashah ? 'भामाशाह आवेदन' : 'प्रतिभा आवेदन')),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
        titleTextStyle: const TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      backgroundColor: Colors.white,
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: ThemeConfig.primary),
        ),
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 3) {
                setState(() => _currentStep += 1);
              } else {
                _submit();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              } else {
                Navigator.pop(context);
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: ThemeConfig.border),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('पीछे जाएं', style: TextStyle(color: ThemeConfig.textPrimary)),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConfig.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(_currentStep == 3 ? (widget.isAdminOrMember ? 'जोड़ें' : 'जमा करें') : 'आगे बढ़ें', style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('जानकारी', style: TextStyle(fontSize: 10)),
                content: _buildStep1Info(),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: Text(widget.isBhamashah ? 'योगदान' : 'उपलब्धि', style: const TextStyle(fontSize: 10)),
                content: widget.isBhamashah ? _buildStep2Donation() : _buildStep2Achievement(),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('दस्तावेज़', style: TextStyle(fontSize: 10)),
                content: _buildStep3Docs(),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('समीक्षा', style: TextStyle(fontSize: 10)),
                content: _buildStep4Review(),
                isActive: _currentStep >= 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1Info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isBhamashah) ...[
          const Text('किस श्रेणी में आवेदन करना चाहते हैं?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat['id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat['id']),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? ThemeConfig.primary.withOpacity(0.1) : Colors.white,
                    border: Border.all(color: isSelected ? ThemeConfig.primary : ThemeConfig.border, width: isSelected ? 2 : 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat['icon'], color: cat['color'], size: 32),
                      const SizedBox(height: 8),
                      Text(cat['label'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
        
        Text(widget.isBhamashah ? 'भामाशाह की जानकारी' : 'व्यक्ति की जानकारी', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'पूर्ण नाम *', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'नाम आवश्यक है' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _fatherNameCtrl,
          decoration: const InputDecoration(labelText: 'पिता / पति का नाम *', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dobCtrl,
          decoration: const InputDecoration(labelText: 'जन्म तिथि * (DD/MM/YYYY)', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressCtrl,
          decoration: const InputDecoration(labelText: 'पता *', border: OutlineInputBorder()),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _districtCtrl,
                decoration: const InputDecoration(labelText: 'ज़िला *', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _mobileCtrl,
                decoration: const InputDecoration(labelText: 'मोबाइल नंबर *', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailCtrl,
          decoration: const InputDecoration(labelText: 'ईमेल (वैकल्पिक)', border: OutlineInputBorder()),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildStep2Achievement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('उपलब्धि विवरण', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _achievementCtrl,
          decoration: const InputDecoration(labelText: 'परीक्षा / पद / उपलब्धि का नाम *', hintText: 'जैसे - RAS, REET, राज्य टॉपर आदि', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'उपलब्धि आवश्यक है' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _yearCtrl,
          decoration: const InputDecoration(labelText: 'वर्ष *', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _instituteCtrl,
          decoration: const InputDecoration(labelText: 'संस्थान / विभाग', hintText: 'संस्थान / विभाग का नाम', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _rankCtrl,
          decoration: const InputDecoration(labelText: 'प्राप्त स्थान / रैंक (यदि लागू हो)', hintText: 'जैसे - AIR 145, राज्य में प्रथम आदि', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _locationCtrl,
          decoration: const InputDecoration(labelText: 'स्थल / ज़िला', hintText: 'चुनें', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _detailsCtrl,
          decoration: const InputDecoration(labelText: 'विवरण *', hintText: 'संक्षिप्त विवरण लिखें...', border: OutlineInputBorder()),
          maxLines: 4,
        ),
      ],
    );
  }
  
  Widget _buildStep2Donation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('योगदान विवरण', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _donationAmountCtrl,
          decoration: const InputDecoration(labelText: 'योगदान राशि (₹) *', hintText: 'जैसे - 51000', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          validator: (v) => v!.isEmpty ? 'राशि आवश्यक है' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _detailsCtrl,
          decoration: const InputDecoration(labelText: 'योगदान का उद्देश्य / विवरण *', hintText: 'जैसे - समाज भवन निर्माण हेतु...', border: OutlineInputBorder()),
          maxLines: 4,
          validator: (v) => v!.isEmpty ? 'विवरण आवश्यक है' : null,
        ),
      ],
    );
  }

  Widget _buildStep3Docs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('दस्तावेज़ अपलोड करें', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        _buildUploadBox('पहचान प्रमाण पत्र *', 'आधार कार्ड / अन्य'),
        _buildUploadBox(widget.isBhamashah ? 'योगदान प्रमाण *' : 'उपलब्धि प्रमाण पत्र *', widget.isBhamashah ? 'रसीद / अन्य प्रमाण' : 'सर्टिफिकेट / मार्कशीट'),
        _buildUploadBox('फोटो *', 'पासपोर्ट साइज़ फोटो'),
        _buildUploadBox('अन्य दस्तावेज़ (वैकल्पिक)', 'कोई भी अतिरिक्त दस्तावेज़'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 8),
              Text('केवल PDF / JPG / PNG (अधिकतम 5 MB)', style: TextStyle(color: Colors.orange, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: ThemeConfig.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: ThemeConfig.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.file_copy_outlined, color: ThemeConfig.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('अपलोड करें', style: TextStyle(color: ThemeConfig.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('समीक्षा करें', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        const Text('कृपया सबमिट करने से पहले सभी जानकारी जांच लें।', style: TextStyle(color: ThemeConfig.textSecondary)),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: ThemeConfig.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReviewRow('नाम:', _nameCtrl.text),
                if (!widget.isBhamashah) _buildReviewRow('श्रेणी:', _selectedCategory),
                if (!widget.isBhamashah) _buildReviewRow('उपलब्धि:', _achievementCtrl.text),
                if (!widget.isBhamashah) _buildReviewRow('वर्ष:', _yearCtrl.text),
                if (widget.isBhamashah) _buildReviewRow('योगदान राशि:', '₹${_donationAmountCtrl.text}'),
                _buildReviewRow('मोबाइल:', _mobileCtrl.text),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 13))),
          Expanded(child: Text(value.isEmpty ? '-' : value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }
}
