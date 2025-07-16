import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../utils/helper.dart';
import 'simple_virtual_mic_service.dart';

/// Legacy wrapper for VirtualAudioDeviceService
/// Redirects to SimpleVirtualMicService for compatibility
class VirtualAudioDeviceService extends GetxService {
  static const String deviceName = "AMADEUSE MUSIC Virtual Mic";
  static const String deviceDescription = "Virtual Microphone for AMADEUSE MUSIC";

  SimpleVirtualMicService? _simpleService;

  bool get isDeviceCreated => _simpleService?.isDeviceCreated ?? false;
  String get virtualDeviceName => deviceName;

  @override
  void onInit() {
    super.onInit();
    printINFO("VirtualAudioDeviceService initialized (legacy wrapper)");
    _simpleService = Get.put(SimpleVirtualMicService());
  }

  /// Create virtual microphone device
  Future<bool> createVirtualMicrophone() async {
    if (_simpleService == null) {
      _simpleService = Get.put(SimpleVirtualMicService());
    }
    return await _simpleService!.createVirtualMicrophone();
  }

  /// Remove virtual microphone device
  Future<void> removeVirtualMicrophone() async {
    if (_simpleService != null) {
      await _simpleService!.removeVirtualMicrophone();
    }
  }

  /// Send audio data to virtual microphone (for compatibility)
  void sendAudioData(Uint8List audioData) {
    if (_simpleService != null) {
      _simpleService!.sendAudioData(audioData);
    }
  }

  /// Get virtual device information (for compatibility)
  Map<String, dynamic> getDeviceInfo() {
    if (_simpleService != null) {
      return _simpleService!.getDeviceInfo();
    }
    return {
      'name': deviceName,
      'description': deviceDescription,
      'isCreated': false,
      'deviceId': null,
      'platform': Platform.operatingSystem,
    };
  }

  /// Check if virtual device is available in Windows audio settings (for compatibility)
  Future<bool> isDeviceVisibleInSystem() async {
    if (_simpleService != null) {
      return await _simpleService!.isDeviceVisibleInSystem();
    }
    return false;
  }

  @override
  void onClose() {
    removeVirtualMicrophone();
    super.onClose();
  }
}