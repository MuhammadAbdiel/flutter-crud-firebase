import 'package:crud_firebase_5/google_sign_in_provider.dart';
import 'package:crud_firebase_5/main.dart';
import 'package:crud_firebase_5/page/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logged In'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              final provider =
                  Provider.of<GoogleSignInProvider>(context, listen: false);
              provider.googleLogout();
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            return Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 32),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user.photoURL!),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Name: ' + user.displayName!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: ' + user.email!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return const MainPage();
                          },
                        ),
                      );
                    },
                    child: const Text('Main Page'),
                  ),
                ],
              ),
            );
          } else {
            return const SignUp();
          }
        },
      ),
    );
  }
}
