import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shop_audit/component/internal_shop.dart';
import 'package:shop_audit/global/global_variants.dart';
import 'package:shop_audit/main.dart';
import 'package:shop_audit/pages/camera_handler.dart';

String photoPath = '';

class PhotoPage extends StatefulWidget
{
  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<PhotoPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState(){
    _controller = CameraController(
      CameraHandler().cameras![0],
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _initializeControllerFuture = _controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as CustomArgument;
    InternalShop shop = sqlFliteDB.shops[args.shopId]!;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(shop.shopName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: () {
            Navigator.of(context).pop();
          },
          )
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            if (!mounted) return;
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                ),
              ),
            );
            if(photoPath != ''){
              File photoFile = File(photoPath);
              var dir = await getApplicationSupportDirectory();
              String newName = DateTime.now().millisecondsSinceEpoch.toString();
              photoFile.copySync('${dir.path}/$newName.jpg');
              sqlFliteDB.setPhoto(args.shopId, args.photoType, '${dir.path}/$newName.jpg');
              Navigator.of(context).pop();
            }
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Stack(
                fit: StackFit.passthrough,
                children: [
                  Image.file(
                    File(imagePath)
                    ,fit: BoxFit.cover,
                  ),
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: IconButton(
                        iconSize: 50,
                        onPressed: () {
                          photoPath = imagePath;
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.check),
                      )
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        iconSize: 50,
                        onPressed: () {
                          photoPath = '';
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.cancel),
                      )
                  ),
                ]
            )
        )
    );
  }
}