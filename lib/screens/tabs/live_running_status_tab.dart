import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';

class LiveRunningStatusTab extends StatefulWidget {
  const LiveRunningStatusTab({super.key});

  @override
  State<LiveRunningStatusTab> createState() => _LiveRunningStatusTabState();
}

class _LiveRunningStatusTabState extends State<LiveRunningStatusTab> {
  final TextEditingController _trainController = TextEditingController();
  int _startDay = 1;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _result;

  Future<void> fetchLiveStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });
    final trainNumber = _trainController.text.trim();
    final url = Uri.https(
      'irctc1.p.rapidapi.com',
      '/api/v1/liveTrainStatus',
      {
        'trainNo': trainNumber,
        'startDay': _startDay.toString(),
      },
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'X-Rapidapi-Key': '3c2a7c429cmsh23642ae008e61aep1ec4c1jsn27453a293f08',
          'X-Rapidapi-Host': 'irctc1.p.rapidapi.com',
          'Host': 'irctc1.p.rapidapi.com',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _result = json.decode(response.body);
        });
      } else {
        setState(() {
          _error = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.accent,
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.3),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_train, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Live Running Status',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              letterSpacing: 1.0,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Track your train in real-time',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.accent,
                          AppTheme.accent.withOpacity(0.8),
                          AppTheme.accent.withOpacity(0.6),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Train Number', style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _trainController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter train number',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppTheme.accent, width: 2),
                                ),
                                prefixIcon: Icon(Icons.train, color: AppTheme.accent),
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                            ),
                            const SizedBox(height: 16),
                            Text('Start Day', style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: _startDay,
                              dropdownColor: AppTheme.background,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              items: [
                                const DropdownMenuItem(value: 1, child: Text('Today')),
                                const DropdownMenuItem(value: 2, child: Text('Yesterday')),
                                const DropdownMenuItem(value: 3, child: Text('Day Before Yesterday')),
                                const DropdownMenuItem(value: 4, child: Text('3 Days Ago')),
                                const DropdownMenuItem(value: 5, child: Text('4 Days Ago')),
                                const DropdownMenuItem(value: 6, child: Text('5 Days Ago')),
                                const DropdownMenuItem(value: 7, child: Text('6 Days Ago')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _startDay = val);
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : fetchLiveStatus,
                                icon: _isLoading
                                    ? SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Icon(Icons.search_rounded, color: Colors.white, size: 24),
                                label: Text(
                                  _isLoading ? 'Checking...' : 'Check Live Status',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accent,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shadowColor: AppTheme.accent.withOpacity(0.4),
                                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_result != null && (_result!['status'] == true || _result!['data']?['success'] == true) && _result!['data'] != null) ...[
                        const SizedBox(height: 24),
                        // Top summary card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.accent.withOpacity(0.15)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.train, color: AppTheme.accent, size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${_result!['data']['train_number'] ?? ''}  ·  ${_result!['data']['train_name'] ?? ''}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: AppTheme.accent2, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Current: ${_result!['data']['current_station_name'] ?? '--'}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.92),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.access_time, color: Colors.orange, size: 18),
                                  const SizedBox(width: 4),
                                  Text('ETA: ${_result!['data']['eta'] ?? '--'}', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                                  const SizedBox(width: 12),
                                  Icon(Icons.arrow_forward, color: Colors.orange, size: 16),
                                  const SizedBox(width: 4),
                                  Text('ETD: ${_result!['data']['etd'] ?? '--'}', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.timer, color: Colors.red, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Delay: ${_result!['data']['delay'] ?? '--'} min',
                                    style: TextStyle(
                                      color: (_result!['data']['delay'] ?? 0) == 0
                                          ? Colors.green
                                          : (_result!['data']['delay'] ?? 0) < 15
                                              ? Colors.orange
                                              : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.straighten, color: Colors.teal, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Covered: ${_result!['data']['distance_from_source'] ?? '--'} / ${_result!['data']['total_distance'] ?? '--'} km',
                                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Next stoppage section
                        if (_result!['data']['next_stoppage_info'] != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.accent2.withOpacity(0.15)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.flag, color: AppTheme.accent2, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Next: ${_result!['data']['next_stoppage_info']['next_stoppage'] ?? '--'}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.92),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, color: Colors.orange, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_result!['data']['next_stoppage_info']['next_stoppage_time_diff'] ?? '--'}',
                                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.timer, color: Colors.red, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Delay: ${_result!['data']['next_stoppage_info']['next_stoppage_delay'] ?? '--'} min',
                                      style: TextStyle(color: Colors.red, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        // Current location info timeline
                        if (_result!['data']['current_location_info'] != null && (_result!['data']['current_location_info'] as List).isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text('Current Location Updates', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (_result!['data']['current_location_info'] as List).length,
                            separatorBuilder: (context, i) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final info = (_result!['data']['current_location_info'] as List)[i];
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.accent.withOpacity(0.08)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.info_outline, color: AppTheme.accent2, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          info['label'] ?? '',
                                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      info['readable_message'] ?? info['message'] ?? '',
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                    if ((info['hint'] ?? '').toString().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        info['hint'],
                                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                        // Upcoming stations list
                        if (_result!['data']['upcoming_stations'] != null && (_result!['data']['upcoming_stations'] as List).isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text('Upcoming Stations', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (_result!['data']['upcoming_stations'] as List).length,
                            separatorBuilder: (context, i) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final station = (_result!['data']['upcoming_stations'] as List)[i];
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.accent2.withOpacity(0.08)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, color: AppTheme.accent2, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${station['station_name'] ?? '--'} (${station['station_code'] ?? ''})',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                                          ),
                                        ),
                                        if (station['platform_number'] != null)
                                          Row(
                                            children: [
                                              Icon(Icons.dns, color: Colors.blueGrey, size: 16),
                                              const SizedBox(width: 2),
                                              Text('PF ${station['platform_number']}', style: TextStyle(color: Colors.blueGrey[200], fontSize: 12)),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, color: Colors.orange, size: 16),
                                        const SizedBox(width: 4),
                                        Text('STA: ${station['sta'] ?? '--'}', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                                        const SizedBox(width: 10),
                                        Icon(Icons.access_time_filled, color: Colors.green, size: 16),
                                        const SizedBox(width: 4),
                                        Text('ETA: ${station['eta'] ?? '--'}', style: TextStyle(color: Colors.green[200], fontSize: 13)),
                                        const SizedBox(width: 10),
                                        Icon(Icons.timer, color: Colors.red, size: 16),
                                        const SizedBox(width: 4),
                                        Text('Delay: ${station['arrival_delay'] ?? '--'} min', style: TextStyle(color: Colors.red[200], fontSize: 13)),
                                      ],
                                    ),
                                    if (station['distance_from_current_station_txt'] != null) ...[
                                      const SizedBox(height: 4),
                                      Text(station['distance_from_current_station_txt'], style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                        // Optionally, previous stations toggle (not implemented here for brevity)
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accent2,
        child: const Icon(Icons.refresh, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Row(
                children: [
                  Icon(Icons.refresh, color: AppTheme.accent2),
                  const SizedBox(width: 8),
                  const Text('Reload Live Status'),
                ],
              ),
              content: const Text('Do you want to fetch the latest live running status?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          Navigator.pop(context);
                          await fetchLiveStatus();
                        },
                  icon: _isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isLoading ? 'Reloading...' : 'Reload'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 