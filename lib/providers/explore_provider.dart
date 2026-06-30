import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/business_model.dart';

class ExploreProvider extends ChangeNotifier {
  List<BusinessModel> _businesses = [];
  bool _isLoading = false;
  String? _error;

  List<BusinessModel> get businesses => _businesses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBusinesses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final client = ApiClient().dio;
      final response = await client.get('/api/v1/businesses?page=1&per_page=20');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['success'] == true) {
          _businesses = (data['items'] as List)
              .map((e) => BusinessModel.fromJson(e))
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
