import 'package:flutter_paypal/flutter_paypal.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:learndash/screens/upi_payment.dart';
import 'package:learndash/utils/Constants.dart';
import 'package:learndash/widgets/navigation_bar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../controllers/cart_controller.dart';
import '../models/courses.dart';
import '../services/base_api.dart';
import '../services/courses_api.dart';

class CartScreen extends StatefulWidget {
  final int id;
  final Course? course;
  const CartScreen({Key? key, this.id = 1, this.course}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController cartController = Get.put(CartController());
  String selectedPaymentMethod = "";
  Map<String, dynamic>? paymentIntentData;

  @override
  void initState() {
    super.initState();
    getCartCourses();
  }

  bool isLoading = true;
  List<Course> cartCoursesList = [];
  getCartCourses() async {
    if (widget.id == 1) {
      List<int> coursesWish = [];
      if (cartController.cartCourses.isNotEmpty) {
        for (String id in cartController.cartCourses) {
          coursesWish.add(int.parse(id));
        }
        EasyLoading.show();
        var response = await CoursesApi().getCourse(id: coursesWish);
        cartCoursesList = (response);
        EasyLoading.dismiss();
      }
    } else {
      cartCoursesList = [widget.course!];
    }

    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.id == 2 ? "Buy Now" : "My Cart"),
      ),
      body: Obx(() {
        return Column(
          children: [
            SizedBox(
              height: Get.height * 0.72,
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                children: [
                  if (cartController.cartCourses.isEmpty &&
                      !isLoading &&
                      widget.id == 1)
                    SizedBox(
                      height: Get.height * 0.7,
                      child: const Center(
                          child: Text(
                        "There's no available courses",
                        style: TextStyle(color: Colors.grey, fontSize: 17),
                      )),
                    ),
                  if (((widget.id == 1 &&
                              cartController.cartCourses.isNotEmpty) ||
                          (widget.id == 2)) &&
                      !isLoading)
                    Column(
                      children: [
                        for (Course course in cartCoursesList)
                          buildCartCourses(course)
                      ],
                    ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "Payment Method",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                      height: 60,
                      width: Get.width,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (String payment in Constants.paymentGateways)
                            buildPaymentMethod(payment)
                        ],
                      ))
                ],
              ),
            ),
            if (((widget.id == 1 && cartController.cartCourses.isNotEmpty) ||
                    (widget.id == 2)) &&
                !isLoading)
              Expanded(
                  child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Colors.grey),
                        ),
                        Text(
                          Constants.currency + getTotalPrice(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Constants.secondaryColor,
                              fontSize: 20),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MaterialButton(
                      color: Constants.primaryColor,
                      textColor: Colors.white,
                      minWidth: Get.width,
                      height: 40,
                      onPressed: () {
                        if (selectedPaymentMethod == "") {
                          Get.showSnackbar(const GetSnackBar(
                            message: "Please select a payment gateway",
                            duration: Duration(seconds: 1),
                          ));
                        }
                        if (selectedPaymentMethod == "paypal") {
                          showPaypalCheckout();
                        }
                        if (selectedPaymentMethod == "razorpay") {
                          showRazorpayCheckout();
                        }
                        if (selectedPaymentMethod == "stripe") {
                          showStripeCheckout();
                        }

                        if (selectedPaymentMethod == "upi") {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return UpiPayment(getTotalAmountInDouble(),
                                    cartCoursesList, completePayment);
                              });
                        }
                      },
                      child: const Text("Pay Now"),
                    )
                  ],
                ),
              ))
          ],
        );
      }),
    );
  }

  completePayment() async {
    EasyLoading.show();
    String ids = "";
    for (Course course in cartCoursesList) {
      if (course != cartCoursesList.last) {
        ids += "${course.id},";
      } else {
        ids += course.id.toString();
      }
    }
    var box = await Hive.openBox(
      "learndash",
    );
    await BaseApi.postAsync(
        "learndashapp/v1/enroll-course", {"id": ids, "user_id": box.get("id")},
        requiresPurchaseCode: true);
    for (Course course in cartCoursesList) {
      if (isCoursIdInCart(course.id.toString())) {
        cartController.removeFromcartCourses(course.id.toString());
      }
    }
    EasyLoading.dismiss();
    Get.defaultDialog(
        barrierDismissible: false,
        title: "Success",
        middleText: "Course enrolled successfully!",
        textConfirm: "Ok",
        buttonColor: Constants.secondaryColor,
        confirmTextColor: Colors.white,
        onWillPop: () async {
          return false;
        },
        onConfirm: () {
          Get.offAll(const Navbar());
        });
  }

  isCoursIdInCart(String id) {
    for (Course course in cartCoursesList) {
      if (id == course.id.toString()) {
        return true;
      } else {
        return false;
      }
    }
  }

  showStripeCheckout() async {
    paymentIntentData =
        await createPaymentIntent(cartCoursesList, Constants.stripeCurrency);
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        customFlow: false,
        merchantDisplayName: Constants.stripemerchantDisplayName,
        paymentIntentClientSecret: paymentIntentData!['client_secret'],
        customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
        customerId: paymentIntentData!['customer'],
        style: ThemeMode.dark,
      ),
    );
    displayPaymentSheet(cartCoursesList as dynamic);
  }

  showRazorpayCheckout() async {
    Razorpay razorpay = Razorpay();
    var box = await Hive.openBox(
      "learndash",
    );
    var options = {
      'key': Constants.razorPayApiKey,
      'amount': getTotalAmountInDouble().toInt() * 100,
      'name': '${Constants.appName} courses',
      'description': '${Constants.appName} courses',
      'prefill': {'email': box.get("email")},
    };
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
        (PaymentSuccessResponse response) {
      completePayment();
    });
    razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {});

    razorpay.open(options);
  }

  getTotalAmountInDouble() {
    double amount = 0;
    for (Course course in cartCoursesList) {
      amount += double.parse(course.price);
    }
    return amount;
  }

  showPaypalCheckout() async {
    List transactionsList = [
      {
        "amount": {
          "total": getTotalAmountInDouble().toString(),
          "currency": Constants.paypalCurrency,
          "details": {
            "subtotal": getTotalAmountInDouble().toString(),
            "shipping": '0',
            "shipping_discount": 0
          }
        },
        "description": Constants.paypalTransactionDescription,
        "item_list": {
          "items": [
            for (Course course in cartCoursesList)
              {
                "name": course.title,
                "quantity": 1,
                "price": course.price,
                "currency": Constants.paypalCurrency
              }
          ],
        }
      }
    ];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UsePaypal(
            sandboxMode: Constants.isSandbox,
            clientId: Constants.paypalClientId,
            secretKey: Constants.paypalSecret,
            returnURL: Constants.returnURL,
            cancelURL: Constants.cancelURL,
            transactions: transactionsList,
            note: Constants.paypalNotePayer,
            onSuccess: (Map params) async {
              completePayment();
            },
            onError: (error) {},
            onCancel: (params) {}),
      ),
    );
  }

  displayPaymentSheet(List<dynamic> courses) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((newValue) {
        completePayment();
      }).onError((error, stackTrace) {});
    } on StripeException {
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    }
  }

  createPaymentIntent(List<dynamic> courses, String currency) async {
    num amount = 0;
    for (Course course in courses) {
      amount += double.parse(course.price);
    }
    Map<String, dynamic> body = {
      'amount': (amount * 100).toInt().toString(),
      'currency': currency,
      'payment_method_types[]': 'card'
    };
    var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer ${Constants.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded'
        });
    return jsonDecode(response.body);
  }

  getTotalPrice() {
    num price = 0;
    for (Course course in cartCoursesList) {
      price += double.parse(course.price);
    }
    return price.toInt().toString();
  }

  Widget buildPaymentMethod(String paymentMethod) {
    return GestureDetector(
      onTap: () {
        selectedPaymentMethod = paymentMethod;
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(20, 149, 157, 165),
              blurRadius: 24.0,
              offset: Offset(0, 8),
            ),
          ],
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: GestureDetector(
          onTap: () {
            selectedPaymentMethod = paymentMethod;
            setState(() {});
          },
          child: Row(
            children: [
              ExtendedImage.asset(
                "assets/$paymentMethod.png",
                height: 30,
                width: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(
                width: 25,
              ),
              SizedBox(
                height: 25,
                width: 25,
                child: Column(
                  children: [
                    if (selectedPaymentMethod == paymentMethod)
                      Icon(
                        Icons.check_circle,
                        color: Constants.secondaryColor,
                      )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCartCourses(Course course) {
    return Container(
      width: Get.width * 0.9,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(20, 149, 157, 165),
            blurRadius: 24.0,
            offset: Offset(0, 8),
          ),
        ],
        color: Colors.white,
      ),
      child: Row(
        children: [
          (course.image != "")
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    course.image,
                    height: 115,
                    width: 100,
                    fit: BoxFit.cover,
                  ))
              : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/coursesPlaceholder.png",
                    height: 115,
                    width: 100,
                    fit: BoxFit.cover,
                  )),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title,
                        maxLines: 2,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      course.instructor["name"],
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Constants.currency + course.price,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Constants.secondaryColor,
                              fontSize: 18),
                        ),
                        if (widget.id == 1)
                          InkWell(
                              onTap: () {
                                cartController.removeFromcartCourses(
                                    course.id.toString());
                                cartCoursesList.remove(course);
                                setState(() {});
                              },
                              child: const Icon(
                                Icons.delete,
                                size: 20,
                                color: Colors.red,
                              ))
                      ],
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }
}
