import 'package:flutter/material.dart';
import 'StudentSigninPage.dart';
import 'package:studentapp/views/StudentSignupPage.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Student App!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentSignupPage()),
                );
              },
              child: const Text('Sign Up'),
            ),
            SizedBox(height: 25,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
