import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:post_notifs/components/signin_button.dart';
import 'package:post_notifs/components/square_tile.dart';
import 'package:post_notifs/components/text_field.dart';
import 'package:post_notifs/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  const LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // try signing in
   try{
     await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );

     // pop the loading circle
      Navigator.pop(context);

    
   } on FirebaseAuthException catch(e){
     // pop the loading circle
      Navigator.pop(context);

    // show error message
    showErrorMessage(e.code);
   }
  }

  // error message popup
  void showErrorMessage(String message){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue[700],
          title: Center(
            child: Text(
              message,
              style: TextStyle(color:Colors.white),
            ),
          ),
        );
      }
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[100],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // logo
                  Icon(
                    Icons.lock,
                    size: 100,
                    color: Colors.blue[800],
                  ),
              
                  const SizedBox(
                    height: 50,
                  ),
              
                  // welcome text
                  Text(
                    'Welcome back you\'ve been missed',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
              
                  const SizedBox(
                    height: 25,
                  ),
              
                  // username textfield
                  MyTextfield(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
              
                  const SizedBox(
                    height: 10,
                  ),
              
                  // password textfield
                  MyTextfield(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
              
                  const SizedBox(
                    height: 25,
                  ),
              
                  // sign in button
                  SignInButton(
                    text: 'Sign In',
                    onTap: () => signUserIn()
                  ),
              
                  const SizedBox(
                    height: 50,
                  ),
              
                  //or continue with
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(thickness: 0.5, color: Colors.grey[500]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text('Or continue with',
                              style: TextStyle(color: Colors.grey[700])),
                        ),
                        Expanded(
                          child: Divider(thickness: 0.5, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
              
                  const SizedBox(
                    height: 10,
                  ),
              
                  // google sign in button
                  SquareTile(
                    onTap: () => AuthService().signInWithGoogle(),
                    imagePath: 'lib/assets/search.png'
                    ),
              
                  const SizedBox(
                    height: 50,
                  ),
              
                  // not a memeber?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          'Register now',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
