import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../screens/information_page.dart';

class WelcomeHeader extends StatefulWidget {
  final Size screenSize;

  const WelcomeHeader({Key? key, required this.screenSize}) : super(key: key);

  @override
  _WelcomeHeaderState createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends State<WelcomeHeader> {
  int _tapCount = 0;
  Timer? _resetTimer;

  void _onTitleTapped() {
    _resetTimer?.cancel();
    _tapCount++;
    if (_tapCount >= 7) {
      _tapCount = 0;
      final provider =
          Provider.of<SubscriptionProvider>(context, listen: false);
      // Grant the freeForever subscription:
      provider.buySubscription(SubscriptionPlan.freeForever());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              ' ✨ ✨ ✨ Votre abonnement cadeau de la part de Sika est actif !\n Tout est débloqué  ✨ ✨ ✨'),
          backgroundColor: Colors.indigo,
          duration: Duration(seconds: 4),
        ),
      );
    } else {
      // reset counter if no new tap within 2 seconds
      _resetTimer = Timer(const Duration(seconds: 2), () {
        _tapCount = 0;
      });
    }
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: widget.screenSize.height * 0.03),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(child: SizedBox()),
              GestureDetector(
                onTap: _onTitleTapped,
                child: const Text(
                  'Maths Pour Enfants',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded,
                          color: Colors.indigo, size: 28),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InformationPage(),
                            settings:
                                const RouteSettings(name: 'information_page'),
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