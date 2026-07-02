import re

file_path = 'lib/views/home/event_list_widget.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Replace _allEvents and _fetchEvents
old_fetch = """  List<EventModel> _allEvents = [];
  bool _isLoading = true;
  String? _error;

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

  Future<void> _fetchEvents() async {
    try {
      final dio = ApiClient().dio;
      
      final response = await dio.get('/api/v1/events/', queryParameters: {
        'page': 1,
        'per_page': 50,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> items = response.data['items'];
        if (mounted) {
          setState(() {
            _allEvents = items.map((e) => EventModel.fromJson(e)).toList();
            _error = null;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'डेटा लोड करने में विफल';
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
  }"""

new_fetch = """  List<EventModel> _upcomingEvents = [];
  List<EventModel> _pastEvents = [];
  bool _isLoading = true;
  String? _error;

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

  Future<void> _fetchEvents() async {
    try {
      final dio = ApiClient().dio;
      
      // Fetch upcoming
      final resUpcoming = await dio.get('/api/v1/events/', queryParameters: {
        'page': 1,
        'per_page': 50,
        'upcoming': true,
      });
      
      // Fetch past
      final resPast = await dio.get('/api/v1/events/', queryParameters: {
        'page': 1,
        'per_page': 50,
        'upcoming': false,
      });

      if (resUpcoming.statusCode == 200 && resPast.statusCode == 200) {
        final List<dynamic> upItems = resUpcoming.data['items'];
        final List<dynamic> paItems = resPast.data['items'];
        
        if (mounted) {
          setState(() {
            _upcomingEvents = upItems.map((e) => EventModel.fromJson(e)).toList();
            _pastEvents = paItems.map((e) => EventModel.fromJson(e)).toList();
            _error = null;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'डेटा लोड करने में विफल';
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
    if (tabIndex == 0) return _upcomingEvents;
    return _pastEvents;
  }"""

if "List<EventModel> _getSegmentedEvents" in content:
    content = content.replace(old_fetch, new_fetch)

with open(file_path, 'w') as f:
    f.write(content)
