import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subject.dart';
import '../models/subscription.dart';

class SubscriptionProvider extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  List<ProductDetails> _products = [];
  List<SubscriptionPlan> _plans = [];
  SubscriptionType _currentSubscription = SubscriptionType.free;
  DateTime? _expiryDate;
  bool _isLoading = true;

  // Getters
  List<ProductDetails> get products => _products;
  List<SubscriptionPlan> get plans => _plans;
  SubscriptionType get currentSubscription => _currentSubscription;
  DateTime? get expiryDate => _expiryDate;
  bool get isLoading => _isLoading;

  // Check if a subject is unlocked
  bool isSubjectUnlocked(String subjectId) {
    // Always allow access to the free subject (e.g., Addition)
    if (subjectId == SubjectType.addition.name) return true;
    if (subjectId == SubjectType.problemes.name) return true;

    // For other subjects, check subscription status
    return _currentSubscription != SubscriptionType.free;
  }

  // Format methods for the UI
  String get subscriptionName {
    switch (_currentSubscription) {
      case SubscriptionType.free:
        return 'Gratuit';
      case SubscriptionType.monthly:
        return 'Mensuel';
      case SubscriptionType.annual:
        return 'Annuel';
      case SubscriptionType.family:
        return 'Famille';
      case SubscriptionType.freeForever:
        return 'Abonnement gratuit permanent';
      default:
        return 'Inconnu';
    }
  }

  SubscriptionProvider() {
    _initialize();
  }

  Future<void> _initialize() async {

    if (Platform.isAndroid) {
      InAppPurchase.instance.isAvailable().then((available) {
        if (available) {
          InAppPurchase.instance.restorePurchases();
        }
      });
    }

    // Load existing subscription from local storage
    await _loadSubscriptionStatus();

    // Setup IAP stream
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    // Initialize product list
    await _initializeProducts();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final subscriptionType = prefs.getInt('subscriptionType') ?? 0;
    _currentSubscription = SubscriptionType.values[subscriptionType];

    final expiryMillis = prefs.getInt('subscriptionExpiry');
    if (expiryMillis != null) {
      _expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryMillis);

      // Check if subscription has expired
      if (_expiryDate!.isBefore(DateTime.now())) {
        _currentSubscription = SubscriptionType.free;
        _expiryDate = null;
        await _saveSubscriptionStatus();
      }
    }
  }

  Future<void> _saveSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('subscriptionType', _currentSubscription.index);

    if (_expiryDate != null) {
      await prefs.setInt(
          'subscriptionExpiry', _expiryDate!.millisecondsSinceEpoch);
    } else {
      await prefs.remove('subscriptionExpiry');
    }
  }

  Future<void> _initializeProducts() async {
    // Create the list of subscription plans
    _plans = [
      SubscriptionPlan.monthly(),
      SubscriptionPlan.annual(),
    ];

    // Get the store IDs for the purchasable plans
    final Set<String> productIds = _plans
        .where((plan) => plan.type != SubscriptionType.free)
        .map((plan) => plan.storeId)
        .toSet();

    try {
      final ProductDetailsResponse response =
      await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
    } catch (e) {
      debugPrint('Failed to load products: $e');
    }
  }

  // Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show loading UI
        debugPrint('Purchase pending: ${purchaseDetails.productID}');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error
          debugPrint('Purchase error: ${purchaseDetails.error?.message}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          debugPrint('Purchase successful/restored: ${purchaseDetails.productID}');
          _handleSuccessfulPurchase(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
    notifyListeners();
  }

  void _updateStreamOnDone() {
    _subscription?.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    debugPrint('IAP stream error: $error');
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    // Find which plan was purchased
    final plan = _plans.firstWhere(
          (plan) => plan.storeId == purchase.productID,
      orElse: () => SubscriptionPlan.free(),
    );

    // Update subscription details
    _currentSubscription = plan.type;

    // Calculate expiry date based on purchase date
    final now = DateTime.now();
    _expiryDate = now.add(plan.duration);

    // Log subscription details
    debugPrint('Subscription activated: ${plan.name}, expires: $_expiryDate');

    // Save to local storage
    await _saveSubscriptionStatus();

    notifyListeners();
  }

  Future<void> _handleSuccessfulFreeSubscription(SubscriptionPlan plan) async {
    // Update subscription details
    _currentSubscription = plan.type;

    // Calculate expiry date based on purchase date
    final now = DateTime.now();
    _expiryDate = now.add(plan.duration);

    // Save to local storage
    await _saveSubscriptionStatus();

    notifyListeners();
  }

  // Initiate a purchase
  Future<void> buySubscription(SubscriptionPlan plan) async {
    if (plan.type == SubscriptionType.free || plan.type == SubscriptionType.freeForever) {
      _handleSuccessfulFreeSubscription(plan);
      return;
    }

    try {
      // Find the corresponding product
      final product = _products.firstWhere(
            (product) => product.id == plan.storeId,
      );

      // Create purchase param
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      // Start the purchase flow
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Failed to initiate purchase: $e');
    }
  }

  // Restore purchases - can be called manually if needed
  Future<void> restorePurchases() async {
    try {
      debugPrint('Manually restoring purchases');
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Failed to restore purchases: $e');
    }
  }

  // Start trial
  Future<void> startFreeTrial() async {
    // Set a temporary subscription that expires after 7 days
    _currentSubscription =
        SubscriptionType.monthly; // Use whatever plan for trial
    _expiryDate = DateTime.now().add(const Duration(days: 7));
    await _saveSubscriptionStatus();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}