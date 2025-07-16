import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../utils/helper.dart';
import 'virtual_audio_device_service.dart';

class BluetoothVirtualMicService extends GetxService {
  static const String virtualMicDeviceName = "AMADEUSE MUSIC Virtual Mic";
  static const String audioServiceUuid = "12345678-1234-1234-1234-123456789abc";
  static const String audioCharacteristicUuid = "87654321-4321-4321-4321-cba987654321";

  bool _isServiceRunning = false;
  bool _isBluetoothConnected = false;
  StreamController<Uint8List>? _audioStreamController;
  Timer? _connectionCheckTimer;

  // Bluetooth related
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _audioCharacteristic;
  StreamSubscription<List<int>>? _audioSubscription;
  List<BluetoothDevice> _discoveredDevices = [];

  // Virtual audio device service
  VirtualAudioDeviceService? _virtualAudioService;

  bool get isServiceRunning => _isServiceRunning;
  bool get isBluetoothConnected => _isBluetoothConnected;
  List<BluetoothDevice> get discoveredDevices => _discoveredDevices;
  
  @override
  void onInit() {
    super.onInit();
    printINFO("BluetoothVirtualMicService initialized");
  }
  
  /// Start the Bluetooth virtual microphone service
  Future<bool> startService() async {
    if (_isServiceRunning) {
      printINFO("Bluetooth Virtual Mic service is already running");
      return true;
    }
    
    try {
      printINFO("Starting Bluetooth Virtual Microphone service...");
      
      // Create virtual audio device
      if (Platform.isWindows) {
        _virtualAudioService = Get.put(VirtualAudioDeviceService());
        final success = await _virtualAudioService!.createVirtualMicrophone();
        if (!success) {
          printERROR("Failed to create virtual audio device");
          return false;
        }
      }
      
      // Initialize Bluetooth connection
      await _initializeBluetoothConnection();
      
      // Start audio streaming
      _startAudioStreaming();
      
      // Start connection monitoring
      _startConnectionMonitoring();
      
      _isServiceRunning = true;
      printINFO("Bluetooth Virtual Microphone service started successfully");
      return true;
      
    } catch (e) {
      printERROR("Failed to start Bluetooth Virtual Mic service: $e");
      return false;
    }
  }
  
  /// Stop the Bluetooth virtual microphone service
  Future<void> stopService() async {
    if (!_isServiceRunning) {
      printINFO("Bluetooth Virtual Mic service is not running");
      return;
    }
    
    try {
      printINFO("Stopping Bluetooth Virtual Microphone service...");
      
      // Stop connection monitoring
      _connectionCheckTimer?.cancel();
      _connectionCheckTimer = null;
      
      // Stop audio streaming
      await _stopAudioStreaming();
      
      // Disconnect Bluetooth
      await _disconnectBluetooth();
      
      // Remove virtual audio device
      if (Platform.isWindows && _virtualAudioService != null) {
        await _virtualAudioService!.removeVirtualMicrophone();
        Get.delete<VirtualAudioDeviceService>();
        _virtualAudioService = null;
      }
      
      _isServiceRunning = false;
      _isBluetoothConnected = false;
      
      printINFO("Bluetooth Virtual Microphone service stopped successfully");
      
    } catch (e) {
      printERROR("Error stopping Bluetooth Virtual Mic service: $e");
    }
  }
  

  
  /// Initialize Bluetooth connection
  Future<void> _initializeBluetoothConnection() async {
    try {
      printINFO("Initializing Bluetooth connection...");

      // Check if Bluetooth is supported and enabled
      if (await FlutterBluePlus.isSupported == false) {
        throw Exception("Bluetooth not supported on this device");
      }

      // Check if Bluetooth is turned on
      if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
        printINFO("Bluetooth is not enabled, requesting to turn on...");
        await FlutterBluePlus.turnOn();
      }

      // Start scanning for devices
      await _startBluetoothScan();

      printINFO("Bluetooth initialization completed");

    } catch (e) {
      printERROR("Failed to initialize Bluetooth connection: $e");
      _isBluetoothConnected = false;
      rethrow;
    }
  }

  /// Start scanning for Bluetooth devices
  Future<void> _startBluetoothScan() async {
    try {
      printINFO("Starting Bluetooth device scan...");

      // Clear previous discoveries
      _discoveredDevices.clear();

      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (!_discoveredDevices.contains(result.device)) {
            _discoveredDevices.add(result.device);
            printINFO("Discovered device: ${result.device.platformName} (${result.device.remoteId})");

            // Auto-connect to devices with our app name or specific service
            if (result.device.platformName.contains("AMADEUSE") ||
                result.advertisementData.serviceUuids.contains(Guid(audioServiceUuid))) {
              _connectToDevice(result.device);
            }
          }
        }
      });

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 30),
        withServices: [Guid(audioServiceUuid)], // Look for our specific service
      );

    } catch (e) {
      printERROR("Failed to start Bluetooth scan: $e");
    }
  }

  /// Connect to a specific Bluetooth device
  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      printINFO("Attempting to connect to device: ${device.platformName}");

      // Connect to the device
      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;

      // Discover services
      List<BluetoothService> services = await device.discoverServices();

      // Find our audio service
      for (BluetoothService service in services) {
        if (service.uuid.toString() == audioServiceUuid) {
          // Find the audio characteristic
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == audioCharacteristicUuid) {
              _audioCharacteristic = characteristic;

              // Subscribe to audio data
              await characteristic.setNotifyValue(true);
              _audioSubscription = characteristic.lastValueStream.listen(
                (data) => _handleIncomingAudioData(Uint8List.fromList(data)),
                onError: (error) => printERROR("Audio data stream error: $error"),
              );

              _isBluetoothConnected = true;
              printINFO("Successfully connected to audio service");
              return;
            }
          }
        }
      }

      printWarning("Audio service not found on device");

    } catch (e) {
      printERROR("Failed to connect to device: $e");
      _isBluetoothConnected = false;
    }
  }

  /// Handle incoming audio data from Bluetooth
  void _handleIncomingAudioData(Uint8List audioData) {
    try {
      if (_audioStreamController != null && !_audioStreamController!.isClosed) {
        _audioStreamController!.add(audioData);
      }
    } catch (e) {
      printERROR("Error handling incoming audio data: $e");
    }
  }
  
  /// Disconnect Bluetooth
  Future<void> _disconnectBluetooth() async {
    try {
      if (_isBluetoothConnected) {
        printINFO("Disconnecting Bluetooth...");

        // Cancel audio subscription
        await _audioSubscription?.cancel();
        _audioSubscription = null;

        // Disconnect from device
        if (_connectedDevice != null) {
          await _connectedDevice!.disconnect();
          _connectedDevice = null;
        }

        // Stop scanning if still active
        if (await FlutterBluePlus.isScanning.first) {
          await FlutterBluePlus.stopScan();
        }

        _audioCharacteristic = null;
        _isBluetoothConnected = false;
        _discoveredDevices.clear();

        printINFO("Bluetooth disconnected successfully");
      }
    } catch (e) {
      printERROR("Failed to disconnect Bluetooth: $e");
    }
  }
  
  /// Start audio streaming
  void _startAudioStreaming() {
    try {
      printINFO("Starting audio streaming...");
      
      _audioStreamController = StreamController<Uint8List>.broadcast();
      
      // Set up audio routing from Bluetooth to virtual microphone
      _audioStreamController?.stream.listen(
        (audioData) => _routeAudioToVirtualMic(audioData),
        onError: (error) => printERROR("Audio routing error: $error"),
      );

      printINFO("Audio streaming started");
      
    } catch (e) {
      printERROR("Failed to start audio streaming: $e");
    }
  }
  
  /// Stop audio streaming
  Future<void> _stopAudioStreaming() async {
    try {
      if (_audioStreamController != null) {
        printINFO("Stopping audio streaming...");
        
        await _audioStreamController!.close();
        _audioStreamController = null;
        
        printINFO("Audio streaming stopped");
      }
    } catch (e) {
      printERROR("Failed to stop audio streaming: $e");
    }
  }
  
  /// Start connection monitoring
  void _startConnectionMonitoring() {
    _connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => _checkConnection(),
    );
  }
  
  /// Route audio data from Bluetooth to virtual microphone
  void _routeAudioToVirtualMic(Uint8List audioData) {
    try {
      if (_virtualAudioService != null && _virtualAudioService!.isDeviceCreated) {
        // Send audio data to virtual microphone device
        _virtualAudioService!.sendAudioData(audioData);
      }
    } catch (e) {
      printERROR("Error routing audio to virtual microphone: $e");
    }
  }

  /// Send audio data to the virtual microphone (public method for external use)
  void sendAudioData(Uint8List audioData) {
    if (_audioStreamController != null && !_audioStreamController!.isClosed) {
      _audioStreamController!.add(audioData);
    }
  }

  /// Check Bluetooth connection status
  void _checkConnection() {
    try {
      // In a real implementation, you would check the actual Bluetooth connection
      // For now, we'll simulate occasional disconnections

      if (_isBluetoothConnected && DateTime.now().second % 30 == 0) {
        // Simulate occasional disconnection for testing
        printINFO("Bluetooth connection lost, attempting to reconnect...");
        _isBluetoothConnected = false;

        // Attempt to reconnect
        _initializeBluetoothConnection().catchError((e) {
          printERROR("Failed to reconnect Bluetooth: $e");
        });
      }

    } catch (e) {
      printERROR("Error checking connection: $e");
    }
  }
  
  @override
  void onClose() {
    stopService();
    super.onClose();
  }
}
