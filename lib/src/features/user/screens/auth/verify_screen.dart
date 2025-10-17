import 'package:codemy_app/src/features/user/widgets/auth/verify_form.dart';
import 'package:codemy_app/src/presentation/layouts/modal_layout.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class VerifyScreen extends StatelessWidget {
  final String? email;
  const VerifyScreen({this.email, super.key});

  @override
  Widget build(BuildContext context) {
    return ModalLayout(
      title: 'Email Verification',
      subtitle:
          'We sent a verification code to your email. Please enter it below.',
      child: VerifyForm(email: email),
    );
  }
}
