import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

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

class ImageWithLocation {
  final File image;
  final LatLng location;
  ImageWithLocation(this.image, this.location);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final picker = ImagePicker();
  final List<ImageWithLocation> _images = [];
  final MapController _mapController = MapController(); // 追加

  Future<void> _getImage(ImageSource source) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('位置情報の権限がありません')),
      );
      return;
    }
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _images.add(
          ImageWithLocation(
            File(pickedFile.path),
            LatLng(position.latitude, position.longitude),
          ),
        );
      });
    }
  }

  Future<void> _moveToCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('位置情報の権限がありません')),
      );
      return;
    }
    Position position = await Geolocator.getCurrentPosition();
    _mapController.move(
      LatLng(position.latitude, position.longitude),
      _mapController.camera.zoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OpenStreetMapにピン止め')),
      body: FlutterMap(
        mapController: _mapController, // 追加
        options: MapOptions(
          initialCenter: LatLng(35.681236, 139.767125),
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: _images.asMap().entries.map((entry) {
              int index = entry.key;
              ImageWithLocation imgLoc = entry.value;
              return Marker(
                width: 40,
                height: 40,
                point: imgLoc.location,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        content: Image.file(imgLoc.image),
                      ),
                    );
                  },
                  onLongPress: () {
                    setState(() {
                      _images.removeAt(index);
                    });
                  },
                  child: const Icon(Icons.location_on,
                      color: Colors.red, size: 40),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'location',
            onPressed: _moveToCurrentLocation,
            child: const Icon(Icons.my_location),
            tooltip: '現在地に移動',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: () => _getImage(ImageSource.gallery),
            child: const Icon(Icons.photo),
            tooltip: 'アルバムから選択',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: () => _getImage(ImageSource.camera),
            child: const Icon(Icons.camera_alt),
            tooltip: 'カメラで撮影',
          ),
        ],
      ),
    );
  }
}
