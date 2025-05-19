import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnement'),
        backgroundColor: Colors.blue,
        actions: [
          TextButton(
            onPressed: () {
              final provider =
                  Provider.of<SubscriptionProvider>(context, listen: false);
              provider.restorePurchases();
            },
            child: const Text(
              'Actualiser',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildCurrentSubscriptionInfo(context, provider),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: provider.plans
                      .where((plan) => plan.type != SubscriptionType.free)
                      .map((plan) => _buildPlanCard(context, plan, provider))
                      .toList(),
                ),
              ),
             /* if (provider.currentSubscription == SubscriptionType.free)
                _buildTrialButton(context, provider),*/
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentSubscriptionInfo(
      BuildContext context, SubscriptionProvider provider) {
    final expiryDate = provider.expiryDate;
    final formattedDate = expiryDate != null
        ? '${expiryDate.day}/${expiryDate.month}/${expiryDate.year}'
        : 'Jamais';

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.info_outline),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Abonnement actuel: ${provider.subscriptionName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (expiryDate != null) Text('Expire le: $formattedDate'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPlan plan,
      SubscriptionProvider provider) {
    final isCurrentPlan = provider.currentSubscription == plan.type;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentPlan
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${plan.price.toStringAsFixed(2)} \€',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan.description,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            ...plan.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isCurrentPlan ? null : () => provider.buySubscription(plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isCurrentPlan ? 'Abonnement actuel' : 'S\'abonner',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialButton(
      BuildContext context, SubscriptionProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => provider.startFreeTrial(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Start 7-Day Free Trial'),
        ),
      ),
    );
  }
}
