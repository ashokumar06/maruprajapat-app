import re

file_path = 'lib/views/home/create_event_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Add initState
init_state = """
  @override
  void initState() {
    super.initState();
    if (widget.existingEvent != null) {
      final ev = widget.existingEvent!;
      _titleController.text = ev.title;
      _descController.text = ev.description?.replaceAll('<br>', '\\n') ?? '';
      _locController.text = ev.location ?? '';
      _eventType = ev.eventType;
      _selectedDate = ev.startDate;
      _selectedTime = TimeOfDay.fromDateTime(ev.startDate);
      // For cover image, we can't easily auto-fill a File, but we could handle the URL if we wanted to
    }
  }
"""
if "void initState()" not in content:
    content = content.replace("  @override\n  void dispose()", init_state + "\n  @override\n  void dispose()")

# Update submit logic
old_submit_post = "final response = await dio.post('/api/v1/events/', data: payload);"
new_submit = """
      Response response;
      if (widget.existingEvent != null) {
        response = await dio.put('/api/v1/events/${widget.existingEvent!.id}', data: payload);
      } else {
        response = await dio.post('/api/v1/events/', data: payload);
      }
"""
content = content.replace(old_submit_post, new_submit)

# Update success status check since PUT returns 200, POST returns 201
old_success = "if (response.statusCode == 201 && mounted) {"
new_success = "if ((response.statusCode == 200 || response.statusCode == 201) && mounted) {"
content = content.replace(old_success, new_success)

with open(file_path, 'w') as f:
    f.write(content)

