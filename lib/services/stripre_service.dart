import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tipre_pay/models/models.dart';
import 'package:http/http.dart' as http;

class StripeService {
  //Singleton
  StripeService._privateConstructor();

  static final StripeService _instance = StripeService._privateConstructor();
  factory StripeService() => _instance;

  final String _paymentApiUrl = 'https://api.stripe.com/v1/payment_intents';
  static String secretKey =
      'sk_test_51Ln0bQKFqIblrhSkx8JwtS4tqTExnQJ9m0BLwbS9X70gQMAsh9ilJxHZSlEtNixchZhsBesVxLzv56m8aPPt4mkJ00QrQxuF5l';
  final String _apiKey =
      'pk_test_51Ln0bQKFqIblrhSkFcwufhVNurnPL1lIbQaps61vyyFJG49BPaGBPdFtscEKlRFS7YUh3zLCR8SIzVp7ucydSOA700qfoO4R6T';

  final Map<String, String> _headers = {
    'Authorization': 'Bearer ${StripeService.secretKey}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  void init() async {
    WidgetsFlutterBinding.ensureInitialized();
    Stripe.publishableKey = _apiKey;
    //Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    //Stripe.urlScheme = 'flutterstripe';
    await Stripe.instance.applySettings();
  }

  Future<PaymentIntentResponse> pagarConTarjetaExistente({
    required String amount,
    required String currency,
    required CardDetails card,
  }) async {
    try {
      await Stripe.instance.dangerouslyUpdateCardDetails(card);

      final paymentMethod = await Stripe.instance
          .createPaymentMethod(const PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(),
      ));

      final paymentIntentResult = await _createPaymentIntent(
        amount: amount,
        currency: currency,
        paymentMethodId: paymentMethod.id,
      );
      return paymentIntentResult;
    } catch (e) {
      log('Error: ${e.toString()}');
      return PaymentIntentResponse(status: e.toString());
    }
  }

  Future<PaymentIntentResponse> pagarConTarjetaNueva({
    required String amount,
    required String currency,
  }) async {
    try {
      return await _realizarPago(
        amount: amount,
        currency: currency,
      );
    } catch (err) {
      log('Error: ${err.toString()}');
      return PaymentIntentResponse(status: err.toString());
    }
  }

  Future pagarConApplePayGooglePay({
    required String amount,
    required String currency,
  }) async {
    final googlePaySupported = await Stripe.instance
        .isGooglePaySupported(const IsGooglePaySupportedParams());
    if (googlePaySupported) {
      try {
        final paymentResult = await _createPaymentIntent(
          amount: amount,
          currency: currency,
        );
        final clientSecret = paymentResult.clientSecret;
        //log('Cliente: $clientSecret');
      } catch (e) {
        //log('Error: ${e.toString()}');
        return PaymentIntentResponse(status: e.toString());
      }
    } else {
      return PaymentIntentResponse(
          status: 'El dispositivo no soporta Google pay');
    }
  }

  Future<PaymentIntentResponse> _realizarPago({
    required String amount,
    required String currency,
  }) async {
    try {
      final paymentResult = await _createPaymentIntent(
        amount: amount,
        currency: currency,
      );

      return paymentResult;
    } catch (e) {
      log('Error: ${e.toString()}');
      return PaymentIntentResponse(status: '400');
    }
  }

  Future<PaymentIntentResponse> _createPaymentIntent({
    required String amount,
    required String currency,
    String? paymentMethodId,
  }) async {
    try {
      Map<String, dynamic> other;

      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
      };

      if (paymentMethodId != null) {
        other = {'payment_method': paymentMethodId, 'confirm': 'true'};
      } else {
        other = {'payment_method_types[]': 'card'};
      }
      body.addAll(other);

      final response = await http.post(
        Uri.parse(_paymentApiUrl),
        headers: _headers,
        body: body,
      );
      //log('Body: $body');
      //log('Respuesta: ${response.body}');
      return paymentIntentResponseFromJson(response.body);
    } catch (e) {
      log('Error: ${e.toString()}');
      return PaymentIntentResponse(status: e.toString());
    }
  }
}
