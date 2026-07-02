import re

file_path = 'lib/views/home/create_event_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Add imports
content = content.replace("import '../../providers/news_provider.dart';", "import '../../providers/news_provider.dart';\nimport 'dart:io';\nimport 'dart:convert';\nimport 'package:image_picker/image_picker.dart';\nimport 'package:flutter_quill/flutter_quill.dart' as quill;")

# Add state variables
content = content.replace("  final _descController = TextEditingController();", "  final _descController = TextEditingController();\n  File? _selectedImage;\n  final ImagePicker _picker = ImagePicker();\n  final quill.QuillController _quillController = quill.QuillController.basic();")

# Add pick image method
pick_image_method = """
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
"""
content = content.replace("  Future<void> _pickDate() async {", pick_image_method + "\n  Future<void> _pickDate() async {")

# Update image picker UI
image_ui_old = """                      // Image Upload Area (Dashed Mock container matching Screen 5)
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: ThemeConfig.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ThemeConfig.border,
                            style: BorderStyle.solid, // solid fallback
                            width: 1.5,
                          ),
                        ),
                        child: Column(
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
                              'JPG, PNG (Max 5MB)',
                              style: TextStyle(fontSize: 11, color: ThemeConfig.textHint),
                            ),
                          ],
                        ),
                      ),"""

image_ui_new = """                      // Image Upload Area
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
                      ),"""
content = content.replace(image_ui_old, image_ui_new)

# Update description field to quill
desc_old = """                      TextFormField(
                        controller: _descController,
                        validator: (v) => v == null || v.isEmpty ? 'कृपया कार्यक्रम का विवरण लिखें' : null,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'कार्यक्रम का विवरण लिखें',
                          hintStyle: const TextStyle(color: ThemeConfig.textHint, fontSize: 13),
                          filled: true,
                          fillColor: ThemeConfig.surface,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeConfig.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeConfig.border)),
                        ),
                      ),"""

desc_new = """                      Container(
                        decoration: BoxDecoration(
                          color: ThemeConfig.surface,
                          border: Border.all(color: ThemeConfig.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            quill.QuillSimpleToolbar(
                              controller: _quillController,
                              configurations: const quill.QuillSimpleToolbarConfigurations(
                                showFontFamily: false,
                                showFontSize: false,
                                showListCheck: false,
                                showCodeBlock: false,
                                showInlineCode: false,
                                showColorButton: false,
                                showBackgroundColorButton: false,
                                showClearFormat: false,
                                showHeaderStyle: false,
                                showQuote: false,
                                showSearchButton: false,
                                showSubscript: false,
                                showSuperscript: false,
                              ),
                            ),
                            const Divider(height: 1, thickness: 1, color: ThemeConfig.border),
                            Container(
                              height: 150,
                              padding: const EdgeInsets.all(12),
                              child: quill.QuillEditor.basic(
                                controller: _quillController,
                                configurations: const quill.QuillEditorConfigurations(
                                  placeholder: 'कार्यक्रम का विवरण यहाँ लिखें...',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),"""
content = content.replace(desc_old, desc_new)

# Update submit method description payload
submit_old = "'description': _descController.text.trim(),"
submit_new = "'description': jsonEncode(_quillController.document.toDelta().toJson()),"
content = content.replace(submit_old, submit_new)

with open(file_path, 'w') as f:
    f.write(content)
