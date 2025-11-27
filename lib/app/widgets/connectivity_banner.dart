import 'package:e_services_app/utils/ui_tokens.dart';
import 'package:flutter/material.dart';

class ConnectivityBanner extends StatelessWidget {
  final bool isOnline;
  const ConnectivityBanner({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    if (isOnline) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: AppSpacing.banner,
      color: Colors.red.shade600,
      child: Row(
        children: const [
          Icon(Icons.wifi_off, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text('No internet connection. Some features may not work.', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
