import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'HomeScreen.dart';
import 'package:vitapp/src/Widgets/SnackBar.dart';
import 'package:vitapp/src//Widgets/header.dart';
import 'package:image/image.dart' as im;
import '../constants.dart';

class AddNotice extends StatefulWidget {
  @override
  _AddNoticeState createState() => _AddNoticeState();
}

class _AddNoticeState extends State<AddNotice> {
  TextEditingController _noticeController = TextEditingController();
  TextEditingController _fromController = TextEditingController();
  bool noticeError = false;
  bool fromError = false;
  bool _loading = false;
  File file;
  String postId = Uuid().v4();
  String ownerId = Uuid().v4();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(
        context,
        isAppTitle: false,
        titleText: 'Add Notice',
        isCenterTitle: true,
        bold: true,
        isLogout: true,
      ),
      body: _loading
          ? CircularProgressIndicator()
          : ListView(
              children: [
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 15.0, right: 15.0),
                        child: TextFormField(
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          controller: _noticeController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Add Notice Here....',
                            labelText: 'Notice',
                            errorText: noticeError ? 'Notice is empty' : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0),
                      GestureDetector(
                        onTap: () => {selectImage(context)},
                        child: Container(
                          height: 200.0,
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  image: file != null
                                      ? DecorationImage(image: FileImage(file))
                                      : DecorationImage(
                                          image: AssetImage(
                                              'assets/images/upload.jpg')),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 30.0),
                        child: Text(
                          'Adding Image is Optional',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0, bottom: 10.0),
                        child: TextFormField(
                          maxLines: 1,
                          controller: _fromController,
                          decoration: InputDecoration(
                            hintText: 'ex. David Assistant Professor',
                            labelText: 'From:',
                            errorText:
                                fromError ? 'This field is required' : null,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      Container(
                        height: 50.0,
                        width: 350.0,
                        child: Material(
                          borderRadius: BorderRadius.circular(5.0),
                          elevation: 2.0,
                          color: kPrimaryColor,
                          child: InkWell(
                            onTap: onSubmit,
                            child: Center(
                              child: Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  selectImage(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  'Open a Camera',
                  style: TextStyle(
                    fontFamily: 'mont',
                    fontSize: 17.0,
                  ),
                ),
                onPressed: () => handleTakePhoto(context),
              ),
              SimpleDialogOption(
                child: Text(
                  'Open a Gallery',
                  style: TextStyle(
                    fontFamily: 'mont',
                    fontSize: 17.0,
                  ),
                ),
                onPressed: () => handleChooseFromGallery(context),
              ),
              SimpleDialogOption(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'mont',
                    fontSize: 17.0,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  handleTakePhoto(BuildContext context) async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = File(pickedFile.path);
    });
  }

  handleChooseFromGallery(BuildContext context) async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    setState(() {
      this.file = File(pickedFile.path);
    });
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    im.Image imageFile = im.decodeImage(file.readAsBytesSync());

    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(
        im.encodeJpg(imageFile, quality: 80),
      );

    setState(() {
      file = compressedImageFile;
    });
  }

  void onSubmit() async {
    if (_fromController.text.trim().isEmpty) {
      setState(() {
        fromError = true;
      });
    } else {
      setState(() {
        fromError = false;
      });
    }

    if (_noticeController.text.trim().isEmpty) {
      setState(() {
        noticeError = true;
      });
    } else {
      noticeError = false;
    }

    if (_fromController.text.trim().isNotEmpty &&
        _noticeController.text.trim().isNotEmpty) {
      String notice = _noticeController.text.trim();
      String from = _fromController.text.trim();

      if (file != null) {
        await compressImage();
      }
      sendNotice(notice, from, file);
    }
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child('posts').child('post_$postId.jpg').putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> sendNotice(notice, from, file) async {
    try {
      String mediaUrl = '';
      if (file != null) {
        mediaUrl = await uploadImage(file);
      }

      Map<String, dynamic> data = {
        'postId': postId,
        'from': from,
        'mediaUrl': mediaUrl,
        'notice': notice,
        'timestamp': DateTime.now()
      };
      await postRef
          .doc(from)
          .collection(postId)
          .doc(DateTime.now().toString())
          .set(data)
          .then((value) {
        _scaffoldKey.currentState.showSnackBar(snackBar(
          context,
          isErrorSnackbar: false,
          successText: 'Notice sent Successfully',
        ));
      });
      await timelineRef
          .doc('all')
          .collection('timelinePost')
          .doc(postId)
          .set(data)
          .then((value) {
        _scaffoldKey.currentState.showSnackBar(snackBar(
          context,
          isErrorSnackbar: false,
          successText: 'Notice sent Successfully',
        ));
        Timer.periodic(new Duration(seconds: 2), (time) {
          Navigator.pop(context);
          time.cancel();
        });
      });
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(snackBar(context,
          isErrorSnackbar: true, errorText: 'Something went wrong'));
    }
    setState(() {
      _loading = false;
    });
  }
}
