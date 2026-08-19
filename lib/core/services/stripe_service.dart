import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  // These should ideally be in environment variables, but for MVP we hardcode the test keys.
  static const String _publishableKey = 'pk_test_51U68fiLu7nyNkKtgpKSR63pTM5lLuHWi3IOoiPB6noF4QquQKmZQ07kg2gsa3wVPWbDCWmvStabV6Jbm7UJlNWAL00YXpkLn2C';
  static const String _secretKey = 'sk_test_51U68fiLu7nyNkKtgyNDG6LYbmT0kcH6ClR4lrWDpHo2SThuDFc84TRzdejo4zD1alRMSFyd3dLTpzUSMJ8iRwv9J00gOeyJLO1';

  void init() {
    Stripe.publishableKey = _publishableKey;
  }

  Future<String?> createPaymentIntent(int amount, String currency) async {
    try {
      final Map<String, dynamic> body = {
        'amount': amount.toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
        // Disable automatic payment methods (which includes Link)
        'automatic_payment_methods[enabled]': 'false',
      };

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['client_secret'];
      } else {
        debugPrint('Stripe Error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception in createPaymentIntent: $e');
      return null;
    }
  }

  Future<bool> initPaymentSheet(String clientSecret, String merchantDisplayName) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
          style: ThemeMode.light,
          returnURL: 'munasabat://stripe-redirect',
          // Disable Stripe Link ("Save my info for faster checkout")
          primaryButtonLabel: 'Pay Now',
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Exception in initPaymentSheet: $e');
      return false;
    }
  }

  Future<bool> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      // Distinguish between user cancellation and actual errors
      final msg = e.error.localizedMessage?.toLowerCase() ?? '';
      if (msg.contains('cancel')) {
        // User explicitly canceled — not an error
        return false;
      }
      // For other StripeExceptions, re-throw so the caller can handle
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Directly queries Stripe API to check the actual status of a payment intent.
  /// Used as a fallback when presentPaymentSheet() throws despite payment succeeding.
  Future<String?> checkPaymentIntentStatus(String paymentIntentId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId'),
        headers: {'Authorization': 'Bearer $_secretKey'},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['status'] as String?;
      }
    } catch (_) {}
    return null;
  }
}
