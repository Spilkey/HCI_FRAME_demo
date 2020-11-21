import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'select_recipients.dart';
import 'confirmation.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
      routes: <String, WidgetBuilder> {
        '/recipientScreen': (BuildContext context) =>
        RecipientScreen(),
        '/confirmationScreen': (BuildContext context) =>
        Confirmation()
      }
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  final picker = ImagePicker();

  Image selectedImage;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  bool _pictureTaken = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            var imageOrCamera = CameraPreview(_controller);

            return Stack(
              children: <Widget>[
                (selectedImage != null ? selectedImage : imageOrCamera),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Visibility(
                      visible: !_pictureTaken,
                      child: FloatingActionButton(
                        child: Icon(Icons.add_box_outlined),
                        // Provide an onPressed callback.
                        onPressed: () async {
                          picker
                              .getImage(source: ImageSource.gallery)
                              .then((PickedFile p) {
                            setState(() {
                              selectedImage = Image.file(File(p.path));
                              _pictureTaken = !_pictureTaken;
                            });
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Visibility(
                      visible: _pictureTaken,
                      child: FloatingActionButton(
                        child: Icon(
                          Icons.arrow_right_sharp,
                          size: 20,
                        ),
                        // Provide an onPressed callback.
                        onPressed:
                          _selectRecipients
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Visibility(
                      visible: !_pictureTaken,
                      child: FloatingActionButton(
                        child: Icon(Icons.camera_alt),
                        // Provide an onPressed callback.
                        onPressed: () async {
                          // Take the Picture in a try / catch block. If anything goes wrong,
                          // catch the error.
                          try {
                            // Ensure that the camera is initialized.
                            await _initializeControllerFuture;

                            // Construct the path where the image should be saved using the
                            // pattern package.
                            final path = join(
                              // Store the picture in the temp directory.
                              // Find the temp directory using the `path_provider` plugin.
                              (await getTemporaryDirectory()).path,
                              '${DateTime.now()}.png',
                            );

                            // Attempt to take a picture and log where it's been saved.
                            await _controller.takePicture(path);

                            // If the picture was taken, display it on a new screen.

                            setState(() {
                              selectedImage = Image.file(File(path));
                              _pictureTaken = !_pictureTaken;
                            });
                          } catch (e) {
                            // If an error occurs, log the error to the console.
                            print(e);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> _selectRecipients() async {
    Navigator.pushNamed(context, '/recipientScreen');
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}

