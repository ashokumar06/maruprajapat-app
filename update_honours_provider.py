import re

file_path = 'lib/providers/honours_provider.dart'

new_models = """class BhamashahModel {
  final int id;
  final String name;
  final String? fatherHusbandName;
  final String? dob;
  final String? address;
  final String? district;
  final String? mobileNumber;
  final String? email;
  final String? photoUrl;
  final String? details;
  final double? donationAmount;
  final String status;

  BhamashahModel({
    required this.id,
    required this.name,
    this.fatherHusbandName,
    this.dob,
    this.address,
    this.district,
    this.mobileNumber,
    this.email,
    this.photoUrl,
    this.details,
    this.donationAmount,
    required this.status,
  });

  factory BhamashahModel.fromJson(Map<String, dynamic> json) {
    return BhamashahModel(
      id: json['id'],
      name: json['name'],
      fatherHusbandName: json['father_husband_name'],
      dob: json['dob'],
      address: json['address'],
      district: json['district'],
      mobileNumber: json['mobile_number'],
      email: json['email'],
      photoUrl: json['photo_url'],
      details: json['details'],
      donationAmount: json['donation_amount'] != null ? double.tryParse(json['donation_amount'].toString()) : null,
      status: json['status'] ?? 'pending',
    );
  }
}

class PratibhaModel {
  final int id;
  final String name;
  final String? fatherHusbandName;
  final String? dob;
  final String? address;
  final String? district;
  final String? mobileNumber;
  final String? email;
  final String category;
  final String? photoUrl;
  final String achievement;
  final String? year;
  final String? instituteDept;
  final String? rankPlace;
  final String? location;
  final String? details;
  final String status;

  PratibhaModel({
    required this.id,
    required this.name,
    this.fatherHusbandName,
    this.dob,
    this.address,
    this.district,
    this.mobileNumber,
    this.email,
    required this.category,
    this.photoUrl,
    required this.achievement,
    this.year,
    this.instituteDept,
    this.rankPlace,
    this.location,
    this.details,
    required this.status,
  });

  factory PratibhaModel.fromJson(Map<String, dynamic> json) {
    return PratibhaModel(
      id: json['id'],
      name: json['name'],
      fatherHusbandName: json['father_husband_name'],
      dob: json['dob'],
      address: json['address'],
      district: json['district'],
      mobileNumber: json['mobile_number'],
      email: json['email'],
      category: json['category'] ?? 'Anya',
      photoUrl: json['photo_url'],
      achievement: json['achievement'] ?? '',
      year: json['year'],
      instituteDept: json['institute_dept'],
      rankPlace: json['rank_place'],
      location: json['location'],
      details: json['details'],
      status: json['status'] ?? 'pending',
    );
  }
}
"""

with open(file_path, 'r') as f:
    content = f.read()

# Replace existing models
pattern = r"class BhamashahModel.*?class HonoursProvider with ChangeNotifier \{"
content = re.sub(pattern, new_models + "\nclass HonoursProvider with ChangeNotifier {", content, flags=re.DOTALL)

# Add admin dashboard fetching and category parameter
provider_replacement = """  List<BhamashahModel> _bhamashahs = [];
  List<PratibhaModel> _pratibhas = [];
  Map<String, dynamic>? _adminDashboard;
  bool _isLoading = false;

  List<BhamashahModel> get bhamashahs => _bhamashahs;
  List<PratibhaModel> get pratibhas => _pratibhas;
  Map<String, dynamic>? get adminDashboard => _adminDashboard;
  bool get isLoading => _isLoading;

  Future<void> fetchHonours({String? category}) async {
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
      String pratibhaUrl = '/api/v1/honours/pratibha';
      if (category != null && category.isNotEmpty && category != 'सभी') {
        pratibhaUrl += '?category=$category';
      }
      final resPratibha = await client.get(pratibhaUrl);
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
  
  Future<void> fetchAdminDashboard() async {
    try {
      final client = ApiClient().dio;
      final res = await client.get('/api/v1/honours/admin/dashboard');
      if (res.statusCode == 200 && res.data['success'] == true) {
        _adminDashboard = res.data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching admin dashboard: $e');
    }
  }"""

pattern2 = r"  List<BhamashahModel> _bhamashahs = \[\];.*?Future<void> fetchHonours\(\) async \{.*?\}.*?notifyListeners\(\);\n    \}\n  \}"
content = re.sub(pattern2, provider_replacement, content, flags=re.DOTALL)

with open(file_path, 'w') as f:
    f.write(content)

