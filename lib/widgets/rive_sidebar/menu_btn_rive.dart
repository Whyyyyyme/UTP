import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class MenuBtnRive extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onTap;

  const MenuBtnRive({super.key, required this.isOpen, required this.onTap});

  @override
  State<MenuBtnRive> createState() => _MenuBtnRiveState();
}

class _MenuBtnRiveState extends State<MenuBtnRive> {
  SMIBool? _isOpenInput;

  @override
  void didUpdateWidget(covariant MenuBtnRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOpen != widget.isOpen) {
      _isOpenInput?.value = widget.isOpen;
    }
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "State Machine",
    );

    if (controller == null) return;
    artboard.addController(controller);

    // menu_button.riv biasanya pakai input boolean "isOpen"
    final input = controller.findInput<bool>("isOpen");
    if (input is SMIBool) {
      _isOpenInput = input;
      _isOpenInput?.value = widget.isOpen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: RiveAnimation.asset(
          "assets/RiveAssets/menu_button.riv",
          fit: BoxFit.cover,
          onInit: _onRiveInit,
        ),
      ),
    );
  }
}
