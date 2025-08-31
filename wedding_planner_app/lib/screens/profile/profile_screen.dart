import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.user?.name ?? 'Guest',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  if (auth.user?.email != null)
                    Text('📧 ${auth.user!.email}')
                  else
                    const SizedBox.shrink(),
                  if (auth.user?.phone != null)
                    Text('📱 ${auth.user!.phone}')
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Danger Zone',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final yes = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Reset data?'),
                          content: const Text(
                              'This will clear local saved user and app state.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: const Text('Reset')),
                          ],
                        ),
                      );
                      if (yes == true) {
                        await Provider.of<AuthProvider>(context, listen: false)
                            .logout();
                      }
                    },
                    child: const Text('Reset all data'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE6EE)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
