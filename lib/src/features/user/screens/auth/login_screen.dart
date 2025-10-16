import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../widgets/auth/login_form.dart';
import '../../../../locale/index.dart';
import '../../../../presentation/layouts/modal_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ModalLayout(
      title: l10n.login,
      subtitle: 'Welcome back! Please sign in to your account.',
      child: const LoginForm(),
    );
  }
}
