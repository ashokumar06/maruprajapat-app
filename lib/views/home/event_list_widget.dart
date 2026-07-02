import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme_config.dart';
import '../../models/event_model.dart';
import '../../services/api_client.dart';
import 'create_event_screen.dart';
import 'event_details_screen.dart';

class EventListWidget extends StatefulWidget {
  final int? communityId;
  final bool canCreate;

  const EventListWidget({
    super.key,
    this.communityId,
    required this.canCreate,
  });

  @override
  State<EventListWidget> createState() => _EventListWidgetState();
}

class _EventListWidgetState extends State<EventListWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<EventModel> _allEvents = [];
  String _searchQuery = '';
  String? _error;

  // Inline Search State
  bool _isSearching = false;
  final _searchController = TextEditingController();

  // Filter criteria
  DateTime? _filterFromDate;
  DateTime? _filterToDate;
  String? _filterType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _fetchEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = ApiClient().dio;
      final Map<String, dynamic> params = {
        'page': 1,
        'per_page': 50,
      };
      if (widget.communityId != null) {
        params['community_id'] = widget.communityId;
      }

      final response = await dio.get('/api/v1/events/', queryParameters: params);
      
      if (response.statusCode == 200 && response.data != null) {
        final List items = response.data['items'] ?? [];
        final parsedEvents = items.map((e) => EventModel.fromJson(e)).toList();
        
        if (mounted) {
          setState(() {
            _allEvents = parsedEvents;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching events: $e');
      if (mounted) {
        setState(() {
          _error = 'कार्यक्रम लोड करने में विफल';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<EventModel> _getSegmentedEvents(int tabIndex) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    List<EventModel> filtered = _allEvents.where((e) {
      final eventDate = DateTime(e.startDate.year, e.startDate.month, e.startDate.day);
      
      final bool isPast = eventDate.isBefore(today);
      final bool isUpcoming = !isPast; // Includes today and future

      if (tabIndex == 0) return isUpcoming;
      return isPast;
    }).toList();

    if (tabIndex == 0) {
      // Upcoming: Nearest dates first (Ascending)
      filtered.sort((a, b) => a.startDate.compareTo(b.startDate));
    } else {
      // Past: Most recent past dates first (Descending)
      filtered.sort((a, b) => b.startDate.compareTo(a.startDate));
    }

    return filtered;
  }

  List<EventModel> _getFilteredEvents(List<EventModel> events) {
    return events.where((e) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final titleMatch = e.title.toLowerCase().contains(query);
        final descMatch = e.description?.toLowerCase().contains(query) ?? false;
        final locMatch = e.location?.toLowerCase().contains(query) ?? false;
        if (!titleMatch && !descMatch && !locMatch) return false;
      }

      if (_filterType != null && _filterType != 'all' && e.eventType != _filterType) {
        return false;
      }

      if (_filterFromDate != null && e.startDate.isBefore(_filterFromDate!)) {
        return false;
      }
      if (_filterToDate != null && e.startDate.isAfter(_filterToDate!.add(const Duration(days: 1)))) {
        return false;
      }

      return true;
    }).toList();
  }

  String _getEventTypeText(String type) {
    switch (type.toLowerCase()) {
      case 'meeting':
        return 'बैठक';
      case 'ceremony':
        return 'समारोह';
      case 'conference':
        return 'सम्मेलन';
      case 'sports':
        return 'खेलकूद';
      case 'festival':
        return 'उत्सव';
      default:
        return 'सामान्य कार्यक्रम';
    }
  }

  IconData _getEventTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'meeting':
        return Icons.groups;
      case 'ceremony':
        return Icons.military_tech;
      case 'conference':
        return Icons.co_present;
      case 'sports':
        return Icons.emoji_events;
      case 'festival':
        return Icons.celebration;
      default:
        return Icons.event;
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final fromText = _filterFromDate == null
                ? 'dd/mm/yyyy'
                : DateFormat('dd/MM/yyyy').format(_filterFromDate!);
            final toText = _filterToDate == null
                ? 'dd/mm/yyyy'
                : DateFormat('dd/MM/yyyy').format(_filterToDate!);

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'फ़िल्टर',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text('तिथि के अनुसार', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2025),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setSheetState(() => _filterFromDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: ThemeConfig.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ThemeConfig.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(fromText, style: TextStyle(color: _filterFromDate == null ? ThemeConfig.textHint : ThemeConfig.textPrimary, fontSize: 13)),
                                const Icon(Icons.calendar_today, size: 14, color: ThemeConfig.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _filterFromDate ?? DateTime.now(),
                              firstDate: _filterFromDate ?? DateTime(2025),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setSheetState(() => _filterToDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: ThemeConfig.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ThemeConfig.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(toText, style: TextStyle(color: _filterToDate == null ? ThemeConfig.textHint : ThemeConfig.textPrimary, fontSize: 13)),
                                const Icon(Icons.calendar_today, size: 14, color: ThemeConfig.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text('कार्यक्रम प्रकार', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _filterType ?? 'all',
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('सभी प्रकार')),
                      DropdownMenuItem(value: 'meeting', child: Text('बैठक')),
                      DropdownMenuItem(value: 'ceremony', child: Text('समारोह')),
                      DropdownMenuItem(value: 'conference', child: Text('सम्मेलन')),
                      DropdownMenuItem(value: 'sports', child: Text('खेलकूद')),
                      DropdownMenuItem(value: 'festival', child: Text('उत्सव')),
                    ],
                    onChanged: (val) {
                      setSheetState(() => _filterType = val);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: ThemeConfig.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeConfig.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeConfig.border)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(() {
                              _filterFromDate = null;
                              _filterToDate = null;
                              _filterType = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: ThemeConfig.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('रीसेट करें', style: TextStyle(color: ThemeConfig.primary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConfig.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text('फ़िल्टर लागू करें', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.communityId == null ? Colors.white : Colors.transparent,
      appBar: widget.communityId == null
          ? AppBar(
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'कार्यक्रम खोजें...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: ThemeConfig.textHint),
                      ),
                      style: const TextStyle(color: ThemeConfig.textPrimary, fontSize: 16),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    )
                  : const Text(
                      'समाज कार्यक्रम (Events)',
                      style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
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
                  icon: const Icon(Icons.tune),
                  onPressed: _showFilterSheet,
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // Standard Tab Bar matching Figma
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: ThemeConfig.primary,
              indicatorWeight: 3,
              labelColor: ThemeConfig.primary,
              unselectedLabelColor: ThemeConfig.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
              tabs: const [
                Tab(text: 'आगामी कार्यक्रम'),
                Tab(text: 'बीते कार्यक्रम'),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: ThemeConfig.divider),

          // Events List View
          Expanded(
            child: Container(
              color: const Color(0xFFFAF8F5), // Light warm background matching Figma
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEventsListView(0),
                  _buildEventsListView(1),
                ],
              ),
            ),
          ),
          
          // Fixed Bottom Button Area (Footer)
          if (widget.canCreate)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: ThemeConfig.divider)),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateEventScreen(communityId: widget.communityId),
                    ),
                  ).then((value) {
                    _fetchEvents();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: const Text(
                  'नया कार्यक्रम जोड़ें',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventsListView(int tabIndex) {
    final rawEvents = _getSegmentedEvents(tabIndex);
    final events = _getFilteredEvents(rawEvents);

    if (_isLoading && _allEvents.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeConfig.primary),
      );
    }

    if (_error != null && _allEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: ThemeConfig.error)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchEvents,
              child: const Text('पुनः प्रयास करें'),
            ),
          ],
        ),
      );
    }

    if (events.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchEvents,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'खोज से मेल खाता कोई कार्यक्रम नहीं मिला।'
                    : (tabIndex == 0
                        ? 'कोई आगामी कार्यक्रम नहीं है।'
                        : tabIndex == 1
                            ? 'कोई चल रहा कार्यक्रम नहीं है।'
                            : 'कोई बीते कार्यक्रम नहीं हैं।'),
                style: const TextStyle(color: ThemeConfig.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchEvents,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _buildEventCard(event, tabIndex);
        },
      ),
    );
  }

  Widget _buildEventCard(EventModel event, int tabIndex) {
    final dateStr = DateFormat('dd MMMM yyyy').format(event.startDate);
    final timeStr = DateFormat('hh:mm a').format(event.startDate);

    Color statusBgColor = Colors.green.shade50;
    Color statusTextColor = Colors.green.shade700;
    String statusLabel = 'आगामी';

    if (tabIndex == 1) {
      statusBgColor = Colors.blue.shade50;
      statusTextColor = Colors.blue.shade700;
      statusLabel = 'बीता';
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ThemeConfig.divider, width: 1.0)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailsScreen(event: event),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 85,
                  height: 85,
                  color: ThemeConfig.primary.withOpacity(0.06),
                  child: event.coverImageUrl != null && event.coverImageUrl!.isNotEmpty
                      ? Image.network(event.coverImageUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.event, color: ThemeConfig.primary, size: 32),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ThemeConfig.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: ThemeConfig.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '$dateStr | सुबह $timeStr से',
                            style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: ThemeConfig.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event.location ?? 'स्थान उपलब्ध नहीं',
                            style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
