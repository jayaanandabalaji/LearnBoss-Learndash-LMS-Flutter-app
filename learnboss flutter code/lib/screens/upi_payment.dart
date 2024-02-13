import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:upi_india/upi_india.dart';

import '../../utils/Constants.dart';

class UpiPayment extends StatefulWidget {
  final num amount;
  final courses;
  final Function successFunction;

  const UpiPayment(this.amount, this.courses, this.successFunction, {Key? key})
      : super(key: key);
  @override
  UpiPaymentState createState() => UpiPaymentState();
}

class UpiPaymentState extends State<UpiPayment> {
  Future<UpiResponse>? _transaction;
  final UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  TextStyle header = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = const TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = [];
    });
    super.initState();
  }

  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    var rnd = Random();
    num amount = widget.amount;

    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: Constants.receiverUpiId,
      receiverName: Constants.receiverName,
      transactionRefId: 'payment#${rnd.nextInt(100)}',
      transactionNote: "${Constants.appName} course purchase",
      amount: (amount * Constants.currencyConversion).toDouble(),
    );
  }

  Widget displayUpiApps() {
    if (apps == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (apps!.isEmpty) {
      return Center(
        child: Text(
          "No apps found to handle transaction.",
          style: header,
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            children: apps!.map<Widget>((UpiApp app) {
              return GestureDetector(
                onTap: () {
                  _transaction = initiateTransaction(app);
                  setState(() {});
                },
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.memory(
                        app.icon,
                        height: 60,
                        width: 60,
                      ),
                      Text(app.name),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  String _upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app not installed on device';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException:
        return 'Requested app cannot handle the transaction';
      default:
        return 'An Unknown error has occurred';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Pay Using your UPI Apps",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )),
          Expanded(
            child: displayUpiApps(),
          ),
          Expanded(
            child: FutureBuilder(
              future: _transaction,
              builder:
                  (BuildContext context, AsyncSnapshot<UpiResponse> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    Future.microtask(() => ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(
                            content: Text(
                                _upiErrorHandler(snapshot.error.runtimeType)
                                    .tr),
                            duration: const Duration(seconds: 1))));
                    return Container();
                  }

                  // If we have data then definitely we will have UpiResponse.
                  // It cannot be null
                  UpiResponse upiResponse = snapshot.data!;

                  // Data in UpiResponse can be null. Check before printing

                  String status = upiResponse.status ?? 'N/A';

                  if (status == UpiPaymentStatus.SUCCESS ||
                      status == UpiPaymentStatus.SUBMITTED) {
                    widget.successFunction();
                  } else {}

                  return Container();
                } else {
                  return const Center(
                    child: Text(''),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
