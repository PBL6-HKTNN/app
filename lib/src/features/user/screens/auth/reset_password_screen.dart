import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../widgets/auth/reset_password_form.dart';
import '../../../../locale/index.dart';
import '../../../../presentation/layouts/modal_layout.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ModalLayout(
      title: l10n.resetPassword,
      subtitle:
          'Enter your email to receive a reset code, then set your new password.',
      child: const ResetPasswordForm(),
    );
  }
}
