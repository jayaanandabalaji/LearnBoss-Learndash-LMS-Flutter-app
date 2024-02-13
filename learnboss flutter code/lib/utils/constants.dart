import 'package:flutter/cupertino.dart';

class Constants {
  static String baseUrl = "http://ec2-54-174-22-163.compute-1.amazonaws.com";
  static Color primaryColor = const Color(0xffD31819);
  static Color secondaryColor = const Color(0xff0071DC);
  static String currency = "₹";
  static List<String> paymentGateways = ["paypal", "razorpay", "stripe", "upi"];
  static String appName = "LearnBoss";
  static String purchaseCode = "b03046ac-7abc-4e7f-b8ce-0a8c3e56e2e2";
  static bool screenProtectOn = true;
  static List<String> supportedFileTypes = [
    "jpg",
    "png",
    "gif",
    "doc",
    "pdf",
    "docx",
    "txt"
  ];
  static List resourcesSection = ["blogs", "others"];
  //Google ads
  static bool showAds = true;
  static String interstitialUnitId = 'ca-app-pub-3940256099942544/1033173712';

  //Razorpay
  static String razorPayApiKey = "rzp_test_UmrLxIJbfW25lC";

  //paypal
  static String paypalClientId =
      "ARPnYa2j3_eeMOkT3wA5mdOLSMJ-OiF-46yKya-cfrSj_0mMZl3H6VCw_L9w2aaV6hnLqMOdUXcDKjcO";
  static String paypalSecret =
      "EOc_KilwBucMB55_qYhbbkH4iMBtP1krx-NzRRVy8qPMMvntHHJH12daFRoWupKeqZdTgZPsSn3iNhKF";
  static String returnURL = 'test.learndash.com';
  static String cancelURL = 'cancel.learndash.com';
  static String paypalTransactionDescription =
      "The payment transaction description.";
  static String paypalNotePayer =
      "Contact us for any questions on your order.";
  static bool isSandbox = true;
  static String paypalCurrency = "USD";

  //stripe
  static String stripePublishableKey =
      "pk_live_51KjO05SIZIXyeU3AUydw3InU4s40aMcMfjakB2Y6S6481UsACJwyRDkSrCdcxYWeqk6fIa2BWXTkt0FDY8HPjqfb00ynbaRw1i";
  static String stripeSecretKey =
      "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";
  static String stripeCurrency = "INR";
  static String stripemerchantCountryCode = "US";
  static String stripemerchantDisplayName = "LearnGun";

  //UPI
  static String receiverUpiId = "jayakannan@fbl";
  static String receiverName = "Jaya Ananda Balaji";
  static num currencyConversion = 1;
}
