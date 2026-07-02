import re

file_path = 'lib/views/home/event_details_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Add import
content = content.replace("import '../../models/event_model.dart';", "import '../../models/event_model.dart';\nimport 'package:flutter_widget_from_html/flutter_widget_from_html.dart';")

# Update description display
desc_old = """              Text(
                event.description ?? 'कोई विवरण प्रदान नहीं किया गया है।',
                style: const TextStyle(fontSize: 13, color: ThemeConfig.textSecondary, height: 1.45),
              ),"""

desc_new = """              HtmlWidget(
                event.description ?? 'कोई विवरण प्रदान नहीं किया गया है।',
                textStyle: const TextStyle(fontSize: 13, color: ThemeConfig.textSecondary, height: 1.45),
              ),"""

content = content.replace(desc_old, desc_new)

with open(file_path, 'w') as f:
    f.write(content)
