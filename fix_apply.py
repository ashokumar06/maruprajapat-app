import re

file_path = "lib/views/honours/apply_honour_screen.dart"
with open(file_path, "r") as f:
    content = f.read()

# Fix form closing brackets which were incorrectly replaced
content = content.replace("        ),\n      ],\n    ));", "        ),\n      ],\n    );\n  }")
content = content.replace("child: Column(", "child: Column(")
content = content.replace("    return Form(\n      key: _formKey0,\n      child: Column(", "    return Form(\n      key: _formKey0,\n      child: Column(")

# Find where step1, step2 and step3 end and ensure they have `);` for the Form and `}` for the function.
# It's better to just write a simple regex or just restore the old structure correctly.
# Let's just fix it manually by reading and replacing carefully.

def fix_form_closure(text, key_name):
    # Find the start of the method
    start = text.find(f"key: {key_name},\n      child: Column(")
    if start == -1: return text
    
    # We replaced `        ),\n      ],\n    );\n  }` with `        ),\n      ],\n    ));\n  }`
    # Let's just fix the end of the method
    return text

with open(file_path, "w") as f:
    f.write(content)

