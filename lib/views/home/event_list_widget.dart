import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../models/event_model.dart';
import '../../services/api_client.dart';
import '../../providers/auth_provider.dart';
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
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _pastEvents = [];
  String _searchQuery = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchEvents();
      }
    });
    _fetchEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      final bool isUpcoming = _tabController.index == 0;
      final String url = '/api/v1/events/';
      
      final Map<String, dynamic> params = {
        'page': 1,
        'per_page': 50,
        'upcoming': isUpcoming,
      };
      if (widget.communityId != null) {
        params['community_id'] = widget.communityId;
      }

      final response = await dio.get(url, queryParameters: params);
      
      if (response.statusCode == 200 && response.data != null) {
        final List items = response.data['items'] ?? [];
        final parsedEvents = items.map((e) => EventModel.fromJson(e)).toList();
        
        if (mounted) {
          setState(() {
            if (isUpcoming) {
              _upcomingEvents = parsedEvents;
            } else {
              _pastEvents = parsedEvents;
            }
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

  List<EventModel> _getFilteredEvents(List<EventModel> events) {
    if (_searchQuery.isEmpty) return events;
    return events.where((e) {
      final query = _searchQuery.toLowerCase();
      final titleMatch = e.title.toLowerCase().contains(query);
      final descMatch = e.description?.toLowerCase().contains(query) ?? false;
      final locMatch = e.location?.toLowerCase().contains(query) ?? false;
      return titleMatch || descMatch || locMatch;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: ThemeConfig.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ThemeConfig.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'कार्यक्रम खोजें...',
                  hintStyle: TextStyle(color: ThemeConfig.textHint, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: ThemeConfig.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Tab Toggle Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: ThemeConfig.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ThemeConfig.border),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: ThemeConfig.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: ThemeConfig.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                tabs: const [
                  Tab(text: 'आगामी कार्यक्रम'),
                  Tab(text: 'बीते कार्यक्रम'),
                ],
              ),
            ),
          ),

          // Main list content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventsListView(true),
                _buildEventsListView(false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.canCreate
          ? FloatingActionButton.extended(
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
              backgroundColor: ThemeConfig.primary,
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text(
                'नया कार्यक्रम जोड़ें',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            )
          : null,
    );
  }

  Widget _buildEventsListView(bool isUpcoming) {
    final rawEvents = isUpcoming ? _upcomingEvents : _pastEvents;
    final events = _getFilteredEvents(rawEvents);

    if (_isLoading && rawEvents.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeConfig.primary),
      );
    }

    if (_error != null && rawEvents.isEmpty) {
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
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'खोज से मेल खाता कोई कार्यक्रम नहीं मिला।'
                    : (isUpcoming ? 'कोई आगामी कार्यक्रम नहीं है।' : 'कोई बीते कार्यक्रम नहीं हैं।'),
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    final typeText = _getEventTypeText(event.eventType);
    final typeIcon = _getEventTypeIcon(event.eventType);
    final dateStr = DateFormat('dd MMMM yyyy').format(event.startDate);
    final timeStr = DateFormat('hh:mm a').format(event.startDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ThemeConfig.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeConfig.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Image or Icon placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 72,
                  height: 72,
                  color: ThemeConfig.primary.withOpacity(0.08),
                  child: event.coverImageUrl != null && event.coverImageUrl!.isNotEmpty
                      ? Image.network(event.coverImageUrl!, fit: BoxFit.cover)
                      : Icon(typeIcon, color: ThemeConfig.primary, size: 30),
                ),
              ),
              const SizedBox(width: 16),
              
              // Right: Text Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ThemeConfig.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            typeText,
                            style: const TextStyle(
                              color: ThemeConfig.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          event.startDate.isAfter(DateTime.now()) ? 'आगामी' : 'बीता',
                          style: TextStyle(
                            color: event.startDate.isAfter(DateTime.now())
                                ? ThemeConfig.success
                                : ThemeConfig.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ThemeConfig.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: ThemeConfig.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          '$dateStr | $timeStr से',
                          style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary),
                        ),
                      ],
                    ),
                    if (event.location != null && event.location!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: ThemeConfig.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
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
