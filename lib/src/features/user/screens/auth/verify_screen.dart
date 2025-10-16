import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../../../presentation/layouts/modal_layout.dart';

class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalLayout(
      title: 'Email Verification',
      subtitle:
          'We sent a verification code to your email. Please enter it below.',
      child: const Text('Verify Screen - Form Coming Soon'),
    );
  }
}
