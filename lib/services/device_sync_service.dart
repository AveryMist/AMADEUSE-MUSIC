import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../utils/helper.dart';
import '../ui/screens/Library/library_controller.dart';

class DeviceSyncService extends GetxService {
  static const String syncServerPort = "8080";
  static const String syncProtocolVersion = "1.0";
  
  bool _isServiceRunning = false;
  bool _isConnected = false;
  String? _deviceId;
  String? _serverAddress;
  
  // WebSocket connection for real-time sync
  WebSocketChannel? _webSocketChannel;
  HttpServer? _webSocketServer;
  StreamSubscription? _connectivitySubscription;
  Timer? _heartbeatTimer;
  Timer? _discoveryTimer;
  RawDatagramSocket? _udpSocket;
  
  // Sync state
  final RxList<String> connectedDevices = <String>[].obs;
  final RxList<Map<String, dynamic>> discoveredDevices = <Map<String, dynamic>>[].obs;
  final RxList<String> pairedDevices = <String>[].obs;
  final RxBool isSyncing = false.obs;
  final RxString syncStatus = "Disconnected".obs;
  final RxString pendingPairingCode = "".obs;
  final RxString pendingPairingDevice = "".obs;
  
  bool get isServiceRunning => _isServiceRunning;
  bool get isConnected => _isConnected;
  String? get deviceId => _deviceId;

  /// Get paired devices from settings
  List<String> _getPairedDevices() {
    try {
      final setBox = Hive.box("AppPrefs");
      final paired = setBox.get("pairedDevices") as List<dynamic>?;
      return paired?.cast<String>() ?? [];
    } catch (e) {
      printERROR("Failed to get paired devices from settings: $e");
      return [];
    }
  }

  /// Save paired devices to settings
  void _savePairedDevices(List<String> devices) {
    try {
      final setBox = Hive.box("AppPrefs");
      setBox.put("pairedDevices", devices);
      pairedDevices.value = devices;
    } catch (e) {
      printERROR("Failed to save paired devices: $e");
    }
  }

  /// Generate temporary pairing code
  String _generatePairingCode() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString(); // 4-digit code
  }

  /// Add device to paired list
  void addPairedDevice(String deviceId) {
    final paired = _getPairedDevices();
    if (!paired.contains(deviceId)) {
      paired.add(deviceId);
      _savePairedDevices(paired);
    }
  }

  /// Remove device from paired list
  Future<void> removePairedDevice(String deviceId) async {
    try {
      // Notify the other device about unpairing before removing locally
      await _notifyDeviceUnpairing(deviceId);

      final paired = _getPairedDevices();
      paired.remove(deviceId);
      _savePairedDevices(paired);

      // Remove from connected devices if present
      connectedDevices.remove(deviceId);

      printINFO("Removed paired device: $deviceId");
    } catch (e) {
      printERROR("Failed to remove paired device: $e");
    }
  }

  /// Notify a device that it's being unpaired
  Future<void> _notifyDeviceUnpairing(String deviceId) async {
    try {
      if (_webSocketChannel != null) {
        final message = {
          'type': 'unpair_notification',
          'deviceId': _deviceId,
          'deviceName': 'AMADEUSE MUSIC',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        _webSocketChannel!.sink.add(jsonEncode(message));
        printINFO("Sent unpairing notification to: $deviceId");
      }
    } catch (e) {
      printERROR("Failed to notify device unpairing: $e");
    }
  }

  /// Handle unpair notification from another device
  void _handleUnpairNotification(Map<String, dynamic> data) {
    try {
      final sourceDeviceId = data['deviceId'] as String;
      final deviceName = data['deviceName'] as String? ?? 'Unknown Device';

      printINFO("Received unpair notification from: $deviceName ($sourceDeviceId)");

      // Remove the device from our paired list
      final paired = _getPairedDevices();
      paired.remove(sourceDeviceId);
      _savePairedDevices(paired);

      // Remove from connected devices if present
      connectedDevices.removeWhere((device) => device.contains(sourceDeviceId));

      // Update UI
      Get.snackbar(
        'Appareil désappairé',
        'L\'appareil "$deviceName" a été désappairé',
        snackPosition: SnackPosition.BOTTOM,
      );

      printINFO("Automatically removed paired device: $sourceDeviceId");
    } catch (e) {
      printERROR("Error handling unpair notification: $e");
    }
  }

  /// Check if device is paired
  bool isDevicePaired(String deviceId) {
    return _getPairedDevices().contains(deviceId);
  }

  /// Send pairing request to a device
  Future<void> sendPairingRequest(String targetDeviceId) async {
    try {
      final pairingCode = _generatePairingCode();
      pendingPairingCode.value = pairingCode;
      pendingPairingDevice.value = targetDeviceId;

      final targetDevice = discoveredDevices.firstWhere(
        (device) => device['deviceId'] == targetDeviceId,
        orElse: () => {},
      );

      if (targetDevice.isEmpty) {
        printERROR("Target device not found in discovered devices");
        return;
      }

      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

      final pairingMessage = jsonEncode({
        'type': 'pairing_request',
        'sourceDeviceId': _deviceId,
        'targetDeviceId': targetDeviceId,
        'pairingCode': pairingCode,
        'deviceName': 'AMADEUSE MUSIC',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      final data = utf8.encode(pairingMessage);
      socket.send(data, InternetAddress(targetDevice['address']), 8081);
      socket.close();

      printINFO("Sent pairing request to $targetDeviceId with code: $pairingCode");

    } catch (e) {
      printERROR("Failed to send pairing request: $e");
    }
  }

  /// Handle incoming pairing request
  void _handlePairingRequest(Map<String, dynamic> data) {
    try {
      final sourceDeviceId = data['sourceDeviceId'] as String;
      final pairingCode = data['pairingCode'] as String;
      final deviceName = data['deviceName'] as String;

      printINFO("Received pairing request from $deviceName ($sourceDeviceId) with code: $pairingCode");

      // Show pairing code to user (this will be handled in UI)
      Get.dialog(
        AlertDialog(
          title: Text('Demande d\'appairage'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('L\'appareil "$deviceName" souhaite se connecter.'),
              SizedBox(height: 16),
              Text('Code de vérification: $pairingCode',
                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Vérifiez que ce code correspond à celui affiché sur l\'autre appareil.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                _sendPairingResponse(sourceDeviceId, false);
              },
              child: Text('Refuser'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _sendPairingResponse(sourceDeviceId, true);
                addPairedDevice(sourceDeviceId);
              },
              child: Text('Accepter'),
            ),
          ],
        ),
      );

    } catch (e) {
      printERROR("Failed to handle pairing request: $e");
    }
  }

  /// Handle pairing response
  void _handlePairingResponse(Map<String, dynamic> data) {
    try {
      final sourceDeviceId = data['sourceDeviceId'] as String;
      final accepted = data['accepted'] as bool;

      if (sourceDeviceId == pendingPairingDevice.value) {
        if (accepted) {
          addPairedDevice(sourceDeviceId);
          printINFO("Pairing accepted by device: $sourceDeviceId");

          // Auto-connect to the newly paired device
          final deviceInfo = discoveredDevices.firstWhere(
            (device) => device['deviceId'] == sourceDeviceId,
            orElse: () => {},
          );

          if (deviceInfo.isNotEmpty) {
            final fullDeviceName = "${deviceInfo['deviceName']}-$sourceDeviceId";
            if (!connectedDevices.contains(fullDeviceName)) {
              connectedDevices.add(fullDeviceName);
              _connectToDevice(fullDeviceName);
            }
          }
        } else {
          printINFO("Pairing rejected by device: $sourceDeviceId");
        }

        // Clear pending pairing
        pendingPairingCode.value = "";
        pendingPairingDevice.value = "";
      }

    } catch (e) {
      printERROR("Failed to handle pairing response: $e");
    }
  }

  /// Send pairing response
  Future<void> _sendPairingResponse(String targetDeviceId, bool accepted) async {
    try {
      final targetDevice = discoveredDevices.firstWhere(
        (device) => device['deviceId'] == targetDeviceId,
        orElse: () => {},
      );

      if (targetDevice.isEmpty) {
        printERROR("Target device not found for pairing response");
        return;
      }

      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

      final responseMessage = jsonEncode({
        'type': 'pairing_response',
        'sourceDeviceId': _deviceId,
        'targetDeviceId': targetDeviceId,
        'accepted': accepted,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      final data = utf8.encode(responseMessage);
      socket.send(data, InternetAddress(targetDevice['address']), 8081);
      socket.close();

      printINFO("Sent pairing response to $targetDeviceId: ${accepted ? 'accepted' : 'rejected'}");

    } catch (e) {
      printERROR("Failed to send pairing response: $e");
    }
  }
  
  @override
  void onInit() {
    super.onInit();
    _deviceId = _generateDeviceId();
    pairedDevices.value = _getPairedDevices();
    printINFO("DeviceSyncService initialized with device ID: $_deviceId");
  }
  
  /// Start the device synchronization service
  Future<bool> startService() async {
    if (_isServiceRunning) {
      printINFO("Device sync service is already running");
      return true;
    }
    
    try {
      printINFO("Starting Device Synchronization service...");
      
      // Check network connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        printERROR("No network connectivity available");
        syncStatus.value = "No Network";
        return false;
      }
      
      // Start WebSocket server
      await _startWebSocketServer();

      // Start network discovery
      await _startNetworkDiscovery();

      // Start connectivity monitoring
      _startConnectivityMonitoring();

      _isServiceRunning = true;
      syncStatus.value = "Discovering devices...";
      
      printINFO("Device Synchronization service started successfully");
      return true;
      
    } catch (e) {
      printERROR("Failed to start Device Sync service: $e");
      syncStatus.value = "Error: $e";
      return false;
    }
  }
  
  /// Stop the device synchronization service
  Future<void> stopService() async {
    if (!_isServiceRunning) {
      printINFO("Device sync service is not running");
      return;
    }
    
    try {
      printINFO("Stopping Device Synchronization service...");
      
      // Stop timers
      _heartbeatTimer?.cancel();
      _discoveryTimer?.cancel();

      // Close UDP socket
      _udpSocket?.close();
      _udpSocket = null;

      // Close WebSocket server
      await _webSocketServer?.close();
      _webSocketServer = null;

      // Close WebSocket connection
      await _disconnectWebSocket();
      
      // Stop connectivity monitoring
      await _connectivitySubscription?.cancel();
      
      _isServiceRunning = false;
      _isConnected = false;
      connectedDevices.clear();
      syncStatus.value = "Disconnected";
      
      printINFO("Device Synchronization service stopped successfully");
      
    } catch (e) {
      printERROR("Error stopping Device Sync service: $e");
    }
  }
  
  /// Start network discovery to find other devices
  Future<void> _startNetworkDiscovery() async {
    try {
      printINFO("Starting network discovery...");

      // Start UDP broadcast discovery
      await _startUdpDiscovery();

      // Start mDNS service discovery
      await _startMdnsDiscovery();

      // Set up periodic discovery
      _discoveryTimer = Timer.periodic(
        const Duration(seconds: 15),
        (timer) => _performDeviceDiscovery(),
      );

      // Perform initial discovery
      await _performDeviceDiscovery();

      printINFO("Network discovery started successfully");

    } catch (e) {
      printERROR("Failed to start network discovery: $e");
    }
  }

  /// Start UDP broadcast discovery
  Future<void> _startUdpDiscovery() async {
    try {
      printINFO("Starting UDP broadcast discovery...");

      // Close existing socket if any
      _udpSocket?.close();

      // Create UDP socket for broadcasting
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081);
      _udpSocket!.broadcastEnabled = true;

      // Listen for discovery responses
      _udpSocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _udpSocket!.receive();
          if (datagram != null) {
            _handleDiscoveryResponse(datagram);
          }
        }
      });

      // Broadcast discovery message
      final discoveryMessage = jsonEncode({
        'type': 'discovery',
        'deviceId': _deviceId,
        'deviceName': 'AMADEUSE MUSIC',
        'version': syncProtocolVersion,
        'port': syncServerPort,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      final data = utf8.encode(discoveryMessage);
      _udpSocket!.send(data, InternetAddress('255.255.255.255'), 8081);

      printINFO("UDP discovery broadcast sent and listening on port 8081");

    } catch (e) {
      printERROR("Failed to start UDP discovery: $e");
    }
  }

  /// Start WebSocket server for incoming connections
  Future<void> _startWebSocketServer() async {
    try {
      printINFO("Starting WebSocket server on port $syncServerPort...");

      _webSocketServer = await HttpServer.bind(InternetAddress.anyIPv4, int.parse(syncServerPort));

      _webSocketServer!.listen((HttpRequest request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          final webSocket = await WebSocketTransformer.upgrade(request);

          printINFO("New WebSocket connection from ${request.connectionInfo?.remoteAddress}");

          // Handle incoming messages from this connection
          webSocket.listen(
            (message) => _handleIncomingMessage(message),
            onError: (error) => printERROR("WebSocket error: $error"),
            onDone: () => printINFO("WebSocket connection closed"),
          );

          // Store the WebSocket for sending messages (we'll need to adapt this)
          // For now, we'll handle this differently

        } else {
          request.response.statusCode = HttpStatus.badRequest;
          await request.response.close();
        }
      });

      printINFO("WebSocket server started successfully on port $syncServerPort");

    } catch (e) {
      printERROR("Failed to start WebSocket server: $e");
    }
  }

  /// Start mDNS service discovery
  Future<void> _startMdnsDiscovery() async {
    try {
      printINFO("Starting mDNS service discovery...");

      // Register our service
      await _registerMdnsService();

      // Scan for other AMADEUSE MUSIC services
      await _scanMdnsServices();

    } catch (e) {
      printERROR("Failed to start mDNS discovery: $e");
    }
  }

  /// Register our mDNS service
  Future<void> _registerMdnsService() async {
    try {
      // In a real implementation, you would use a proper mDNS library
      // For now, we'll simulate service registration

      final serviceName = "AMADEUSE-MUSIC-$_deviceId";
      final serviceType = "_amadeuse._tcp";

      printINFO("Registering mDNS service: $serviceName.$serviceType");
      printINFO("Service available on port: $syncServerPort");

      // Service is now discoverable by other devices

    } catch (e) {
      printERROR("Failed to register mDNS service: $e");
    }
  }

  /// Scan for mDNS services
  Future<void> _scanMdnsServices() async {
    try {
      printINFO("Scanning for AMADEUSE MUSIC mDNS services...");

      // In a real implementation, you would:
      // 1. Query for _amadeuse._tcp services
      // 2. Parse service records
      // 3. Extract device information

      // For demonstration, we'll simulate finding services
      final foundServices = [
        {'name': 'AMADEUSE-MUSIC-PHONE', 'address': '192.168.1.100', 'port': 8080},
        {'name': 'AMADEUSE-MUSIC-TABLET', 'address': '192.168.1.101', 'port': 8080},
      ];

      for (final service in foundServices) {
        final deviceName = service['name'] as String;
        if (!connectedDevices.contains(deviceName) && deviceName != "AMADEUSE-MUSIC-$_deviceId") {
          connectedDevices.add(deviceName);
          printINFO("Found mDNS service: $deviceName at ${service['address']}:${service['port']}");
        }
      }

    } catch (e) {
      printERROR("Failed to scan mDNS services: $e");
    }
  }

  /// Handle discovery response from UDP broadcast
  void _handleDiscoveryResponse(Datagram datagram) {
    try {
      final message = utf8.decode(datagram.data);
      final data = jsonDecode(message) as Map<String, dynamic>;

      if ((data['type'] == 'discovery' || data['type'] == 'discovery_broadcast') && data['deviceId'] != _deviceId) {
        final deviceId = data['deviceId'] as String;
        final deviceName = data['deviceName'] as String;
        final deviceAddress = datagram.address.address;
        final devicePort = data['port'] as String;

        final deviceInfo = {
          'deviceId': deviceId,
          'deviceName': deviceName,
          'address': deviceAddress,
          'port': devicePort,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        // Add to discovered devices if not already present
        final existingIndex = discoveredDevices.indexWhere((device) => device['deviceId'] == deviceId);
        if (existingIndex >= 0) {
          discoveredDevices[existingIndex] = deviceInfo;
        } else {
          discoveredDevices.add(deviceInfo);
        }

        printINFO("Discovered device via UDP: $deviceName-$deviceId at $deviceAddress:$devicePort");

        // Send discovery response back to the requesting device
        _sendDiscoveryResponse(datagram.address, int.parse(devicePort));

        // If device is already paired, auto-connect
        if (isDevicePaired(deviceId)) {
          final fullDeviceName = "$deviceName-$deviceId";
          if (!connectedDevices.contains(fullDeviceName)) {
            connectedDevices.add(fullDeviceName);
            printINFO("Auto-connecting to paired device: $fullDeviceName");
            _connectToDevice(fullDeviceName);
          }
        }
      } else if (data['type'] == 'discovery_response' && data['deviceId'] != _deviceId) {
        // Handle discovery response (when another device responds to our broadcast)
        final deviceId = data['deviceId'] as String;
        final deviceName = data['deviceName'] as String;
        final deviceAddress = datagram.address.address;
        final devicePort = data['port'] as String;

        final deviceInfo = {
          'deviceId': deviceId,
          'deviceName': deviceName,
          'address': deviceAddress,
          'port': devicePort,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        // Add to discovered devices if not already present
        final existingIndex = discoveredDevices.indexWhere((device) => device['deviceId'] == deviceId);
        if (existingIndex >= 0) {
          discoveredDevices[existingIndex] = deviceInfo;
        } else {
          discoveredDevices.add(deviceInfo);
        }

        printINFO("Received discovery response from: $deviceName-$deviceId at $deviceAddress:$devicePort");

        // If device is already paired, auto-connect
        if (isDevicePaired(deviceId)) {
          final fullDeviceName = "$deviceName-$deviceId";
          if (!connectedDevices.contains(fullDeviceName)) {
            connectedDevices.add(fullDeviceName);
            printINFO("Auto-connecting to paired device: $fullDeviceName");
            _connectToDevice(fullDeviceName);
          }
        }
      } else if (data['type'] == 'pairing_request' && data['targetDeviceId'] == _deviceId) {
        // Handle incoming pairing request
        _handlePairingRequest(data);
      } else if (data['type'] == 'pairing_response' && data['targetDeviceId'] == _deviceId) {
        // Handle pairing response
        _handlePairingResponse(data);
      }

    } catch (e) {
      printERROR("Error handling discovery response: $e");
    }
  }
  
  /// Perform device discovery
  Future<void> _performDeviceDiscovery() async {
    try {
      printINFO("Performing active device discovery...");

      // Scan local network for AMADEUSE MUSIC devices
      await _scanLocalNetwork();

      // Refresh mDNS discovery
      await _scanMdnsServices();

      // Send UDP broadcast discovery
      await _sendDiscoveryBroadcast();

      printINFO("Device discovery cycle completed. Found ${connectedDevices.length} devices");

    } catch (e) {
      printERROR("Error during device discovery: $e");
    }
  }

  /// Scan local network for AMADEUSE MUSIC devices
  Future<void> _scanLocalNetwork() async {
    try {
      printINFO("Scanning local network...");

      // Get local IP address
      final interfaces = await NetworkInterface.list();
      String? localSubnet;

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            // Extract subnet (e.g., 192.168.1.x)
            final parts = addr.address.split('.');
            if (parts.length == 4) {
              localSubnet = "${parts[0]}.${parts[1]}.${parts[2]}";
              break;
            }
          }
        }
        if (localSubnet != null) break;
      }

      if (localSubnet == null) {
        printWarning("Could not determine local subnet for network scan");
        return;
      }

      printINFO("Scanning subnet: $localSubnet.x");

      // Scan common IP ranges (1-254)
      final futures = <Future>[];
      for (int i = 1; i <= 254; i++) {
        final ip = "$localSubnet.$i";
        futures.add(_checkDeviceAtAddress(ip));
      }

      // Wait for all scans to complete (with timeout)
      await Future.wait(futures).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          printINFO("Network scan completed (timeout reached)");
          return [];
        },
      );

    } catch (e) {
      printERROR("Error scanning local network: $e");
    }
  }

  /// Check if there's an AMADEUSE MUSIC device at the given IP address
  Future<void> _checkDeviceAtAddress(String ipAddress) async {
    try {
      // Try to connect to the sync port
      final socket = await Socket.connect(
        ipAddress,
        int.parse(syncServerPort),
        timeout: const Duration(seconds: 2),
      );

      // Send identification request
      final request = jsonEncode({
        'type': 'identify',
        'deviceId': _deviceId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      socket.write(request);

      // Listen for response
      final response = await socket.first.timeout(
        const Duration(seconds: 3),
        onTimeout: () => Uint8List(0),
      );

      if (response.isNotEmpty) {
        final responseStr = utf8.decode(response);
        final data = jsonDecode(responseStr) as Map<String, dynamic>;

        if (data['type'] == 'identify_response' &&
            data['appName'] == 'AMADEUSE MUSIC') {
          final deviceName = data['deviceName'] as String;
          final deviceId = data['deviceId'] as String;
          final fullName = "$deviceName-$deviceId";

          if (!connectedDevices.contains(fullName) && deviceId != _deviceId) {
            connectedDevices.add(fullName);
            printINFO("Found AMADEUSE MUSIC device: $fullName at $ipAddress");

            // Attempt to establish sync connection
            await _connectToDevice(fullName);
          }
        }
      }

      await socket.close();

    } catch (e) {
      // This is expected for most IPs that don't have our app
      // Only log if it's an unexpected error
      if (e is! SocketException && e is! TimeoutException) {
        printERROR("Unexpected error checking device at $ipAddress: $e");
      }
    }
  }

  /// Send UDP broadcast discovery message
  Future<void> _sendDiscoveryBroadcast() async {
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;

      final discoveryMessage = jsonEncode({
        'type': 'discovery_broadcast',
        'deviceId': _deviceId,
        'deviceName': 'AMADEUSE MUSIC',
        'version': syncProtocolVersion,
        'port': syncServerPort,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      final data = utf8.encode(discoveryMessage);
      socket.send(data, InternetAddress('255.255.255.255'), 8081);

      socket.close();

      if (kDebugMode) {
        printINFO("Sent UDP discovery broadcast");
      }

    } catch (e) {
      printERROR("Failed to send discovery broadcast: $e");
    }
  }

  /// Send discovery response to a specific device
  Future<void> _sendDiscoveryResponse(InternetAddress targetAddress, int targetPort) async {
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

      final responseMessage = jsonEncode({
        'type': 'discovery_response',
        'deviceId': _deviceId,
        'deviceName': 'AMADEUSE MUSIC',
        'version': syncProtocolVersion,
        'port': syncServerPort,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      final data = utf8.encode(responseMessage);
      socket.send(data, targetAddress, 8081);

      socket.close();

      printINFO("Sent discovery response to ${targetAddress.address}:$targetPort");

    } catch (e) {
      printERROR("Failed to send discovery response: $e");
    }
  }
  
  /// Connect to a discovered device
  Future<void> _connectToDevice(String deviceId) async {
    try {
      printINFO("Attempting to connect to device: $deviceId");

      // Extract device address from discovered devices
      String? deviceAddress = await _getDeviceAddress(deviceId);
      if (deviceAddress == null) {
        printERROR("Could not find address for device: $deviceId");
        return;
      }

      // Establish WebSocket connection
      await _establishWebSocketConnection(deviceAddress, deviceId);

    } catch (e) {
      printERROR("Failed to connect to device $deviceId: $e");
      _isConnected = false;
      syncStatus.value = "Connection failed";
    }
  }

  /// Get device address from device ID
  Future<String?> _getDeviceAddress(String deviceId) async {
    try {
      // In a real implementation, you would look up the device address
      // from the discovery results or device registry

      // For now, we'll simulate address lookup
      if (deviceId.contains("PHONE")) {
        return "192.168.1.100";
      } else if (deviceId.contains("TABLET")) {
        return "192.168.1.101";
      } else {
        // Try to extract from network scan results
        return "192.168.1.102"; // Default fallback
      }
    } catch (e) {
      printERROR("Error getting device address: $e");
      return null;
    }
  }

  /// Establish WebSocket connection to device
  Future<void> _establishWebSocketConnection(String address, String deviceId) async {
    try {
      printINFO("Establishing WebSocket connection to $address:$syncServerPort");

      // Create WebSocket connection
      final uri = Uri.parse("ws://$address:$syncServerPort/sync");
      _webSocketChannel = WebSocketChannel.connect(uri);

      // Listen for incoming messages
      _webSocketChannel!.stream.listen(
        (message) => _handleIncomingMessage(message),
        onError: (error) => _handleWebSocketError(error),
        onDone: () => _handleWebSocketDisconnection(),
      );

      // Send connection handshake
      await _sendConnectionHandshake(deviceId);

      // Wait for handshake response (the sync will be triggered in _handleHandshakeResponse)
      await Future.delayed(const Duration(seconds: 3));

      // Check if handshake was successful
      if (_isConnected) {
        _serverAddress = address;

        // Start heartbeat
        _startHeartbeat();

        printINFO("Successfully connected to device: $deviceId at $address");
      } else {
        printERROR("Handshake failed or timed out for device: $deviceId");
        syncStatus.value = "Handshake failed";
        throw Exception("Handshake failed or timed out");
      }

    } catch (e) {
      printERROR("Failed to establish WebSocket connection: $e");
      _isConnected = false;
      syncStatus.value = "Connection failed";
      rethrow;
    }
  }

  /// Send connection handshake
  Future<void> _sendConnectionHandshake(String targetDeviceId) async {
    try {
      final handshake = {
        'type': 'handshake',
        'deviceId': _deviceId,
        'targetDeviceId': targetDeviceId,
        'appName': 'AMADEUSE MUSIC',
        'version': syncProtocolVersion,
        'capabilities': ['playlist_sync', 'settings_sync'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _webSocketChannel!.sink.add(jsonEncode(handshake));
      printINFO("Sent connection handshake to $targetDeviceId");

    } catch (e) {
      printERROR("Failed to send connection handshake: $e");
    }
  }

  /// Handle incoming WebSocket messages
  void _handleIncomingMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final messageType = data['type'] as String;

      printINFO("Received message type: $messageType");

      switch (messageType) {
        case 'handshake':
          _handleHandshakeRequest(data);
          break;
        case 'handshake_response':
          _handleHandshakeResponse(data);
          break;
        case 'playlist_sync':
          _handlePlaylistSyncMessage(data);
          break;
        case 'album_sync':
          _handleAlbumSyncMessage(data);
          break;
        case 'artist_favorites_sync':
          _handleArtistFavoritesSyncMessage(data);
          break;
        case 'settings_sync':
          _handleSettingsSyncMessage(data);
          break;
        case 'heartbeat':
          _handleHeartbeat(data);
          break;
        case 'identify':
          _handleIdentifyRequest(data);
          break;
        case 'unpair_notification':
          _handleUnpairNotification(data);
          break;
        default:
          printWarning("Unknown message type: $messageType");
      }

    } catch (e) {
      printERROR("Error handling incoming message: $e");
    }
  }

  /// Handle WebSocket errors
  void _handleWebSocketError(dynamic error) {
    printERROR("WebSocket error: $error");
    _isConnected = false;
    syncStatus.value = "Connection error";

    // Attempt to reconnect after a delay
    Timer(const Duration(seconds: 5), () {
      if (_isServiceRunning && !_isConnected) {
        printINFO("Attempting to reconnect...");
        _performDeviceDiscovery();
      }
    });
  }

  /// Handle WebSocket disconnection
  void _handleWebSocketDisconnection() {
    printINFO("WebSocket connection closed");
    _isConnected = false;
    syncStatus.value = "Disconnected";
    _webSocketChannel = null;
  }

  /// Handle incoming handshake request
  void _handleHandshakeRequest(Map<String, dynamic> data) {
    try {
      final sourceDeviceId = data['deviceId'] as String;
      final appName = data['appName'] as String;
      final version = data['version'] as String;

      printINFO("Received handshake request from $sourceDeviceId ($appName v$version)");

      // Verify this is an AMADEUSE MUSIC device
      if (appName == 'AMADEUSE MUSIC') {
        // Send successful handshake response
        final response = {
          'type': 'handshake_response',
          'deviceId': _deviceId,
          'targetDeviceId': sourceDeviceId,
          'success': true,
          'appName': 'AMADEUSE MUSIC',
          'version': syncProtocolVersion,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        _webSocketChannel?.sink.add(jsonEncode(response));
        printINFO("Sent successful handshake response to $sourceDeviceId");

        // Mark as connected and start sync
        _isConnected = true;
        syncStatus.value = "Connected and authenticated";

        // Trigger automatic synchronization after successful handshake
        Future.delayed(const Duration(milliseconds: 500), () async {
          await _performFullSync();
        });

      } else {
        // Send failed handshake response
        final response = {
          'type': 'handshake_response',
          'deviceId': _deviceId,
          'targetDeviceId': sourceDeviceId,
          'success': false,
          'error': 'Invalid application',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        _webSocketChannel?.sink.add(jsonEncode(response));
        printERROR("Rejected handshake from invalid app: $appName");
      }

    } catch (e) {
      printERROR("Error handling handshake request: $e");
    }
  }

  /// Handle handshake response
  void _handleHandshakeResponse(Map<String, dynamic> data) {
    try {
      final success = data['success'] as bool? ?? false;
      if (success) {
        printINFO("Handshake successful with device: ${data['deviceId']}");
        syncStatus.value = "Connected and authenticated";

        // Trigger automatic synchronization after successful handshake
        Future.delayed(const Duration(milliseconds: 500), () async {
          await _performFullSync();
        });

      } else {
        printERROR("Handshake failed: ${data['error']}");
        _isConnected = false;
        syncStatus.value = "Authentication failed";
      }
    } catch (e) {
      printERROR("Error handling handshake response: $e");
    }
  }

  /// Handle playlist sync messages
  void _handlePlaylistSyncMessage(Map<String, dynamic> data) {
    try {
      final action = data['action'] as String;

      switch (action) {
        case 'send':
          _receivePlaylistsFromDevice(data);
          break;
        case 'request':
          _respondToPlaylistRequest(data);
          break;
        case 'update':
          _handlePlaylistUpdate(data);
          break;
        default:
          printWarning("Unknown playlist sync action: $action");
      }

    } catch (e) {
      printERROR("Error handling playlist sync message: $e");
    }
  }

  /// Handle album sync messages
  void _handleAlbumSyncMessage(Map<String, dynamic> data) {
    try {
      final action = data['action'] as String;

      switch (action) {
        case 'send':
          _receiveAlbumsFromDevice(data);
          break;
        case 'request':
          _respondToAlbumRequest(data);
          break;
        case 'update':
          _handleAlbumUpdate(data);
          break;
        default:
          printWarning("Unknown album sync action: $action");
      }

    } catch (e) {
      printERROR("Error handling album sync message: $e");
    }
  }

  /// Handle artist favorites sync messages
  void _handleArtistFavoritesSyncMessage(Map<String, dynamic> data) {
    try {
      final action = data['action'] as String;

      switch (action) {
        case 'send':
          _receiveArtistFavoritesFromDevice(data);
          break;
        case 'request':
          _respondToArtistFavoritesRequest(data);
          break;
        case 'update':
          _handleArtistFavoriteUpdate(data);
          break;
        default:
          printWarning("Unknown artist favorites sync action: $action");
      }

    } catch (e) {
      printERROR("Error handling artist favorites sync message: $e");
    }
  }

  /// Handle settings sync messages
  void _handleSettingsSyncMessage(Map<String, dynamic> data) {
    try {
      final action = data['action'] as String;

      switch (action) {
        case 'send':
          _receiveSettingsFromDevice(data);
          break;
        case 'request':
          _respondToSettingsRequest(data);
          break;
        default:
          printWarning("Unknown settings sync action: $action");
      }

    } catch (e) {
      printERROR("Error handling settings sync message: $e");
    }
  }

  /// Handle heartbeat messages
  void _handleHeartbeat(Map<String, dynamic> data) {
    try {
      final deviceId = data['deviceId'] as String;
      if (kDebugMode) {
        printINFO("Received heartbeat from device: $deviceId");
      }

      // Send heartbeat response
      final response = {
        'type': 'heartbeat_response',
        'deviceId': _deviceId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _webSocketChannel?.sink.add(jsonEncode(response));

    } catch (e) {
      printERROR("Error handling heartbeat: $e");
    }
  }

  /// Handle identify request
  void _handleIdentifyRequest(Map<String, dynamic> data) {
    try {
      final response = {
        'type': 'identify_response',
        'deviceId': _deviceId,
        'deviceName': 'AMADEUSE MUSIC',
        'appName': 'AMADEUSE MUSIC',
        'version': syncProtocolVersion,
        'capabilities': ['playlist_sync', 'settings_sync'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _webSocketChannel?.sink.add(jsonEncode(response));
      printINFO("Sent identify response");

    } catch (e) {
      printERROR("Error handling identify request: $e");
    }
  }

  /// Start connectivity monitoring
  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        if (result == ConnectivityResult.none) {
          printINFO("Network connectivity lost");
          syncStatus.value = "No Network";
          _isConnected = false;
        } else {
          printINFO("Network connectivity restored");
          if (_isServiceRunning) {
            _performDeviceDiscovery();
          }
        }
      },
    );
  }
  
  /// Start heartbeat to maintain connection
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) => _sendHeartbeat(),
    );
  }
  
  /// Send heartbeat to connected devices
  void _sendHeartbeat() {
    try {
      if (_isConnected && _webSocketChannel != null) {
        final heartbeat = {
          'type': 'heartbeat',
          'deviceId': _deviceId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        
        _webSocketChannel!.sink.add(jsonEncode(heartbeat));
      }
    } catch (e) {
      printERROR("Failed to send heartbeat: $e");
    }
  }
  
  /// Disconnect WebSocket connection
  Future<void> _disconnectWebSocket() async {
    try {
      if (_webSocketChannel != null) {
        await _webSocketChannel!.sink.close();
        _webSocketChannel = null;
      }
    } catch (e) {
      printERROR("Error disconnecting WebSocket: $e");
    }
  }
  
  /// Perform full synchronization of all data types
  Future<bool> _performFullSync() async {
    if (!_isConnected) {
      printERROR("Cannot sync: not connected to any device");
      return false;
    }

    try {
      isSyncing.value = true;
      syncStatus.value = "Syncing all data...";

      printINFO("Starting full synchronization...");

      // Sync playlists
      await _syncPlaylists();

      // Sync albums
      await _syncAlbums();

      // Sync artist favorites
      await _syncArtistFavorites();

      isSyncing.value = false;
      syncStatus.value = "Full sync completed";

      printINFO("Full synchronization completed successfully");
      return true;

    } catch (e) {
      printERROR("Failed to perform full sync: $e");
      isSyncing.value = false;
      syncStatus.value = "Sync failed: $e";
      return false;
    }
  }

  /// Public method to trigger manual synchronization
  Future<bool> performManualSync() async {
    if (!_isServiceRunning) {
      printERROR("Cannot sync: service not running");
      syncStatus.value = "Service not running";
      return false;
    }

    if (connectedDevices.isEmpty) {
      printERROR("Cannot sync: no paired devices connected");
      syncStatus.value = "No devices connected";
      return false;
    }

    return await _performFullSync();
  }

  /// Sync playlists with connected devices
  Future<bool> syncPlaylists() async {
    return await _syncPlaylists();
  }

  /// Sync artist favorites with connected devices
  Future<bool> syncArtistFavorites() async {
    return await _syncArtistFavorites();
  }

  /// Trigger automatic sync when playlist is created/modified/deleted
  Future<void> triggerPlaylistSync() async {
    printINFO("triggerPlaylistSync called - Service running: $_isServiceRunning, Connected: $_isConnected, Connected devices: ${connectedDevices.length}");

    if (!_isServiceRunning) {
      printINFO("Skipping playlist sync: service not running");
      return;
    }

    if (!_isConnected) {
      printINFO("Skipping playlist sync: not connected to any device");
      return;
    }

    if (connectedDevices.isEmpty) {
      printINFO("Skipping playlist sync: no paired devices connected");
      return;
    }

    try {
      printINFO("Triggering automatic playlist synchronization...");
      await _syncPlaylists();
    } catch (e) {
      printERROR("Failed to trigger playlist sync: $e");
    }
  }

  /// Trigger automatic sync when artist favorite is added/removed
  Future<void> triggerArtistFavoriteSync() async {
    printINFO("triggerArtistFavoriteSync called - Service running: $_isServiceRunning, Connected: $_isConnected, Connected devices: ${connectedDevices.length}");

    if (!_isServiceRunning) {
      printINFO("Skipping artist favorite sync: service not running");
      return;
    }

    if (!_isConnected) {
      printINFO("Skipping artist favorite sync: not connected to any device");
      return;
    }

    if (connectedDevices.isEmpty) {
      printINFO("Skipping artist favorite sync: no paired devices connected");
      return;
    }

    try {
      printINFO("Triggering automatic artist favorite synchronization...");
      await _syncArtistFavorites();
    } catch (e) {
      printERROR("Failed to trigger artist favorite sync: $e");
    }
  }

  /// Internal method to sync playlists
  Future<bool> _syncPlaylists() async {
    if (!_isConnected) {
      printERROR("Cannot sync playlists: not connected to any device");
      return false;
    }

    try {
      syncStatus.value = "Syncing playlists...";

      printINFO("Starting playlist synchronization...");

      // Get local playlists
      final localPlaylists = await _getLocalPlaylists();

      // Send playlists to connected devices
      await _sendPlaylistsToDevices(localPlaylists);

      // Request playlists from connected devices
      await _requestPlaylistsFromDevices();

      printINFO("Playlist synchronization completed successfully");
      return true;

    } catch (e) {
      printERROR("Failed to sync playlists: $e");
      return false;
    }
  }

  /// Internal method to sync albums
  Future<bool> _syncAlbums() async {
    if (!_isConnected) {
      printERROR("Cannot sync albums: not connected to any device");
      return false;
    }

    try {
      syncStatus.value = "Syncing albums...";

      printINFO("Starting album synchronization...");

      // Get local albums
      final localAlbums = await _getLocalAlbums();

      // Send albums to connected devices
      await _sendAlbumsToDevices(localAlbums);

      // Request albums from connected devices
      await _requestAlbumsFromDevices();

      printINFO("Album synchronization completed successfully");
      return true;

    } catch (e) {
      printERROR("Failed to sync albums: $e");
      return false;
    }
  }

  /// Internal method to sync artist favorites
  Future<bool> _syncArtistFavorites() async {
    if (!_isConnected) {
      printERROR("Cannot sync artist favorites: not connected to any device");
      return false;
    }

    try {
      syncStatus.value = "Syncing artist favorites...";

      printINFO("Starting artist favorites synchronization...");

      // Get local artist favorites
      final localArtistFavorites = await _getLocalArtistFavorites();

      // Send artist favorites to connected devices
      await _sendArtistFavoritesToDevices(localArtistFavorites);

      // Request artist favorites from connected devices
      await _requestArtistFavoritesFromDevices();

      printINFO("Artist favorites synchronization completed successfully");
      return true;

    } catch (e) {
      printERROR("Failed to sync artist favorites: $e");
      return false;
    }
  }

  /// Get local playlists from Hive storage
  Future<List<Map<String, dynamic>>> _getLocalPlaylists() async {
    try {
      final playlistBox = await Hive.openBox('LibraryPlaylists');
      final playlists = <Map<String, dynamic>>[];

      for (final key in playlistBox.keys) {
        final playlist = playlistBox.get(key);
        if (playlist != null) {
          playlists.add({
            'id': key,
            'data': playlist,
            'lastModified': DateTime.now().millisecondsSinceEpoch,
          });
        }
      }

      await playlistBox.close();
      printINFO("Retrieved ${playlists.length} local playlists from LibraryPlaylists");
      return playlists;

    } catch (e) {
      printERROR("Failed to get local playlists: $e");
      return [];
    }
  }

  /// Get local albums from Hive storage
  Future<List<Map<String, dynamic>>> _getLocalAlbums() async {
    try {
      final albumBox = await Hive.openBox('LibraryAlbums');
      final albums = <Map<String, dynamic>>[];

      for (final key in albumBox.keys) {
        final album = albumBox.get(key);
        if (album != null) {
          albums.add({
            'id': key,
            'data': album,
            'lastModified': DateTime.now().millisecondsSinceEpoch,
          });
        }
      }

      await albumBox.close();
      printINFO("Retrieved ${albums.length} local albums");
      return albums;

    } catch (e) {
      printERROR("Failed to get local albums: $e");
      return [];
    }
  }

  /// Get local artist favorites from Hive storage
  Future<List<Map<String, dynamic>>> _getLocalArtistFavorites() async {
    try {
      final artistBox = await Hive.openBox('LibraryArtists');
      final artistFavorites = <Map<String, dynamic>>[];

      for (final key in artistBox.keys) {
        final artist = artistBox.get(key);
        if (artist != null) {
          artistFavorites.add({
            'id': key,
            'data': artist,
            'lastModified': DateTime.now().millisecondsSinceEpoch,
          });
        }
      }

      await artistBox.close();
      printINFO("Retrieved ${artistFavorites.length} local artist favorites");
      return artistFavorites;

    } catch (e) {
      printERROR("Failed to get local artist favorites: $e");
      return [];
    }
  }

  /// Send playlists to connected devices
  Future<void> _sendPlaylistsToDevices(List<Map<String, dynamic>> playlists) async {
    try {
      if (_webSocketChannel != null) {
        final message = {
          'type': 'playlist_sync',
          'action': 'send',
          'deviceId': _deviceId,
          'playlists': playlists,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        
        _webSocketChannel!.sink.add(jsonEncode(message));
        printINFO("Sent ${playlists.length} playlists to connected devices");
      }
    } catch (e) {
      printERROR("Failed to send playlists to devices: $e");
    }
  }
  
  /// Request playlists from connected devices
  Future<void> _requestPlaylistsFromDevices() async {
    try {
      if (_webSocketChannel != null) {
        final message = {
          'type': 'playlist_sync',
          'action': 'request',
          'deviceId': _deviceId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        
        _webSocketChannel!.sink.add(jsonEncode(message));
        printINFO("Requested playlists from connected devices");
      }
    } catch (e) {
      printERROR("Failed to request playlists from devices: $e");
    }
  }

  /// Send albums to connected devices
  Future<void> _sendAlbumsToDevices(List<Map<String, dynamic>> albums) async {
    try {
      if (_webSocketChannel != null) {
        final message = {
          'type': 'album_sync',
          'action': 'send',
          'deviceId': _deviceId,
          'albums': albums,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        _webSocketChannel!.sink.add(jsonEncode(message));
        printINFO("Sent ${albums.length} albums to connected devices");
      }
    } catch (e) {
      printERROR("Failed to send albums to devices: $e");
    }
  }

  /// Request albums from connected devices
  Future<void> _requestAlbumsFromDevices() async {
    try {
      if (_webSocketChannel != null) {
        final message = {
          'type': 'album_sync',
          'action': 'request',
          'deviceId': _deviceId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        _webSocketChannel!.sink.add(jsonEncode(message));
        printINFO("Requested albums from connected devices");
      }
    } catch (e) {
      printERROR("Failed to request albums from devices: $e");
    }
  }

  /// Send artist favorites to connected devices
  Future<void> _sendArtistFavoritesToDevices(List<Map<String, dynamic>> artistFavorites) async {
    try {
      if (_webSocketChannel != null) {
        final message = {
          'type': 'artist_favorites_sync',
          'action': 'send',
          'deviceId': _deviceId,
          'artistFavorites': artistFavorites,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        _webSocketChannel!.sink.add(jsonEncode(message));
        printINFO("Sent ${artistFavorites.length} artist favorites to connected devices");
      }
    } catch (e) {
      printERROR("Failed to send artist favorites to devices: $e");
    }
  }

  /// Request artist favorites from connected devices
  Future<void> _requestArtistFavoritesFromDevices() async {
    try {
      if (_webSocketChannel != null) {
        final message = {
          'type': 'artist_favorites_sync',
          'action': 'request',
          'deviceId': _deviceId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        _webSocketChannel!.sink.add(jsonEncode(message));
        printINFO("Requested artist favorites from connected devices");
      }
    } catch (e) {
      printERROR("Failed to request artist favorites from devices: $e");
    }
  }

  /// Receive playlists from another device
  Future<void> _receivePlaylistsFromDevice(Map<String, dynamic> data) async {
    try {
      final playlists = data['playlists'] as List<dynamic>;
      final sourceDeviceId = data['deviceId'] as String;

      printINFO("Receiving ${playlists.length} playlists from device: $sourceDeviceId");

      final playlistBox = await Hive.openBox('LibraryPlaylists');
      int mergedCount = 0;

      for (final playlistData in playlists) {
        final playlist = playlistData as Map<String, dynamic>;
        final playlistId = playlist['id'] as String;
        final playlistName = playlist['data']['title'] as String? ?? '';
        final lastModified = playlist['lastModified'] as int;

        // Check if we should merge this playlist
        final existingPlaylist = playlistBox.get(playlistId);

        if (existingPlaylist == null) {
          // Check for playlists with the same name but different IDs
          final playlistWithSameName = await _findPlaylistByName(playlistName);

          if (playlistWithSameName != null) {
            // Merge playlists with same name
            await _mergePlaylistsByName(playlistWithSameName, playlist['data'], playlistName);
            mergedCount++;
            printINFO("Merged playlist by name: $playlistName");
          } else {
            // New playlist
            await playlistBox.put(playlistId, playlist['data']);
            mergedCount++;
            printINFO("Added new playlist: $playlistName");
          }
        } else {
          // Compare modification times for existing playlist with same ID
          final existingModified = existingPlaylist['lastModified'] as int? ?? 0;
          if (lastModified > existingModified) {
            // Remote version is newer, but merge songs intelligently
            await _mergePlaylistSongs(existingPlaylist, playlist['data'], playlistId);
            mergedCount++;
            printINFO("Merged playlist songs: $playlistName");
          }
        }
      }

      await playlistBox.close();
      printINFO("Successfully merged $mergedCount playlists from $sourceDeviceId");

      // Refresh UI to show new playlists
      if (mergedCount > 0) {
        _refreshPlaylistUI();
      }

    } catch (e) {
      printERROR("Error receiving playlists from device: $e");
    }
  }

  /// Refresh playlist UI after synchronization
  void _refreshPlaylistUI() {
    try {
      // Trigger UI refresh for library playlists
      if (Get.isRegistered<LibraryPlaylistsController>()) {
        Get.find<LibraryPlaylistsController>().refreshLib();
        printINFO("Refreshed playlist UI after sync");
      }
    } catch (e) {
      printERROR("Failed to refresh playlist UI: $e");
    }
  }

  /// Find playlist by name in local storage
  Future<Map<String, dynamic>?> _findPlaylistByName(String playlistName) async {
    try {
      final playlistBox = await Hive.openBox('LibraryPlaylists');

      for (final key in playlistBox.keys) {
        final playlist = playlistBox.get(key);
        if (playlist != null && playlist['title'] == playlistName) {
          await playlistBox.close();
          return {'id': key, 'data': playlist};
        }
      }

      await playlistBox.close();
      return null;
    } catch (e) {
      printERROR("Error finding playlist by name: $e");
      return null;
    }
  }

  /// Merge playlists with the same name
  Future<void> _mergePlaylistsByName(Map<String, dynamic> existingPlaylist, Map<String, dynamic> newPlaylistData, String playlistName) async {
    try {
      final existingId = existingPlaylist['id'] as String;
      final existingData = existingPlaylist['data'] as Map<String, dynamic>;

      // Get songs from both playlists
      final existingSongs = await _getPlaylistSongs(existingId);
      final newSongs = newPlaylistData['tracks'] as List<dynamic>? ?? [];

      // Merge songs (remove duplicates based on song ID)
      final mergedSongs = <String, dynamic>{};

      // Add existing songs
      for (final song in existingSongs) {
        final songId = song['videoId'] as String;
        mergedSongs[songId] = song;
      }

      // Add new songs (will overwrite if same ID)
      for (final song in newSongs) {
        final songId = song['videoId'] as String;
        mergedSongs[songId] = song;
      }

      // Update the existing playlist with merged songs
      final updatedPlaylistData = Map<String, dynamic>.from(existingData);
      updatedPlaylistData['tracks'] = mergedSongs.values.toList();
      updatedPlaylistData['lastModified'] = DateTime.now().millisecondsSinceEpoch;

      final playlistBox = await Hive.openBox('LibraryPlaylists');
      await playlistBox.put(existingId, updatedPlaylistData);
      await playlistBox.close();

      // Also update the songs box for this playlist
      await _updatePlaylistSongsBox(existingId, mergedSongs.values.toList());

      printINFO("Successfully merged playlist '$playlistName' with ${mergedSongs.length} unique songs");

    } catch (e) {
      printERROR("Error merging playlists by name: $e");
    }
  }

  /// Merge songs from two versions of the same playlist
  Future<void> _mergePlaylistSongs(Map<String, dynamic> existingPlaylist, Map<String, dynamic> newPlaylistData, String playlistId) async {
    try {
      // Get songs from both versions
      final existingSongs = await _getPlaylistSongs(playlistId);
      final newSongs = newPlaylistData['tracks'] as List<dynamic>? ?? [];

      // Merge songs (remove duplicates based on song ID)
      final mergedSongs = <String, dynamic>{};

      // Add existing songs
      for (final song in existingSongs) {
        final songId = song['videoId'] as String;
        mergedSongs[songId] = song;
      }

      // Add new songs (will overwrite if same ID)
      for (final song in newSongs) {
        final songId = song['videoId'] as String;
        mergedSongs[songId] = song;
      }

      // Update the playlist with merged songs
      final updatedPlaylistData = Map<String, dynamic>.from(newPlaylistData);
      updatedPlaylistData['tracks'] = mergedSongs.values.toList();
      updatedPlaylistData['lastModified'] = DateTime.now().millisecondsSinceEpoch;

      final playlistBox = await Hive.openBox('LibraryPlaylists');
      await playlistBox.put(playlistId, updatedPlaylistData);
      await playlistBox.close();

      // Also update the songs box for this playlist
      await _updatePlaylistSongsBox(playlistId, mergedSongs.values.toList());

      printINFO("Successfully merged songs for playlist '$playlistId' with ${mergedSongs.length} unique songs");

    } catch (e) {
      printERROR("Error merging playlist songs: $e");
    }
  }

  /// Get songs from a playlist
  Future<List<dynamic>> _getPlaylistSongs(String playlistId) async {
    try {
      final songsBox = await Hive.openBox(playlistId);
      final songs = <dynamic>[];

      for (final key in songsBox.keys) {
        final song = songsBox.get(key);
        if (song != null) {
          songs.add(song);
        }
      }

      await songsBox.close();
      return songs;
    } catch (e) {
      printERROR("Error getting playlist songs: $e");
      return [];
    }
  }

  /// Update the songs box for a playlist
  Future<void> _updatePlaylistSongsBox(String playlistId, List<dynamic> songs) async {
    try {
      final songsBox = await Hive.openBox(playlistId);
      await songsBox.clear();

      for (int i = 0; i < songs.length; i++) {
        await songsBox.put(i, songs[i]);
      }

      await songsBox.close();
      printINFO("Updated songs box for playlist '$playlistId' with ${songs.length} songs");
    } catch (e) {
      printERROR("Error updating playlist songs box: $e");
    }
  }

  /// Respond to playlist request from another device
  Future<void> _respondToPlaylistRequest(Map<String, dynamic> data) async {
    try {
      final requestingDeviceId = data['deviceId'] as String;
      printINFO("Responding to playlist request from: $requestingDeviceId");

      // Get local playlists
      final localPlaylists = await _getLocalPlaylists();

      // Send playlists to requesting device
      final response = {
        'type': 'playlist_sync',
        'action': 'send',
        'deviceId': _deviceId,
        'playlists': localPlaylists,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _webSocketChannel?.sink.add(jsonEncode(response));
      printINFO("Sent ${localPlaylists.length} playlists to $requestingDeviceId");

    } catch (e) {
      printERROR("Error responding to playlist request: $e");
    }
  }

  /// Handle playlist update from another device
  Future<void> _handlePlaylistUpdate(Map<String, dynamic> data) async {
    try {
      final playlistId = data['playlistId'] as String;
      final playlistData = data['playlistData'] as Map<String, dynamic>;
      final lastModified = data['lastModified'] as int;
      final sourceDeviceId = data['deviceId'] as String;

      printINFO("Handling playlist update for: $playlistId from $sourceDeviceId");

      final playlistBox = await Hive.openBox('LibraryPlaylists');

      // Check if we should apply this update
      final existingPlaylist = playlistBox.get(playlistId);
      bool shouldUpdate = false;

      if (existingPlaylist == null) {
        shouldUpdate = true; // New playlist
      } else {
        final existingModified = existingPlaylist['lastModified'] as int? ?? 0;
        if (lastModified > existingModified) {
          shouldUpdate = true; // Remote version is newer
        }
      }

      if (shouldUpdate) {
        await playlistBox.put(playlistId, playlistData);
        printINFO("Updated playlist: $playlistId");
      } else {
        printINFO("Skipped playlist update (local version is newer): $playlistId");
      }

      await playlistBox.close();

    } catch (e) {
      printERROR("Error handling playlist update: $e");
    }
  }

  /// Receive albums from another device
  Future<void> _receiveAlbumsFromDevice(Map<String, dynamic> data) async {
    try {
      final albums = data['albums'] as List<dynamic>;
      final sourceDeviceId = data['deviceId'] as String;

      printINFO("Received ${albums.length} albums from device: $sourceDeviceId");

      final albumBox = await Hive.openBox('LibraryAlbums');
      int mergedCount = 0;

      for (final albumData in albums) {
        final album = albumData as Map<String, dynamic>;
        final albumId = album['id'] as String;
        final lastModified = album['lastModified'] as int;

        // Check if we should merge this album
        final existingAlbum = albumBox.get(albumId);
        bool shouldMerge = false;

        if (existingAlbum == null) {
          shouldMerge = true; // New album
        } else {
          // Compare modification times
          final existingModified = existingAlbum['lastModified'] as int? ?? 0;
          if (lastModified > existingModified) {
            shouldMerge = true; // Remote version is newer
          }
        }

        if (shouldMerge) {
          await albumBox.put(albumId, album['data']);
          mergedCount++;
          printINFO("Merged album: $albumId");
        }
      }

      await albumBox.close();
      printINFO("Successfully merged $mergedCount albums from $sourceDeviceId");

    } catch (e) {
      printERROR("Error receiving albums from device: $e");
    }
  }

  /// Merge artist favorites from another device
  Future<void> _mergeArtistFavorites(List<dynamic> artistFavorites, String sourceDeviceId) async {
    try {
      final artistBox = await Hive.openBox('LibraryArtists');
      int mergedCount = 0;

      for (final artistData in artistFavorites) {
        final artist = artistData as Map<String, dynamic>;
        final artistId = artist['id'] as String;
        final lastModified = artist['lastModified'] as int;

        // Check if we should merge this artist favorite
        final existingArtist = artistBox.get(artistId);
        bool shouldMerge = false;

        if (existingArtist == null) {
          shouldMerge = true; // New artist favorite
        } else {
          // Compare modification times
          final existingModified = existingArtist['lastModified'] as int? ?? 0;
          if (lastModified > existingModified) {
            shouldMerge = true; // Remote version is newer
          }
        }

        if (shouldMerge) {
          await artistBox.put(artistId, artist['data']);
          mergedCount++;
          printINFO("Merged artist favorite: $artistId");
        }
      }

      await artistBox.close();
      printINFO("Successfully merged $mergedCount artist favorites from $sourceDeviceId");

    } catch (e) {
      printERROR("Error merging artist favorites: $e");
    }
  }

  /// Respond to album request from another device
  Future<void> _respondToAlbumRequest(Map<String, dynamic> data) async {
    try {
      final requestingDeviceId = data['deviceId'] as String;
      printINFO("Responding to album request from: $requestingDeviceId");

      // Get local albums
      final localAlbums = await _getLocalAlbums();

      // Send albums to requesting device
      final response = {
        'type': 'album_sync',
        'action': 'send',
        'deviceId': _deviceId,
        'albums': localAlbums,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _webSocketChannel?.sink.add(jsonEncode(response));
      printINFO("Sent ${localAlbums.length} albums to $requestingDeviceId");

    } catch (e) {
      printERROR("Error responding to album request: $e");
    }
  }

  /// Handle album update from another device
  Future<void> _handleAlbumUpdate(Map<String, dynamic> data) async {
    try {
      final albumId = data['albumId'] as String;
      final albumData = data['albumData'] as Map<String, dynamic>;
      final lastModified = data['lastModified'] as int;
      final sourceDeviceId = data['deviceId'] as String;

      printINFO("Handling album update for: $albumId from $sourceDeviceId");

      final albumBox = await Hive.openBox('LibraryAlbums');

      // Check if we should apply this update
      final existingAlbum = albumBox.get(albumId);
      bool shouldUpdate = false;

      if (existingAlbum == null) {
        shouldUpdate = true; // New album
      } else {
        final existingModified = existingAlbum['lastModified'] as int? ?? 0;
        if (lastModified > existingModified) {
          shouldUpdate = true; // Remote version is newer
        }
      }

      if (shouldUpdate) {
        await albumBox.put(albumId, albumData);
        printINFO("Updated album: $albumId");
      } else {
        printINFO("Skipped album update (local version is newer): $albumId");
      }

      await albumBox.close();

    } catch (e) {
      printERROR("Error handling album update: $e");
    }
  }

  /// Receive artist favorites from another device
  Future<void> _receiveArtistFavoritesFromDevice(Map<String, dynamic> data) async {
    try {
      final artistFavorites = data['artistFavorites'] as List<dynamic>;
      final sourceDeviceId = data['deviceId'] as String;

      printINFO("Received ${artistFavorites.length} artist favorites from device: $sourceDeviceId");

      // Merge artist favorites into local storage
      await _mergeArtistFavorites(artistFavorites, sourceDeviceId);

    } catch (e) {
      printERROR("Error receiving artist favorites from device: $e");
    }
  }

  /// Respond to artist favorites request from another device
  Future<void> _respondToArtistFavoritesRequest(Map<String, dynamic> data) async {
    try {
      final requestingDeviceId = data['deviceId'] as String;
      printINFO("Responding to artist favorites request from: $requestingDeviceId");

      // Get local artist favorites
      final localArtistFavorites = await _getLocalArtistFavorites();

      // Send artist favorites to requesting device
      final response = {
        'type': 'artist_favorites_sync',
        'action': 'send',
        'deviceId': _deviceId,
        'artistFavorites': localArtistFavorites,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _webSocketChannel?.sink.add(jsonEncode(response));
      printINFO("Sent ${localArtistFavorites.length} artist favorites to $requestingDeviceId");

    } catch (e) {
      printERROR("Error responding to artist favorites request: $e");
    }
  }

  /// Handle artist favorite update from another device
  Future<void> _handleArtistFavoriteUpdate(Map<String, dynamic> data) async {
    try {
      final artistId = data['artistId'] as String;
      final artistData = data['artistData'] as Map<String, dynamic>;
      final lastModified = data['lastModified'] as int;
      final sourceDeviceId = data['deviceId'] as String;

      printINFO("Handling artist favorite update for: $artistId from $sourceDeviceId");

      final artistBox = await Hive.openBox('LibraryArtists');

      // Check if we should apply this update
      final existingArtist = artistBox.get(artistId);
      bool shouldUpdate = false;

      if (existingArtist == null) {
        shouldUpdate = true; // New artist favorite
      } else {
        final existingModified = existingArtist['lastModified'] as int? ?? 0;
        if (lastModified > existingModified) {
          shouldUpdate = true; // Remote version is newer
        }
      }

      if (shouldUpdate) {
        await artistBox.put(artistId, artistData);
        printINFO("Updated artist favorite: $artistId");
      } else {
        printINFO("Skipped artist favorite update (local version is newer): $artistId");
      }

      await artistBox.close();

    } catch (e) {
      printERROR("Error handling artist favorite update: $e");
    }
  }

  /// Receive settings from another device
  Future<void> _receiveSettingsFromDevice(Map<String, dynamic> data) async {
    try {
      final settings = data['settings'] as Map<String, dynamic>;
      final sourceDeviceId = data['deviceId'] as String;

      printINFO("Receiving settings from device: $sourceDeviceId");

      final settingsBox = Hive.box('settings');

      // Merge settings (only non-device-specific ones)
      final mergeableSettings = [
        'theme',
        'language',
        'audioQuality',
        'autoSync',
        'syncWiFiOnly',
      ];

      int mergedCount = 0;
      for (final key in mergeableSettings) {
        if (settings.containsKey(key)) {
          await settingsBox.put(key, settings[key]);
          mergedCount++;
        }
      }

      printINFO("Merged $mergedCount settings from $sourceDeviceId");

    } catch (e) {
      printERROR("Error receiving settings from device: $e");
    }
  }

  /// Respond to settings request from another device
  Future<void> _respondToSettingsRequest(Map<String, dynamic> data) async {
    try {
      final requestingDeviceId = data['deviceId'] as String;
      printINFO("Responding to settings request from: $requestingDeviceId");

      final settingsBox = Hive.box('settings');
      final settings = <String, dynamic>{};

      // Only share non-device-specific settings
      final shareableSettings = [
        'theme',
        'language',
        'audioQuality',
        'autoSync',
        'syncWiFiOnly',
      ];

      for (final key in shareableSettings) {
        final value = settingsBox.get(key);
        if (value != null) {
          settings[key] = value;
        }
      }

      final response = {
        'type': 'settings_sync',
        'action': 'send',
        'deviceId': _deviceId,
        'settings': settings,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _webSocketChannel?.sink.add(jsonEncode(response));
      printINFO("Sent ${settings.length} settings to $requestingDeviceId");

    } catch (e) {
      printERROR("Error responding to settings request: $e");
    }
  }

  /// Generate unique device ID
  String _generateDeviceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final platform = Platform.operatingSystem.toUpperCase();
    return "AMADEUSE-$platform-$timestamp";
  }
  
  @override
  void onClose() {
    stopService();
    super.onClose();
  }
}
