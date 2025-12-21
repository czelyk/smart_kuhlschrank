import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_kuhlschrank/l10n/app_localizations.dart';

class BluetoothSetupScreen extends StatefulWidget {
  const BluetoothSetupScreen({Key? key}) : super(key: key);

  @override
  State<BluetoothSetupScreen> createState() => _BluetoothSetupScreenState();
}

class _BluetoothSetupScreenState extends State<BluetoothSetupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  bool _isConnecting = false;
  String _statusMessage = '';

  // ESP32'deki Servis ve Karakteristik UUID'leri (Bunları ESP32 kodunuzla eşleştirin)
  // Genellikle standart bir UART servisi veya kendi özel UUID'niz olabilir.
  // Örnek olarak yaygın kullanılan Nordic UART Service UUID'lerini koyuyorum.
  // ESP32 tarafında bunları kullanmanız veya burayı güncellemeniz gerekir.
  final String SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"; 
  final String CHARACTERISTIC_UUID_RX = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"; // Yazma (Write)
  // final String CHARACTERISTIC_UUID_TX = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"; // Okuma (Notify)

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      // Android 12+ için
      if (await Permission.bluetoothScan.request().isGranted &&
          await Permission.bluetoothConnect.request().isGranted &&
          await Permission.location.request().isGranted) {
        // İzinler tamam
      } else {
        // Eski Android sürümleri için (Location yeterli olabilir)
        await Permission.location.request();
      }
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _scanResults.clear();
      _statusMessage = 'Scanning for devices...';
    });

    try {
      // Sadece 4 saniye tara
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

      FlutterBluePlus.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            // Sadece ismi olan cihazları göster
            _scanResults = results
                .where((r) => r.device.platformName.isNotEmpty)
                .toList();
          });
        }
      });

      // Tarama bittiğinde
      FlutterBluePlus.isScanning.listen((isScanning) {
        if (mounted) {
          setState(() {
            _isScanning = isScanning;
            if (!isScanning && _scanResults.isEmpty) {
              _statusMessage = 'No devices found.';
            } else if (!isScanning) {
              _statusMessage = 'Select your Smart Fridge';
            }
          });
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error scanning: $e';
        _isScanning = false;
      });
    }
  }

  Future<void> _connectAndSendUid(BluetoothDevice device) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    setState(() {
      _isConnecting = true;
      _statusMessage = 'Connecting to ${device.platformName}...';
    });

    try {
      await device.connect();
      _connectedDevice = device;

      setState(() {
        _statusMessage = 'Connected! Discovering services...';
      });

      // Servisleri keşfet
      List<BluetoothService> services = await device.discoverServices();
      
      BluetoothCharacteristic? writeCharacteristic;

      // Doğru servisi ve karakteristiği bul
      for (var service in services) {
        // Servis UUID kontrolü (veya herhangi bir yazılabilir karakteristik bulmaya çalış)
        // Burada basitlik adına yazılabilir (write) özelliği olan ilk karakteristiği buluyoruz
        // ESP32 tarafında özel bir UUID kullanıyorsanız, onu filtrelemek daha iyi olur.
        for (var characteristic in service.characteristics) {
           if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
             writeCharacteristic = characteristic;
             // Eğer özel UUID eşleşiyorsa döngüyü kırabiliriz
             if (service.uuid.toString().toUpperCase() == SERVICE_UUID || 
                 characteristic.uuid.toString().toUpperCase() == CHARACTERISTIC_UUID_RX) {
               break;
             }
           }
        }
        if (writeCharacteristic != null) break;
      }

      if (writeCharacteristic != null) {
        setState(() {
          _statusMessage = 'Sending User ID...';
        });

        // UID'yi byte array'e çevirip gönder
        String dataToSend = "UID:${user.uid}\n"; // Sonu \n ile biten bir string gönderiyoruz
        await writeCharacteristic.write(utf8.encode(dataToSend));

        setState(() {
          _statusMessage = 'Setup Complete! Device registered.';
        });

        // Başarılı mesajı göster
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Your Smart Fridge has been successfully linked to your account!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Dialog kapat
                    Navigator.of(context).pop(); // Ekranı kapat
                  },
                  child: const Text('OK'),
                )
              ],
            ),
          );
        }

        // İşi bitince bağlantıyı kesebiliriz
        await device.disconnect();

      } else {
        setState(() {
          _statusMessage = 'Error: Writable characteristic not found on device.';
        });
        await device.disconnect();
      }

    } catch (e) {
      setState(() {
        _statusMessage = 'Connection failed: $e';
      });
      // Hata durumunda bağlantıyı kesmeyi dene
      try { await device.disconnect(); } catch (_) {}
    } finally {
      setState(() {
        _isConnecting = false;
        _connectedDevice = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Localization desteği olmadığı için şimdilik hardcoded stringler kullanıyoruz
    // İsterseniz l10n dosyalarına ekleyebilirsiniz.
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Setup'),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            width: double.infinity,
            child: Column(
              children: [
                const Icon(Icons.bluetooth_searching, size: 48, color: Colors.teal),
                const SizedBox(height: 8),
                Text(
                  _statusMessage.isEmpty ? 'Tap scan to find your fridge' : _statusMessage,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Device List
          Expanded(
            child: _isScanning 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _scanResults.length,
                  itemBuilder: (context, index) {
                    final result = _scanResults[index];
                    return ListTile(
                      leading: const Icon(Icons.kitchen),
                      title: Text(result.device.platformName),
                      subtitle: Text(result.device.remoteId.toString()),
                      trailing: ElevatedButton(
                        onPressed: _isConnecting 
                          ? null 
                          : () => _connectAndSendUid(result.device),
                        child: const Text('Connect'),
                      ),
                    );
                  },
                ),
          ),
          
          // Scan Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(_isScanning ? 'Scanning...' : 'Scan for Devices'),
                onPressed: _isScanning || _isConnecting ? null : _startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
