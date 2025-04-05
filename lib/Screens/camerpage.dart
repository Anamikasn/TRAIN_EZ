import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:trainez_miniproject/Screens/pose_processor_squat.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };
  late final PoseProcessorService _poseProcessor;
  String _feedback = "Please wait...";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _poseProcessor = PoseProcessorService(
      onFeedbackUpdate: (feedback) {
        if (!mounted) return;
        setState(() {
          // Store feedback in your state and display it
          _feedback = feedback;
        });
      },
      processingDelayMs: 100, // Adjust as needed
    );
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();

    final frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse:
          () =>
              _cameras
                  .first, // Fallback to first camera if no front camera found
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup:
          Platform.isAndroid
              ? ImageFormatGroup.nv21
              : ImageFormatGroup.bgra8888,
    );
    await _controller!.initialize();

    _controller?.startImageStream((CameraImage image) {
      //debugPrint('Before conversion: $image');
      final inputImage = _inputImageFromCameraImage(image);
      //debugPrint('After conversion: $inputImage');

      if (inputImage != null) {
        // Do something with the inputImage
        debugPrint('InputImage going to be processed');
        _poseProcessor.scheduleProcessing(inputImage);
      }
    });
    if (!mounted) return;
    setState(() {});
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _cameras.first;
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    // debugPrint(
    //   'Image format: ${image.format.group}, '
    //   'planes: ${image.planes.length}, '
    //   'width: ${image.width}, height: ${image.height}',
    // );

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);

      // debugPrint(
      //   'Android rotation: '
      //   'deviceOrientation: ${_controller!.value.deviceOrientation}, '
      //   'sensorOrientation: $sensorOrientation, '
      //   'rotationCompensation: $rotationCompensation',
      // );
    }
    if (rotation == null) return null;

    // Handle YUV420 format (3 planes)
    //debugPrint("image format group: ${image.format.group}");
    if (image.format.group == ImageFormatGroup.yuv420) {
      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      // debugPrint(
      //   'YUV420 Planes: '
      //   'Y bytes: ${yPlane.bytes.length}, '
      //   'U bytes: ${uPlane.bytes.length}, '
      //   'V bytes: ${vPlane.bytes.length}, '
      //   'Y bytesPerRow: ${yPlane.bytesPerRow}',
      // );

      if (yPlane.bytes.length != image.width * image.height) {
        debugPrint(
          '⚠️ Invalid Y plane size! Expected ${image.width * image.height}, got ${yPlane.bytes.length}',
        );
        return null;
      }

      // Calculate expected U/V size (4:2:0 subsampling)
      final uvSize = (image.width * image.height) ~/ 4;
      if (uPlane.bytes.length < uvSize || vPlane.bytes.length < uvSize) {
        debugPrint(
          '⚠️ Invalid U/V plane size! Expected at least $uvSize, got U:${uPlane.bytes.length}, V:${vPlane.bytes.length}',
        );
        return null;
      }

      // Create NV21 buffer (Y + interleaved VU)
      final nv21Bytes = Uint8List(image.width * image.height * 3 ~/ 2);

      // 1. Copy Y plane
      nv21Bytes.setRange(0, yPlane.bytes.length, yPlane.bytes);

      // 2. Interleave V and U (NV21 requires VU order)
      final uvBuffer = Uint8List.view(nv21Bytes.buffer, yPlane.bytes.length);
      for (int i = 0; i < uvSize; i++) {
        uvBuffer[i * 2] = vPlane.bytes[i]; // V
        uvBuffer[i * 2 + 1] = uPlane.bytes[i]; // U
      }

      debugPrint('✅ NV21 conversion successful');

      return InputImage.fromBytes(
        bytes: nv21Bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21, // Explicitly set NV21
          bytesPerRow: yPlane.bytesPerRow,
        ),
      );
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    debugPrint('Non-YUV format: $format');
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;
    debugPrint("image plane: $plane");

    debugPrint(
      'InputImage created: '
      'format: $format, '
      'rotation: $rotation, '
      'size: ${image.width}x${image.height}',
    );

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Squat Trainer')),
      body: Column(
        children: [
          // Camera Preview (top portion)
          Expanded(
            flex: 3, // Takes 3/4 of the space
            child: CameraPreview(_controller!),
          ),
          Container(
            height:
                MediaQuery.of(context).size.height *
                0.15, // 15% of screen height
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main Feedback Text
                Text(
                  _feedback,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _poseProcessor.dispose();
    _controller?.dispose();
    super.dispose();
  }
}
