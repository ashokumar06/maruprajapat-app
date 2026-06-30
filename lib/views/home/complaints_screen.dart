import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final List<Map<String, dynamic>> _complaints = [
    {
      'title': 'प्रजापत छात्रावास में साफ-सफाई की समस्या',
      'status': 'निस्तारित (Resolved)',
      'date': '24/06/2026',
      'desc': 'छात्रावास परिसर में साफ-सफाई ठीक से नहीं हो रही थी, वार्डन को सूचित कर दिया गया है और अब सफाई नियमित रूप से की जा रही है।'
    },
    {
      'title': 'सामुदायिक भवन की बुकिंग शुल्क में पारदर्शिता',
      'status': 'लंबित (Pending)',
      'date': '29/06/2026',
      'desc': 'बुकिंग के नियमों और रसीदों का विवरण ऑनलाइन पोर्टल पर साझा किया जाना चाहिए।'
    }
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitComplaint() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _complaints.insert(0, {
          'title': _titleController.text,
          'status': 'लंबित (Pending)',
          'date': '30/06/2026',
          'desc': _descController.text,
        });
        _isSubmitting = false;
      });
      _titleController.clear();
      _descController.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('शिकायत सफलतापूर्वक दर्ज कर ली गई है।'),
          backgroundColor: ThemeConfig.success,
        ),
      );
    });
  }

  void _showNewComplaintSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('नई शिकायत दर्ज करें', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'शिकायत का विषय/शीर्षक',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'कृपया शीर्षक दर्ज करें' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'शिकायत का विस्तृत विवरण',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (val) => val == null || val.isEmpty ? 'कृपया विवरण दर्ज करें' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConfig.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSubmitting 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('शिकायत जमा करें', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text('शिकायत निवारण', style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewComplaintSheet,
        backgroundColor: ThemeConfig.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _complaints.length,
        itemBuilder: (context, index) {
          final item = _complaints[index];
          final isResolved = item['status']!.contains('Resolved');
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
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isResolved ? ThemeConfig.success : Colors.orange).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['status']!,
                          style: TextStyle(
                            color: isResolved ? ThemeConfig.success : Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'दर्ज तिथि: ${item['date']}',
                    style: const TextStyle(fontSize: 12, color: ThemeConfig.textHint),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: ThemeConfig.divider),
                  const SizedBox(height: 8),
                  Text(
                    item['desc']!,
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
