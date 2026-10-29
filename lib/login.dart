import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  bool rememberMe = false;

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xff033B33),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            children: [

              const SizedBox(height: 40),

              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color:
                      const Color(0xffF4B400),
                  borderRadius:
                      BorderRadius.circular(
                          25),
                ),
                child: const Icon(
                  Icons.mosque,
                  size: 55,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Islamic App",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Welcome Back",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller:
                    emailController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration:
                    InputDecoration(
                  hintText:
                      "Enter Email",
                  hintStyle:
                      const TextStyle(
                    color:
                        Colors.white54,
                  ),
                  prefixIcon:
                      const Icon(
                    Icons.email,
                    color:
                        Colors.white,
                  ),
                  filled: true,
                  fillColor:
                      const Color(
                          0xff0A5448),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                15),
                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller:
                    passwordController,
                obscureText: true,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration:
                    InputDecoration(
                  hintText:
                      "Enter Password",
                  hintStyle:
                      const TextStyle(
                    color:
                        Colors.white54,
                  ),
                  prefixIcon:
                      const Icon(
                    Icons.lock,
                    color:
                        Colors.white,
                  ),
                  filled: true,
                  fillColor:
                      const Color(
                          0xff0A5448),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                15),
                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [

                  Checkbox(
                    value: rememberMe,
                    activeColor:
                        const Color(
                            0xffF4B400),
                    onChanged: (value) {
                      setState(() {
                        rememberMe =
                            value!;
                      });
                    },
                  ),

                  const Text(
                    "Remember Me",
                    style: TextStyle(
                      color:
                          Colors.white,
                    ),
                  ),

                  const Spacer(),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        "/forgotPassword",
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color(
                            0xffF4B400),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                            0xffF4B400),
                  ),
                  onPressed: () {

                    // Login API
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color:
                          Colors.black,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: const [

                  Expanded(
                    child: Divider(
                      color:
                          Colors.white24,
                    ),
                  ),

                  Padding(
                    padding:
                        EdgeInsets.symmetric(
                            horizontal:
                                10),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        color:
                            Colors.white,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Divider(
                      color:
                          Colors.white24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 30,
                  ),
                  label: const Text(
                    "Continue with Google",
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.apple,
                  ),
                  label: const Text(
                    "Continue with Apple",
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  const Text(
                    "Don't have account?",
                    style: TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        "/register",
                      );
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Color(
                            0xffF4B400),
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}