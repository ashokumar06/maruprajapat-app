import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme_config.dart';
import '../../providers/news_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../services/api_client.dart';
import '../widgets/inline_youtube_player.dart';
import '../widgets/post_content_view.dart';

class CreatePostScreen extends StatefulWidget {
  final PostModel? postToEdit;
  const CreatePostScreen({super.key, this.postToEdit});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _locationController = TextEditingController();

  // Secondary screen controllers
  final _photoDescController = TextEditingController();
  final _ytTitleController = TextEditingController();
  final _ytDescController = TextEditingController();
  final _pollQuestionController = TextEditingController();

  File? _selectedImage;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;

  // Screen state machine: 0 = Main Form, 1 = Photo Config, 2 = YouTube Config, 3 = Poll Config, 4 = Preview
  int _currentStep = 0;

  // Selected Type
  String _selectedPostType = 'text'; // 'text', 'poll', 'achievement', 'event'

  // Pinned toggle (Admins only)
  bool _isPinned = false;

  // Coordinates
  double? _latitude;
  double? _longitude;

  // Poll options
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(text: 'पूर्ण समर्थन'),
    TextEditingController(text: 'आर्थिक सहयोग'),
  ];
  bool _pollAllowMultiple = false;
  DateTime _pollExpiryDate = DateTime.now().add(const Duration(days: 5));

  // Emoji/Feeling
  String? _selectedFeeling;

  // Aspect ratio selected for photo
  String _selectedAspectRatio = 'free';

  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.postToEdit != null) {
      final post = widget.postToEdit!;
      String content = post.textContent ?? '';
      if (content.contains('\n\n')) {
        final idx = content.indexOf('\n\n');
        _titleController.text = content.substring(0, idx);
        _contentController.text = content.substring(idx + 2);
      } else {
        _contentController.text = content;
      }
      _selectedPostType = post.postType;
      _locationController.text = post.locationName ?? '';
      _latitude = post.latitude;
      _longitude = post.longitude;
      _youtubeController.text = post.youtubeUrl ?? '';
      _isPinned = post.isPinned;
      _existingImageUrl = post.mediaUrl;
    } else {
      _loadLocalDraft();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _youtubeController.dispose();
    _locationController.dispose();
    _photoDescController.dispose();
    _ytTitleController.dispose();
    _ytDescController.dispose();
    _pollQuestionController.dispose();
    for (var c in _pollOptionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // --- Local Persistence (Auto-Save) ---
  Future<void> _loadLocalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _titleController.text = prefs.getString('draft_post_title') ?? '';
      _contentController.text = prefs.getString('draft_post_content') ?? '';
      _selectedPostType = prefs.getString('draft_post_type') ?? 'text';
      _locationController.text = prefs.getString('draft_post_location') ?? '';
      _latitude = prefs.getDouble('draft_post_lat');
      _longitude = prefs.getDouble('draft_post_lng');
      _youtubeController.text = prefs.getString('draft_post_youtube') ?? '';
      _selectedFeeling = prefs.getString('draft_post_feeling');

      // Secondary fields
      _photoDescController.text =
          prefs.getString('draft_post_photo_desc') ?? '';
      _ytTitleController.text = prefs.getString('draft_post_yt_title') ?? '';
      _ytDescController.text = prefs.getString('draft_post_yt_desc') ?? '';
      _pollQuestionController.text = prefs.getString('draft_post_poll_q') ?? '';
      _isPinned = prefs.getBool('draft_post_pinned') ?? false;

      // Load poll options if saved
      final savedOptions = prefs.getStringList('draft_post_poll_options');
      if (savedOptions != null && savedOptions.isNotEmpty) {
        for (var c in _pollOptionControllers) {
          c.dispose();
        }
        _pollOptionControllers.clear();
        for (var opt in savedOptions) {
          _pollOptionControllers.add(TextEditingController(text: opt));
        }
      }
    });
  }

  Future<void> _saveLocalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_post_title', _titleController.text);
    await prefs.setString('draft_post_content', _contentController.text);
    await prefs.setString('draft_post_type', _selectedPostType);
    await prefs.setString('draft_post_location', _locationController.text);
    if (_latitude != null) {
      await prefs.setDouble('draft_post_lat', _latitude!);
    }
    if (_longitude != null) {
      await prefs.setDouble('draft_post_lng', _longitude!);
    }
    await prefs.setString('draft_post_youtube', _youtubeController.text);

    if (_selectedFeeling != null) {
      await prefs.setString('draft_post_feeling', _selectedFeeling!);
    } else {
      await prefs.remove('draft_post_feeling');
    }

    await prefs.setString('draft_post_photo_desc', _photoDescController.text);
    await prefs.setString('draft_post_yt_title', _ytTitleController.text);
    await prefs.setString('draft_post_yt_desc', _ytDescController.text);
    await prefs.setString('draft_post_poll_q', _pollQuestionController.text);
    await prefs.setBool('draft_post_pinned', _isPinned);

    final optionsText = _pollOptionControllers.map((c) => c.text).toList();
    await prefs.setStringList('draft_post_poll_options', optionsText);
  }

  Future<void> _clearLocalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_post_title');
    await prefs.remove('draft_post_content');
    await prefs.remove('draft_post_type');
    await prefs.remove('draft_post_location');
    await prefs.remove('draft_post_lat');
    await prefs.remove('draft_post_lng');
    await prefs.remove('draft_post_youtube');
    await prefs.remove('draft_post_feeling');
    await prefs.remove('draft_post_photo_desc');
    await prefs.remove('draft_post_yt_title');
    await prefs.remove('draft_post_yt_desc');
    await prefs.remove('draft_post_poll_q');
    await prefs.remove('draft_post_pinned');
    await prefs.remove('draft_post_poll_options');
  }

  bool get _hasImage => _selectedImage != null;
  bool get _hasYoutube => _youtubeController.text.trim().isNotEmpty;

  // Auto quality reduction (Max 10 KB limit)
  Future<void> _pickImage() async {
    if (_hasYoutube) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'यूट्यूब वीडियो लिंक होने पर फोटो अपलोड नहीं की जा सकती।',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 60,
      );

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        int sizeBytes = await file.length();

        if (sizeBytes > 10 * 1024) {
          pickedFile = await ImagePicker().pickImage(
            source: ImageSource.gallery,
            maxWidth: 120,
            maxHeight: 120,
            imageQuality: 25,
          );
          if (pickedFile != null) {
            file = File(pickedFile.path);
            sizeBytes = await file.length();
          }
        }

        setState(() {
          _selectedImage = file;
          _currentStep = 1; // Transition to Photo Config screen!
        });
        _saveLocalDraft();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('फोटो चुनने में त्रुटि'),
            backgroundColor: ThemeConfig.error,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _existingImageUrl = null;
      _currentStep = 0;
    });
    _saveLocalDraft();
  }

  Future<String?> _uploadImage(File file) async {
    setState(() => _isUploadingImage = true);
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
      print('Error uploading image: $e');
    } finally {
      setState(() => _isUploadingImage = false);
    }
    return null;
  }

  void _insertFormat(String formatStart, [String formatEnd = '']) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    if (!selection.isValid) {
      _contentController.text = text + formatStart + formatEnd;
      _saveLocalDraft();
      return;
    }

    final start = selection.start;
    final end = selection.end;
    final selectedText = text.substring(start, end);
    final newText = text.replaceRange(
      start,
      end,
      '$formatStart$selectedText$formatEnd',
    );

    _contentController.text = newText;
    _contentController.selection = TextSelection.collapsed(
      offset:
          start + formatStart.length + selectedText.length + formatEnd.length,
    );
    _saveLocalDraft();
  }

  Future<void> _insertLink() async {
    final selectedText = _contentController.selection.isValid
        ? _contentController.selection
              .textInside(_contentController.text)
              .trim()
        : '';
    final linkTextController = TextEditingController(text: selectedText);
    final urlController = TextEditingController();

    final shouldInsert = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('लिंक जोड़ें'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: linkTextController,
                decoration: const InputDecoration(
                  labelText: 'लिंक टेक्स्ट',
                  hintText: 'उदा. समाज वेबसाइट',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://example.com',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('रद्द करें'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('जोड़ें'),
            ),
          ],
        );
      },
    );

    if (shouldInsert == true) {
      final label = linkTextController.text.trim();
      final url = urlController.text.trim();
      if (label.isNotEmpty && url.isNotEmpty) {
        final insertedText = '[$label]($url)';
        final text = _contentController.text;
        final selection = _contentController.selection;
        if (selection.isValid && selection.start >= 0 && selection.end >= 0) {
          final replacement = selectedText.isNotEmpty
              ? '[$selectedText]($url)'
              : insertedText;
          final newText = text.replaceRange(
            selection.start,
            selection.end,
            replacement,
          );
          _contentController.text = newText;
          _contentController.selection = TextSelection.collapsed(
            offset: selection.start + replacement.length,
          );
        } else {
          _contentController.text = '$text$insertedText';
          _contentController.selection = TextSelection.collapsed(
            offset: _contentController.text.length,
          );
        }
        _saveLocalDraft();
        setState(() {});
      }
    }

    linkTextController.dispose();
    urlController.dispose();
  }

  void _showLocationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'स्थान जोड़ें (Add Location)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'स्थान का नाम (उदा. Ramnagar, Barmer)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _latitude = 25.75;
                          _longitude = 71.38;
                          if (_locationController.text.isEmpty) {
                            _locationController.text = 'बाड़मेर, राजस्थान';
                          }
                        });
                        _saveLocalDraft();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('लाइव लोकेशन सेट की गई (बाड़मेर)'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.my_location),
                      label: const Text('लाइव लोकेशन'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final lat = _latitude ?? 25.75;
                        final lon = _longitude ?? 71.38;
                        final url = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('मैप पर देखें'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _saveLocalDraft();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.primary,
                ),
                child: const Text(
                  'सहेजें (Save)',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) => setState(() {}));
  }

  void _openYoutubeComposer() {
    if (_hasImage || _existingImageUrl != null) {
      setState(() {
        _selectedImage = null;
        _existingImageUrl = null;
      });
    }
    setState(() => _currentStep = 2);
  }

  void _showFeelingsDialog() {
    final feelings = [
      '😊 खुश',
      '😇 धन्य',
      '🎉 उत्साहित',
      '🤝 गर्व',
      '🙏 आभारी',
      '💔 दुखी',
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'अपनी भावना चुनें',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: feelings.map((f) {
                  return ChoiceChip(
                    label: Text(f),
                    selected: _selectedFeeling == f,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFeeling = selected ? f : null;
                      });
                      _saveLocalDraft();
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    ).then((_) => setState(() {}));
  }

  Future<void> _submitPost({required bool isDraft}) async {
    final content = _contentController.text.trim();
    final ytUrl = _youtubeController.text.trim();
    final title = _titleController.text.trim();
    final locationName = _locationController.text.trim();

    // Poll options logic
    List<String>? pollOptions;
    if (_selectedPostType == 'poll') {
      pollOptions = _pollOptionControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();
    }

    setState(() => _isSubmitting = true);

    try {
      String? uploadedUrl = _existingImageUrl;
      if (_selectedImage != null) {
        uploadedUrl = await _uploadImage(_selectedImage!);
        if (uploadedUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('फोटो अपलोड करने में विफल'),
                backgroundColor: ThemeConfig.error,
              ),
            );
          }
          setState(() => _isSubmitting = false);
          return;
        }
      }

      String finalPostType = _selectedPostType;
      if (_selectedPostType == 'text') {
        if (_selectedImage != null || _existingImageUrl != null) {
          finalPostType = 'image';
        } else if (ytUrl.isNotEmpty) {
          finalPostType = 'video';
        }
      }

      final resolvedMediaUrl = finalPostType == 'image' ? uploadedUrl : null;
      final resolvedYoutubeUrl = ytUrl.isNotEmpty ? ytUrl : null;

      if (mounted) {
        final newsProvider = Provider.of<NewsProvider>(context, listen: false);
        final success = widget.postToEdit != null
            ? await newsProvider.updatePost(
                widget.postToEdit!.id,
                text: title.isNotEmpty ? '$title\n\n$content' : content,
                mediaUrl: resolvedMediaUrl,
                isDraft: isDraft,
                youtubeUrl: resolvedYoutubeUrl,
                isPinned: _isPinned,
                locationName: locationName.isNotEmpty ? locationName : null,
                latitude: _latitude,
                longitude: _longitude,
                pollOptions: pollOptions,
              )
            : await newsProvider.createPost(
                text: title.isNotEmpty ? '$title\n\n$content' : content,
                mediaUrl: resolvedMediaUrl,
                isDraft: isDraft,
                youtubeUrl: resolvedYoutubeUrl,
                postType: finalPostType,
                isPinned: _isPinned,
                locationName: locationName.isNotEmpty ? locationName : null,
                latitude: _latitude,
                longitude: _longitude,
                pollOptions: pollOptions,
              );

        if (success && mounted) {
          // Success: Clear local draft persistent storage!
          await _clearLocalDraft();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isDraft
                    ? 'ड्राफ्ट सहेज लिया गया है।'
                    : 'पोस्ट सफलतापूर्वक प्रकाशित हो गई है।',
              ),
              backgroundColor: ThemeConfig.success,
            ),
          );
          Navigator.pop(context);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('पोस्ट सहेजने/प्रकाशित करने में विफल।'),
                backgroundColor: ThemeConfig.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('कोई त्रुटि आई।'),
            backgroundColor: ThemeConfig.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // --- Step Screen Layouts ---

  // STEP 0: Main Compose Screen
  Widget _buildMainFormScreen(UserModel? user, bool isAdmin) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text(
          'पोस्ट बनाएं',
          style: TextStyle(
            color: ThemeConfig.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeConfig.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                setState(() => _currentStep = 4); // Go to Preview Screen!
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'अगला (Preview)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile row
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.orange.shade100,
                    backgroundImage:
                        user?.profilePhotoUrl != null &&
                            user!.profilePhotoUrl.isNotEmpty
                        ? NetworkImage(user.profilePhotoUrl)
                        : null,
                    child:
                        user?.profilePhotoUrl == null ||
                            user!.profilePhotoUrl.isEmpty
                        ? const Icon(Icons.person, color: ThemeConfig.primary)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user?.fullName ?? 'गजेंद्र कुमार प्रजापत',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user?.role == 'admin' ? 'एडमिन' : 'सदस्य',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Visibility Dropdown Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.public,
                                size: 13,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'सार्वजनिक',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'आप क्या साझा करना चाहते हैं?',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Dynamic Tab Selector Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTypeTab('text', Icons.article_outlined, 'समाचार'),
                    _buildTypeTab('poll', Icons.poll_outlined, 'पोल'),
                    _buildTypeTab(
                      'achievement',
                      Icons.campaign_outlined,
                      'घोषणा',
                    ),
                    _buildTypeTab(
                      'event',
                      Icons.calendar_month_outlined,
                      'कार्यक्रम',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        maxLength: 100,
                        onChanged: (val) => _saveLocalDraft(),
                        decoration: const InputDecoration(
                          hintText: 'शीर्षक (वैकल्पिक)',
                          hintStyle: TextStyle(color: ThemeConfig.textHint),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                      ),
                    ),
                    Text(
                      '${_titleController.text.length}/100',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Description Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _contentController,
                      minLines: 5,
                      maxLines: 10,
                      maxLength: 2000,
                      onChanged: (val) => _saveLocalDraft(),
                      decoration: const InputDecoration(
                        hintText: 'विवरण लिखें... (bold, list, link support)',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: ThemeConfig.textHint),
                        counterText: '',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${_contentController.text.length}/2000',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    // Formatting Toolbar
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.format_bold,
                              size: 20,
                              color: ThemeConfig.textSecondary,
                            ),
                            onPressed: () => _insertFormat('**', '**'),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.format_italic,
                              size: 20,
                              color: ThemeConfig.textSecondary,
                            ),
                            onPressed: () => _insertFormat('*', '*'),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.format_list_bulleted,
                              size: 20,
                              color: ThemeConfig.textSecondary,
                            ),
                            onPressed: () => _insertFormat('\n- '),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.link,
                              size: 20,
                              color: ThemeConfig.textSecondary,
                            ),
                            onPressed: _insertLink,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Media Picker Section Title
              const Text(
                'मीडिया (एक चुनें)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: ThemeConfig.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              // Media Row Boxes
              Row(
                children: [
                  _buildMediaBox(
                    'फोटो',
                    Icons.photo_outlined,
                    Colors.orange,
                    _pickImage,
                    _hasImage,
                  ),
                  const SizedBox(width: 12),
                  _buildMediaBox(
                    'YouTube',
                    Icons.play_circle_fill_outlined,
                    Colors.red,
                    _openYoutubeComposer,
                    _hasYoutube,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Other Options Pills
              const Text(
                'अन्य विकल्प',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: ThemeConfig.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  _buildOtherOptionButton(
                    'स्थान जोड़ें',
                    Icons.location_on_outlined,
                    Colors.blue,
                    _showLocationDialog,
                  ),
                  const SizedBox(width: 12),
                  _buildOtherOptionButton(
                    'भावना / इमोजी',
                    Icons.sentiment_satisfied_alt,
                    Colors.green,
                    _showFeelingsDialog,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Pin toggle if Admin
              if (isAdmin) ...[
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'पोस्ट पिन करें (Pin Post)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'यह पोस्ट हमेशा सबसे ऊपर रहेगी',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _isPinned,
                    onChanged: (val) {
                      setState(() {
                        _isPinned = val;
                      });
                      _saveLocalDraft();
                    },
                    activeColor: ThemeConfig.primary,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Save Draft locally / Publish double buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _submitPost(isDraft: true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeConfig.primary,
                        side: const BorderSide(color: ThemeConfig.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('ड्राफ्ट सहेजें (Save Draft)'),
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

  // STEP 1: Photo config screen
  Widget _buildPhotoConfigScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text(
          'फोटो चुनें',
          style: TextStyle(
            color: ThemeConfig.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeConfig.textPrimary),
          onPressed: () => setState(() => _currentStep = 0),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () => setState(() => _currentStep = 0),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'अगला',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedImage != null || _existingImageUrl != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            height: 260,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            _existingImageUrl!,
                            height: 260,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.6),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _removeImage,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),

            // Mock thumbnails
            Row(
              children: [
                if (_selectedImage != null)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: ThemeConfig.primary, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else if (_existingImageUrl != null)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: ThemeConfig.primary, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(_existingImageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'केवल एक फोटो या वीडियो चुन सकते हैं   1/1',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Photo description field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _photoDescController,
                      maxLength: 200,
                      onChanged: (val) => _saveLocalDraft(),
                      decoration: const InputDecoration(
                        hintText: 'फोटो विवरण (वैकल्पिक)',
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),
                  Text(
                    '${_photoDescController.text.length}/200',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'फोटो क्रॉप करें (वैकल्पिक)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['स्वतंत्र', '1:1', '16:9', '4:3', '3:4'].map((ratio) {
                final isSelected = _selectedAspectRatio == ratio;
                return ChoiceChip(
                  label: Text(ratio),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      _selectedAspectRatio = ratio;
                    });
                  },
                  selectedColor: Colors.orange.shade100,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: YouTube configure screen
  Widget _buildYoutubeConfigScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text(
          'YouTube लिंक जोड़ें',
          style: TextStyle(
            color: ThemeConfig.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeConfig.textPrimary),
          onPressed: () => setState(() => _currentStep = 0),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () => setState(() => _currentStep = 0),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.primary,
              ),
              child: const Text(
                'अगला',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'YouTube URL',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _youtubeController,
              onChanged: (val) {
                _saveLocalDraft();
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'https://youtu.be/9abcXYZ1234',
                border: const OutlineInputBorder(),
                suffixIcon: _youtubeController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            setState(() => _youtubeController.clear()),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Mock video preview
            if (_youtubeController.text.isNotEmpty) ...[
              InlineYoutubePlayer(
                videoUrl: _youtubeController.text.trim(),
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _ytTitleController,
              onChanged: (val) => _saveLocalDraft(),
              decoration: const InputDecoration(
                labelText: 'वीडियो शीर्षक (वैकल्पिक)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ytDescController,
              maxLines: 3,
              maxLength: 500,
              onChanged: (val) => _saveLocalDraft(),
              decoration: const InputDecoration(
                labelText: 'वीडियो विवरण (वैकल्पिक)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 3: Poll Configure Screen
  Widget _buildPollConfigScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text(
          'पोल बनाएं',
          style: TextStyle(
            color: ThemeConfig.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeConfig.textPrimary),
          onPressed: () => setState(() => _currentStep = 0),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () => setState(() => _currentStep = 0),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.primary,
              ),
              child: const Text(
                'अगला',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'पोल प्रश्न',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pollQuestionController,
              maxLength: 200,
              onChanged: (val) => _saveLocalDraft(),
              decoration: const InputDecoration(
                hintText: 'आप समाज भवन निर्माण के लिए क्या समर्थन देंगे?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'पोल विकल्प (अधिकतम 6)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(_pollOptionControllers.length, (idx) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _pollOptionControllers[idx],
                        onChanged: (val) => _saveLocalDraft(),
                        decoration: InputDecoration(
                          hintText: 'विकल्प ${idx + 1}',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    if (_pollOptionControllers.length > 2)
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () => setState(() {
                          _pollOptionControllers[idx].dispose();
                          _pollOptionControllers.removeAt(idx);
                          _saveLocalDraft();
                        }),
                      ),
                  ],
                ),
              );
            }),
            if (_pollOptionControllers.length < 6)
              TextButton.icon(
                onPressed: () => setState(() {
                  _pollOptionControllers.add(TextEditingController());
                  _saveLocalDraft();
                }),
                icon: const Icon(Icons.add),
                label: const Text('विकल्प जोड़ें'),
              ),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('एकाधिक चयन अनुमति दें'),
              value: _pollAllowMultiple,
              onChanged: (val) {
                setState(() => _pollAllowMultiple = val);
                _saveLocalDraft();
              },
              activeColor: ThemeConfig.primary,
            ),

            const SizedBox(height: 16),
            const Text(
              'पोल समाप्ति तिथि',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: ThemeConfig.primary,
              ),
              title: Text(
                '${_pollExpiryDate.day} जून ${_pollExpiryDate.year}, 11:59 PM',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _pollExpiryDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) {
                  setState(() {
                    _pollExpiryDate = picked;
                  });
                  _saveLocalDraft();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // STEP 4: Post Preview Screen
  Widget _buildPreviewScreen(UserModel? user) {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final locationName = _locationController.text.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text(
          'पोस्ट का पूर्वावलोकन',
          style: TextStyle(
            color: ThemeConfig.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeConfig.textPrimary),
          onPressed: () => setState(() => _currentStep = 0),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _currentStep = 0),
            child: const Text(
              'संपादित करें',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile info
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              user?.profilePhotoUrl != null &&
                                  user!.profilePhotoUrl.isNotEmpty
                              ? NetworkImage(user.profilePhotoUrl)
                              : null,
                          child:
                              user?.profilePhotoUrl == null ||
                                  user!.profilePhotoUrl.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user?.fullName ?? 'गजेंद्र कुमार प्रजापत',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'सदस्य',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'सार्वजनिक • अभी कुछ सेकंड पहले',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (title.isNotEmpty) ...[
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (content.isNotEmpty) ...[
                      PostContentView(
                        text: content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ThemeConfig.textPrimary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Media photo
                    if (_selectedImage != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ] else if (_existingImageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _existingImageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (_youtubeController.text.trim().isNotEmpty) ...[
                      InlineYoutubePlayer(
                        videoUrl: _youtubeController.text.trim(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Poll choices layout
                    if (_selectedPostType == 'poll') ...[
                      const Text(
                        'आपकी क्या राय है?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Mock options
                      _buildMockPollOption(
                        'हाँ, समर्थन करता हूँ',
                        68,
                        136,
                        true,
                      ),
                      _buildMockPollOption(
                        'हाँ, मैं सहयोग करूँगा',
                        25,
                        50,
                        false,
                      ),
                      _buildMockPollOption(
                        'अभी विचार कर रहा हूँ',
                        7,
                        14,
                        false,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'कुल वोट: 200 • समाप्ति: 25 जून 2025',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Location pill
                    if (locationName.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.orange.shade700,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            locationName,
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedFeeling != null) ...[
                            const SizedBox(width: 12),
                            Text(
                              '• महसूस कर रहे हैं ${_selectedFeeling!}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Divider(),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.thumb_up_outlined,
                            color: Colors.grey,
                          ),
                          label: const Text(
                            'लाइक',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.grey,
                          ),
                          label: const Text(
                            'टिप्पणी',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.share_outlined,
                            color: Colors.grey,
                          ),
                          label: const Text(
                            'शेयर',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () => _submitPost(isDraft: false),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'प्रकाशित करें (Publish)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockPollOption(
    String title,
    int percent,
    int count,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Stack(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? ThemeConfig.primary : Colors.grey.shade300,
              ),
            ),
          ),
          FractionallySizedBox(
            widthFactor: percent / 100,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: ThemeConfig.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '$percent% ($count)',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaBox(
    String label,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
    bool isActive,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? ThemeConfig.primary : Colors.grey.shade200,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: ThemeConfig.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherOptionButton(
    String label,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: iconColor, size: 18),
        label: Text(
          label,
          style: const TextStyle(color: ThemeConfig.textPrimary, fontSize: 12),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildTypeTab(String type, IconData icon, String label) {
    final isSelected = _selectedPostType == type;
    final color = isSelected ? Colors.white : Colors.grey.shade700;
    final bg = isSelected ? ThemeConfig.primary : Colors.white;
    final border = isSelected ? ThemeConfig.primary : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPostType = type;
            _saveLocalDraft();
            if (type == 'poll') {
              _currentStep = 3; // Open poll config directly!
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUserModel;
    final isAdmin = user?.role == 'admin';

    if (_isSubmitting || _isUploadingImage) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: ThemeConfig.primary),
              SizedBox(height: 16),
              Text(
                'सहेजा जा रहा है, कृपया प्रतीक्षा करें...',
                style: TextStyle(color: ThemeConfig.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return _buildBody(user, isAdmin);
  }

  Widget _buildBody(UserModel? user, bool isAdmin) {
    switch (_currentStep) {
      case 1:
        return _buildPhotoConfigScreen();
      case 2:
        return _buildYoutubeConfigScreen();
      case 3:
        return _buildPollConfigScreen();
      case 4:
        return _buildPreviewScreen(user);
      default:
        return _buildMainFormScreen(user, isAdmin);
    }
  }
}
