import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';

class PNRStatusTab extends StatefulWidget {
  const PNRStatusTab({super.key});

  @override
  State<PNRStatusTab> createState() => _PNRStatusTabState();
}

class _PNRStatusTabState extends State<PNRStatusTab> {
  final TextEditingController _pnrController = TextEditingController();
  Map<String, dynamic>? _parsedData;
  String? _error;
  bool _isLoading = false;

  // Manual parsing for the specific format shown
  Map<String, dynamic> manualParsePNRData(String textData) {
    final Map<String, dynamic> parsedData = {};
    
    try {
      // Remove the outer braces and split by comma
      String data = textData.trim();
      if (data.startsWith('{') && data.endsWith('}')) {
        data = data.substring(1, data.length - 1);
      }
      
      // Split by comma, but be careful with nested objects
      final parts = data.split(', ');
      
      for (String part in parts) {
        if (part.contains(':')) {
          final colonIndex = part.indexOf(':');
          String key = part.substring(0, colonIndex).trim();
          String value = part.substring(colonIndex + 1).trim();
          
          // Clean up the key and value
          key = key.replaceAll('"', '').replaceAll("'", '');
          
          // Handle possible list fields
          if ((key == 'passengerList' || key == 'informationMessage') && value.isNotEmpty) {
            if (value.startsWith('[') && value.endsWith(']')) {
              parsedData[key] = parsePassengerList(value);
            } else {
              // If it's a string, wrap in a list
              parsedData[key] = [value];
            }
          } else if (value == 'true' || value == 'false') {
            // Handle booleans
            parsedData[key] = value == 'true';
          } else if (value.contains(RegExp(r'^\d+$'))) {
            // Handle numbers
            parsedData[key] = int.tryParse(value) ?? value;
          } else {
            // Handle strings
            value = value.replaceAll('"', '').replaceAll("'", '');
            parsedData[key] = value;
          }
        }
      }
    } catch (e) {
      print('Error in manual parsing: $e');
    }
    
    // Defensive: ensure passengerList and informationMessage are always lists
    if (parsedData['passengerList'] is String) {
      parsedData['passengerList'] = [parsedData['passengerList']];
    } else if (parsedData['passengerList'] == null) {
      parsedData['passengerList'] = <dynamic>[];
    }
    if (parsedData['informationMessage'] is String) {
      parsedData['informationMessage'] = [parsedData['informationMessage']];
    } else if (parsedData['informationMessage'] == null) {
      parsedData['informationMessage'] = <dynamic>[];
    }
    
    return parsedData;
  }
  
  List<Map<String, dynamic>> parsePassengerList(String passengerData) {
    final List<Map<String, dynamic>> passengers = [];
    
    try {
      // Remove brackets
      String data = passengerData.substring(1, passengerData.length - 1);
      
      // Split by passenger objects
      final passengerParts = data.split('}, {');
      
      for (int i = 0; i < passengerParts.length; i++) {
        String passengerPart = passengerParts[i];
        
        // Clean up the passenger part
        if (passengerPart.startsWith('{')) {
          passengerPart = passengerPart.substring(1);
        }
        if (passengerPart.endsWith('}')) {
          passengerPart = passengerPart.substring(0, passengerPart.length - 1);
        }
        
        final Map<String, dynamic> passenger = {};
        final fields = passengerPart.split(', ');
        
        for (String field in fields) {
          if (field.contains(':')) {
            final colonIndex = field.indexOf(':');
            String key = field.substring(0, colonIndex).trim();
            String value = field.substring(colonIndex + 1).trim();
            
            key = key.replaceAll('"', '').replaceAll("'", '');
            value = value.replaceAll('"', '').replaceAll("'", '');
            
            // Handle different possible field names
            String normalizedKey = key;
            if (key == 'currentCoachld') normalizedKey = 'currentCoachId'; // Fix typo
            if (key == 'coachId') normalizedKey = 'currentCoachId';
            if (key == 'berthNo') normalizedKey = 'currentBerthNo';
            if (key == 'berthCode') normalizedKey = 'currentBerthCode';
            if (key == 'status') normalizedKey = 'currentStatus';
            if (key == 'serialNumber') normalizedKey = 'passengerSerialNumber';
            
            if (value == 'true' || value == 'false') {
              passenger[normalizedKey] = value == 'true';
            } else if (value.contains(RegExp(r'^\d+$'))) {
              passenger[normalizedKey] = int.tryParse(value) ?? value;
            } else {
              passenger[normalizedKey] = value;
            }
          }
        }
        
        if (passenger.isNotEmpty) {
          passengers.add(passenger);
        }
      }
    } catch (e) {
      print('Error parsing passenger list: $e');
    }
    
    return passengers;
  }

  Future<void> fetchPNRStatus(String pnr) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _parsedData = null;
    });

    final url = Uri.parse('https://irctc-indian-railway-pnr-status.p.rapidapi.com/getPNRStatus/$pnr');
    
    try {
      const apiKey = '3c2a7c429cmsh23642ae008e61aep1ec4c1jsn27453a293f08';
      
      final response = await http.get(
        url,
        headers: {
          'X-Rapidapi-Key': apiKey,
          'X-Rapidapi-Host': 'irctc-indian-railway-pnr-status.p.rapidapi.com',
        },
      );
      
      if (response.statusCode == 200) {
        try {
        final data = json.decode(response.body);
          
          if (data['status'] == true || data['success'] == true) {
            // Handle the nested data structure directly
            Map<String, dynamic> parsedData = {};
            
            if (data['data'] != null) {
              if (data['data'] is Map<String, dynamic>) {
                // If data is already a Map, use it directly
                parsedData = Map<String, dynamic>.from(data['data']);
              } else {
                // If data is a string, try to parse it as JSON
                try {
                  final textData = data['data'].toString();
                  parsedData = manualParsePNRData(textData);
                  
                  // Handle nested data structure - check if passengerList is inside a data object
                  if (parsedData['data'] != null && parsedData['data'] is Map<String, dynamic>) {
                    final nestedData = parsedData['data'] as Map<String, dynamic>;
                    if (nestedData['passengerList'] != null) {
                      parsedData['passengerList'] = nestedData['passengerList'];
                      // Also copy other fields from nested data
                      parsedData['pnrNumber'] = nestedData['pnrNumber'];
                    }
                  }
                } catch (e) {
                  print('Error parsing data as JSON: $e');
                }
              }
            }
            
            // Ensure passengerList is properly structured
            if (parsedData['passengerList'] != null && parsedData['passengerList'] is List) {
              final passengerList = parsedData['passengerList'] as List;
              print('Successfully parsed ${passengerList.length} passengers');
              
              // Validate passenger structure
              for (int i = 0; i < passengerList.length; i++) {
                final passenger = passengerList[i];
                if (passenger is Map<String, dynamic>) {
                  print('Passenger $i keys: ${passenger.keys.toList()}');
                  print('Passenger $i data: $passenger');
                  
                  // Check specific fields we need
                  print('  passengerSerialNumber: ${passenger['passengerSerialNumber']} (${passenger['passengerSerialNumber']?.runtimeType})');
                  print('  currentStatus: ${passenger['currentStatus']} (${passenger['currentStatus']?.runtimeType})');
                  print('  currentCoachId: ${passenger['currentCoachId']} (${passenger['currentCoachId']?.runtimeType})');
                  print('  currentBerthNo: ${passenger['currentBerthNo']} (${passenger['currentBerthNo']?.runtimeType})');
                  print('  currentBerthCode: ${passenger['currentBerthCode']} (${passenger['currentBerthCode']?.runtimeType})');
                } else {
                  print('Passenger $i is not a Map: ${passenger.runtimeType}');
                }
              }
            } else {
              print('No passenger list found or invalid format');
              print('passengerList type: ${parsedData['passengerList']?.runtimeType}');
              print('passengerList value: ${parsedData['passengerList']}');
              
              // Let's see what keys are actually in the parsed data
              print('All parsed data keys: ${parsedData.keys.toList()}');
              for (String key in parsedData.keys) {
                print('  $key: ${parsedData[key]} (${parsedData[key]?.runtimeType})');
              }
            }
            
          setState(() {
            _parsedData = parsedData;
          });
        } else {
            final errorMessage = data['message'] ?? 'Invalid PNR or network error.';
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
        } catch (jsonError) {
          print('JSON parsing error: $jsonError');
          setState(() {
            _error = 'Invalid response format from server.';
          });
        }
      } else if (response.statusCode == 403) {
        setState(() {
          _error = 'Access forbidden (403). Check your API key, host, or quota.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access forbidden (403). Check your API key, host, or quota.')),
        );
      } else {
        setState(() {
          _error = 'Server error (${response.statusCode}). Please try again later.';
        });
      }
    } catch (e) {
      print('Network error: $e');
      setState(() {
        _error = 'Network error. Please check your connection and try again.';
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
                          Icon(Icons.train, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'PNR Status',
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
                        'Check your live booking details',
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
                      onPressed: _parsedData != null ? () => fetchPNRStatus(_pnrController.text) : null,
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
                                  'Check PNR Status',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _pnrController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter 10-digit PNR number',
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
                                prefixIcon: Icon(Icons.confirmation_number, color: AppTheme.accent),
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoading ? null : () => fetchPNRStatus(_pnrController.text),
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
                                      _isLoading ? 'Checking...' : 'Check Status',
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
                      
                      if (_parsedData != null) ...[
                        const SizedBox(height: 24),
                        
                        // Train Information Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                          '${_parsedData?['trainName'] ?? _parsedData?['train'] ?? 'Train'} (${_parsedData?['trainNumber'] ?? 'Number'})',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_parsedData?['sourceStation'] ?? _parsedData?['from'] ?? 'From'} → ${_parsedData?['destinationStation'] ?? _parsedData?['to'] ?? 'To'}',
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      icon: Icons.calendar_today,
                                      label: 'Journey Date',
                                      value: _parsedData?['dateOfJourney'] ?? _parsedData?['journeyDate'] ?? 'N/A',
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      icon: Icons.assignment_turned_in,
                                      label: 'Chart Status',
                                      value: _parsedData?['chartStatus'] ?? _parsedData?['chart_status'] ?? 'N/A',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Divider
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Passenger List Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accent2.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.people, color: AppTheme.accent2, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Passenger Information',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.accent2.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_parsedData?['numberOfpassenger'] ?? _parsedData?['passengerList']?.length ?? 0} passengers',
                                style: TextStyle(
                                  color: AppTheme.accent2,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Passenger List
                        if (_parsedData != null && _parsedData!['passengerList'] != null) ...[
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              final passengerList = _parsedData!['passengerList'];
                              
                              // Type safety checks
                              if (passengerList == null) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                  ),
                                  child: const Text(
                                    'No passenger data available',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                );
                              }
                              
                              if (passengerList is! List) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    'Invalid passenger data format: ${passengerList.runtimeType}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }
                              
                              if (passengerList.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                  ),
                                  child: const Text(
                                    'No passengers found',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                );
                              }
                              
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: passengerList.length,
                                itemBuilder: (context, index) {
                                  final passenger = passengerList[index];
                                  
                                  // More lenient type checking - accept any non-null value
                                  if (passenger == null) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        'Passenger $index: Null data',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    );
                                  }
                                  
                                  // Try to convert to Map if it's not already
                                  Map<String, dynamic> passengerMap;
                                  if (passenger is Map<String, dynamic>) {
                                    passengerMap = passenger;
                                  } else {
                                    // If it's not a Map, try to convert it or create a safe fallback
                                    try {
                                      passengerMap = {'passengerSerialNumber': index + 1, 'data': passenger.toString()};
                                    } catch (e) {
                                      passengerMap = {'passengerSerialNumber': index + 1, 'error': 'Invalid data format'};
                                    }
                                  }
                                  
                                  // Safe passenger card rendering
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildPassengerCard(passengerMap),
                                  );
                                },
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

  Widget _buildInfoItem({required IconData icon, required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.accent2, size: 18),
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerCard(Map<String, dynamic> passenger) {
    // Safely extract passenger data with full null safety
    final passengerSerialNumber = _safeExtractString(passenger, 'passengerSerialNumber');
    final currentStatus = _safeExtractString(passenger, 'currentStatus');
    final currentCoachId = _safeExtractString(passenger, 'currentCoachId');
    final currentBerthNo = _safeExtractString(passenger, 'currentBerthNo');
    final currentBerthCode = _safeExtractString(passenger, 'currentBerthCode');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Passenger Number and Status
            Row(
              children: [
                Icon(Icons.person, color: AppTheme.accent, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Passenger $passengerSerialNumber',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (currentStatus == 'CNF') ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (currentStatus == 'CNF') ? Colors.green : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    currentStatus,
                    style: TextStyle(
                      color: (currentStatus == 'CNF') ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Seat Details - Vertical Layout
            Column(
              children: [
                _buildDetailRow(
                  icon: Icons.train,
                  label: 'Coach',
                  value: currentCoachId,
                  color: AppTheme.accent2,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.event_seat,
                  label: 'Berth No',
                  value: currentBerthNo,
                  color: AppTheme.accent,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.receipt,
                  label: 'Berth Code',
                  value: currentBerthCode,
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to safely extract string values from passenger data
  String _safeExtractString(Map<String, dynamic> passenger, String key) {
    try {
      final value = passenger[key];
      if (value == null) return 'N/A';
      
      // Handle different data types safely
      if (value is String) return value;
      if (value is int) return value.toString();
      if (value is double) return value.toString();
      if (value is bool) return value.toString();
      
      // For any other type, try to convert to string
      return value.toString();
    } catch (e) {
      // If anything goes wrong, return N/A
      return 'N/A';
    }
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 