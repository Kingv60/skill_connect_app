import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:skillconnect/New/profile-setup.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          children: <Widget>[

            /// TOP DESIGN
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  FadeInUp(
                    duration: const Duration(milliseconds: 1600),
                    child: Container(
                      margin: const EdgeInsets.only(top: 30),
                      alignment: Alignment.topCenter,
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// FORM
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    FadeInUp(
                      duration: const Duration(milliseconds: 1800),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF8F94FB)),
                        ),
                        child: Column(
                          children: <Widget>[

                            /// NAME
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFF8F94FB)),
                                ),
                              ),
                              child: TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Full Name",
                                  prefixIcon: Icon(Icons.person,color: Color(0xFF8F94FB)),
                                ),
                              ),
                            ),

                            /// EMAIL
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFF8F94FB)),
                                ),
                              ),
                              child: TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Email",
                                  prefixIcon: Icon(Icons.email,color: Color(0xFF8F94FB)),
                                ),
                              ),
                            ),

                            /// PASSWORD
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Password",
                                prefixIcon: Icon(Icons.lock,color: Color(0xFF8F94FB)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// REGISTER BUTTON
                    FadeInUp(
                      duration: const Duration(milliseconds: 1900),
                      child: GestureDetector(
                        onTap: () {

                          String name = nameController.text;
                          String email = emailController.text;
                          String password = passwordController.text;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileSetupPage(
                                name: name,
                                email: email,
                                password: password,
                              ),
                            ),
                          );

                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFF8F94FB),
                          ),
                          child: Center(
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "Register",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// LOGIN LINK
                    FadeInUp(
                      duration: const Duration(milliseconds: 2000),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Color(0xFF8F94FB),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}