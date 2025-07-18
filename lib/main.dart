import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'screens/main_nav_screen.dart';
import 'screens/google_login_screen.dart';
import 'screens/tabs/train_schedule_tab.dart';
import 'screens/tabs/pnr_tab.dart';
import 'screens/tabs/seat_availability_tab.dart';
import 'screens/tabs/fare_enquiry_tab.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/tabs/live_running_status_tab.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyRailLiteRoot());
}

class MyRailLiteRoot extends StatelessWidget {
  const MyRailLiteRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GoogleSignInAccount?>(
      valueListenable: userNotifier,
      builder: (context, user, _) => MyRailLiteApp(user: user),
    );
  }
}

class MyRailLiteApp extends StatelessWidget {
  final GoogleSignInAccount? user;
  const MyRailLiteApp({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyRail Lite',
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      routes: {
        '/main_nav': (context) => MainNavScreen(
              userName: user?.displayName ?? 'User',
              userEmail: user?.email ?? '',
              userPhotoUrl: user?.photoUrl,
            ),
        '/google_login': (context) => const GoogleLoginScreen(),
        '/train_status': (context) => const TrainScheduleTab(),
        '/pnr_status': (context) => const PNRStatusTab(),
        '/seat_availability': (context) => const SeatAvailabilityTab(),
        '/fare_enquiry': (context) => const FareEnquiryTab(),
        '/live_running_status': (context) => const LiveRunningStatusTab(),
      },
    );
  }
}
