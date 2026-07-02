import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../services/api_client.dart';
import '../../providers/news_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';


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

  void _insertHtmlTag(String startTag, String endTag) {
    final text = _descController.text;
    final selection = _descController.selection;
    if (selection.isValid && selection.start >= 0 && selection.end >= 0) {
      final start = selection.start;
      final end = selection.end;
      final selectedText = text.substring(start, end);
      final newText = text.replaceRange(start, end, '$startTag$selectedText$endTag');
      _descController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + startTag.length + selectedText.length + endTag.length),
      );
    } else {
      final newText = text + '$startTag$endTag';
      _descController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
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


  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 30, // Compress heavily
      );
      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        final int sizeInBytes = await file.length();
        if (sizeInBytes > 20 * 1024) { // 20 KB limit
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('इमेज 20KB से बड़ी है। कृपया छोटी इमेज चुनें या compress करें।'),
                backgroundColor: ThemeConfig.error,
              ),
            );
          }
          return;
        }
        setState(() {
          _selectedImage = file;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
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
      String? coverImageUrl;
      
      if (_selectedImage != null) {
        try {
          final fileName = _selectedImage!.path.split('/').last;
          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(_selectedImage!.path, filename: fileName),
          });
          final uploadRes = await dio.post('/api/v1/upload/image', data: formData);
          if (uploadRes.statusCode == 200 && uploadRes.data != null) {
            coverImageUrl = uploadRes.data['url'];
          }
        } catch (e) {
          debugPrint('Error uploading cover image: $e');
        }
      }

      final payload = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim().replaceAll('\n', '<br>'),
        'event_type': _eventType,
        'location': _locController.text.trim(),
        'start_date': combinedStart.toUtc().toIso8601String(),
        'end_date': combinedStart.add(const Duration(hours: 3)).toUtc().toIso8601String(),
        'cover_image_url': coverImageUrl,
        'registration_open': false,
        'max_registrations': null,
        'community_id': widget.communityId,
      };

      final response = await dio.post('/api/v1/events/', data: payload);

      if (response.statusCode == 201 && mounted) {
        _showPostPrompt(
          title: _titleController.text.trim(),
          dateStr: DateFormat('dd MMMM yyyy').format(combinedStart),
          timeStr: _selectedTime!.format(context),
          location: _locController.text.trim(),
          
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
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text('नहीं', style: TextStyle(color: ThemeConfig.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                
                final String postText = 
                    '📢 नवीन कार्यक्रम घोषणा: $title\n'
                    '📅 तिथि: $dateStr\n'
                    '⏰ समय: $timeStr से\n'
                    '📍 स्थान: $location\n\n'
                    'विवरण: (Rich Text Details)'; // Simplified for post

                final newsProvider = Provider.of<NewsProvider>(this.context, listen: false);
                await newsProvider.createPost(
                  text: postText,
                  postType: 'text',
                  communityId: widget.communityId,
                );

                if (mounted) {
                  Navigator.pop(this.context, true);
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
        ? 'dd/mm/yyyy'
        : DateFormat('dd/MM/yyyy').format(_selectedDate!);
    final timeText = _selectedTime == null ? '--:-- --' : _selectedTime!.format(context);

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
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
                    children: [
                      // Image Upload Area
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: ThemeConfig.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ThemeConfig.border,
                              style: BorderStyle.solid, 
                              width: 1.5,
                            ),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined, color: ThemeConfig.textHint, size: 36),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'इमेज अपलोड करें',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ThemeConfig.textSecondary),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'JPG, PNG (Max 20KB)',
                                      style: TextStyle(fontSize: 11, color: ThemeConfig.textHint),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input Fields
                      const Text(
                        'कार्यक्रम का नाम *',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ThemeConfig.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleController,
                        validator: (v) => v == null || v.isEmpty ? 'कृपया कार्यक्रम का नाम लिखें' : null,
                        decoration: InputDecoration(
                          hintText: 'कार्यक्रम का नाम लिखें',
                          hintStyle: const TextStyle(color: ThemeConfig.textHint, fontSize: 13),
                          filled: true,
                          fillColor: ThemeConfig.surface,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeConfig.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeConfig.border)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'कार्यक्रम का प्रकार *',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ThemeConfig.textSecondary),
                      ),
                      const SizedBox(height: 6),
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
                          fillColor: ThemeConfig.surface,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeConfig.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeConfig.border)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date & Time pickers
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
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: _pickDate,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: ThemeConfig.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: ThemeConfig.border),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          dateText,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: _selectedDate == null ? ThemeConfig.textHint : ThemeConfig.textPrimary,
                                          ),
                                        ),
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
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: _pickTime,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: ThemeConfig.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: ThemeConfig.border),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          timeText,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: _selectedTime == null ? ThemeConfig.textHint : ThemeConfig.textPrimary,
                                          ),
                                        ),
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
                      const SizedBox(height: 16),

                      const Text(
                        'स्थान *',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ThemeConfig.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _locController,
                        validator: (v) => v == null || v.isEmpty ? 'कृपया कार्यक्रम का स्थान लिखें' : null,
                        decoration: InputDecoration(
                          hintText: 'स्थान लिखें',
                          hintStyle: const TextStyle(color: ThemeConfig.textHint, fontSize: 13),
                          filled: true,
                          fillColor: ThemeConfig.surface,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeConfig.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeConfig.border)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'विवरण *',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ThemeConfig.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: ThemeConfig.surface,
                          border: Border.all(color: ThemeConfig.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: ThemeConfig.border)),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.format_bold),
                                    onPressed: () => _insertHtmlTag('<b>', '</b>'),
                                    tooltip: 'Bold',
                                    iconSize: 20,
                                    splashRadius: 20,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.format_italic),
                                    onPressed: () => _insertHtmlTag('<i>', '</i>'),
                                    tooltip: 'Italic',
                                    iconSize: 20,
                                    splashRadius: 20,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.link),
                                    onPressed: () => _insertHtmlTag('<a href="https://link-here.com">', '</a>'),
                                    tooltip: 'Link',
                                    iconSize: 20,
                                    splashRadius: 20,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.location_on_outlined),
                                    onPressed: () => _insertHtmlTag('📍 ', ''),
                                    tooltip: 'Location',
                                    iconSize: 20,
                                    splashRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            TextFormField(
                              controller: _descController,
                              validator: (v) => v == null || v.isEmpty ? 'कृपया कार्यक्रम का विवरण लिखें' : null,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                hintText: 'कार्यक्रम का विवरण यहाँ लिखें... (Text select करके बोल्ड/इटैलिक बटन दबाएं)',
                                hintStyle: TextStyle(color: ThemeConfig.textHint, fontSize: 13),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Fixed Bottom Orange Submission Button
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConfig.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        child: const Text(
                          'कार्यक्रम जोड़ें',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
