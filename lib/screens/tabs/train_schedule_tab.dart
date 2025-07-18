import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';

class TrainScheduleTab extends StatefulWidget {
  const TrainScheduleTab({super.key});

  @override
  State<TrainScheduleTab> createState() => _TrainScheduleTabState();
}

class _TrainScheduleTabState extends State<TrainScheduleTab> {
  final TextEditingController _trainController = TextEditingController();
  Map<String, dynamic>? _trainData;
  String? _error;
  bool _isLoading = false;
  bool _showStops = false; // <-- Add toggle state

  @override
  void initState() {
    super.initState();
    // Set default train number for testing (using the working example)
    _trainController.text = '12562';
  }

  Future<void> fetchTrainStatus(String trainNumber) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _trainData = null;
    });

    // Clean the train number - remove any whitespace
    final cleanTrainNumber = trainNumber.trim();
    
    // Construct URL exactly as in Postman - using proper Uri.https constructor
    final url = Uri.https(
      'indian-railway-irctc.p.rapidapi.com',
      '/api/trains-search/v1/train/$cleanTrainNumber',
      {
        'isH5': 'true',
        'client': 'web',
      },
    );
    
    // Log the exact request details
    debugPrint('=== API REQUEST DEBUG ===');
    debugPrint('URL: ${url.toString()}');
    debugPrint('Train Number: "$cleanTrainNumber" (length: ${cleanTrainNumber.length})');
    debugPrint('Method: GET');
    
    try {
      const apiKey = '3c2a7c429cmsh23642ae008e61aep1ec4c1jsn27453a293f08';
      
      // Headers exactly as in Postman (removed extra Host header)
      final headers = {
        'X-Rapidapi-Key': apiKey,
        'X-Rapidapi-Host': 'indian-railway-irctc.p.rapidapi.com',
        'X-Rapid-Api': 'rapid-api-database',
      };
      
      debugPrint('Headers: $headers');
      
      final response = await http.get(
        url,
        headers: headers,
      );
      
      debugPrint('=== API RESPONSE DEBUG ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          
          // Check if the response has the expected structure
          if (data['status'] != null && data['body'] != null && data['body'] is List && data['body'].isNotEmpty) {
            final bodyData = data['body'][0];
            if (bodyData['trains'] != null && bodyData['trains'] is List && bodyData['trains'].isNotEmpty) {
              final trainData = bodyData['trains'][0];
              debugPrint('=== TRAIN DATA DEBUG ===');
              debugPrint('Train Name: ${trainData['trainName']}');
              debugPrint('Train Number: ${trainData['trainNumber']}');
              debugPrint('Train Type: ${trainData['train_type']}');
              debugPrint('Running On: ${trainData['runningOn']}');
              debugPrint('Origin: ${trainData['origin']}');
              debugPrint('Destination: ${trainData['destination']}');
              setState(() {
                _trainData = trainData;
              });
            } else {
              final errorMessage = 'No train data found for the given train number.';
              if (mounted) {
                setState(() {
                  _error = errorMessage;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('API Error: $errorMessage'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            }
          } else {
            final errorMessage = data['status']?['message']?['message'] ?? 'Train not found or invalid train number.';
            if (mounted) {
              setState(() {
                _error = errorMessage;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('API Error: $errorMessage'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        } catch (jsonError) {
          debugPrint('JSON parsing error: $jsonError');
          if (mounted) {
            setState(() {
              _error = 'Invalid response format from server.';
            });
          }
        }
      } else if (response.statusCode == 403) {
        if (mounted) {
          setState(() {
            _error = 'Access forbidden (403). Check your API key, host, or quota.';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access forbidden (403). Check your API key, host, or quota.')),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Server error (${response.statusCode}). Please try again later.';
          });
        }
      }
    } catch (e) {
      debugPrint('Network error: $e');
      if (mounted) {
        setState(() {
          _error = 'Network error. Please check your connection and try again.';
        });
      }
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
                          Icon(Icons.train, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Train Summary',
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
                        'Detailed train info, route, classes & more',
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
                    child: Stack(
                      children: [
                        // Background pattern
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: -30,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        // Train tracks pattern
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  // Refresh button
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      onPressed: _trainData != null ? () => fetchTrainStatus(_trainController.text) : null,
                      icon: Icon(
                        Icons.refresh_rounded,
                      color: Colors.white,
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Input Section
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
                            Row(
                              children: [
                                Icon(Icons.search, color: AppTheme.accent, size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  'Check Live Train Status',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _trainController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter train number (e.g., 12051)',
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
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoading ? null : () => fetchTrainStatus(_trainController.text),
                                    icon: _isLoading 
                                      ? SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Icon(
                                          Icons.search_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                    label: Text(
                                      _isLoading ? 'Checking...' : 'Get Live Status',
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
                          ],
                        ),
                      ),
                      
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                            padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                              const SizedBox(height: 12),
                              // Debug info
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                    Text(
                                      'Debug Info:',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'URL: https://indian-railway-irctc.p.rapidapi.com/api/trains-search/v1/train/${_trainController.text.trim()}?isH5=true&client=web',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Headers: X-Rapidapi-Key, X-Rapidapi-Host, X-Rapid-Api',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Check console logs for detailed request/response',
                                      style: TextStyle(
                                        color: Colors.orange.withOpacity(0.8),
                                        fontSize: 10,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      if (_trainData != null) ...[
                        const SizedBox(height: 24),
                        
                        // Train Summary Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.accent.withOpacity(0.1),
                                AppTheme.accent2.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with Train Icon
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.train, color: AppTheme.accent, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _trainData?['trainName'] ?? 'Train Name',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Train ${_trainData?['trainNumber'] ?? 'Number'}',
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: AppTheme.accent,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // From/To Stations with Codes
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSummaryItem(
                                      icon: Icons.location_on,
                                      label: 'From',
                                      value: '${_trainData?['origin'] ?? 'N/A'} (${_trainData?['stationFrom'] ?? 'N/A'})',
                                      color: AppTheme.accent2,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildSummaryItem(
                                      icon: Icons.location_on,
                                      label: 'To',
                                      value: '${_trainData?['destination'] ?? 'N/A'} (${_trainData?['stationTo'] ?? 'N/A'})',
                                      color: AppTheme.accent,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Train Type and Departure Time
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSummaryItem(
                                      icon: Icons.train,
                                      label: 'Type',
                                      value: getTrainType(_trainData?['train_type']),
                                      color: Colors.purple,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildSummaryItem(
                                      icon: Icons.access_time,
                                      label: 'Departure Time',
                                      value: _getDepartureTime(),
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Days of Operation
                              _buildSummaryItem(
                                icon: Icons.calendar_today,
                                label: 'Days of Operation',
                                value: parseRunningDays(_trainData?['runningOn']),
                                color: Colors.teal,
                              ),
                            ],
                          ),
                        ),
                        
                        if (_trainData?['journeyClasses'] != null && (_trainData?['journeyClasses'] as List).isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 36,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: (_trainData?['journeyClasses'] as List).length,
                              separatorBuilder: (context, i) => const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final code = (_trainData?['journeyClasses'] as List)[i];
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.accent2.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    getClassFullForm(code),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.accent2,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              icon: Icon(_showStops ? Icons.expand_less : Icons.expand_more, color: AppTheme.accent2),
                              label: Text(_showStops ? 'Hide Stops' : 'Show Stops'),
                              onPressed: () {
                                setState(() {
                                  _showStops = !_showStops;
                                });
                              },
                            ),
                          ),
                        ],
                        
                        if (_trainData?['schedule'] != null && (_trainData?['schedule'] as List).isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.route, color: AppTheme.accent, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Total Stations: ${(_trainData?['schedule'] as List).length}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        if (_showStops && _trainData?['schedule'] != null && (_trainData?['schedule'] as List).isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(
                            '🚉 Stops',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (_trainData?['schedule'] as List).length,
                            separatorBuilder: (context, i) => const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final stop = (_trainData?['schedule'] as List)[i];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.accent2.withOpacity(0.15)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, color: AppTheme.accent2, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${stop['stationName'] ?? ''} (${stop['stationCode'] ?? ''})',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, color: Colors.orange, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Arrival: ${stop['arrivalTime'] ?? '--'}',
                                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(Icons.arrow_forward, color: Colors.orange, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Departure: ${stop['departureTime'] ?? '--'}',
                                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.straighten, color: Colors.teal, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Distance: ${stop['distance'] ?? '--'} km',
                                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(Icons.calendar_today, color: Colors.blue, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Day: ${stop['dayCount'] ?? '--'}',
                                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                        
                      ],
                    ],
                  ),
                ),
              ),
            ],
        ),
      ],
      ),
    );
  }

  Widget _buildRouteInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.location_on,
                label: 'From',
                value: _trainData?['origin'] ?? 'N/A',
                color: AppTheme.accent2,
              ),
            ),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.location_on,
                label: 'To',
                value: _trainData?['destination'] ?? 'N/A',
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.train,
                label: 'Station From',
                value: _trainData?['stationFrom'] ?? 'N/A',
                color: Colors.blue,
              ),
            ),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.train,
                label: 'Station To',
                value: _trainData?['stationTo'] ?? 'N/A',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentStatus() {
    final schedule = _trainData?['schedule'];
    if (schedule == null || schedule.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem(
                icon: Icons.departure_board,
                label: 'Departure',
                value: schedule[0]['departureTime'] ?? 'N/A',
                color: Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildInfoItem(
                icon: Icons.access_time,
                label: 'Arrival',
                value: schedule[schedule.length - 1]['arrivalTime'] ?? 'N/A',
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              _buildInfoItem(
                icon: Icons.route,
                label: 'Total Stations',
                value: '${schedule.length}',
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Helper for train type mapping
  String getTrainType(List<dynamic>? trainTypeList) {
    final typeCode = (trainTypeList != null && trainTypeList.isNotEmpty) ? trainTypeList[0] : 'N/A';
    final trainTypeMap = {
      "JS": "Jan Shatabdi",
      "EXP": "Express",
      "SF": "Superfast",
      "RAJ": "Rajdhani",
      "SH": "Shatabdi",
      "T": "Intercity",
      "DUR": "Duronto",
      "GAT": "Gatimaan",
      "O": "Ordinary",
    };
    return trainTypeMap[typeCode] ?? typeCode;
  }

  // Helper for running days mapping
  String parseRunningDays(String? code) {
    if (code == null || code.length != 7) return 'N/A';
    final daysMap = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final days = List.generate(7, (i) => code[i] == 'Y' ? daysMap[i] : null)
        .where((e) => e != null)
        .join(" ");
    return days.isEmpty ? 'N/A' : days;
  }

  // Helper for journey class mapping
  String getClassFullForm(String code) {
    final map = {
      "1A": "AC First Class",
      "2A": "AC 2 Tier",
      "3A": "AC 3 Tier",
      "3E": "AC 3 Economy",
      "SL": "Sleeper",
      "2S": "Second Sitting",
      "CC": "AC Chair Car",
      "EV": "Executive Chair Car"
    };
    return map[code] ?? code;
  }

  String _getDepartureTime() {
    final schedule = _trainData?['schedule'];
    if (schedule == null || schedule.isEmpty) return 'N/A';
    
    // Find the first station (stnSerialNumber == "1")
    for (final station in schedule) {
      if (station['stnSerialNumber'] == '1') {
        return station['departureTime'] ?? 'N/A';
      }
    }
    
    // Fallback to first station's departure time
    return schedule[0]['departureTime'] ?? 'N/A';
  }
} 