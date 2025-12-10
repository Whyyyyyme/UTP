import 'package:rive/rive.dart';

class RiveModel {
  final String src;
  final String artboard;
  final String stateMachineName;
  SMIBool? status; // ini nanti diisi saat onInit()

  RiveModel({
    required this.src,
    required this.artboard,
    required this.stateMachineName,
    this.status,
  });

  set setStatus(SMIBool state) {
    status = state;
  }
}
