//excess frames are simply just dropped rather than queing
//this one works!!!!!!

//feedback - standing is not shown
// when no person detected should show something else rather than previous feedback

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseProcessorService {
  final PoseDetector _poseDetector;
  bool _isProcessing = false;
  final Function(String) _onFeedbackUpdate;
  int _lastProcessingTimeMs = 0;
  Timer? _processingTimer;
  InputImage? _latestPendingImage;
  final int _processingDelayMs;

  PoseProcessorService({
    required Function(String) onFeedbackUpdate,
    int processingDelayMs = 100,
  }) : _poseDetector = PoseDetector(options: PoseDetectorOptions()),
       _onFeedbackUpdate = onFeedbackUpdate,
       _processingDelayMs = processingDelayMs;

  void scheduleProcessing(InputImage inputImage) {
    // Always store the latest frame, dropping intermediate ones
    _latestPendingImage = inputImage;

    // If already processing, the timer will handle the next frame
    if (_isProcessing) {
      return;
    }

    // Calculate dynamic delay based on last processing time
    final delayMs = max(0, _processingDelayMs - _lastProcessingTimeMs);

    _processingTimer?.cancel();
    _processingTimer = Timer(
      Duration(milliseconds: delayMs),
      () {
        if (_latestPendingImage != null) {
          processImage(_latestPendingImage!);
          _latestPendingImage = null;
        }
      },
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    _isProcessing = true;
    final stopwatch = Stopwatch()..start();

    try {
      final poses = await _poseDetector.processImage(inputImage);
      if (poses.isNotEmpty) {
        final feedback = _analyzePose(poses.first);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _onFeedbackUpdate(feedback);
        });
      }
    } catch (e) {
      debugPrint('❌ Processing error: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onFeedbackUpdate("System busy");
      });
    } finally {
      stopwatch.stop();
      _lastProcessingTimeMs = stopwatch.elapsedMilliseconds;
      debugPrint('⏱️ Frame processed in $_lastProcessingTimeMs ms');
      _isProcessing = false;
      
      // Schedule next processing if there's a pending frame
      if (_latestPendingImage != null) {
        scheduleProcessing(_latestPendingImage!);
      }
    }
  }

  String _analyzePose(Pose pose) {
    // Get required landmarks
    debugPrint('🦴 Retrieving landmarks...');
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (leftShoulder == null) debugPrint('❌ Missing left shoulder');
    if (leftHip == null) debugPrint('❌ Missing left hip');
    if (leftKnee == null) debugPrint('❌ Missing left knee');
    if (leftAnkle == null) debugPrint('❌ Missing left ankle');

    // Check if all required landmarks are detected
    if (leftShoulder == null ||
        leftHip == null ||
        leftKnee == null ||
        leftAnkle == null) {
      debugPrint('🚫 Insufficient landmarks detected');
      return "Adjust position - ensure full body is visible";
    }

    // Calculate angles
    debugPrint('📐 Calculating angles...');
    final kneeAngle = _calculateAngle(
      leftHip.x,
      leftHip.y,
      leftKnee.x,
      leftKnee.y,
      leftAnkle.x,
      leftAnkle.y,
    );

    final hipAngle = _calculateAngle(
      leftShoulder.x,
      leftShoulder.y,
      leftHip.x,
      leftHip.y,
      leftKnee.x,
      leftKnee.y,
    );

    debugPrint('🔄 Knee angle: ${kneeAngle.toStringAsFixed(1)}°');
    debugPrint('🔄 Hip angle: ${hipAngle.toStringAsFixed(1)}°');

    // Analyze squat form based on angles
    return _getSquatFeedback(kneeAngle, hipAngle);
  }

  double _calculateAngle(
    double x1,
    double y1, // Point A
    double x2,
    double y2, // Point B (vertex)
    double x3,
    double y3, // Point C
  ) {
    // Vector BA (A - B)
    final baX = x1 - x2;
    final baY = y1 - y2;

    // Vector BC (C - B)
    final bcX = x3 - x2;
    final bcY = y3 - y2;

    // Dot product and magnitudes
    final dotProduct = baX * bcX + baY * bcY;
    final magnitudeBA = sqrt(baX * baX + baY * baY);
    final magnitudeBC = sqrt(bcX * bcX + bcY * bcY);

    // Avoid division by zero
    if (magnitudeBA == 0 || magnitudeBC == 0) {
      debugPrint('⚠️ Zero magnitude in angle calculation');
      return 0;
    }

    // Calculate angle in radians then convert to degrees
    final angleRad = acos(dotProduct / (magnitudeBA * magnitudeBC));
    return angleRad * (180 / pi);
  }

  String _getSquatFeedback(double kneeAngle, double hipAngle) {
    debugPrint('🤔 Determining feedback...');
    debugPrint(
      '📊 Angles - Knee: ${kneeAngle.toStringAsFixed(1)}°, Hip: ${hipAngle.toStringAsFixed(1)}°',
    );

    const double perfectThreshold = 90;
    const double bendThreshold = 100;
    const double standingThreshold = 160;

    // Check for perfect squat position
    if (kneeAngle < perfectThreshold && hipAngle < perfectThreshold) {
      debugPrint('🏆 Perfect squat detected');
      return "Perfect Squat!";
    } else if (hipAngle > kneeAngle && hipAngle > bendThreshold) {
      debugPrint('↘️ Forward bend detected');
      return "Bend Forward";
    } else if (kneeAngle > hipAngle && kneeAngle > bendThreshold) {
      debugPrint('↗️ Backward bend detected');
      return "Bend Backward";
    } else if (kneeAngle > perfectThreshold && kneeAngle < standingThreshold) {
      debugPrint('⏳ Transition detected');
      return "Keep Going!!";
    } else {
      debugPrint('🧍 Standing detected');
      return "Ready to squat?";
    }
  }

  Future<void> dispose() async {
    _processingTimer?.cancel();
    _latestPendingImage = null;
    await _poseDetector.close();
    debugPrint('♻️ Processor disposed');
  }
}
