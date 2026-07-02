import re

file_path = 'lib/views/home/create_event_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Add import
content = content.replace("import 'package:dio/dio.dart';", "import 'package:dio/dio.dart';\nimport 'package:html_editor_enhanced/html_editor.dart';")

# Add controller state
state_old = "  final _descController = TextEditingController();"
state_new = "  final HtmlEditorController _htmlController = HtmlEditorController();"
content = content.replace(state_old, state_new)

# Update _submit validation
val_old = "if (!_formKey.currentState!.validate()) return;"
val_new = """if (!_formKey.currentState!.validate()) return;
    final String description = await _htmlController.getText();
    if (description.isEmpty || description == '<p><br></p>') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया कार्यक्रम का विवरण लिखें')));
      return;
    }"""
content = content.replace(val_old, val_new)

# Update payload description
payload_old = "'description': _descController.text.trim(),"
payload_new = "'description': description.trim(),"
content = content.replace(payload_old, payload_new)

# Update post format
post_old = "'विवरण: $desc';"
post_new = "'विवरण: (Rich Text Details)'; // Simplified for post"
content = content.replace(post_old, post_new)

# Update UI for Description
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
                          color: Colors.white,
                          border: Border.all(color: ThemeConfig.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: HtmlEditor(
                          controller: _htmlController,
                          htmlEditorOptions: const HtmlEditorOptions(
                            hint: "कार्यक्रम का विवरण यहाँ लिखें...",
                            shouldEnsureVisible: true,
                          ),
                          htmlToolbarOptions: const HtmlToolbarOptions(
                            toolbarPosition: ToolbarPosition.aboveEditor,
                            toolbarType: ToolbarType.nativeScrollable,
                            defaultToolbarButtons: [
                              StyleButtons(),
                              FontSettingButtons(fontSizeUnit: false),
                              FontButtons(clearAll: false, strikethrough: false, subscript: false, superscript: false),
                              ColorButtons(),
                              ListButtons(listStyles: false),
                              ParagraphButtons(textDirection: false, lineHeight: false, caseConverter: false),
                              InsertButtons(video: false, audio: false, table: false, hr: false, otherFile: false),
                            ],
                          ),
                          otherOptions: OtherOptions(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: ThemeConfig.surface,
                            ),
                          ),
                        ),
                      ),"""
content = content.replace(desc_old, desc_new)

# _showPostPrompt update
prompt_old = "required String desc,"
prompt_new = ""
content = content.replace(prompt_old, prompt_new)

prompt_old2 = "desc: _descController.text.trim(),"
prompt_new2 = ""
content = content.replace(prompt_old2, prompt_new2)

with open(file_path, 'w') as f:
    f.write(content)
