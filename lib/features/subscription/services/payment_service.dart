import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PaymentService - Handles Razorpay payments for Quirzy Pro subscriptions
class PaymentService {
  static PaymentService? _instance;
  late Razorpay _razorpay;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ⚠️ IMPORTANT: Replace with your actual Razorpay API Key
  // Test Key: rzp_test_XXXXXXXXXXXX
  // Live Key: rzp_live_XXXXXXXXXXXX
  static const String _razorpayKey = 'rzp_test_XXXXXXXXXXXX';

  // Callbacks
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(ExternalWalletResponse)? onExternalWallet;

  factory PaymentService() {
    _instance ??= PaymentService._internal();
    return _instance!;
  }

  PaymentService._internal() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Start a payment for a subscription plan
  Future<void> startPayment({
    required String planName,
    required int amountInPaise, // ₹299 = 29900 paise
    required String description,
    String? email,
    String? phone,
  }) async {
    // Get user details from storage
    final userName = await _storage.read(key: 'user_name') ?? 'Quirzy User';
    final userEmail = email ?? await _storage.read(key: 'user_email') ?? '';
    final userPhone = phone ?? '';

    var options = {
      'key': _razorpayKey,
      'amount': amountInPaise,
      'name': 'Quirzy Pro',
      'description': description,
      'prefill': {'name': userName, 'email': userEmail, 'contact': userPhone},
      'theme': {'color': '#5B13EC'},
      'notes': {'plan': planName, 'app': 'quirzy'},
      'modal': {'confirm_close': true},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
    }
  }

  /// Start Monthly Plan Payment (₹299)
  Future<void> startMonthlyPlan({String? email, String? phone}) async {
    await startPayment(
      planName: 'monthly',
      amountInPaise: 29900, // ₹299
      description: 'Quirzy Pro - Monthly Plan',
      email: email,
      phone: phone,
    );
  }

  /// Start Yearly Plan Payment (₹2,999)
  Future<void> startYearlyPlan({String? email, String? phone}) async {
    await startPayment(
      planName: 'yearly',
      amountInPaise: 299900, // ₹2,999
      description: 'Quirzy Pro - Yearly Plan (Save 20%)',
      email: email,
      phone: phone,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Payment Success: ${response.paymentId}');

    // Save subscription status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_pro', true);
    await prefs.setString('payment_id', response.paymentId ?? '');
    await prefs.setString(
      'subscription_date',
      DateTime.now().toIso8601String(),
    );

    // Store securely too
    await _storage.write(key: 'is_pro', value: 'true');
    await _storage.write(key: 'payment_id', value: response.paymentId ?? '');

    onPaymentSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
    onPaymentError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    onExternalWallet?.call(response);
  }

  /// Check if user has Pro subscription
  static Future<bool> isPro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_pro') ?? false;
  }

  /// Dispose Razorpay instance
  void dispose() {
    _razorpay.clear();
  }
}
