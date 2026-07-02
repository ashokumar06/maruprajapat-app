import re

file_path = 'lib/views/home/create_event_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Remove quill imports
content = content.replace("import 'package:flutter_quill/flutter_quill.dart' as quill;\n", "")

# Remove quill state
content = content.replace("final quill.QuillController _quillController = quill.QuillController.basic();", "")

# Restore _submit validation
val_old = """if (!_formKey.currentState!.validate()) return;
    if (_quillController.document.isEmpty()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया कार्यक्रम का विवरण लिखें')));
      return;
    }"""
val_new = "if (!_formKey.currentState!.validate()) return;"
content = content.replace(val_old, val_new)

# Restore payload description
submit_old = "'description': jsonEncode(_quillController.document.toDelta().toJson()),"
submit_new = "'description': _descController.text.trim(),"
content = content.replace(submit_old, submit_new)

# Restore UI for description
desc_old = """                      Container(
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

desc_new = """                      TextFormField(
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
content = content.replace(desc_old, desc_new)

with open(file_path, 'w') as f:
    f.write(content)
