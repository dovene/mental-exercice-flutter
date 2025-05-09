enum SubscriptionType { free, monthly, annual, family }

class SubscriptionPlan {
  final String id;
  final String storeId; // ID used in App Store/Google Play
  final String name;
  final String description;
  final double price;
  final SubscriptionType type;
  final Duration duration;
  final List<String> features;

  SubscriptionPlan({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.duration,
    required this.features,
  });

  // Factory methods for each plan type
  factory SubscriptionPlan.free() {
    return SubscriptionPlan(
      id: 'free',
      storeId: '',
      name: 'Free',
      description: 'Access to basic operations',
      price: 0.0,
      type: SubscriptionType.free,
      duration: const Duration(days: 0),
      features: [
        'Addition exercises',
        'Limited exercises per day',
        'Progress tracking'
      ],
    );
  }

  factory SubscriptionPlan.monthly() {
    return SubscriptionPlan(
      id: 'monthly',
      storeId: 'math_app_monthly', // Set your actual Google/Apple product ID
      name: 'Monthly Plan',
      description: 'Full access to all operations',
      price: 4.99,
      type: SubscriptionType.monthly,
      duration: const Duration(days: 30),
      features: [
        'All operations',
        'Unlimited exercises',
        'Progress tracking',
        'No ads'
      ],
    );
  }

  factory SubscriptionPlan.annual() {
    return SubscriptionPlan(
      id: 'annual',
      storeId: 'math_app_annual', // Set your actual Google/Apple product ID
      name: 'Annual Plan',
      description: 'Full access with 20% savings',
      price: 47.99,
      type: SubscriptionType.annual,
      duration: const Duration(days: 365),
      features: [
        'All operations',
        'Unlimited exercises',
        'Progress tracking',
        'Bonus content',
        'No ads'
      ],
    );
  }

  factory SubscriptionPlan.family() {
    return SubscriptionPlan(
      id: 'family',
      storeId: 'math_app_family', // Set your actual Google/Apple product ID
      name: 'Family Plan',
      description: 'Share with up to 5 family members',
      price: 79.99,
      type: SubscriptionType.family,
      duration: const Duration(days: 365),
      features: [
        'Up to 5 profiles',
        'All operations',
        'Unlimited exercises',
        'Progress tracking',
        'Bonus content',
        'No ads'
      ],
    );
  }
}
