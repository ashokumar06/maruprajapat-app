import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme_config.dart';

class GalleryItem {
  final String id;
  final String titleEn;
  final String titleHi;
  final String categoryEn;
  final String categoryHi;
  final String imageUrl;
  final String author;
  final String date;

  GalleryItem({
    required this.id,
    required this.titleEn,
    required this.titleHi,
    required this.categoryEn,
    required this.categoryHi,
    required this.imageUrl,
    required this.author,
    required this.date,
  });
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Mock Gallery Data representing Prajapat/Maru Community
  final List<GalleryItem> _galleryItems = [
    GalleryItem(
      id: '1',
      titleEn: 'Shaping the Future - Clay Art',
      titleHi: 'भविष्य को आकार - मिट्टी कला',
      categoryEn: 'Pottery & Arts',
      categoryHi: 'कला व हस्तशिल्प',
      imageUrl: 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=600&auto=format&fit=crop',
      author: 'Ramesh Prajapat',
      date: '02 Jul 2026',
    ),
    GalleryItem(
      id: '2',
      titleEn: 'Traditional Terracotta Pots',
      titleHi: 'पारंपरिक टेराकोटा के बर्तन',
      categoryEn: 'Pottery & Arts',
      categoryHi: 'कला व हस्तशिल्प',
      imageUrl: 'https://images.unsplash.com/photo-1565192647048-f997ded87ab0?w=600&auto=format&fit=crop',
      author: 'Suresh Prajapat',
      date: '30 Jun 2026',
    ),
    GalleryItem(
      id: '3',
      titleEn: 'Community Temple Maha Aarti',
      titleHi: 'समाज मंदिर महा आरती',
      categoryEn: 'Temples',
      categoryHi: 'मंदिर व धरोहर',
      imageUrl: 'https://images.unsplash.com/photo-1600100397608-f010e42ecde5?w=600&auto=format&fit=crop',
      author: 'Pooja Maru',
      date: '28 Jun 2026',
    ),
    GalleryItem(
      id: '4',
      titleEn: 'Annual Community Sports Meet',
      titleHi: 'वार्षिक समाज खेलकूद प्रतियोगिता',
      categoryEn: 'Events',
      categoryHi: 'कार्यक्रम',
      imageUrl: 'https://images.unsplash.com/photo-1606800052052-a08af7148866?w=600&auto=format&fit=crop',
      author: 'Sunil Prajapati',
      date: '25 Jun 2026',
    ),
    GalleryItem(
      id: '5',
      titleEn: 'Academic Excellence Award',
      titleHi: 'शैक्षणिक गौरव सम्मान समारोह',
      categoryEn: 'Honours',
      categoryHi: 'गौरव',
      imageUrl: 'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=600&auto=format&fit=crop',
      author: 'Dr. Manoj Prajapat',
      date: '20 Jun 2026',
    ),
    GalleryItem(
      id: '6',
      titleEn: 'Clay Lanterns & Diya Exhibition',
      titleHi: 'मिट्टी के दीपक एवं लालटेन प्रदर्शनी',
      categoryEn: 'Pottery & Arts',
      categoryHi: 'कला व हस्तशिल्प',
      imageUrl: 'https://images.unsplash.com/photo-1595206133361-b1fe343e5e23?w=600&auto=format&fit=crop',
      author: 'Kavita Prajapati',
      date: '18 Jun 2026',
    ),
    GalleryItem(
      id: '7',
      titleEn: 'Community Working Committee Meeting',
      titleHi: 'समाज कार्यकारिणी बैठक',
      categoryEn: 'Communities',
      categoryHi: 'समुदाय',
      imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=600&auto=format&fit=crop',
      author: 'Ashok Kumar Maru',
      date: '15 Jun 2026',
    ),
    GalleryItem(
      id: '8',
      titleEn: 'Main Entrance - Heritage Temple',
      titleHi: 'मुख्य द्वार - ऐतिहासिक मंदिर',
      categoryEn: 'Temples',
      categoryHi: 'मंदिर व धरोहर',
      imageUrl: 'https://images.unsplash.com/photo-1561361513-2d000a50f0db?w=600&auto=format&fit=crop',
      author: 'Dinesh Prajapat',
      date: '10 Jun 2026',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Get active languages
  bool get _isEnglish => Localizations.localeOf(context).languageCode == 'en';

  // Filter Categories English & Hindi
  List<Map<String, String>> get _categories => [
        {'en': 'All', 'hi': 'सभी'},
        {'en': 'Pottery & Arts', 'hi': 'कला व हस्तशिल्प'},
        {'en': 'Events', 'hi': 'कार्यक्रम'},
        {'en': 'Communities', 'hi': 'समुदाय'},
        {'en': 'Honours', 'hi': 'गौरव'},
        {'en': 'Temples', 'hi': 'मंदिर व धरोहर'},
      ];

  List<GalleryItem> get _filteredItems {
    return _galleryItems.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item.categoryEn == _selectedCategory;
      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          item.titleEn.toLowerCase().contains(query) ||
          item.titleHi.contains(query) ||
          item.author.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Pick Image & Add Local Item
  Future<void> _addPhotoFlow() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile == null) return;

    final titleController = TextEditingController();
    String selectedCat = 'Pottery & Arts';

    if (!mounted) return;

    // Show Dialog to enter details
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                _isEnglish ? 'Add to Gallery' : 'गैलरी में फोटो जोड़ें',
                style: const TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: _isEnglish ? 'Title / Caption' : 'शीर्षक / विवरण',
                        hintText: _isEnglish ? 'Enter photo title' : 'फोटो का नाम दर्ज करें',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCat,
                      decoration: InputDecoration(
                        labelText: _isEnglish ? 'Category' : 'श्रेणी',
                      ),
                      items: _categories
                          .where((c) => c['en'] != 'All')
                          .map((c) => DropdownMenuItem(
                                value: c['en'],
                                child: Text(_isEnglish ? c['en']! : c['hi']!),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCat = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_isEnglish ? 'Cancel' : 'रद्द करें', style: const TextStyle(color: ThemeConfig.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    final itemCat = _categories.firstWhere((c) => c['en'] == selectedCat);

                    setState(() {
                      _galleryItems.insert(
                        0,
                        GalleryItem(
                          id: DateTime.now().toString(),
                          titleEn: title,
                          titleHi: title,
                          categoryEn: selectedCat,
                          categoryHi: itemCat['hi']!,
                          imageUrl: pickedFile.path,
                          author: _isEnglish ? 'You' : 'आप',
                          date: _isEnglish ? 'Today' : 'आज',
                        ),
                      );
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isEnglish ? 'Photo added successfully!' : 'फोटो सफलतापूर्वक जोड़ी गई!'),
                        backgroundColor: ThemeConfig.success,
                      ),
                    );
                  },
                  child: Text(_isEnglish ? 'Save' : 'सुरक्षित करें'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: _isEnglish ? 'Search gallery...' : 'गैलरी में खोजें...',
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: ThemeConfig.textHint),
                ),
                style: const TextStyle(color: ThemeConfig.textPrimary, fontSize: 16),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              )
            : Text(
                _isEnglish ? 'Community Gallery' : 'समाज गैलरी (Gallery)',
                style: const TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: _addPhotoFlow,
          ),
        ],
      ),
      body: Column(
        children: [
          // Horizontal Categories bar
          Container(
            height: 52,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat['en'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      _isEnglish ? cat['en']! : cat['hi']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : ThemeConfig.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: ThemeConfig.primary,
                    backgroundColor: ThemeConfig.background,
                    checkmarkColor: Colors.white,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat['en']!;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 1, color: ThemeConfig.divider),

          // Gallery Grid View
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      _isEnglish ? 'No photos found' : 'कोई फोटो नहीं मिली',
                      style: const TextStyle(color: ThemeConfig.textSecondary),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredItems.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return _buildGalleryCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryCard(GalleryItem item) {
    final title = _isEnglish ? item.titleEn : item.titleHi;
    final category = _isEnglish ? item.categoryEn : item.categoryHi;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeConfig.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openFullScreenViewer(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Hero(
                  tag: 'gallery_hero_${item.id}',
                  child: item.imageUrl.startsWith('http')
                      ? Image.network(
                          item.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const ContainerFallback(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          },
                        )
                      : Image.asset(
                          item.imageUrl, // Fallback for local picked image or standard assets
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const ContainerFallback(),
                        ),
                ),
              ),
            ),
            // Caption Info Area
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ThemeConfig.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: ThemeConfig.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: ThemeConfig.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'By ${item.author}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: ThemeConfig.textSecondary),
                        ),
                      ),
                      Text(
                        item.date,
                        style: const TextStyle(fontSize: 9, color: ThemeConfig.textHint),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullScreenViewer(GalleryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          final title = _isEnglish ? item.titleEn : item.titleHi;
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Uploaded by ${item.author} • ${item.date}',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    Share.share('Check out this photo: ${item.imageUrl}\nShared via Maru Prajapat App');
                  },
                ),
              ],
            ),
            body: Center(
              child: Hero(
                tag: 'gallery_hero_${item.id}',
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: item.imageUrl.startsWith('http')
                      ? Image.network(
                          item.imageUrl,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          item.imageUrl,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ContainerFallback extends StatelessWidget {
  const ContainerFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeConfig.background,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: ThemeConfig.textHint,
          size: 32,
        ),
      ),
    );
  }
}
