// lib/rive/rive_utils.dart
import 'package:rive/rive.dart';

class RiveUtils {
  static SMIBool getRiveInput(
    Artboard artboard, {
    required String stateMachineName,
  }) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      stateMachineName,
    );

    artboard.addController(controller!);

    return controller.findInput<bool>("active") as SMIBool;
  }

  static void changeSMIBoolState(SMIBool input) {
    input.change(true);
    Future.delayed(const Duration(milliseconds: 800), () {
      input.change(false);
    });
  }
}
