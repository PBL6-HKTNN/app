import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../providers/auth_providers.dart';
import '../widgets/avatar_picker.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final displayName = user?.name ?? 'Guest';
    final displayEmail = user?.email ?? '';
    final displayRole = _getRoleText(user?.role ?? -1);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 48,
              left: 16,
              right: 16,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  // Back button
                  Button.ghost(
                    onPressed: () => context.pop(),
                    child: Icon(
                      LucideIcons.arrowLeft,
                      color: Theme.of(context).colorScheme.foreground,
                      size: 24,
                    ),
                  ),
                  const Gap(12),
                  // Avatar + Info
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.muted,
                              width: 2,
                            ),
                          ),
                          child: Avatar(
                            size: 52,
                            provider: user?.profilePicture!.isNotEmpty == true
                                ? (user!.profilePicture!.startsWith('http')
                                          ? NetworkImage(user.profilePicture!)
                                          : FileImage(
                                              File(user.profilePicture!),
                                            ))
                                      as ImageProvider
                                : null,
                            initials: user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        const Gap(12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.foreground,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap(4),
                              PrimaryBadge(
                                child: Text(displayRole.toUpperCase()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Settings button
                  Button.ghost(
                    onPressed: () {
                      context.push('/settings');
                    },
                    child: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.foreground,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const AvatarPicker(),
                const Gap(16),
                // Account Card
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _infoRow(context, Icons.person, 'Full name', displayName),
                      const Divider(height: 1),
                      _infoRow(
                        context,
                        LucideIcons.mail,
                        'Email',
                        displayEmail,
                      ),
                      const Divider(height: 1),
                      _infoRow(context, Icons.badge, 'Role', displayRole),
                    ],
                  ),
                ),
                const Gap(24),
                // Action Buttons
                Button.primary(
                  onPressed: () {
                    context.push('/profile/edit');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(LucideIcons.pencil, size: 18),
                      Gap(8),
                      Text('Edit Profile'),
                    ],
                  ),
                ),
                const Gap(24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.mutedForeground,
          ),
          const Gap(12),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.mutedForeground,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

String _getRoleText(int role) {
  switch (role) {
    case 0:
      return 'Admin';
    case 1:
      return 'Instructor';
    case 2:
      return 'Student';
    default:
      return 'Unknown';
  }
}
