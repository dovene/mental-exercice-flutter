import 'package:flutter/material.dart';

import '../screens/subscription_page.dart';

class WelcomeHeader extends StatelessWidget {
  final Size screenSize;

  const WelcomeHeader({
    Key? key,
    required this.screenSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.03),
      child: Column(
        children: [
          const Text(
            'Math Pour Enfants',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 100,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Les maths, c\'est amusant et on aime ❤️',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          // add a button to navigate to the subscription page
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SubscriptionPage()),
              );
            }, child:
            const Text('Abonnement'),)
        ],
      ),
    );
  }
}
