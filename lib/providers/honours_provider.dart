import 'package:flutter/material.dart';
import '../services/api_client.dart';

class BhamashahModel {
  final int id;
  final String name;
  final String? photoUrl;
  final String? details;
  final double? donationAmount;
  final bool isApproved;

  BhamashahModel({
    required this.id,
    required this.name,
    this.photoUrl,
    this.details,
    this.donationAmount,
    required this.isApproved,
  });

  factory BhamashahModel.fromJson(Map<String, dynamic> json) {
    return BhamashahModel(
      id: json['id'],
      name: json['name'],
      photoUrl: json['photo_url'],
      details: json['details'],
      donationAmount: json['donation_amount'] != null ? double.tryParse(json['donation_amount'].toString()) : null,
      isApproved: json['is_approved'] ?? false,
    );
  }
}

class PratibhaModel {
  final int id;
  final String name;
  final String? photoUrl;
  final String achievement;
  final String? details;
  final bool isApproved;

  PratibhaModel({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.achievement,
    this.details,
    required this.isApproved,
  });

  factory PratibhaModel.fromJson(Map<String, dynamic> json) {
    return PratibhaModel(
      id: json['id'],
      name: json['name'],
      photoUrl: json['photo_url'],
      achievement: json['achievement'],
      details: json['details'],
      isApproved: json['is_approved'] ?? false,
    );
  }
}

class HonoursProvider with ChangeNotifier {
  List<BhamashahModel> _bhamashahs = [];
  List<PratibhaModel> _pratibhas = [];
  bool _isLoading = false;

  List<BhamashahModel> get bhamashahs => _bhamashahs;
  List<PratibhaModel> get pratibhas => _pratibhas;
  bool get isLoading => _isLoading;

  Future<void> fetchHonours() async {
    _isLoading = true;
    notifyListeners();

    try {
      final client = ApiClient().dio;

      // Fetch Bhamashah
      final resBhamashah = await client.get('/api/v1/honours/bhamashah');
      if (resBhamashah.statusCode == 200) {
        final data = resBhamashah.data;
        if (data['success'] == true) {
          _bhamashahs = (data['items'] as List).map((i) => BhamashahModel.fromJson(i)).toList();
        }
      }

      // Fetch Pratibha
      final resPratibha = await client.get('/api/v1/honours/pratibha');
      if (resPratibha.statusCode == 200) {
        final data = resPratibha.data;
        if (data['success'] == true) {
          _pratibhas = (data['items'] as List).map((i) => PratibhaModel.fromJson(i)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching honours: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyBhamashah(Map<String, dynamic> data) async {
    try {
      final client = ApiClient().dio;
      final res = await client.post(
        '/api/v1/honours/bhamashah',
        data: data,
      );
      if (res.statusCode == 201) {
        await fetchHonours();
        return true;
      }
    } catch (e) {
      debugPrint('Error applying bhamashah: $e');
    }
    return false;
  }

  Future<bool> applyPratibha(Map<String, dynamic> data) async {
    try {
      final client = ApiClient().dio;
      final res = await client.post(
        '/api/v1/honours/pratibha',
        data: data,
      );
      if (res.statusCode == 201) {
        await fetchHonours();
        return true;
      }
    } catch (e) {
      debugPrint('Error applying pratibha: $e');
    }
    return false;
  }
}
