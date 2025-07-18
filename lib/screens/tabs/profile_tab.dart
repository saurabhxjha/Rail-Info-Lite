import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../user_provider.dart';

class ProfileTab extends StatefulWidget {
  final GoogleSignInAccount? user;
  const ProfileTab({Key? key, this.user}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _loading = false;
  String? _error;

  Future<void> _handleSignOut() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await GoogleSignIn().signOut();
      userNotifier.value = null;
      if (mounted) Navigator.of(context).pushReplacementNamed('/google_login');
    } catch (e) {
      setState(() => _error = 'Logout failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user?.photoUrl != null)
              CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(user!.photoUrl!),
              )
            else
              const CircleAvatar(
                radius: 48,
                child: Icon(Icons.person, size: 48),
              ),
            const SizedBox(height: 24),
            Text(
              user?.displayName ?? 'Guest User',
              style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleSignOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Sign Out from Google',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }
} 