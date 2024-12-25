import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_client/utils/const.dart';
import 'package:http/http.dart' as http;

class StripeProvider extends ChangeNotifier {
  Map<String, dynamic>? data;

  Future<Map<String, dynamic>?> createPaymentIntent(int amount) async {
    final url = Uri.parse('https://api.stripe.com/v1/payment_intents');

    final int amountInCents = amount * 100 * 84;

    final body = {
      'amount': amountInCents.toString(),
      'currency': 'INR',
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic>? json = jsonDecode(response.body);
        log('Created payment intent: ${json!['client_secret']}');
        return json;
      } else {
        log('Failed to create payment intent: ${response.statusCode} ${response.body}');
        throw Exception(
            'Failed to create payment intent: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e.toString());
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
            billingDetails: const BillingDetails(
              name: 'Sumit Paul',
              email: 'sumit@gmail.com',
              phone: '9876543210',
              address: Address(
                city: 'Siliguri',
                country: 'India',
                line1: 'Shaktigarh Road No. 10',
                line2: 'Ward No. 31',
                postalCode: '734005',
                state: 'West Bengal',
              ),
            ),
            googlePay: const PaymentSheetGooglePay(
              merchantCountryCode: 'US',
              testEnv: true,
            ),
            style: ThemeMode.dark,
          ),
        );
        notifyListeners();
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
      await Stripe.instance.presentPaymentSheet().then((e) {
        data = null;
      });

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
        msg: e.error.code == FailureCode.Canceled
            ? 'Payment Cancelled!!!'
            : 'Payment Failed!!!',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
    }
  }
}
