import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HomeTab extends StatelessWidget {
  final String userName;
  const HomeTab({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final cardData = [
      {
        'icon': Icons.schedule,
        'label': 'Check Train Schedule',
        'color': Theme.of(context).colorScheme.primary,
        'onTap': () => Navigator.pushNamed(context, '/train_status'),
      },
      {
        'icon': Icons.directions_train,
        'label': 'Live Running Status',
        'color': AppTheme.accent2,
        'onTap': () => Navigator.pushNamed(context, '/live_running_status'),
      },
      {
        'icon': Icons.receipt_long,
        'label': 'PNR Status',
        'color': Theme.of(context).colorScheme.secondary,
        'onTap': () => Navigator.pushNamed(context, '/pnr_status'),
      },
      {
        'icon': Icons.event_seat,
        'label': 'Seat Availability',
        'color': Colors.purpleAccent,
        'onTap': () => Navigator.pushNamed(context, '/seat_availability'),
      },
      {
        'icon': Icons.attach_money,
        'label': 'Fare Enquiry',
        'color': Colors.amberAccent,
        'onTap': () => Navigator.pushNamed(context, '/fare_enquiry'),
      },
    ];

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $userName',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 1.1,
                ),
                itemCount: cardData.length,
                itemBuilder: (context, i) {
                  final data = cardData[i];
                  return GestureDetector(
                    onTap: data['onTap'] as void Function(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white.withOpacity(0.08),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(color: Colors.white12),
                        backgroundBlendMode: BlendMode.overlay,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: (data['color'] as Color).withOpacity(0.18),
                            radius: 28,
                            child: Icon(
                              data['icon'] as IconData,
                              color: data['color'] as Color,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data['label'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
} 