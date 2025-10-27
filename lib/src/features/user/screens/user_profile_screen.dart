import 'dart:io';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../widgets/avatar_picker.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final canEdit = (user?.role ?? -1) == 2;
    final displayName = user?.name ?? 'Guest';
    final displayEmail = user?.email ?? '';
    final displayRole = _getRoleText(user?.role ?? -1);

    return Scaffold(
      backgroundColor: Colors.gray[100],
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
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
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
                    onPressed: () => context.go('/'),
                    child: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
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
                              color: Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Avatar(
                            size: 52,
                            provider: user?.profilePicture.isNotEmpty == true
                                ? (user!.profilePicture.startsWith('http')
                                          ? NetworkImage(user.profilePicture)
                                          : FileImage(
                                              File(user.profilePicture),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap(4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  displayRole.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Settings button
                  Button.ghost(
                    onPressed: () {},
                    child: const Icon(
                      Icons.settings,
                      color: Colors.white,
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
                const Gap(24),

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
                      _infoRow(Icons.person, 'Full name', displayName),
                      const Divider(height: 1),
                      _infoRow(LucideIcons.mail, 'Email', displayEmail),
                      const Divider(height: 1),
                      _infoRow(Icons.badge, 'Role', displayRole),
                    ],
                  ),
                ),

                const Gap(16),

                // Stats Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statItem('12', 'Courses'),
                        Container(
                          width: 1,
                          height: 36,
                          color: Colors.gray[300],
                        ),
                        _statItem('4', 'Completed'),
                        Container(
                          width: 1,
                          height: 36,
                          color: Colors.gray[300],
                        ),
                        _statItem('23', 'Hours Studied'),
                      ],
                    ),
                  ),
                ),

                const Gap(24),

                // Action Buttons
                if (canEdit)
                  Button.primary(
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(LucideIcons.pencil, size: 18),
                        Gap(8),
                        Text('Edit Profile'),
                      ],
                    ),
                  )
                else
                  Button.ghost(
                    onPressed: null,
                    child: const Text('Editing available for Students only'),
                  ),

                const Gap(12),

                Button.destructive(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(LucideIcons.logOut, size: 18),
                      Gap(8),
                      Text('Logout'),
                    ],
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const Gap(12),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
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

  Widget _statItem(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const Gap(4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.gray[600])),
      ],
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
