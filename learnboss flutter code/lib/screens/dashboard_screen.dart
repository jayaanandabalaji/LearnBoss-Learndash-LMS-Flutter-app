import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../services/base_api.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    getStatistics();
  }

  Map analytics = {};

  getStatistics() async {
    EasyLoading.show();
    var response = await BaseApi.getAsync("learndashapp/v1/analytics",
        requiredToken: true);
    analytics = response;
    EasyLoading.dismiss();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Dashboard")),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          if (analytics.isNotEmpty)
            Column(
              children: [
                analyticWidget(analytics["courses"].toString(),
                    "Enrolled Courses", Colors.blue, Icons.menu_book_outlined),
                analyticWidget(
                    analytics["courses"].toString(),
                    "Active Courses",
                    const Color(0xffFFBA01),
                    Icons.video_library_outlined),
                analyticWidget(
                    analytics["completed"].toString(),
                    "Completed Courses",
                    Colors.green,
                    Icons.check_circle_outline)
              ],
            )
        ],
      ),
    );
  }

  Widget analyticWidget(
      String number, String title, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
                border: Border.all(color: color.withOpacity(0.5), width: 1)),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                color: color,
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(number,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(
                height: 5,
              ),
              Text(title,
                  style: TextStyle(
                      fontSize: 18, color: Colors.black.withOpacity(0.8)))
            ],
          )
        ],
      ),
    );
  }
}
