enum SubscriptionType { free, monthly, annual, family, test, freeForever }

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
      description: 'Accès aux opérations sans abonnement',
      price: 0.0,
      type: SubscriptionType.free,
      duration: const Duration(days: 0),
      features: [
        'Addition',
        'Configuration des exercices d\addition',
        'Suivi des progrès'
      ],
    );
  }

  factory SubscriptionPlan.monthly() {
    return SubscriptionPlan(
      id: 'monthly',
      storeId: 'mathomagic_monthly', // Set your actual Google/Apple product ID
      name: 'Abonnement Mensuel',
      description: 'Access complet à toutes les opérations',
      price: 10,
      type: SubscriptionType.monthly,
      duration: const Duration(days: 30),
      features: [
        'Toutes les opérations',
        'Exercices illimités',
        'Suivi des progrès',
        'Contenu bonus',
        'Pas de publicités'
      ],
    );
  }

  factory SubscriptionPlan.annual() {
    return SubscriptionPlan(
      id: 'annual',
      storeId: 'mathomagic_yearly', // Set your actual Google/Apple product ID
      name: 'Abonnement annuel',
      description: 'Access complet avec une remise de 20% sur le prix',
      price: 96,
      type: SubscriptionType.annual,
      duration: const Duration(days: 365),
      features: [
        'Toutes les opérations',
        'Exercices illimités',
        'Suivi des progrès',
        'Contenu bonus',
        'Pas de publicités'
      ],
    );
  }

  factory SubscriptionPlan.freeForever() {
    return SubscriptionPlan(
      id: 'freeForever',
      storeId: 'FreeForever', // This is my free forever plan to keep hidden from users
      name: 'Abonnement gratuit permanent',
      description: 'Cadeau de Sika',
      price: 0,
      type: SubscriptionType.family,
      duration: const Duration(days: 10000000),
      features: [
        'Toutes les opérations',
        'Exercices illimités',
        'Suivi des progrès',
        'Contenu bonus',
        'Pas de publicités'
      ],
    );
  }
}
