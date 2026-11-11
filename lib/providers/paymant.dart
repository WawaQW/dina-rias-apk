// NOTE: Ensure `bookingId` (the Firestore document id or bookingId field) is used as order_id when requesting snap token.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:midtrans_sdk/midtrans_sdk.dart';

class PaymentService {
  static MidtransSDK? _midtrans;

  static Future<void> initSDK() async {
    if (_midtrans != null) return;

    _midtrans = await MidtransSDK.init(
      config: MidtransConfig(
        clientKey: "SB-Mid-client-CC0cQTYgMovaOc9O",
        merchantBaseUrl: "",
        colorTheme: ColorTheme(
          colorPrimary: Colors.blue,
          colorPrimaryDark: Colors.blue,
          colorSecondary: Colors.blue,
        ),
      ),
    );

    _midtrans?.setUIKitCustomSetting(
      skipCustomerDetailsPages: true,
    );
  }

  static Future<void> startPayment(
      amount, bookingId, Function(String) onTransactionFinished) async {
    try {
      await initSDK(); // Ensure SDK is initialized

      final orderId = bookingId;
      final grossAmount = amount;

      final response = await http.post(
        Uri.parse('https://backend-seven-dusky-76.vercel.app/get-snap-token'),
        // Uri.parse('https://dina-midtrans.vercel.app/get-snap-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id': orderId,
          'gross_amount': grossAmount,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final snapToken = jsonResponse['snap_token'];

        if (snapToken == null) {
          throw Exception('Snap token is null');
        }

        _midtrans?.startPaymentUiFlow(
          token: snapToken,
        );

        _midtrans?.setTransactionFinishedCallback((result) {
          final callback = result.toJson();
          onTransactionFinished(callback['transactionStatus']);
        });
      } else {
        throw Exception('Failed to load snap token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow; // Rethrow to handle in the UI
    }
  }

  static void dispose() {
    _midtrans?.removeTransactionFinishedCallback();
  }
}
