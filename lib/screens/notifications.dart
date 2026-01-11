import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:smart_kuhlschrank/l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _currentStep = 0;
  bool _isConnecting = false;
  BluetoothDevice? _targetDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  String _statusMessage = "";

  Future<void> _findAndConnect() async {
    setState(() {
      _isConnecting = true;
      _statusMessage = "Searching for device...";
    });

    try {
      // 1. Tarama başlat
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      
      Completer<BluetoothDevice?> completer = Completer();
      var subscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.platformName == "Smart Fridge ESP32") {
            completer.complete(r.device);
            FlutterBluePlus.stopScan();
            break;
          }
        }
      });

      _targetDevice = await completer.future.timeout(const Duration(seconds: 10), onTimeout: () => null);
      await subscription.cancel();

      if (_targetDevice == null) {
        setState(() {
          _isConnecting = false;
          _statusMessage = "Device not found. Please make sure it's on.";
        });
        return;
      }

      // 2. Bağlan
      await _targetDevice!.connect();
      List<BluetoothService> services = await _targetDevice!.discoverServices();
      
      for (var service in services) {
        for (var c in service.characteristics) {
          if (c.properties.write || c.properties.writeWithoutResponse) {
            _writeCharacteristic = c;
            break;
          }
        }
        if (_writeCharacteristic != null) break;
      }

      setState(() {
        _isConnecting = false;
        _statusMessage = "Connected to device.";
      });
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _statusMessage = "Error: $e";
      });
    }
  }

  Future<void> _sendCommand(String command) async {
    if (_writeCharacteristic == null) {
      await _findAndConnect();
    }

    if (_writeCharacteristic != null) {
      try {
        await _writeCharacteristic!.write(utf8.encode(command));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Command sent: $command"), backgroundColor: Colors.green),
        );
      } catch (e) {
        setState(() => _statusMessage = "Send Error: $e");
      }
    }
  }

  @override
  void dispose() {
    _targetDevice?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sensorCalibration),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.sensorCalibration,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: _statusMessage.contains("Error") ? Colors.red : Colors.teal),
            ),
            const SizedBox(height: 30),
            
            _buildStepCard(
              step: 1,
              title: l10n.emptyPlatforms,
              buttonLabel: l10n.setZero,
              icon: Icons.exposure_zero,
              onPressed: () => _sendCommand("CAL:ZERO").then((_) => setState(() => _currentStep = 1)),
              isActive: _currentStep >= 0,
              isCompleted: _currentStep > 0,
            ),
            
            const SizedBox(height: 16),
            
            _buildStepCard(
              step: 2,
              title: l10n.place800gP1,
              buttonLabel: l10n.calibrateP1,
              icon: Icons.fitness_center,
              onPressed: () => _sendCommand("CAL:P1:800").then((_) => setState(() => _currentStep = 2)),
              isActive: _currentStep >= 1,
              isCompleted: _currentStep > 1,
            ),
            
            const SizedBox(height: 16),
            
            _buildStepCard(
              step: 3,
              title: l10n.place800gP2,
              buttonLabel: l10n.calibrateP2,
              icon: Icons.fitness_center,
              onPressed: () => _sendCommand("CAL:P2:800").then((_) => setState(() => _currentStep = 3)),
              isActive: _currentStep >= 2,
              isCompleted: _currentStep > 2,
            ),

            if (_currentStep == 3) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.calibrationComplete, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: Text(l10n.startCalibration),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required int step,
    required String title,
    required String buttonLabel,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isActive,
    required bool isCompleted,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Opacity(
      opacity: isActive ? 1.0 : 0.5,
      child: Card(
        elevation: isActive ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: isCompleted ? Colors.green : (isActive ? Colors.teal : Colors.grey.shade300), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isCompleted ? Colors.green : (isActive ? Colors.teal : Colors.grey),
                    child: Text(step.toString(), style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (isCompleted) const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isActive ? onPressed : null,
                  icon: Icon(icon),
                  label: Text(buttonLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted ? Colors.green : Colors.teal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
