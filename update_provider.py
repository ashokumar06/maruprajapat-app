file_path = "lib/providers/honours_provider.dart"

with open(file_path, "r") as f:
    content = f.read()

new_methods = """
  Future<bool> updateBhamashah(int id, Map<String, dynamic> data) async {
    try {
      final client = ApiClient().dio;
      final res = await client.put(
        '/api/v1/honours/bhamashah/$id',
        data: data,
      );
      if (res.statusCode == 200) {
        await fetchHonours();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating bhamashah: $e');
    }
    return false;
  }

  Future<bool> deleteBhamashah(int id) async {
    try {
      final client = ApiClient().dio;
      final res = await client.delete('/api/v1/honours/bhamashah/$id');
      if (res.statusCode == 200) {
        await fetchHonours();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting bhamashah: $e');
    }
    return false;
  }

  Future<bool> updatePratibha(int id, Map<String, dynamic> data) async {
    try {
      final client = ApiClient().dio;
      final res = await client.put(
        '/api/v1/honours/pratibha/$id',
        data: data,
      );
      if (res.statusCode == 200) {
        await fetchHonours();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating pratibha: $e');
    }
    return false;
  }

  Future<bool> deletePratibha(int id) async {
    try {
      final client = ApiClient().dio;
      final res = await client.delete('/api/v1/honours/pratibha/$id');
      if (res.statusCode == 200) {
        await fetchHonours();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting pratibha: $e');
    }
    return false;
  }
}
"""

content = content.replace("}\n", "}\n" + new_methods)
# Fix potential double class closure by replacing the last brace
content = content[:content.rfind('}')] + new_methods

with open(file_path, "w") as f:
    f.write(content)

print("Provider updated.")
