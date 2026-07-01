import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../services/api_client.dart';
import '../../providers/auth_provider.dart';

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

  List<dynamic> _users = [];
  bool _isLoadingUsers = false;
  int? _selectedAdminId;

  final List<String> _categories = [
    'शिक्षा • सेवा',
    'सेवा • सहयोग',
    'शिक्षा • मार्गदर्शन',
    'सेवा • स्वास्थ्य',
    'युवा • विकास',
    'महिला • उत्थान'
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      final response = await ApiClient().dio.get('/api/v1/users/', queryParameters: {'per_page': 100});
      if (response.data != null && response.data['items'] != null) {
        setState(() {
          _users = response.data['items'];
          final currentUser = context.read<AuthProvider>().currentUserModel;
          if (currentUser != null) {
            final exists = _users.any((u) => u['id'] == currentUser.id);
            if (exists) {
              _selectedAdminId = currentUser.id;
            } else if (_users.isNotEmpty) {
              _selectedAdminId = _users.first['id'];
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      setState(() => _isLoadingUsers = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
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
      final response = await ApiClient().dio.post('/api/v1/communities/', data: {
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'description': _descController.text.trim(),
        'location': _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        'logo_url': null,
        'admin_id': _selectedAdminId,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final user = context.read<AuthProvider>().currentUserModel;
        final role = (user?.role ?? 'guest').toLowerCase();
        final isAdmin = role == 'admin' || role == 'superadmin';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(isAdmin
                ? (Localizations.localeOf(context).languageCode == 'en'
                    ? 'Community created successfully!'
                    : 'समुदाय सफलतापूर्वक बनाया गया!')
                : (Localizations.localeOf(context).languageCode == 'en'
                    ? 'Community request sent successfully! Admin approval required.'
                    : 'समुदाय निर्माण अनुरोध सफलतापूर्वक भेजा गया! एडमिन की स्वीकृति आवश्यक है।')),
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
    final user = context.watch<AuthProvider>().currentUserModel;
    final role = (user?.role ?? 'guest').toLowerCase();
    final isAdmin = role == 'admin' || role == 'superadmin';

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
              // Select Admin Dropdown
              Text(
                (isEnglish ? 'Select Community Admin' : 'समुदाय एडमिन चुनें') + ' *',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
              ),
              const SizedBox(height: 8),
              _isLoadingUsers
                  ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                  : DropdownButtonFormField<int>(
                      value: _selectedAdminId,
                      hint: Text(
                        isEnglish ? 'Select Admin' : 'एडमिन चुनें',
                        style: const TextStyle(color: ThemeConfig.textHint, fontSize: 13),
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: _users.map<DropdownMenuItem<int>>((user) {
                        final String name = user['full_name'] ?? '';
                        final String gotra = user['gotra'] ?? '';
                        final String displayName = gotra.isNotEmpty 
                            ? '$name ($gotra)' 
                            : name;
                        return DropdownMenuItem<int>(
                          value: user['id'] as int,
                          child: Text(
                            displayName,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedAdminId = val;
                        });
                      },
                      validator: (val) {
                        if (val == null) {
                          return isEnglish ? 'Admin is required' : 'एडमिन चुनना अनिवार्य है';
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
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConfig.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              isAdmin
                                  ? (isEnglish ? 'Create' : 'बनाएं')
                                  : (isEnglish ? 'Submit Request' : 'अनुरोध भेजें'),
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
