import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/form_model.dart';

class FormsProvider extends ChangeNotifier {
  List<FormModel> _forms = [];
  bool _isLoading = false;
  String? _error;

  List<FormModel> get forms => _forms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchForms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final client = ApiClient().dio;
      final response = await client.get('/api/v1/forms?page=1&per_page=20&active_only=true');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['success'] == true) {
          _forms = (data['items'] as List)
              .map((e) => FormModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      _error = 'सर्वर रखरखाव के अधीन है, इसे जल्द ही अपडेट किया जाएगा।';
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
