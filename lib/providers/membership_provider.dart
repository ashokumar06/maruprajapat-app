import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/membership_model.dart';

class MembershipProvider extends ChangeNotifier {
  List<MembershipRequestModel> _myRequests = [];
  bool _isLoading = false;
  String? _error;

  List<MembershipRequestModel> get myRequests => _myRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MembershipRequestModel? get latestRequest {
    if (_myRequests.isEmpty) return null;
    return _myRequests.first;
  }

  Future<void> fetchMyRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final client = ApiClient().dio;
      final response = await client.get('/api/v1/memberships/my?page=1&per_page=5');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['success'] == true) {
          _myRequests = (data['items'] as List)
              .map((e) => MembershipRequestModel.fromJson(e))
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

  Future<bool> applyForMembership(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final client = ApiClient().dio;
      final response = await client.post('/api/v1/memberships/apply', data: data);

      if (response.statusCode == 201) {
        await fetchMyRequests();
        return true;
      }
    } catch (e) {
      _error = 'सर्वर रखरखाव के अधीन है, इसे जल्द ही अपडेट किया जाएगा।';
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}
