import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/services/device_sync_service.dart';

class DeviceDiscoveryScreen extends StatefulWidget {
  const DeviceDiscoveryScreen({super.key});

  @override
  State<DeviceDiscoveryScreen> createState() => _DeviceDiscoveryScreenState();
}

class _DeviceDiscoveryScreenState extends State<DeviceDiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    // Start discovery when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceSyncService = Get.find<DeviceSyncService>();
      deviceSyncService.startService();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSyncService = Get.find<DeviceSyncService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Découverte d\'appareils',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Instructions Card
            Card(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('1. Assurez-vous que les deux appareils sont sur le même WiFi',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text('2. Ouvrez l\'application sur l\'autre appareil',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text('3. Activez la synchronisation sur l\'autre appareil',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text('4. Sélectionnez l\'appareil à appairer ci-dessous',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text('5. Confirmez le code sur les deux appareils',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            
            // Discovered devices section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Appareils découverts:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          // Refresh discovery
                          deviceSyncService.discoveredDevices.clear();
                          deviceSyncService.startService();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: Obx(() {
                      if (deviceSyncService.discoveredDevices.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, size: 64, color: Theme.of(context).disabledColor),
                              const SizedBox(height: 16),
                              Text(
                                'Recherche d\'appareils...',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Assurez-vous que l\'autre appareil est sur le même WiFi',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).disabledColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        itemCount: deviceSyncService.discoveredDevices.length,
                        itemBuilder: (context, index) {
                          final device = deviceSyncService.discoveredDevices[index];
                          final deviceId = device['deviceId'] as String;
                          final deviceName = device['deviceName'] as String;
                          final deviceAddress = device['address'] as String;
                          final isPaired = deviceSyncService.isDevicePaired(deviceId);

                          return Card(
                            color: Theme.of(context).cardColor,
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isPaired
                                    ? Colors.green
                                    : Theme.of(context).primaryColor,
                                child: Icon(
                                  isPaired ? Icons.link : Icons.smartphone,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                deviceName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ID: $deviceId',
                                      style: Theme.of(context).textTheme.bodySmall),
                                  Text('Adresse: $deviceAddress',
                                      style: Theme.of(context).textTheme.bodySmall),
                                  Text(
                                    isPaired ? 'Appareil appairé ✓' : 'Non appairé',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isPaired ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: isPaired
                                  ? PopupMenuButton(
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: const Row(
                                            children: [
                                              Icon(Icons.link_off, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Désappairer'),
                                            ],
                                          ),
                                          onTap: () {
                                            deviceSyncService.removePairedDevice(deviceId);
                                          },
                                        ),
                                      ],
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: () {
                                        _showPairingDialog(context, deviceSyncService, deviceId, deviceName);
                                      },
                                      icon: const Icon(Icons.link),
                                      label: const Text('Appairer'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Paired devices section
            Card(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appareils appairés:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Obx(() {
                      if (deviceSyncService.pairedDevices.isEmpty) {
                        return Text(
                          'Aucun appareil appairé',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).disabledColor,
                          ),
                        );
                      }

                      return Column(
                        children: deviceSyncService.pairedDevices.map((deviceId) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.link, color: Colors.green),
                            title: Text(
                              'Appareil $deviceId',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showUnpairDialog(context, deviceSyncService, deviceId);
                              },
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPairingDialog(BuildContext context, DeviceSyncService service, String deviceId, String deviceName) {
    service.sendPairingRequest(deviceId);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Obx(() {
        // Auto-close dialog when pairing is completed (pendingPairingCode becomes empty)
        if (service.pendingPairingCode.value.isEmpty && service.pendingPairingDevice.value.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
        }

        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Demande d\'appairage',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Demande envoyée à:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                deviceName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Code de vérification:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                service.pendingPairingCode.value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Vérifiez que ce code correspond à celui affiché sur l\'autre appareil, puis confirmez sur les deux appareils.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                service.pendingPairingCode.value = "";
                service.pendingPairingDevice.value = "";
                Navigator.of(context).pop();
              },
              child: Text(
                'Annuler',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showUnpairDialog(BuildContext context, DeviceSyncService service, String deviceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Désappairer l\'appareil',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Êtes-vous sûr de vouloir désappairer cet appareil ?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              service.removePairedDevice(deviceId);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Désappairer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
