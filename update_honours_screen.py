import re

file_path = "lib/views/honours/honours_screen.dart"
with open(file_path, "r") as f:
    content = f.read()

# Pass isAdmin to tabs
content = content.replace("_buildBhamashahTab(provider.bhamashahs),", "_buildBhamashahTab(provider.bhamashahs, isAdmin),")
content = content.replace("_buildPratibhaTab(provider.pratibhas),", "_buildPratibhaTab(provider.pratibhas, isAdmin),")

# Update Bhamashah signature
content = content.replace("Widget _buildBhamashahTab(List<BhamashahModel> list) {", "Widget _buildBhamashahTab(List<BhamashahModel> list, bool isAdmin) {")

# Add PopupMenu to Bhamashah
bhamashah_chevron = "const Icon(Icons.chevron_right, color: ThemeConfig.textHint),"
bhamashah_menu = """isAdmin ? PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: ThemeConfig.textHint),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          // TODO: Edit
                        } else if (value == 'delete') {
                          bool success = await context.read<HonoursProvider>().deleteBhamashah(item.id);
                          if (success && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('भामाशाह हटा दिया गया')));
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('एडिट करें')),
                        const PopupMenuItem(value: 'delete', child: Text('डिलीट करें', style: TextStyle(color: Colors.red))),
                      ],
                    ) : const Icon(Icons.chevron_right, color: ThemeConfig.textHint),"""
content = content.replace(bhamashah_chevron, bhamashah_menu)

# Update Pratibha signature
content = content.replace("Widget _buildPratibhaTab(List<PratibhaModel> list) {", "Widget _buildPratibhaTab(List<PratibhaModel> list, bool isAdmin) {")

# Add PopupMenu to Pratibha
pratibha_chevron = "const Icon(Icons.chevron_right, color: ThemeConfig.textHint),"
pratibha_menu = """isAdmin ? PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: ThemeConfig.textHint),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          // TODO: Edit
                        } else if (value == 'delete') {
                          bool success = await context.read<HonoursProvider>().deletePratibha(item.id);
                          if (success && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('प्रतिभा हटा दी गई')));
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('एडिट करें')),
                        const PopupMenuItem(value: 'delete', child: Text('डिलीट करें', style: TextStyle(color: Colors.red))),
                      ],
                    ) : const Icon(Icons.chevron_right, color: ThemeConfig.textHint),"""
content = content.replace(pratibha_chevron, pratibha_menu)

with open(file_path, "w") as f:
    f.write(content)

print("Updated honours screen")
