import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../services/api_client.dart';
import '../../providers/news_provider.dart';

class CreateEventScreen extends StatefulWidget {
  final int? communityId;

  const CreateEventScreen({
    super.key,
    this.communityId,
  });

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locController = TextEditingController();
  
  String _eventType = 'meeting';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  final List<Map<String, String>> _types = [
    {'value': 'meeting', 'label': 'बैठक (Meeting)'},
    {'value': 'ceremony', 'label': 'समारोह (Ceremony)'},
    {'value': 'conference', 'label': 'सम्मेलन (Conference)'},
    {'value': 'sports', 'label': 'खेलकूद (Sports)'},
    {'value': 'festival', 'label': 'उत्सव (Festival)'},
    {'value': 'general', 'label': 'सामान्य (General)'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ThemeConfig.primary,
              onPrimary: Colors.white,
              onSurface: ThemeConfig.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ThemeConfig.primary,
              onPrimary: Colors.white,
              onSurface: ThemeConfig.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया कार्यक्रम की तिथि चुनें')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया कार्यक्रम का समय चुनें')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final combinedStart = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final dio = ApiClient().dio;
      final payload = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'event_type': _eventType,
        'location': _locController.text.trim(),
        'start_date': combinedStart.toUtc().toIso8601String(),
        'end_date': combinedStart.add(const Duration(hours: 3)).toUtc().toIso8601String(),
        'registration_open': false, // RSVP options disabled as requested
        'max_registrations': null,
        'community_id': widget.communityId,
      };

      final response = await dio.post('/api/v1/events/', data: payload);

      if (response.statusCode == 201 && mounted) {
        // Success! Prompt to publish as post
        _showPostPrompt(
          title: _titleController.text.trim(),
          dateStr: DateFormat('dd MMMM yyyy').format(combinedStart),
          timeStr: _selectedTime!.format(context),
          location: _locController.text.trim(),
          desc: _descController.text.trim(),
        );
      }
    } catch (e) {
      debugPrint('Error creating event: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('कार्यक्रम बनाने में विफल'),
            backgroundColor: ThemeConfig.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPostPrompt({
    required String title,
    required String dateStr,
    required String timeStr,
    required String location,
    required String desc,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'पोस्ट साझा करें?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'क्या आप इस कार्यक्रम को समाज के मुख्य फीड (होम पेज) पर एक पोस्ट के रूप में भी साझा करना चाहते हैं?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Pop screen back to list
              },
              child: const Text('नहीं', style: TextStyle(color: ThemeConfig.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                setState(() => _isLoading = true);
                
                final String postText = 
                    '📢 नवीन कार्यक्रम घोषणा: $title\n'
                    '📅 तिथि: $dateStr\n'
                    '⏰ समय: $timeStr से\n'
                    '📍 स्थान: $location\n\n'
                    'विवरण: $desc';

                final newsProvider = Provider.of<NewsProvider>(this.context, listen: false);
                await newsProvider.createPost(
                  text: postText,
                  postType: 'text',
                  communityId: widget.communityId,
                );

                if (mounted) {
                  Navigator.pop(this.context, true); // Pop screen back to list
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('हाँ, पोस्ट करें', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate == null
        ? 'चुनें'
        : DateFormat('dd MMMM yyyy').format(_selectedDate!);
    final timeText = _selectedTime == null ? 'चुनें' : _selectedTime!.format(context);

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text(
          'नया कार्यक्रम जोड़ें',
          style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ThemeConfig.primary))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Form Card Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ThemeConfig.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: ThemeConfig.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field
                        const Text(
                          'कार्यक्रम का नाम *',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ThemeConfig.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          validator: (v) => v == null || v.isEmpty ? 'कृपया कार्यक्रम का नाम लिखें' : null,
                          decoration: InputDecoration(
                            hintText: 'उदा. वार्षिक समाज मिलन समारोह',
                            hintStyle: const TextStyle(color: ThemeConfig.textHint, fontSize: 14),
                            filled: true,
                            fillColor: ThemeConfig.background.withOpacity(0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: ThemeConfig.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: ThemeConfig.border),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Dropdown Event Type
                        const Text(
                          'कार्यक्रम का प्रकार *',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ThemeConfig.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _eventType,
                          items: _types.map((type) {
                            return DropdownMenuItem<String>(
                              value: type['value'],
                              child: Text(type['label']!),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _eventType = val;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: ThemeConfig.background.withOpacity(0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: ThemeConfig.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: ThemeConfig.border),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Date & Time Picker row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'तिथि *',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ThemeConfig.textSecondary),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: _pickDate,
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: ThemeConfig.background.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: ThemeConfig.border),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(dateText, style: const TextStyle(fontSize: 14)),
                                          const Icon(Icons.calendar_today, size: 16, color: ThemeConfig.textSecondary),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'समय *',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ThemeConfig.textSecondary),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: _pickTime,
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: ThemeConfig.background.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: ThemeConfig.border),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(timeText, style: const TextStyle(fontSize: 14)),
                                          const Icon(Icons.access_time, size: 16, color: ThemeConfig.textSecondary),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Location Field
                        const Text(
                          'स्थान *',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ThemeConfig.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _locController,
                          validator: (v) => v == null || v.isEmpty ? 'कृपया कार्यक्रम का स्थान लिखें' : null,
                          decoration: InputDecoration(
                            hintText: 'उदा. सामुदायिक भवन, बालोतरा',
                            hintStyle: const TextStyle(color: ThemeConfig.textHint, fontSize: 14),
                            filled: true,
                            fillColor: ThemeConfig.background.withOpacity(0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: ThemeConfig.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: ThemeConfig.border),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Description Field
                        const Text(
                          'विवरण *',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ThemeConfig.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descController,
                          validator: (v) => v == null || v.isEmpty ? 'कृपया विवरण या नियम लिखें' : null,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'उदा. कार्यक्रम की रूपरेखा और आमंत्रण संदेश लिखें...',
                            hintStyle: const TextStyle(color: ThemeConfig.textHint, fontSize: 14),
                            filled: true,
                            fillColor: ThemeConfig.background.withOpacity(0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: ThemeConfig.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: ThemeConfig.border),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Submit Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConfig.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'कार्यक्रम जोड़ें',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
