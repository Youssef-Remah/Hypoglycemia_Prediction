import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hypoglycemia_prediction/modules/login_page/login_screen.dart';
import 'package:hypoglycemia_prediction/modules/signup_page/signup_screen.dart';


class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SizedBox(height: 35),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        "Welcome",
                        style: GoogleFonts.robotoCondensed(
                            fontWeight: FontWeight.bold, fontSize: 38),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "This app will help you in your life to be safe before hypoglycemia happens",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.robotoCondensed(fontSize: 16),
                      ),
                    ),
                    Container(
                        height: 220,
                        child: Image(
                            image: AssetImage("lib/assets/images/diabetes-test.png"))),
                    SizedBox(
                      height: 45,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.blueAccent),
                      width: 250,
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => LoginScreen()));
                        },
                        child: Text("Log In Now",
                            style: GoogleFonts.robotoCondensed(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.greenAccent),
                      width: 250,
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => SignupScreen()));
                        },
                        child: Text("Sign Up Now",
                            style: GoogleFonts.robotoCondensed(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
