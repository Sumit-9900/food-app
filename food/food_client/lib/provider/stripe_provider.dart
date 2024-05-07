import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class StripeProvider extends ChangeNotifier {
  Map<String, dynamic>? data;

  Future createPaymentIntent(int amount) async {
    final url = Uri.parse('https://api.stripe.com/v1/payment_intents');

    final int amountInCents = amount * 100;

    final body = {
      'amount': amountInCents.toString(),
      'currency': 'usd',
    };

    final response = await http.post(
      url,
      headers: {
        // 'Authorization': 'Bearer ${dotenv.env['secretKey']}',
        'Authorization':
            'Bearer sk_test_51P6y0dSAg5DgXRL5PaoaAvKCYXGbYrQRQ7vPhEhynB8OfxLCHSJiiTMdmQdHr9FiHlphMqkr1Shrnjs92KnkAqha00uD0dnU0u',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    try {
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        log('Created payment intent: ${json['client_secret']}');
        return json;
      } else {
        log('Failed to create payment intent: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> initPaymentSheet(int amount) async {
    try {
      data = await createPaymentIntent(amount);

      if (data != null) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            customFlow: false,
            merchantDisplayName: 'Quick Foodie',
            paymentIntentClientSecret: data!['client_secret'],
            customerId: data!['id'],
            googlePay: const PaymentSheetGooglePay(
              merchantCountryCode: 'US',
              testEnv: true,
            ),
            style: ThemeMode.dark,
          ),
        );
      } else {
        log('Error in initPaymentSheet');
      }
    } catch (e) {
      log(e.toString());
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
      rethrow;
    }
  }

  Future<void> displayPaymentSheet(int amount) async {
    await initPaymentSheet(amount);
    try {
      await Stripe.instance.presentPaymentSheet();

      Fluttertoast.showToast(
        msg: 'Payment Successfully Done!!!',
        backgroundColor: Colors.green,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
    } on StripeException catch (e) {
      log(e.toString());
      Fluttertoast.showToast(
        msg: 'Payment Failed!!!',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
    }
  }
}
