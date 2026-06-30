import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/explore_provider.dart';
import '../../models/business_model.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreProvider>().fetchBusinesses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text(
          'अन्वेषण',
          style: TextStyle(
            color: ThemeConfig.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<ExploreProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.businesses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // 1. Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'खोजें व्यवसाय, सदस्य, सेवाएँ...',
                      hintStyle: const TextStyle(color: ThemeConfig.textHint),
                      prefixIcon: const Icon(Icons.search, color: ThemeConfig.textHint),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: ThemeConfig.border, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: ThemeConfig.border, width: 1),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Categories Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildCategoryIcon(Icons.storefront, 'व्यवसाय', Colors.orange.shade800),
                      _buildCategoryIcon(Icons.people, 'सदस्य', Colors.orange.shade800),
                      _buildCategoryIcon(Icons.diamond_outlined, 'विवाह', ThemeConfig.error), // Ring-like
                      _buildCategoryIcon(Icons.event_note, 'कार्यक्रम', Colors.orange.shade800),
                      _buildCategoryIcon(Icons.bloodtype, 'रक्तदाता', ThemeConfig.error),
                      _buildCategoryIcon(Icons.school, 'शिक्षा', Colors.blue.shade700),
                      _buildCategoryIcon(Icons.work, 'नौकरियाँ', Colors.orange.shade800),
                      _buildCategoryIcon(Icons.account_balance, 'मन्दिर/मठ', Colors.blue.shade700),
                    ],
                  ),
                ),
              ),

              // 3. Popular Businesses Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'लोकप्रिय व्यवसाय',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Text(
                        'सभी देखें >',
                        style: TextStyle(
                          color: Colors.deepOrange, // Matches mockup
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Businesses List
              if (provider.businesses.isEmpty && !provider.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('कोई व्यवसाय नहीं मिला।')),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildBusinessCard(provider.businesses[index], index == provider.businesses.length - 1);
                    },
                    childCount: provider.businesses.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(BusinessModel business, bool isLast) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isLast 
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : (business == context.read<ExploreProvider>().businesses.first 
                ? const BorderRadius.vertical(top: Radius.circular(20)) 
                : BorderRadius.zero),
        border: Border(
          left: const BorderSide(color: ThemeConfig.border),
          right: const BorderSide(color: ThemeConfig.border),
          top: business == context.read<ExploreProvider>().businesses.first ? const BorderSide(color: ThemeConfig.border) : BorderSide.none,
          bottom: isLast ? const BorderSide(color: ThemeConfig.border) : BorderSide.none,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: ThemeConfig.border,
                    borderRadius: BorderRadius.circular(12),
                    image: (business.images != null && business.images!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(business.images!.first),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (business.images == null || business.images!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white, size: 30) // Using person as fallback per mockup
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.businessName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        business.address ?? "स्थान उपलब्ध नहीं",
                        style: const TextStyle(fontSize: 13, color: ThemeConfig.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          const Text('4.6', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          const Text('(128)', style: TextStyle(fontSize: 13, color: ThemeConfig.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: ThemeConfig.textHint),
              ],
            ),
          ),
          if (!isLast)
            const Divider(height: 1, indent: 88, endIndent: 16, color: ThemeConfig.border),
        ],
      ),
    );
  }
}
