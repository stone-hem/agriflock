import 'package:agriflock360/features/farmer/vet/tabs/browse_vets_tab.dart';
import 'package:flutter/material.dart';

class MainVetScreen extends StatefulWidget {
  const MainVetScreen({super.key});

  @override
  State<MainVetScreen> createState() => _MainVetScreenState();
}

class _MainVetScreenState extends State<MainVetScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logos/Logo_0725.png',
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.green,
                  child: const Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.white54,
                  ),
                );
              },
            ),
            const Text('Agriflock 360'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BrowseVetsTab(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}