import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../services/google_places_mosque_service.dart';
import '../services/location_service.dart';


/// Mosque Finder
///
/// We deliberately do not build a partial mosque directory inside Seeker.
/// Local mosque coverage can differ substantially between map providers.
/// Instead, Seeker gets the user's location and hands the search to Google
/// Maps, where the user can see the current listings, names, pins, directions,
/// phone numbers, opening information, photos, reviews, etc. when available.
class MosquesScreen extends StatefulWidget {
  const MosquesScreen({super.key});

  @override
  State<MosquesScreen> createState() => _MosquesScreenState();
}

class _MosquesScreenState extends State<MosquesScreen> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  Position? _position;
  String _city = 'Current location';
  bool _isLoading = true;
  String? _error;
  NearbyMosque? _nearestMosque;
  bool _isFindingNearest = false;

  // Pass the key at runtime. Example:
  // flutter run --dart-define=GOOGLE_PLACES_API_KEY=YOUR_KEY
  static const String _googlePlacesApiKey =
      String.fromEnvironment('GOOGLE_PLACES_API_KEY');
  final GooglePlacesMosqueService _placesService =
      GooglePlacesMosqueService();

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLocation({bool forceCurrentLocation = false}) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      Position? position;
      String? savedCity;

      if (!forceCurrentLocation) {
        final savedLat = await _locationService.getSavedLatitude();
        final savedLng = await _locationService.getSavedLongitude();
        savedCity = await _locationService.getSavedCity();
        position = _locationService.getSavedPosition(
          latitude: savedLat,
          longitude: savedLng,
        );
      }

      position ??= await _locationService.getCurrentLocation();

      final city = savedCity ?? await _locationService.getCityName(position);

      if (!mounted) return;
      setState(() {
        _position = position;
        _city = city.isEmpty ? 'Current location' : city;
        _isLoading = false;
        _nearestMosque = null;
      });

      await _findNearestMosque();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = _friendlyError(e);
      });
    }
  }

  String _friendlyError(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('permission') || text.contains('location')) {
      return 'Location permission is needed to search for mosques near you.';
    }
    return 'We could not get your location right now. You can try again.';
  }

  String _mapsQuery(String query) {
    final position = _position;
    if (position == null) return query;

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return 'mosques near ${position.latitude},${position.longitude}';
    }

    return '$trimmed near ${position.latitude},${position.longitude}';
  }

  Future<void> _openGoogleMaps({String? query}) async {
    final position = _position;
    if (position == null) return;

    final search = _mapsQuery(query ?? 'mosques');

    // Google Maps Search URL. On Android, this normally hands off to the
    // installed Google Maps app; otherwise it opens the Maps web experience.
    final uri = Uri.https(
      'www.google.com',
      '/maps/search/',
      {
        'api': '1',
        'query': search,
      },
    );

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  Future<void> _searchSpecificPlace() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      await _openGoogleMaps(query: 'mosques');
      return;
    }
    await _openGoogleMaps(query: query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2F2F2F),
      appBar: AppBar(
        backgroundColor: const Color(0xff2F2F2F),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 4,
        title: const Text(
          'Mosques',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Use current location',
            onPressed: _isLoading
                ? null
                : () => _loadLocation(forceCurrentLocation: true),
            icon: const Icon(Icons.my_location_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _loadLocation(forceCurrentLocation: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 34),
          children: [
            _buildHero(),
            const SizedBox(height: 16),
            if (_error != null) _buildError(),
            if (_error == null) ...[
              _buildNearestMosqueCard(),
              const SizedBox(height: 16),
              _buildSearchCard(),
              const SizedBox(height: 16),
              _buildQuickSearches(),
              const SizedBox(height: 14),
              _buildMapsNote(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff1F5C4B), Color(0xff123E3B)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .11),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mosque_rounded,
              color: Color(0xffF4C76A),
              size: 29,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find a place to pray',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _isLoading ? 'Getting your location…' : 'Near $_city',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .72),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xffF4C76A),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNearestMosqueCard() {
    final mosque = _nearestMosque;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff1F5C4B), Color(0xff123E3B)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.near_me_rounded,
                  color: Color(0xffF4C76A),
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nearest mosque',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isFindingNearest
                          ? 'Finding the closest mapped mosque…'
                          : mosque == null
                              ? 'No verified mosque found nearby.'
                              : mosque.address ?? 'Verified on Google Maps',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isFindingNearest)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xffF4C76A),
                  ),
                ),
            ],
          ),
          if (mosque != null && !_isFindingNearest) ...[
            const SizedBox(height: 15),
            Text(
              mosque.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(
                  Icons.place_rounded,
                  color: Color(0xffF4C76A),
                  size: 17,
                ),
                const SizedBox(width: 5),
                Text(
                  mosque.distanceLabel,
                  style: const TextStyle(
                    color: Color(0xffF4C76A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (_isLoading || _isFindingNearest || mosque == null)
                  ? null
                  : _navigateToNearestMosque,
              icon: const Icon(Icons.navigation_rounded),
              label: Text(
                mosque == null ? 'Nearest mosque unavailable' : 'Navigate there',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xffD8E9DE),
                foregroundColor: const Color(0xff1D5545),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          if (_googlePlacesApiKey.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Nearest-mosque navigation needs Google Places to be configured. Use Search below in the meantime.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .55),
                fontSize: 10.5,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _findNearestMosque() async {
    final position = _position;
    if (position == null || _googlePlacesApiKey.isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        _isFindingNearest = true;
      });
    }

    try {
      final mosque = await _placesService.findNearestMosque(
        latitude: position.latitude,
        longitude: position.longitude,
        apiKey: _googlePlacesApiKey,
        radiusMeters: 10000,
      );

      if (!mounted) return;
      setState(() {
        _nearestMosque = mosque;
        _isFindingNearest = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _nearestMosque = null;
        _isFindingNearest = false;
      });
      debugPrint('Nearest mosque lookup failed: $e');
    }
  }

  Future<void> _navigateToNearestMosque() async {
    final position = _position;
    final mosque = _nearestMosque;
    if (position == null || mosque == null) return;

    final uri = Uri.https(
      'www.google.com',
      '/maps/dir/',
      {
        'api': '1',
        'origin': '${position.latitude},${position.longitude}',
        'destination': '${mosque.latitude},${mosque.longitude}',
        'destination_place_id': mosque.placeId,
        'travelmode': 'driving',
        'dir_action': 'navigate',
      },
    );

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xff3A3A3A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search a mosque or place',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _searchSpecificPlace(),
            style: const TextStyle(color: Colors.white),
            cursorColor: const Color(0xffF4C76A),
            decoration: InputDecoration(
              hintText: 'e.g. Khanqah Faiz Panah, Jamia Masjid…',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: .40)),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xffA7C7B7),
              ),
              suffixIcon: IconButton(
                tooltip: 'Search Maps',
                onPressed: _searchSpecificPlace,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xffF4C76A),
                ),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: .07),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: .07),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: .07),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17),
                borderSide: const BorderSide(
                  color: Color(0xffA7C7B7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearches() {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 18),
      decoration: BoxDecoration(
        color: const Color(0xff3A3A3A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick search',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 13),
          _quickSearchTile(
            icon: Icons.mosque_rounded,
            title: 'Nearby mosques',
            subtitle: 'Show mosques around your current location',
            query: 'mosques',
          ),
          const SizedBox(height: 9),
          _quickSearchTile(
            icon: Icons.account_balance_rounded,
            title: 'Khanqahs & Ziyarat',
            subtitle: 'Search nearby khanqahs and ziyarat places',
            query: 'khanqah ziyarat',
          ),
          const SizedBox(height: 9),
          _quickSearchTile(
            icon: Icons.location_city_rounded,
            title: 'Jamia Masjids',
            subtitle: 'Find larger congregational mosques nearby',
            query: 'Jamia Masjid',
          ),
        ],
      ),
    );
  }

  Widget _buildMapsNote() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .035),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              color: Color(0xffA7C7B7),
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why does Seeker open Google Maps?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Mosque listings, names, locations and availability can change, and coverage can differ between map providers. Instead of keeping an incomplete mosque directory inside Seeker, we use Google Maps for live map listings and directions.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .55),
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickSearchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String query,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: .055),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: () => _openGoogleMaps(query: query),
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xffD8E9DE).withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: const Color(0xffA7C7B7)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .50),
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new_rounded, color: Colors.white38, size: 19),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xff3A3A3A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xff1F5C4B).withValues(alpha: .28),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_rounded,
              color: Color(0xffA7C7B7),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Location unavailable',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .55),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 19),
          FilledButton.icon(
            onPressed: () => _loadLocation(forceCurrentLocation: true),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
