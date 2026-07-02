import re

file_path = 'lib/views/home/create_event_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Remove html editor imports and add TextEditingController back
content = content.replace("import 'package:html_editor_enhanced/html_editor.dart';", "")
content = content.replace("  final HtmlEditorController _htmlController = HtmlEditorController();", "  final _descController = TextEditingController();\n\n  void _insertHtmlTag(String startTag, String endTag) {\n    final text = _descController.text;\n    final selection = _descController.selection;\n    if (selection.isValid && selection.start >= 0 && selection.end >= 0) {\n      final start = selection.start;\n      final end = selection.end;\n      final selectedText = text.substring(start, end);\n      final newText = text.replaceRange(start, end, '$startTag$selectedText$endTag');\n      _descController.value = TextEditingValue(\n        text: newText,\n        selection: TextSelection.collapsed(offset: start + startTag.length + selectedText.length + endTag.length),\n      );\n    } else {\n      final newText = text + '$startTag$endTag';\n      _descController.value = TextEditingValue(\n        text: newText,\n        selection: TextSelection.collapsed(offset: newText.length),\n      );\n    }\n  }")

# Restore submit validation
val_old = """if (!_formKey.currentState!.validate()) return;
    final String description = await _htmlController.getText();
    if (description.isEmpty || description == '<p><br></p>') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया कार्यक्रम का विवरण लिखें')));
      return;
    }"""
val_new = "if (!_formKey.currentState!.validate()) return;"
content = content.replace(val_old, val_new)

# Restore payload
payload_old = "'description': description.trim(),"
payload_new = "'description': _descController.text.trim().replaceAll('\\n', '<br>'),"
content = content.replace(payload_old, payload_new)

# Replace the HTML editor UI with the custom toolbar and textfield
ui_old = """                      Container(
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

ui_new = """                      Container(
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
                      ),"""
content = content.replace(ui_old, ui_new)

with open(file_path, 'w') as f:
    f.write(content)
