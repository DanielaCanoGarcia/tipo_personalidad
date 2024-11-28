import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DocumentScannerPage extends StatefulWidget {
  const DocumentScannerPage({Key? key}) : super(key: key);

  @override
  _DocumentScannerPageState createState() => _DocumentScannerPageState();
}

class _DocumentScannerPageState extends State<DocumentScannerPage> {
  CameraController? _cameraController;
  XFile? _capturedImage;
  bool _isVerifying = false;
  bool _isUsingFrontCamera = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera([bool useFrontCamera = true]) async {
    final cameras = await availableCameras();
    final camera = useFrontCamera
        ? cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          )
        : cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () => cameras.first,
          );

    _cameraController = CameraController(camera, ResolutionPreset.medium);
    await _cameraController!.initialize();

    setState(() {});
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      Fluttertoast.showToast(msg: 'Cámara no está lista.');
      return;
    }
    try {
      final image = await _cameraController!.takePicture();

      setState(() {
        _capturedImage = image;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error al tomar la foto: $e');
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image != null) {
        final resizedImageBytes = await _resizeImage(File(image.path));
        setState(() {
          _capturedImage = XFile(image.path);
        });
        await _verifyPhoto(resizedImageBytes);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error al seleccionar la foto: $e');
    }
  }

  Future<List<List<List<List<int>>>>> _resizeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final uint8List = Uint8List.fromList(bytes);

    // Ajustar la forma a (1, 64, 64, 3)
    final reshapedImage = _reshapeImage(uint8List, height: 64, width: 64, channels: 3);

    return reshapedImage;
  }

  List<List<List<List<int>>>> _reshapeImage(Uint8List imageBytes, {required int height, required int width, required int channels}) {
    final reshapedImage = List.generate(
      1,  // Batch size de 1
      (i) => List.generate(
        height,
        (j) => List.generate(
          width,
          (k) => List.generate(
            channels,
            (l) => imageBytes[(j * width * channels) + (k * channels) + l],
          ),
        ),
      ),
    );

    return reshapedImage;
  }

  int argMax(List<double> list) {
    var maxIndex = 0;
    for (var i = 1; i < list.length; i++) {
      if (list[i] > list[maxIndex]) {
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  Future<void> _verifyPhoto(List<List<List<List<int>>>> resizedImageBytes) async {
    if (_capturedImage == null) {
      Fluttertoast.showToast(msg: 'Por favor, toma o selecciona una foto');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      const url = 'https://tensorflow-linear-model-0khx.onrender.com/v1/models/flowers-model:predict';

      List<List<List<List<int>>>> instances = resizedImageBytes;
      final Map<String, dynamic> predictionInstance = {'instances': instances};

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(predictionInstance),
      );

      final jsonResponse = response.body;
      if (response.statusCode == 200) {
        print('Response from server: ${response.body}');

        final predictions = jsonDecode(jsonResponse)['predictions'][0].cast<double>();
        final classesLabels = ['dandelion', 'sunflowers', 'daisy', 'tulips', 'roses'];
        final predictedClass = classesLabels[argMax(predictions)];

        print('Predicciones: $predictions');
        print('Etiquetas de clases: $classesLabels');
        print('Índice de clase predicha: ${argMax(predictions)}');
        print('La clase de flor predicha es: $predictedClass');

        Fluttertoast.showToast(msg: 'La clase de flor predicha es: $predictedClass');
        Fluttertoast.showToast(msg: 'Predicciones: $predictions');
        Fluttertoast.showToast(msg: 'Etiquetas de clases: $classesLabels');

      } else {
        print('Error en la predicción. Respuesta: $jsonResponse');
        Fluttertoast.showToast(msg: 'Error en la predicción.');
      }
    } catch (error) {
      print('Error en la solicitud: $error');
      Fluttertoast.showToast(msg: 'Error en la solicitud: $error');
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _toggleCamera() async {
    _isUsingFrontCamera = !_isUsingFrontCamera;
    await _initializeCamera(_isUsingFrontCamera);
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Document Scanner'),
        actions: [
          IconButton(
            icon: Icon(_isUsingFrontCamera ? Icons.camera_front : Icons.camera_rear),
            onPressed: _toggleCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              color: Colors.black.withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(0, 255, 255, 255).withOpacity(0.7),
                    ),
                    child: IconButton(
                      onPressed: _pickPhoto,
                      icon: Icon(Icons.photo),
                      iconSize: 32.0,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 32.0),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                    child: IconButton(
                      onPressed: _takePhoto,
                      icon: Icon(Icons.camera_alt),
                      iconSize: 64.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 32.0),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    child: _isVerifying
                        ? CircularProgressIndicator()
                        : IconButton(
                            onPressed: () async {
                              await _verifyPhoto(await _resizeImage(File(_capturedImage!.path)));
                            },
                            icon: Icon(Icons.check),
                            iconSize: 23.0,
                            color: Colors.black,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
