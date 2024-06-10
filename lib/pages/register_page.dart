import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../components/my_textfield.dart';
import '../components/my_button.dart';
import '../components/square_tile.dart';
class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text editting controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //sign user up method
  void signUserUp() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
    // try creating the user
    try {
      if (passwordController.text != confirmPasswordController.text) {
        // pop the loading circle
        Navigator.pop(context);
        if (true){
          showErrorMessage("Passwords do not match");
        }
        showErrorMessage("Passwords do not match");
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: usernameController.text,
          password: passwordController.text,
        );
        return;
      }
      // pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);
      if (e.code == 'invalid-email') {
        showErrorMessage('Invalid email provided.');
      } else if (e.code == 'email-already-in-use') {
        showErrorMessage("Email already in use");
      }
    }
  }

  //error message to user
  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.deepPurple,
            title: Center(
                child: Text(message, style: TextStyle(color: Colors.white))),
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

                    //Let's create your account
                    Text(
                      "Let's create your account!",
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

                    //confirm password textfield
                    MyTextField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      obscureText: true,
                    ),

                    SizedBox(height: 10),
                    //forgot password
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 25),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     children: [
                    //       Text("Forgot password?",
                    //         style: TextStyle(
                    //             color: Colors.grey[600],
                    //             fontSize: 16
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(height: 25),

                    //sign in button
                    MyButton(
                      text: "Sign Up",
                      onTap: signUserUp,
                    ),

                    SizedBox(height: 20),

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
                    SizedBox(height: 20),
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
                    SizedBox(height: 20),

                    //dont have an account? sign up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Sign in",
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
