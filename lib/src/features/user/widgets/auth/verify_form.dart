import 'package:flutter/material.dart'
    show
        BuildContext,
        Widget,
        TextEditingController,
        Text,
        CrossAxisAlignment,
        SizedBox,
        Column,
        Theme,
        TextStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    show TextField, Button, CircularProgressIndicator;
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/verify.dart';
import 'package:codemy_app/src/features/user/providers/auth_providers.dart';

class VerifyForm extends ConsumerStatefulWidget {
  final String? email;
  const VerifyForm({this.email, super.key});

  @override
  ConsumerState<VerifyForm> createState() => _VerifyFormState();
}

class _VerifyFormState extends ConsumerState<VerifyForm> {
  final _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final authNotifier = ref.read(authStateProvider.notifier);

    final email = widget.email ?? '';
    final token = _tokenController.text.trim();

    if (token.isEmpty) {
      // Show error or set error state
      return;
    }

    final verifyDto = VerifyDto(email: email, token: token);

    await authNotifier.verifyEmail(verifyDto);

    // Check if email is verified and navigate
    final updatedState = ref.read(authStateProvider);
    if (updatedState.user?.emailVerified == true) {
      Logger.log('Email verified, navigating to home', tag: 'AUTH');
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    final email = widget.email ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: TextEditingController(text: email),
          enabled: false,
          placeholder: Text('Email'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _tokenController,
          placeholder: Text('Verification Token'),
        ),
        const SizedBox(height: 24),
        if (authState.error != null)
          Text(
            authState.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        const SizedBox(height: 16),
        Button.primary(
          onPressed: authState.isLoading ? null : _handleVerify,
          child: authState.isLoading
              ? const CircularProgressIndicator()
              : const Text('Verify Email'),
        ),
      ],
    );
  }
}
