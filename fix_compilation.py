import re

# Fix create_event_screen.dart
file_path = 'lib/views/home/create_event_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Fix constructor
const_old = """class CreateEventScreen extends StatefulWidget {
  final int? communityId;

  const CreateEventScreen({
    super.key,
    this.communityId,
  });"""
const_new = """class CreateEventScreen extends StatefulWidget {
  final int? communityId;
  final EventModel? existingEvent;

  const CreateEventScreen({
    super.key,
    this.communityId,
    this.existingEvent,
  });"""
content = content.replace(const_old, const_new)

# Fix const Text issue
btn_old = "const Text(widget.existingEvent != null ? 'कार्यक्रम अपडेट करें' : 'नया कार्यक्रम जोड़ें'"
btn_new = "Text(widget.existingEvent != null ? 'कार्यक्रम अपडेट करें' : 'नया कार्यक्रम जोड़ें'"
content = content.replace(btn_old, btn_new)

# Another instance of const Text?
# Let's just use regex to remove const before Text(widget.existingEvent...
content = re.sub(r"const Text\(widget\.existingEvent !=", r"Text(widget.existingEvent !=", content)

with open(file_path, 'w') as f:
    f.write(content)

# Fix event_details_screen.dart
file_path2 = 'lib/views/home/event_details_screen.dart'
with open(file_path2, 'r') as f:
    content2 = f.read()

content2 = content2.replace("import '../../utils/api_client.dart';", "import '../../services/api_client.dart';")

with open(file_path2, 'w') as f:
    f.write(content2)
