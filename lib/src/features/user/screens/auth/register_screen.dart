import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../widgets/auth/register_form.dart';
import '../../../../locale/index.dart';
import '../../../../presentation/layouts/modal_layout.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ModalLayout(
      title: l10n.register,
      subtitle: 'Create your account to get started.',
      padding: const EdgeInsets.all(16.0),
      child: const RegisterForm(),
    );
  }
}
