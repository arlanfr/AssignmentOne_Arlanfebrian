import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

import 'auth_page.dart';

class NfcReaderScreen extends StatefulWidget {
  const NfcReaderScreen({super.key});

  @override
  State<NfcReaderScreen> createState() => _NfcReaderScreenState();
}

class _NfcReaderScreenState extends State<NfcReaderScreen> {
  String nfcContent = 'Tap an NFC tag to read';
  bool isReading = false;

  Future<void> _readNfc() async {
    setState(() {
      isReading = true;
      nfcContent = 'Waiting for NFC tag...';
    });

    try {
      final tag = await FlutterNfcKit.poll();
      final ndefRecords = await FlutterNfcKit.readNDEFRecords();

      setState(() {
        nfcContent =
            'Tag Type: ${tag.type}\n'
            'NDEF Records: ${ndefRecords.length}\n'
            'First Record: ${ndefRecords.isNotEmpty ? ndefRecords.first : 'Empty'}';
      });
    } catch (e) {
      setState(() {
        nfcContent = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() => isReading = false);
      await FlutterNfcKit.finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.nfc, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              nfcContent,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.nfc),
              label: Text(isReading ? 'Reading...' : 'Start Reading'),
              onPressed: isReading ? null : _readNfc,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    FlutterNfcKit.finish();
    super.dispose();
  }
}
