import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class NoInternetView extends StatelessWidget {
  const NoInternetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 100, color: Colors.red),
              const SizedBox(height: 20),
              Text('No Internet Connection', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text(
                'Please check your connection and try again.',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Get.forceAppUpdate(), // rebuild app (optional)
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
