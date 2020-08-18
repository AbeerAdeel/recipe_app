import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageItem extends StatefulWidget {
  ImageItem({Key key, this.imageFile}) : super(key: key);
  final String imageFile;
  @override
  _ImageItemState createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  Uint8List imageFile;
  StorageReference photosReference =
      FirebaseStorage.instance.ref().child('images');

  @override
  void dispose() {
    super.dispose();
  }

  getImage() {
    int MAX_SIZE = 2 * 1024 * 1024;
    photosReference.child(widget.imageFile).getData(MAX_SIZE).then((data) {
      if (this.mounted) {
        this.setState(() {
          imageFile = data;
        });
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

  Widget imageWidget() {
    if (imageFile == null) {
      return Center(child: Text("No image"));
    } else {
      return Image.memory(imageFile, fit: BoxFit.cover);
    }
  }

  @override
  void initState() {
    super.initState();
    if (this.mounted) {
      getImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return imageWidget();
  }
}
