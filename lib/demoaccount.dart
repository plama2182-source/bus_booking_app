import 'package:flutter/material.dart';

class DemoAccountsPage extends StatelessWidget {
  const DemoAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Accounts'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _accountCard(
            context,
            title: 'Normal User',
            icon: Icons.person,
            email: 'demo.user@example.com',
            password: 'DemoUser123',
          ),

          _accountCard(
            context,
            title: 'Bus Admin',
            icon: Icons.directions_bus,
            email: 'demo.busadmin@example.com',
            password: 'DemoBusAdmin123',
          ),

          _accountCard(
            context,
            title: 'Super Admin',
            icon: Icons.admin_panel_settings,
            email: 'demo.admin@example.com',
            password: 'DemoAdmin123',
          ),
        ],
      ),
    );
  }

  Widget _accountCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String email,
    required String password,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text('Email: $email'),
            const SizedBox(height: 8),
            Text('Password: $password'),
          ],
        ),
      ),
    );
  }
}