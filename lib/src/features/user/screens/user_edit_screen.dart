import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../providers/user_provider.dart';
import '../widgets/user/change_avatar_form.dart';
import '../widgets/user/change_info_form.dart';
import '../widgets/user/change_password_form.dart';

enum EditTab { profile, avatar, password }

class UserEditScreen extends ConsumerStatefulWidget {
  final EditTab initialTab;

  const UserEditScreen({super.key, this.initialTab = EditTab.profile});

  @override
  ConsumerState<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends ConsumerState<UserEditScreen> {
  late EditTab _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTab = EditTab.values[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton(
              variance: ButtonVariance.ghost,
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => context.pop(),
            ),
          ],
          title: const Text('Edit Profile'),
        ),
      ],
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
          child: Column(
            children: [
              // Tab Navigation
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.muted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Tabs(
                  index: _currentTab.index,
                  onChanged: _onTabChanged,
                  children: const [
                    TabItem(child: Text('Profile')),
                    TabItem(child: Text('Avatar')),
                    TabItem(child: Text('Password')),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildCurrentTab(user),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab(user) {
    switch (_currentTab) {
      case EditTab.profile:
        return ChangeInfoForm(key: const ValueKey('profile'), user: user);
      case EditTab.avatar:
        return ChangeAvatarForm(key: const ValueKey('avatar'), user: user);
      case EditTab.password:
        return const ChangePasswordForm(key: ValueKey('password'));
    }
  }
}
