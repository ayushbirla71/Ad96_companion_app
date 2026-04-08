import 'package:flutter/material.dart';

class FeatureNotAvailablePage extends StatelessWidget {
  final String featureName;

  const FeatureNotAvailablePage({
    super.key,
    this.featureName = "This Feature",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upgrade Required"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// ICON
            const Icon(
              Icons.lock_outline,
              size: 90,
              color: Colors.indigo,
            ),

            const SizedBox(height: 20),

            /// TITLE
            Text(
              "$featureName is not available in your plan",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// DESCRIPTION
            const Text(
              "Upgrade your plan to unlock this feature and enjoy full access.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            /// UPGRADE BUTTON
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       // TODO: Navigate to pricing or contact sales
            //     },
            //     style: ElevatedButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(vertical: 16),
            //     ),
            //     child: const Text("Upgrade Plan"),
            //   ),
            // ),

            const SizedBox(height: 10),

            /// BACK BUTTON
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Go Back"),
            )
          ],
        ),
      ),
    );
  }
}