import 'package:flutter/material.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onLater;

  const LocationPermissionDialog({
    super.key,
    required this.onAllow,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      title: const Row(
        children: [
          Icon(Icons.location_on, color: Color(0xFF0B4B4B)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Allow Seeker to access your location",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),

      content: const Text(
        "Seeker uses your location to calculate accurate prayer times, prayer notifications and Qibla direction.\n\nYour location is stored only on this device and is never shared.",
        style: TextStyle(fontSize: 15, height: 1.5),
      ),

      actions: [
        TextButton(onPressed: onLater, child: const Text("Not Now")),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B4B4B),
          ),
          onPressed: onAllow,
          child: const Text("Allow", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
