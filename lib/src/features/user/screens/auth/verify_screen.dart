import 'package:codemy_app/src/features/user/widgets/auth/verify_form.dart';
import 'package:codemy_app/src/locale/index.dart';
import 'package:codemy_app/src/presentation/layouts/modal_layout.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class VerifyScreen extends StatelessWidget {
  final String? email;
  const VerifyScreen({this.email, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ModalLayout(
      title: l10n.emailVerification,
      subtitle: l10n.emailVerificationSubtitle,
      child: VerifyForm(email: email),
    );
  }
}
