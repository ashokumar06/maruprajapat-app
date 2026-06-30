import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/forms_provider.dart';
import '../../models/form_model.dart';

class FormsScreen extends StatefulWidget {
  const FormsScreen({super.key});

  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormsProvider>().fetchForms();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text(
          'फॉर्म',
          style: TextStyle(
            color: ThemeConfig.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeConfig.primary,
          unselectedLabelColor: ThemeConfig.textSecondary,
          indicatorColor: ThemeConfig.primary,
          tabs: const [
            Tab(text: 'सभी फॉर्म'),
            Tab(text: 'सक्रिय'),
            Tab(text: 'पुराने'),
          ],
        ),
      ),
      body: Consumer<FormsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.forms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.forms.isEmpty && !provider.isLoading) {
            return const Center(child: Text('कोई फॉर्म उपलब्ध नहीं है।'));
          }

          final activeForms = provider.forms.where((f) => f.isActive).toList();
          final inactiveForms = provider.forms.where((f) => !f.isActive).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildFormsList(provider.forms),
              _buildFormsList(activeForms),
              _buildFormsList(inactiveForms),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormsList(List<FormModel> formList) {
    if (formList.isEmpty) {
      return const Center(child: Text('इस श्रेणी में कोई फॉर्म नहीं है।'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: formList.length,
      itemBuilder: (context, index) {
        return _buildFormCard(formList[index]);
      },
    );
  }

  Widget _buildFormCard(FormModel form) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: ThemeConfig.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ThemeConfig.primaryLight.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.assignment, color: ThemeConfig.primary),
        ),
        title: Text(
          form.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            form.description ?? '',
            style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: form.isActive ? ThemeConfig.success.withOpacity(0.1) : ThemeConfig.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                form.isActive ? 'सक्रिय' : 'बंद',
                style: TextStyle(color: form.isActive ? ThemeConfig.success : ThemeConfig.error, fontSize: 10),
              ),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, color: ThemeConfig.textHint),
          ],
        ),
        onTap: () {
          if (!form.isActive) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('यह फॉर्म अब सक्रिय नहीं है।')),
            );
            return;
          }
          // Navigate to form detail (placeholder for now)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('फॉर्म खोलें: ${form.title}')),
          );
        },
      ),
    );
  }
}
