import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hypoglycemia_prediction/modules/basal_insulin_log/basal_insulin_dose_screen.dart';
import 'package:hypoglycemia_prediction/modules/blood_glucose_log/blood_glucose_log_screen.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/meals_screen.dart';
import 'package:hypoglycemia_prediction/modules/emergency_contact/emergency_contact_screen.dart';
import 'package:hypoglycemia_prediction/modules/insights/insights_screen.dart';
import 'package:hypoglycemia_prediction/modules/sensor_configuration/sensor_configuration_screen.dart';
import 'package:hypoglycemia_prediction/modules/settings/settings_screen.dart';
import 'package:hypoglycemia_prediction/modules/smartwatch_connection/scan_screen/scan_screen.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final Color bottomNavColor = Colors.blueAccent;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeContentScreen(),
    BleDeviceScanScreen(),
    SettingsScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 15),
          child: Container(
            height: 55,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: bottomNavColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: bottomNavColor.withOpacity(0.5),
                  blurRadius: 25,
                  offset:
                  const Offset(0.0, 18.0), // Double precision for offsets
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 0),
                _buildNavItem(Icons.show_chart, 1),
                _buildNavItem(Icons.settings, 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _selectedIndex == index ? Colors.white : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: _selectedIndex == index ? bottomNavColor : Colors.white,
        ),
      ),
    );
  }
}

class HomeContentScreen extends StatelessWidget {
  const HomeContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text("Dashboard"),
        actions: [
          IconButton(
              onPressed: () {
                alertDialog(context);
              },
              icon: const Icon(Icons.info_outline))
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(11.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: buildHomePageItem(
                      destinationWidget: const SensorConfigScreen(),
                      context: context,
                      image: "lib/assets/images/sensor.png",
                      title: "Sensor Connection",
                    ),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: buildHomePageItem(
                      destinationWidget: const BleDeviceScanScreen(),
                      context: context,
                      image: "lib/assets/images/smartwatch.png",
                      title: "Smartwatch Connection",
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: buildHomePageItem(
                      destinationWidget: BasalInsulinLogScreen(),
                      context: context,
                      image: 'lib/assets/images/insulin_log.png',
                      title: "Basal Insulin Input",
                    ),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: buildHomePageItem(
                      destinationWidget: BloodGlucoseLogScreen(),
                      context: context,
                      image: 'lib/assets/images/glucometer.png',
                      title: "Blood Glucose Input",
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30.0,
              ),
              buildHomeListItem(
                context: context,
                destinationWidget: MealsScreen(),
                image: 'lib/assets/images/meal.png',
                title: 'Dietary Manager',
              ),
              buildHomeListItem(
                context: context,
                destinationWidget: EmergencyContactScreen(),
                image: 'lib/assets/images/emergency_contact.png',
                title: 'Emergency Contact',
              ),
              buildHomeListItem(
                context: context,
                destinationWidget: InsightsScreen(),
                image: 'lib/assets/images/medical_report.png',
                title: 'Insights Report',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHomePageItem({
    required context,
    required Widget destinationWidget,
    required String image,
    required String title,
    Function? callbackFunc,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => destinationWidget,
          ),
        );

        if (callbackFunc != null) {
          callbackFunc();
        }
      },
      child: Container(
        height: 165,
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.greenAccent,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 8.0,
            ),
            Text(
              title,
              style: GoogleFonts.robotoCondensed(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            Image(
              image: AssetImage(image),
              width: 100,
              height: 80,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHomeListItem({
    required String title,
    required String image,
    required context,
    required Widget destinationWidget,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => destinationWidget,
          ),
        );
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image(
                image: AssetImage(image),
                width: 60,
                height: 60,
              ),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => destinationWidget,
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios_rounded),
              ),
            ],
          ),
          const Divider(thickness: 1.3),
          const SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }
}
