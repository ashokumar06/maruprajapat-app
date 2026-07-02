import re

file_path = 'lib/views/home/create_event_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Add dio import
if "package:dio/dio.dart" not in content:
    content = content.replace("import 'package:image_picker/image_picker.dart';", "import 'package:image_picker/image_picker.dart';\nimport 'package:dio/dio.dart';")

# Add upload logic to _submit
submit_old = """      final dio = ApiClient().dio;
      final payload = {"""
submit_new = """      final dio = ApiClient().dio;
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

      final payload = {"""
content = content.replace(submit_old, submit_new)

payload_old = "'cover_image_url': null,"
if payload_old in content:
    content = content.replace(payload_old, "'cover_image_url': coverImageUrl,")
else:
    # Let's insert it if it's missing
    content = content.replace("'end_date': combinedStart.add(const Duration(hours: 3)).toUtc().toIso8601String(),", "'end_date': combinedStart.add(const Duration(hours: 3)).toUtc().toIso8601String(),\n        'cover_image_url': coverImageUrl,")

# Also fix the form validation for the desc quill editor. Since we removed _descController from the TextFormField (replaced with QuillEditor), the form validation might fail if the formKey is checking the TextFormField which we removed. Wait, did we remove the TextFormField? Yes, we replaced it. The form validation will just skip it. Let's make sure _submit doesn't fail.
val_old = "if (!_formKey.currentState!.validate()) return;"
val_new = "if (!_formKey.currentState!.validate()) return;\n    if (_quillController.document.isEmpty()) {\n      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया कार्यक्रम का विवरण लिखें')));\n      return;\n    }"
content = content.replace(val_old, val_new)

with open(file_path, 'w') as f:
    f.write(content)
