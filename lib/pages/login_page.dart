import 'package:tamiyochi/components/my_button.dart';
import 'package:tamiyochi/components/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../components/my_textfield.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editting controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  //sign user in method
  void signUserIn() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
    // try to sign in the user
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: usernameController.text, password: passwordController.text);
      // pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);
      if (e.code == 'invalid-email') {
        showErrorMessage('Invalid email provided');
      } else {
        showErrorMessage("Invalid email or password");
      }
    }
  }

  //error message to user
  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.redAccent,
            title: Center(
                child: Text(message,
                    style: const TextStyle(color: Colors.white), textAlign: TextAlign.center,)),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        body: SafeArea(
          child: Center(
            child: ListView(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    //logo
                    //take from assets
                    Image.asset(
                      "lib/assets/Seaborn.png",
                      height: 100,
                    ),

                    SizedBox(height: 20),

                    //welcome back
                    Text(
                      "Welcome back, you\'ve been missed!",
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    ),

                    SizedBox(height: 25),
                    //username textfield
                    MyTextField(
                      controller: usernameController,
                      hintText: "Username",
                      obscureText: false,
                    ),

                    SizedBox(height: 10),

                    //password textfield
                    MyTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true,
                    ),

                    SizedBox(height: 10),
                    //forgot password
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 25),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     children: [
                    //       Text(
                    //         "Forgot password?",
                    //         style: TextStyle(
                    //             color: Colors.grey[600], fontSize: 16),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: 25),

                    //sign in button
                    MyButton(
                      text: "Sign in",
                      onTap: signUserIn,
                    ),

                    SizedBox(height: 40),

                    //or continue with
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 0.5,
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              '  Or continue with  ',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 16),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    //url image
                    //google button
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SquareTile(
                            online: true,
                            imagePath:
                            "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png"),
                        SizedBox(width: 10),
                        //apple button
                        SquareTile(
                            online: true,
                            imagePath:
                            "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Apple_logo_grey.svg/862px-Apple_logo_grey.svg.png"),
                      ],
                    ),
                    SizedBox(height: 50),

                    //dont have an account? sign up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don\'t have an account?",
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}