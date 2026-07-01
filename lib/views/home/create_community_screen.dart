import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../config/theme_config.dart';
import '../../services/api_client.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  
  String? _selectedCategory;
  bool _isSubmitting = false;
  File? _logoFile;
  bool _isUploadingLogo = false;
  String? _logoError;

  final List<String> _categories = [
    'शिक्षा • सेवा',
    'सेवा • सहयोग',
    'शिक्षा • मार्गदर्शन',
    'सेवा • स्वास्थ्य',
    'युवा • विकास',
    'महिला • उत्थान'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    setState(() {
      _logoError = null;
    });
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final int sizeInBytes = await file.length();
        final double sizeInKB = sizeInBytes / 1024;

        if (sizeInKB > 10.0) {
          setState(() {
            _logoError = Localizations.localeOf(context).languageCode == 'en'
                ? 'Logo size must be maximum 10 KB (Selected: ${sizeInKB.toStringAsFixed(1)} KB)'
                : 'लोगो का आकार अधिकतम 10 KB होना चाहिए (चयनित: ${sizeInKB.toStringAsFixed(1)} KB)';
            _logoFile = null;
          });
        } else {
          setState(() {
            _logoFile = file;
            _logoError = null;
          });
        }
      }
    } catch (e) {
      debugPrint("Error picking logo: $e");
    }
  }

  Future<String?> _uploadLogo(File file) async {
    setState(() => _isUploadingLogo = true);
    try {
      final dio = ApiClient().dio;
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await dio.post('/api/v1/upload/image', data: formData);
      if (response.statusCode == 200 && response.data != null) {
        return response.data['url'];
      }
    } catch (e) {
      debugPrint('Error uploading logo: $e');
    } finally {
      setState(() => _isUploadingLogo = false);
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Localizations.localeOf(context).languageCode == 'en'
            ? 'Please fill all mandatory fields!'
            : 'कृपया सभी अनिवार्य क्षेत्र भरें!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      String? logoUrl;
      if (_logoFile != null) {
        logoUrl = await _uploadLogo(_logoFile!);
        if (logoUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(Localizations.localeOf(context).languageCode == 'en'
                ? 'Failed to upload logo, please try again.'
                : 'लोगो अपलोड करने में विफल, कृपया पुनः प्रयास करें।')),
          );
          setState(() => _isSubmitting = false);
          return;
        }
      }

      final response = await ApiClient().dio.post('/communities/', data: {
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'description': _descController.text.trim(),
        'location': _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        'logo_url': logoUrl,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(Localizations.localeOf(context).languageCode == 'en'
                ? 'Community request sent successfully! Admin approval required.'
                : 'समुदाय निर्माण अनुरोध सफलतापूर्वक भेजा गया! एडमिन की स्वीकृति आवश्यक है।'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Create Community' : 'समुदाय बनाएं',
          style: const TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeConfig.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header image/icon banner
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ThemeConfig.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.group_add_outlined,
                        color: ThemeConfig.primary,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isEnglish ? 'Create New Community' : 'नया समुदाय बनाएं',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish 
                          ? 'Create a new community for positive changes in society'
                          : 'समाज में सकारात्मक परिवर्तन के लिए नया समुदाय बनाएं',
                      style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Community Name
              Text(
                (isEnglish ? 'Community Name' : 'समुदाय का नाम') + ' *',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: isEnglish ? 'e.g. Maru Prajapat Hostel Committee' : 'जैसे: मारू प्रजापत हॉस्टल समिति',
                  hintStyle: const TextStyle(color: ThemeConfig.textHint, fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return isEnglish ? 'Name is required' : 'नाम दर्ज करना अनिवार्य है';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              Text(
                (isEnglish ? 'Category' : 'श्रेणी') + ' *',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: Text(
                  isEnglish ? 'Select Category' : 'श्रेणी चुनें',
                  style: const TextStyle(color: ThemeConfig.textHint, fontSize: 13),
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(cat, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
                validator: (val) {
                  if (val == null) {
                    return isEnglish ? 'Category is required' : 'श्रेणी चुनना अनिवार्य है';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                (isEnglish ? 'Description' : 'विवरण') + ' *',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: isEnglish 
                      ? 'Describe objectives and work of this community...' 
                      : 'समुदाय के उद्देश्य और कार्यों का विवरण दें...',
                  hintStyle: const TextStyle(color: ThemeConfig.textHint, fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.all(12),
                  counterText: "",
                ),
                onChanged: (val) => setState(() {}),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return isEnglish ? 'Description is required' : 'विवरण दर्ज करना अनिवार्य है';
                  }
                  if (val.trim().length < 10) {
                    return isEnglish ? 'Must be at least 10 characters' : 'कम से कम 10 वर्ण होने चाहिए';
                  }
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '${_descController.text.length}/300',
                    style: const TextStyle(fontSize: 11, color: ThemeConfig.textHint),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Logo container with Working Pick Image size validation (< 10 KB)
              Text(
                isEnglish ? 'Community Logo (Max 10 KB)' : 'समुदाय का लोगो (अधिकतम 10 KB)',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickLogo,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: ThemeConfig.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _logoError != null ? ThemeConfig.error : ThemeConfig.border,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _logoFile != null ? Icons.check_circle_outline : Icons.upload_file,
                        color: _logoFile != null ? Colors.green : ThemeConfig.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _logoFile != null
                              ? (isEnglish ? 'Logo selected: ${_logoFile!.path.split('/').last}' : 'लोगो चयनित: ${_logoFile!.path.split('/').last}')
                              : (isEnglish ? 'Upload Logo (Max 10 KB)' : 'लोगो अपलोड करें (अधिकतम 10 KB)'),
                          style: TextStyle(
                            fontSize: 12,
                            color: _logoFile != null ? Colors.green : ThemeConfig.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_logoFile != null)
                        IconButton(
                          icon: const Icon(Icons.close, color: ThemeConfig.error, size: 18),
                          onPressed: () {
                            setState(() {
                              _logoFile = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              if (_logoError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _logoError!,
                  style: const TextStyle(color: ThemeConfig.error, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 16),

              // Location
              Text(
                isEnglish ? 'Community Location' : 'समुदाय का स्थान',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: isEnglish ? 'Select Location' : 'स्थान चुनें / दर्ज करें',
                  hintStyle: const TextStyle(color: ThemeConfig.textHint, fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: ThemeConfig.border),
                      ),
                      child: Text(
                        isEnglish ? 'Cancel' : 'रद्द करें',
                        style: const TextStyle(color: ThemeConfig.textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || _isUploadingLogo || _logoError != null) ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConfig.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: (_isSubmitting || _isUploadingLogo)
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              isEnglish ? 'Submit Request' : 'अनुरोध भेजें',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
