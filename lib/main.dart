import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? image;
  final picker = ImagePicker();

  Future getImageFromGallery() async {
    final XFile? _image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (_image != null) {
        image = File(_image.path);
      }
    });
  }

  Future getImageFromCamera() async {
    final XFile? _image = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (_image != null) {
        image = File(_image.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('アルバム・カメラから画像を読み込む')),
      body: Center(
        child: image == null
            ? const Text('画像がありません')
            : Image.file(image!, fit: BoxFit.cover),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: () async {
              await getImageFromGallery();
            },
            child: const Icon(Icons.photo),
            tooltip: 'アルバムから選択',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: () async {
              await getImageFromCamera();
            },
            child: const Icon(Icons.camera_alt),
            tooltip: 'カメラで撮影',
          ),
        ],
      ),
    );
  }
}