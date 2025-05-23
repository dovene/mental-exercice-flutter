import 'package:flutter/material.dart';
import '../screens/information_page.dart';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: SizedBox(), // For centering
              ),
              const Text(
                'Math Pour Enfants',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.indigo,
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InformationPage(),
                            settings: const RouteSettings(name: 'information_page'),
                          ),
                        );
                      },
                      tooltip: 'Informations',
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ],
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
        ],
      ),
    );
  }
}