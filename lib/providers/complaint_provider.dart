import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../services/api_client.dart';

class ComplaintProvider extends ChangeNotifier {
  List<ComplaintModel> _myComplaints = [];
  List<ComplaintModel> _allComplaints = [];
  ComplaintModel? _selectedComplaint;
  bool _isLoading = false;
  String? _error;
  Map<String, int> _stats = {};

  List<ComplaintModel> get myComplaints => _myComplaints;
  List<ComplaintModel> get allComplaints => _allComplaints;
  ComplaintModel? get selectedComplaint => _selectedComplaint;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, int> get stats => _stats;

  Future<void> fetchMyComplaints({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final dio = ApiClient().dio;
      String url = '/api/v1/complaints/my?per_page=50';
      if (status != null) url += '&status=$status';
      final r = await dio.get(url);
      if (r.statusCode == 200) {
        final items = (r.data['items'] as List?) ?? [];
        _myComplaints = items.map((e) => ComplaintModel.fromJson(e)).toList();
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllComplaints({String? status, String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final dio = ApiClient().dio;
      String url = '/api/v1/complaints/?per_page=50';
      if (status != null) url += '&status=$status';
      if (category != null) url += '&category=$category';
      final r = await dio.get(url);
      if (r.statusCode == 200) {
        final items = (r.data['items'] as List?) ?? [];
        _allComplaints = items.map((e) => ComplaintModel.fromJson(e)).toList();
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<ComplaintModel?> fetchDetail(int id) async {
    try {
      final dio = ApiClient().dio;
      final r = await dio.get('/api/v1/complaints/$id');
      if (r.statusCode == 200) {
        _selectedComplaint = ComplaintModel.fromJson(r.data);
        notifyListeners();
        return _selectedComplaint;
      }
    } catch (e) {
      _error = e.toString();
    }
    return null;
  }

  Future<ComplaintModel?> submitComplaint({
    required String title,
    required String description,
    required String category,
    String? location,
    List<String>? imageUrls,
  }) async {
    try {
      final dio = ApiClient().dio;
      final r = await dio.post('/api/v1/complaints/', data: {
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'image_urls': imageUrls,
      });
      if (r.statusCode == 201) {
        final c = ComplaintModel.fromJson(r.data);
        _myComplaints.insert(0, c);
        notifyListeners();
        return c;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<bool> cancelComplaint(int id, String reason) async {
    try {
      final dio = ApiClient().dio;
      final r = await dio.post('/api/v1/complaints/$id/cancel', data: {'reason': reason});
      if (r.statusCode == 200) {
        await fetchMyComplaints();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }
    return false;
  }

  Future<bool> updateStatus(int id, String status, {String? note}) async {
    try {
      final dio = ApiClient().dio;
      final r = await dio.patch('/api/v1/complaints/$id/status', data: {
        'status': status,
        'resolution_note': note,
      });
      if (r.statusCode == 200) {
        await fetchAllComplaints();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }
    return false;
  }

  Future<void> fetchStats() async {
    try {
      final dio = ApiClient().dio;
      final r = await dio.get('/api/v1/complaints/stats/summary');
      if (r.statusCode == 200) {
        _stats = Map<String, int>.from(r.data.map((k, v) => MapEntry(k, v as int)));
        notifyListeners();
      }
    } catch (_) {}
  }
}
