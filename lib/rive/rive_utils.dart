// lib/utils/rive_utils.dart
import 'package:rive/rive.dart';

class RiveUtils {
  static SMIBool? getRiveInput(
    Artboard artboard, {
    required String stateMachineName,
  }) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      stateMachineName,
    );

    if (controller == null) return null;

    artboard.addController(controller);

    final input = controller.findInput<bool>("active");
    if (input is SMIBool) return input;

    return null;
  }

  static void changeSMIBoolState(SMIBool input) {
    input.change(true);
    Future.delayed(const Duration(milliseconds: 800), () {
      input.change(false);
    });
  }
}
