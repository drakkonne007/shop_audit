import 'package:camera/camera.dart';

class CameraHandler
{
  static final CameraHandler _cameraHandler = CameraHandler._internal();
  factory CameraHandler() {
    return _cameraHandler;
  }
  CameraHandler._internal();

  List<CameraDescription>? cameras;
  List<String> imagePaths = [];

  Future<void> loadCameras() async
  {
    cameras = await availableCameras();
  }
}