import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../widgets/avatar_picker.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    // whether current user can edit avatar
    final canEdit = user.role.toLowerCase() == 'student';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 6))],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  // compact avatar preview left
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: user.avatarUrl != null
                          ? (user.avatarUrl!.startsWith('http') ? NetworkImage(user.avatarUrl!) : FileImage(File(user.avatarUrl!)) as ImageProvider)
                          : null,
                      child: user.avatarUrl == null ? const Icon(Icons.person, size: 28, color: Colors.white) : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // name + role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(user.role.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        )
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // open settings or logout later
                    },
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // big avatar + picker
                const Center(child: AvatarPicker()),
                const SizedBox(height: 20),

                // Info card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Account', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        _infoRow(Icons.person, 'Full name', user.name),
                        const Divider(),
                        _infoRow(Icons.email, 'Email', user.email),
                        const Divider(),
                        _infoRow(Icons.badge, 'Role', user.role),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Stats card (example)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem(context, '12', 'Courses'),
                        _statItem(context, '4', 'Completed'),
                        _statItem(context, '23', 'Hours Studied'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                if (canEdit)
                  ElevatedButton.icon(
                    onPressed: () {
                      // maybe open edit profile form later
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  )
                else
                  OutlinedButton(
                    onPressed: null,
                    child: const Text('Editing available for Students only'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),

                const SizedBox(height: 28),
                // Danger action
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: logout
                  },
                  icon: const Icon(Icons.logout_outlined),
                  label: const Text('Logout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54))),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, String count, String label) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
